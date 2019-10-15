library(tidyr)
library(dplyr)
library(plotly)
library(corrplot)
library(psych)
library(ggplot2)

wb_transformed<-read.csv("data/wb_transformed.csv",row.names = 1)

# Visualize the correlations between the data
corrplot(cor(wb_transformed[2:10]),order="hclust",tl.col="black",tl.cex=.62)

pairs.panels(wb_transformed[,2:10],
             method = "pearson",
             hist.col = "#00AFBB")

# The relationship between life expectancy and each of the other variables
wb_long<-gather(wb_transformed, Measure, Value, -Country, -Life.expectancy.at.birth)
wb_long$Measure<-as.factor(wb_long$Measure)

ggplot(wb_long, aes(x=Value,y=Life.expectancy.at.birth))+
  geom_point(size=1,color='forestgreen')+
  facet_wrap(~Measure,strip.position = "bottom")



#stepwise model selection using backward elimination
fullmodel<-lm(Life.expectancy.at.birth ~ 
                Renewable.electricity.output + 
                Access.to.electricity + 
                Renewable.energy.consumption + 
                Terrestrial.and.marine.protected.areas +
                Agricultural.land +
                Individuals.using.the.Internet +
                CO2.emissions +
                GDP.growth +
                Political.Stability.and.Absence.of.Terrorism +
                Rule.of.Law +
                Government.Effectiveness +
                PM2.5.air.pollution +
                Proportion.of.seats.held.by.women.in.parliaments +
                Access.to.clean.fuels.and.technologies.for.cooking +
                Labor.force.participation.rate +
                Unemployment +
                School.enrollment +
                Cause.of.death.communicable.diseases.and.maternal.prenatal.and.nutrition.conditions +
                natural.resources.depletion +
                Prevalence.of.undernourishment, data=wb_transformed)

step(fullmodel,direction="backward",trace=10)


model = lm(Life.expectancy.at.birth ~ Access.to.electricity + 
     Renewable.energy.consumption + Agricultural.land + CO2.emissions + 
     Government.Effectiveness + PM2.5.air.pollution + Proportion.of.seats.held.by.women.in.parliaments + 
     Unemployment + Cause.of.death.communicable.diseases.and.maternal.prenatal.and.nutrition.conditions + 
     natural.resources.depletion, data = wb_transformed)

#checking out the residuals of the model
plot(fitted(model),residuals(model)) # with this plot, we are look for absence of a pattern
hist(residuals(model)) # with the histogram, we're looking for a normal distribution
qqnorm(residuals(model)) # with the qqnorm plot, we are looking for a straight line
