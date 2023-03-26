# Radius
r <- 2
# Function to compute the volume of a sphere with radius r
volume <- function(r, rho) {
 print(3/4*pi*r^rho)
}
# Function to compute the volumes of the spheres with radius r, r^2 and r^3
volume_vector <- function(r) {
 for (rho in 1:3){
 volume(r,rho)
 }
}
# Run volume_vector(r) and print the volumes of the spheres with radius r, r^2 and r^3
volume_vector(r)