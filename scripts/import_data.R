library(tidyr)
library(dplyr)

# Read in the data 

aqua <- read.csv("data/aquastat_data.csv")


# Tidy up the data

aqua_tidy <- aqua[1:23140, ]%>%  # taking out the last few rows because they are metadata
  select(-c(Variable.Id, Symbol, Md))%>%  # remove irrelevant variables
  distinct()%>% #remove duplicate rows
  droplevels()%>% # reset the levels to just the ones used in this dataframe
  group_by(Area, Variable.Name)%>% 
  summarise(Avg.Value=mean(Value))%>% #average each variable for each country accross all years sampled
  spread(Variable.Name, Avg.Value) # make each variable it's own column  

# Take a look at the variables to see which ones have the most NA values 
sort(colSums(is.na(aqua_tidy)))
summary(aqua_tidy)


# Select some columns to analyze
aqua_select <- aqua_tidy%>%
  select(c(Area, 
           `% of total country area cultivated`,
           `Human Development Index (HDI) [highest = 1]`, 
           `Total internal renewable water resources per capita`,
           `Total renewable water resources per capita`, 
           `Flood occurrence (WRI)`,  
           `Total water withdrawal per capita`,
           `SDG 6.4.2. Water Stress`, 
           `Long-term average annual precipitation in volume`,
           `Total population with access to safe drinking-water (JMP)`))%>%
  na.omit()%>%
  ungroup()

colnames(aqua_select) <- c('Country',
                       'country.area.cultivated',
                       'Human.Devel.Index',
                       'Internal.renewable.water.resources.per.capita', 
                       'Total.renewable.water.resources.per.capita',
                       'Flood.occurance',
                       'Total.water.withdrawal.per.capita',
                       'SDG.water.stress',
                       'Longterm.avg.annual.precip.volumne',
                       'Pop.with.access.to.safe.drinking.water')


write.csv(aqua_select,"data/aqua_tidy.csv")
