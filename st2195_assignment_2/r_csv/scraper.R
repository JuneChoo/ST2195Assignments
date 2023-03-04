# Title     : Scraper
# Objective : Scraping wiki
# Created by: Junezhu
# Created on: 2023/3/5
library(rvest)
library(writexl)
link <- "https://en.wikipedia.org/wiki/Comma-separated_values"
download.file(link, destfile = "scrapedpage.html", quiet=TRUE)
reponse <- read_html("scrapedpage.html")
all_tables <- reponse > html_table()
target_table <- all_tables[[0]]
write_xlsx(target_table,"./scraper_result.csv")



