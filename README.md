# Predicting life expectancy from World Bank data

*R | Tidying data | Transforming data | Multilinear regression | Interactive graphing*

# Intro

The World Bank reports a massive amount of data on what at first pass seems like disparate topics such as gender equality and water stress, but which are related under the umbrella of [sustainable development goals](https://datatopics.worldbank.org/world-development-indicators/wdi-and-the-sustainable-development-goals.html). 

It is fascinating to explore the purpored relationship between these measures and thier effect on the well-being of populations. To this intent, I explored the World Bank's [Environment, Social, And Governance (ESG)](https://datacatalog.worldbank.org/dataset/environment-social-and-governance-data) Dataset, that provide information on 17 key sustainability themes for numerous countries and geographical regions. 

How does one measure well-being? One rough proxy is lifespan. Obviously, factors such as clean water and good healthcare can affect lifespan; but we are discovering that even factors such as [intergenerational stress](https://epigeneticsandchromatin.biomedcentral.com/articles/10.1186/s13072-017-0145-1) can have an effect on lifespan. Thus, I constructed a multilinear regression model to predict average lifespan of a country based on a number of other variables reported in the ESG dataset. 

## To use RStudio:
- Clone this repo and run setup.R to install and attach the required packages
- Individual scripts in `scripts` directory
    - `import_data.R` imports & tidies data, selects variables for analysis, writes tidy data to .csv 
    - `transform_data.R` prepares data from regression
    - `predict_life_exp.R` creates the regression model to predict life expectancy
    - `viz.R` graphs

- `notebooks/WB_sustainability.rmd` run all the code in a notebook (produces .html output)

## To run the Jupyter Notebook in a conda environment:
- Create my R environment from the environment.yml by cloning the repo, stepping into this project directory in the terminal, and running `conda env create -f environment.yml`
- OR Install packages from inside the Jupter Notebook (running the first few cells) 
- `notebooks/WB_sustainability.ipynb` run all the code in juypter notebook through the R kernel (which is part of the .yml env file)


