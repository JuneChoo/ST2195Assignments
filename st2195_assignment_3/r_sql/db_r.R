# install.packages("RSQLite")
library(DBI)
library(RSQLite)
library(dplyr)
library(dbplyr)

# # initialize database
# if (file.exists("airline2.db"))
#  file.remove("airline2.db")

## connecting database
conn <- dbConnect(RSQLite::SQLite(), "airline2.db")

# list all tables
dbListTables(conn)

#read files from csv and save into a variable
carriers <- read.csv("../dataverse_files/carriers.csv", header = TRUE)
airports <- read.csv("../dataverse_files/airports.csv", header = TRUE)
planes <- read.csv("../dataverse_files/plane-data.csv", header = TRUE)

ontime_list <- list()
year_seq = seq(2000, 2005, by=1)
str1 = "../dataverse_files/ontime/"
str2 = ".csv"
for (year in year_seq) {
  temp_df <- read.csv(paste(str1,year,str2,sep=""), header = TRUE)
  ontime_list[[length(ontime_list)+1]] <- temp_df
}
Reduce(full_join,ontime_list)
# Error: cannot allocate vector of size 64.6 Mb
# Error during wrapup: cannot allocate vector of size 99.4 Mb
# Error: no more error handlers available (recursive errors?); invoking 'abort' restart


#write data to db
dbWriteTable(conn, "carriers", carriers)
dbWriteTable(conn, "airports", airports)
dbWriteTable(conn, "planes", planes)
dbWriteTable(conn, 'ontime', ontime_list)


dbListFields(conn, "planes")

#creating table from sql
dbCreateTable(conn, "Teacher", c(staff_id = "TEXT", name = "TEXT"))


# Alternative:
# dbExecute(conn, 
# "CREATE TABLE Teacher (
#     staff_id TEXT PRIMARY KEY,
#     name TEXT)")

dbReadTable(conn, "Teacher")

dbExecute(conn, 
          "Update Student
SET student_id = '201929744'
WHERE name = 'Harper Taylor'")


dbDisconnect(conn)





##filter 
#q1 <- grade_db %>% filter(course_id == "ST101")
#show_query(q1)
# join table
#q2 <- inner_join(student_db, grade_db) %>%  filter(course_id == "ST101") %>%  
# select(name) %>%  arrange(name)
# 
#q3 <- inner_join(student_db, grade_db, by = "student_id") %>% 
# inner_join(course_db, by = "course_id", suffix = c(".student", ".course")) %>% 
# filter(name.student == 'Ava Smith' | name.student == 'Freddie Harris') %>%  
# select(name.course) %>% distinct()
#Calculating
#q4 <- grade_db %>%group_by(course_id) %>% summarize(avg_mark = 
# mean(final_mark, na.rm = TRUE))

ontime_db <- tbl(conn, "ontime")
carriers_db <- tbl(conn, "carriers")
airport_db <- tbl(conn, "airports")
planes_db  <- tbl(conn, "planes")

# practice
# Q1: Which of the following companies has the highest number of cancelled flights, 
#relative to their number of total flights?

targets <- c('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')
q1 = inner_join(carriers_db, 
  inner_join(ontime_db %>% group_by(UniqueCarrier) %>%  summarise(n = n()), 
                ontime_db %>%  filter(Cancelled == 1) %>% group_by(UniqueCarrier) 
                %>% summarise(n = n()),by = "UniqueCarrier",  
                suffix=c(".total", ".cancelled")), 
                by = c("Code" = "UniqueCarrier"))%>%
  filter(Description  %in% targets)%>%
  select (Description, n.total,n.cancelled) %>% 
  mutate(percent_c = (n.cancelled*100/n.total))%>%
  arrange(desc(percent_c))%>%
  head(1) %>%
  write.csv('q1.csv', row.names = T)

# Q2:Which of the following cities has the highest number of inbound flights (excluding cancelled flights)?
q2 = inner_join(airport_db, ontime_db %>%  
                  filter(Cancelled == 0 ) %>% 
                  group_by(Dest) %>% 
                  summarise(n_total = n()),
                  by = c("iata" = "Dest"),
                  suffix=c(".ap", ".al"))%>%
     group_by(city) %>%
     select (city, n_total) %>% 
     summarise(n =  sum(n_total, na.rm = TRUE))%>%
     arrange(desc(n))%>%
     head(1) %>%
     write.csv('q2.csv', row.names = T)

# Q4:Which of the following airplanes has the lowest associated average departure delay (excluding cancelled and diverted flights)?
targets <- c('737-230', 'ERJ 190-100 IGW', 'A330-223', '737-282')
q4 = inner_join(planes_db, ontime_db %>%  
                  filter(Cancelled == 0 | Diverted == 0 ) %>% 
                  group_by(TailNum) %>% 
                  summarise(n_avg = mean(DepDelay)),
                  by = c("tailnum" = "TailNum"),
                  suffix=c(".ap", ".al"))%>%
    filter(model %in% targets)%>%
    group_by(model) %>%
    select (model, n_avg) %>% 
    arrange(n_avg)%>%
    head(1) %>%
    write.csv('q4.csv', row.names = T)

# Q5:Which of the following companies has the highest number of cancelled flights?
targets <- c('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')
q5 = inner_join(carriers_db, ontime_db %>%  
                  filter(Cancelled == 1) %>% 
                  group_by(UniqueCarrier) %>% 
                  summarise(n.cancelled = n()),  
                  by = c("Code" = "UniqueCarrier"))%>%
  filter(Description  %in% targets)%>%
  select (Description, n.cancelled) %>% 
  arrange(desc(n.cancelled))%>%
  head(1) %>%
  write.csv('q5.csv', row.names = T)
