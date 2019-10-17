library(tidyr)
library(dplyr)
library(plotly)
library(corrplot)
library(psych)
library(ggplot2)
library(car)

wb_transformed<-read.csv("data/wb_transformed.csv",row.names = 1)

# Visualize the correlations between the data
corrplot(cor(wb_transformed[2:10]),order="hclust",tl.col="black",tl.cex=.62)

pairs.panels(wb_transformed[,2:10],
             method = "pearson",
             hist.col = "#00AFBB")

# The relationship between life expectancy and each of the other variables
wb_long<-gather(wb_transformed, Measure, Value, -Country, -Life.expectancy.at.birth) # reshape for ggplot
wb_long$Measure<-as.factor(wb_long$Measure)

ggplot(wb_long, aes(x=Value,y=Life.expectancy.at.birth))+
  geom_point(size=1,color='forestgreen')+
  facet_wrap(~Measure,strip.position = "bottom")



# Stepwise model selection using backward elimination, including only linear relationships:

# Initiate full model
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

# Backwards elimination
model<-step(fullmodel,direction="backward",trace=10)

# Stepwise model selection using backward elimination, including square root relationships:

# Initiate full model
fullmodel2<-lm(Life.expectancy.at.birth ~ 
                Renewable.electricity.output + 
                I(sqrt(-(Access.to.electricity)+1)) + # square root of the negative plus 1 (move to positive side of x axis)
                I(sqrt(-(Renewable.energy.consumption)+1)) + 
                Terrestrial.and.marine.protected.areas +
                Agricultural.land +
                I(sqrt(Individuals.using.the.Internet)) +
                I(sqrt(CO2.emissions)) +
                GDP.growth +
                Political.Stability.and.Absence.of.Terrorism +
                I(sqrt(Rule.of.Law)) +
                I(sqrt(Government.Effectiveness)) +
                PM2.5.air.pollution +
                Proportion.of.seats.held.by.women.in.parliaments +
                I(sqrt(-(Access.to.clean.fuels.and.technologies.for.cooking)+1)) +
                Labor.force.participation.rate +
                Unemployment +
                School.enrollment +
                I(sqrt(-(Cause.of.death.communicable.diseases.and.maternal.prenatal.and.nutrition.conditions)+1)) +
                natural.resources.depletion +
                Prevalence.of.undernourishment, data=wb_transformed)

# Backwards elimination
model2<-step(fullmodel,direction="backward",trace=10)



# Evaluate Model:

# Create data frame of VIFs
vifs<-dplyr::bind_cols(as.data.frame(names(vif(model2))), as.data.frame(unname(vif(model2))))


# New model with restricted VIFs
while(any(vifs$`unname(vif(model2))`>10)){  #while any VIFS are greater than 4
  vifs<-filter(vifs,  `unname(vif(model2))`!=max(`unname(vif(model2))`))  #take out the variable with the largest VIF
  formula<-paste("Life.expectancy.at.birth ~", paste(vifs$`names(vif(model2))`, collapse = ' + '), sep=' ')  #create a new formula without that variables
  newmodel<-lm(formula, data = wb_transformed) #create a new model
  vifs=bind_cols(as.data.frame(names(vif(model2)), as.data.frame(unname(vif(model2))))  #create a new dataframe with the VIFs from the new model
}


finalmodel<-step(newmodel,direction="backward",trace=10)


# Inspect residuals

resid <- bind_cols(as.data.frame(fitted(finalmodel)), as.data.frame(residuals(finalmodel))) 

p1 <- ggplot(resid,aes(x= fitted(finalmodel), y=residuals(finalmodel))) + geom_point() + labs(title='Residual Plot', x='Fitted Values', y='Residuals');p1
# with this plot, we are look for absence of a pattern

p2 <- ggplot(resid, aes(residuals(finalmodel))) + geom_histogram(bins=100) + labs(title = 'Histogram of Residuals')
# with the histogram, we're looking for a normal distribution
p3 <- ggplot(resid, aes(sample=residuals(finalmodel))) + geom_qq() + geom_qq_line() + labs(title = "Normal Q-Q Plot of Residuals") 
# with the qqnorm plot, we are looking for a straight line

gridExtra::grid.arrange(p3, p2, p3, nrow=1)