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
methods$instrum_code = factor(methods$instrum_code)
#added height and depth as factor - 12/16/20
methods$height = factor(methods$height, 
                        levels = as.character(c(0,50,60,65,80,85,95,100,105,115,130,140,150,155,160,180,190,200,220,225,235,240,250,255,260,275,285,295,300,305,325,330,335,345,350,365,370,395,400,410,435,450,455,480,500,505,550,555,560,585,600,615,625,810,850,870,1000,1200)))
methods$depth = factor(methods$depth)
methods$method_code = factor(methods$method_code)
methods$probe_code = factor(methods$probe_code)