### Structure - list the packages that need to be loaded at the top of the script
## Running these lines of code needs to be done once to install the packages - in the terminal if the packages are not already installed

#install.packages("tidyverse")

## Load in the libraries using library function

library(tidyverse)
## for data manipulation and plotting with more modern, consistent and intuitive syntax than base R

#read in the data
my_data_R<-read.csv("anova_example.csv")

#check the structure of the data
#In R the notation works with general formal of function(object,options)
# Here the 'object' is the dataframe my_data_R, we are using the head() function to see the first few rows of the data, and we have no further options for the function
head(my_data_R)

#use group_by%>%summarise to obtain summary statistics
#here we are using the %>% to chain between the functions groupby and summarise
my_data_R %>%
  group_by(trt) %>%
    summarise(mean=mean(nitro),median=median(nitro),sd=sd(nitro),n=n())

#make some box plots using ggplot2
ggplot(my_data_R,aes(x=trt,y=nitro))+
  geom_boxplot()

#fit a linear model (ANOVA) using lm function
anova_model2<-lm(nitro~trt,data=my_data_R) 

#get the summary statistics
summary(anova_model2)

#produce an analysis of variance table
anova(anova_model2)
