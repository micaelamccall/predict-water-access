library(tidyr)
library(dplyr)

# Read in the data 
header<- read.csv("data/ESGData.csv", nrows = 1)  # load the header separately
wb <- read.csv("data/ESGData.csv", header= FALSE, skip = 3084) # load the data itself
colnames(wb)<-colnames(header) # assign column names
rm(header) #clean up by removing extra assignment


wb_tidy<-wb%>% 
  select(Country.Name, Indicator.Name, X2013, X2014, X2015, X2016, X2017)%>% # select recent years
  droplevels()%>% # reset index
  gather(Year, Value, -Country.Name, -Indicator.Name)%>%    # make 1 row for each year for each indicator
  group_by(Country.Name, Indicator.Name)%>%  # group by country and indicator and average the value over all years listed 
  summarise(Avg.Value=mean(Value, na.rm = TRUE))%>%
  spread(Indicator.Name, Avg.Value) # make each row one country and each column a different indicator


# Look at the NAs in each variable
sort(colSums(is.na(wb_tidy)))
levels(wb$Country.Name)

# Select some variables with the least missing values
wb_select <- wb_tidy%>%
  select(c(Country.Name,  #select columns
           `Renewable electricity output (% of total electricity output)`,
           `Access to electricity (% of population)`, 
           `Renewable energy consumption (% of total final energy consumption)`,
           `Terrestrial and marine protected areas (% of total territorial area)`, 
           `Agricultural land (% of land area)`,  
           `Individuals using the Internet (% of population)`,
           `CO2 emissions (metric tons per capita)`, 
           `GDP growth (annual %)`,
           `Political Stability and Absence of Violence/Terrorism: Estimate`,
           `Rule of Law: Estimate`,
           `Government Effectiveness: Estimate`,
           `PM2.5 air pollution, mean annual exposure (micrograms per cubic meter)`,
           `Proportion of seats held by women in national parliaments (%)`,
           `Access to clean fuels and technologies for cooking (% of population)`,
           `Labor force participation rate, total (% of total population ages 15-64) (modeled ILO estimate)`,
           `Unemployment, total (% of total labor force) (modeled ILO estimate)`,
           `School enrollment, primary (% gross)`,
           `Cause of death, by communicable diseases and maternal, prenatal and nutrition conditions (% of total)`,
           `Adjusted savings: natural resources depletion (% of GNI)`,
           `Prevalence of undernourishment (% of population)`,
           `Life expectancy at birth, total (years)`))%>%
  na.omit()%>%  # remove NAs
  ungroup()

# Rename columns
colnames(wb_select) <- c('Country', 
                            'Renewable.electricity.output',
                            'Access.to.electricity', 
                            'Renewable.energy.consumption',
                            'Terrestrial.and.marine.protected.areas', 
                            'Agricultural.land',  
                            'Individuals.using.the.Internet',
                            'CO2.emissions', 
                            'GDP.growth',
                            'Political.Stability.and.Absence.of.Terrorism',
                            'Rule.of.Law',
                            'Government.Effectiveness',
                            'PM2.5.air.pollution',
                            'Proportion.of.seats.held.by.women.in.parliaments',
                            'Access.to.clean.fuels.and.technologies.for.cooking',
                            'Labor.force.participation.rate',
                            'Unemployment',
                            'School.enrollment',
                            'Cause.of.death.communicable.diseases.and.maternal.prenatal.and.nutrition.conditions',
                            'natural.resources.depletion',
                            'Prevalence.of.undernourishment',
                            'Life.expectancy.at.birth')


write.csv(wb_select,"data/wb_tidy.csv")

