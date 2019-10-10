# Read in the tidy data

wb_select<-read.csv("data/wb_tidy.csv", row.names = 1)


# Vizualize skew with histograms
library(ggplot2)
check_skew<-gather(wb_select, Measure, Value, -Country)

for (i in unique(check_skew$Measure)){
  plot<-ggplot(check_skew[check_skew$Measure==i,], aes(Value))+
    geom_histogram(bins = 100)+
    labs(title=paste(i))
  print(plot)
}

rm(check_skew) #remove this dataframe so it doesnt clutter our environment


# most of these variables are right skewed, so they could be transformed with a log transformation
wb_log<-wb_select%>%
  mutate_at(vars(Renewable.electricity.output, 
                 Renewable.energy.consumption, 
                 Terrestrial.and.marine.protected.areas, 
                 CO2.emissions, 
                 PM2.5.air.pollution, 
                 Unemployment, 
                 Cause.of.death.communicable.diseases.and.maternal.prenatal.and.nutrition.conditions, 
                 natural.resources.depletion,
                 Prevalence.of.undernourishment), funs(log10(1+.)))%>%
  mutate_at(vars(Access.to.electricity, Access.to.clean.fuels.and.technologies.for.cooking), funs(log10(101-.))) # right skewed variable transformed after subtracted from 110 to turn it into a left skew

#check transformation
check_transform<-gather(wb_log, Measure, Value, -Country)
check_transform$Measure<-as.factor(check_transform$Measure)
for (i in unique(check_transform$Measure)){
  plot<-ggplot(check_transform[check_transform$Measure==i,], aes(Value))+
    geom_histogram(bins = 100)+
    labs(title=paste(i))
  print(plot)
}
rm(check_transform) #remove this dataframe so it doesnt clutter our environment


# rescale data set to mean of 0, sd of 1
wb_scaled<-wb_log%>%
  mutate_at(funs(scale(.)%>% as.vector),.vars=vars(c('Renewable.electricity.output',
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
                                                     'Life.expectancy.at.birth')))

#check scaling
check_scaling<-gather(wb_scaled, Measure, Value, -Country)
check_scaling$Measure<-as.factor(check_scaling$Measure)
ggplot(check_scaling, aes(Value))+
  geom_histogram(bins = 100)+
  facet_wrap(~Measure,strip.position = "bottom")
rm(check_scaling)

# Write transformed data to a csv 
write.csv(wb_scaled, "data/wb_scaled.csv")
