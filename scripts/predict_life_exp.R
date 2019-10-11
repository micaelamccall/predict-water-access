library(plotly)

wb_transformed<-read.csv("data/wb_transformed.csv",row.names = 1)

# Visualize some relationships between the data

library(corrplot)
corrplot(cor(wb_transformed[2:10]),order="hclust",tl.col="black",tl.cex=.62)


library(psych)
pairs.panels(wb_transformed[,2:10],
             method = "pearson",
             hist.col = "#00AFBB")



wb_long<-gather(wb_transformed, Measure, Value, -Country, -Life.expectancy.at.birth)
wb_long$Measure<-as.factor(wb_long$Measure)


library(ggplot2)
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

#checking out the residuals of the model
plot(fitted(fullmodel),residuals(fullmodel))
hist(residuals(fullmodel))
qqnorm(residuals(fullmodel))
