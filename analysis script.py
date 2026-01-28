### Structure - list the packages that need to be loaded at the top of the script
## Running these lines of code needs to be done once to install the packages - in the terminal if the packages are not already installed

#pip3 install pandas
#pip3 install statsmodels
#pip3 install seaborn

## Load in the libraries using import function
## There are standard abbreviations for some packages that are widely used in the community - pandas as pd, numpy as np and so on
## You don't have to follow these conventions, but if not it will make your life more difficult when you are following other people's code

import pandas as pd
# for importing data

import statsmodels.api as sm
#for statistical models

import statsmodels.formula.api as smf
#for statistical models, using a more intuitive formula notation - very similar to R

import seaborn as sns
# for making plots

## If you realise as you are writing your code that you need to add an additional package, always come back to the top and include it here 

#read in the data (using the pandas library) and assign to an object called my_data_python
my_data_python = pd.read_csv('anova_example.csv')

#check the structure of the data
#In Python the notation works with general formal of object.function(options)
# Here the 'object' is the dataframe my_data_python, we are using the head() function to see the first few rows of the data, and we have no further options for the function
my_data_python.head()

#use group_by->agg (aggregate) to obtain summary statistics
#here we are using the . to chain between the functions groupby and agg
my_data_python[['trt','nitro']].groupby('trt').agg(['mean','median','size','std'])

#make some box plots using the seaborn (sns) package
sns.boxplot(x='trt', y='nitro', data=my_data_python)

#fit a linear model (ANOVA) using ols function from statsmodels pacakge
anova_model1 = smf.ols('nitro~trt',data=my_data_python).fit()

#get the summary statistics
print(anova_model1.summary())

#produce an analysis of variance table
sm.stats.anova_lm(anova_model1)