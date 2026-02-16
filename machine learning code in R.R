library(rpart)
library(rattle)
library(openxlsx)
library(tidyverse)
library(ggforce)

## data downloaded from 
#https://www.kaggle.com/datasets/faduregis/farmer-survey-dataset
survey_data<-read.xlsx("pdc_data_zenodo.xlsx")


#Creating a subset for only Tanzania with non missing values for farm size & household.size and ensuring it is numeric

survey_data %>%
  filter(country=="Tanzania") %>%
  filter(!is.na(`farm.size.(acres)`) & !is.na(household.size)) %>%
  mutate(size=as.numeric(`farm.size.(acres)`))->survey_data_tanzania

#produce k means analysis - select only the two columns of interest initially, and set k=4
k_means_4<-kmeans(select(survey_data_tanzania,size,household.size),4)

#To produce alternative splits can change the 4 to different numbers and see what happens

#make a plot
survey_data_tanzania %>%
  mutate(cluster=k_means_4$cluster) %>%
  ggplot(aes(x=size,y=household.size,col=factor(cluster)))+
  geom_mark_ellipse(aes(fill = factor(cluster)), expand = unit(0.01,"mm"))+
  geom_jitter(width=0.01,height=0.01,size=3)+
  theme_light() +
    scale_color_brewer(palette="Dark2")+
  scale_fill_brewer(palette="Dark2")+
  xlab("farm size (acres)")+ylab("household size")



## example 2 - slightly different variables, so subset to remove missing values again

survey_data_tanzania2<-survey_data %>%
  filter(country=="Tanzania") %>%
  select(household.size,crop.type) %>%
  na.omit()

## making the plot and annotating it



plot_1<-survey_data_tanzania2 %>%
  group_by(household.size) %>%
    summarise(food_focus=mean(crop.type=="food crops"),n=n()) %>%
  mutate(logit=log(food_focus/(1-food_focus)))%>%
  filter(n>10)%>%
  ggplot(aes(x=household.size,y=food_focus,size=n))+
  geom_point()+
  scale_y_continuous(labels=scales::percent)+
  ylab("% of farmers focusing on food crops over cash crops")

plot_1


#fitting a glm and summarising and addin the lines
glm1<-glm(I(crop.type=="food crops") ~ household.size,data=survey_data_tanzania2,family="binomial")
summary(glm1)
glm2<-data.frame(household.size=0:15) %>% mutate(n=1,food_focus=predict(glm1,newdata=.,type="response"))

plot_1+
  geom_line(data=glm2,col="blue",size=0.5)

#adding a quadratic term
glm3<-glm(I(crop.type=="food crops") ~ poly(household.size,2),data=survey_data_tanzania2,family="binomial")
summary(glm3)
glm4<-data.frame(household.size=0:12) %>% mutate(n=1,food_focus=predict(glm3,newdata=.,type="response"))

plot_1+
  geom_line(data=glm4,col="red",size=0.5)

#creating a classification tre

tree1<-rpart(crop.type ~ household.size,data=survey_data_tanzania2,control = rpart.control(cp=0.0001))
#making the tree plot
rattle::fancyRpartPlot(tree1,main = "Crop Focus")

#adding this onto the scatter plot
tree_lines<-survey_data_tanzania2 %>%
  mutate(hh_size_tree=cut(household.size,breaks=c(0,3.5,8.5,11,12,99))) %>%
  group_by(hh_size_tree) %>%
  summarise(food_focus=mean(I(crop.type=="food crops")),household.size=min(household.size),household.size0=max(household.size))

#looking side by side
plot_1+
  geom_line(data=glm4,col="red",size=0.5)+
  geom_step(data=tree_lines,size=0.5,col="blue")
