library(RMySQL)
library(readr)

category_data_rsei_v236  <- read_csv("category_data_rsei_v236.csv")

## These lines create an R connection to the MySQL database ashm_rsei237
## using the connection parameters in the [rmysql] group of the (default)
## file .my.cnf
mydbcon  <-  dbConnect(MySQL(), groups="rmysql", dbname="ashm_rsei237")
dbListTables(mydbcon)
dbWriteTable(mydbcon, name='category', value=category_data_rsei_v236, overwrite=TRUE, row.names=FALSE)

