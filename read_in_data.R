#Read in data to app
library(tidyverse)
#methods <- read_csv("shiny_methods.csv", locale = locale(tz = "Etc/GMT-8"), na = "NA")
methods <- read_csv("shiny_methods.csv", locale = locale(tz = "Etc/GMT-8"), na = "NA")
methods <- methods[,c(1:12)]
methods$start = as.Date(methods$start, format = "%m/%d/%Y")
methods$end = as.Date(methods$end, format = "%m/%d/%Y")
methods$end = ifelse(methods$end > Sys.time(), format(Sys.time(), "%m/%d/%Y"), format(methods$end, "%m/%d/%Y"))
methods$end = as.Date(methods$end, format = "%m/%d/%Y")

methods$sitecode = factor(methods$sitecode)
methods$res = factor(methods$res, 
                            levels = c("05 minutes", "10 minutes", "15 minutes", "60 minutes", "Daily", "Daily_only", "Day_night", "Periodic", "None" ))
methods$parameter = factor(methods$parameter)
#added height and depth as factor - 12/16/20
methods$height = factor(order(as.numeric(methods$height)))
methods$depth = factor(methods$depth)
methods$method_code = factor(methods$method_code)
methods$probe_code = factor(methods$probe_code)