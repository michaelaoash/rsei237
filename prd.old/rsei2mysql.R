library(RMySQL)

## These lines create an R connection to the MySQL database ashm_rsei237
## using the connection parameters in the [rmysql] group of the (default)
## file .my.cnf
mydbcon  <-  dbConnect(MySQL(), groups="rmysql", dbname="ashm_rsei237")
dbListTables(mydbcon)

## Read in the csv file to R dataframe
## Note Elements.csv and Facility.csv are substitute files
Chemical <- read.csv("chemical_data_rsei_v237.csv",as.is=TRUE)
Elements <- read.csv("Elements.csv",as.is=TRUE)
Facility <- read.csv("Facilities.csv",as.is=TRUE)
Media <- read.csv("media_information_rsei_v237.csv",as.is=TRUE)
NAICSTable <- read.csv("naics_data_rsei_v237.csv",as.is=TRUE)
Offsite <- read.csv("offsite_data_rsei_v237.csv",as.is=TRUE)
Release <- read.csv("release_rsei_v237.csv",as.is=TRUE)
Submission <- read.csv("submission_rsei_v237.csv",as.is=TRUE)

## Write the R dataframe as a MySQL table 
dbWriteTable(mydbcon, name='chemical', value=Chemical, overwrite=TRUE, row.names=FALSE)
dbWriteTable(mydbcon, name='elements', value=Elements, overwrite=TRUE, row.names=FALSE)
dbWriteTable(mydbcon, name='facility', value=Facility, overwrite=TRUE, row.names=FALSE)
dbWriteTable(mydbcon, name='media', value=Media, overwrite=TRUE, row.names=FALSE)
dbWriteTable(mydbcon, name='naicstable', value=NAICSTable, overwrite=TRUE, row.names=FALSE)
dbWriteTable(mydbcon, name='offsite', value=Offsite, overwrite=TRUE, row.names=FALSE)
dbWriteTable(mydbcon, name='submission', value=Submission, overwrite=TRUE, row.names=FALSE)
dbWriteTable(mydbcon, name='releases', value=Release, overwrite=TRUE, row.names=FALSE)

## Check that it wrote
dbListTables(mydbcon)

