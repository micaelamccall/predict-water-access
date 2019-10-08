# Read in the tidy data

aqua_select<-read.csv("data/aqua_tidy.csv", row.names = 1)


# Check variables for skewness
library(e1071)
skewness(aqua_select$`country.area.cultivated`)
skewness(aqua_select$`Human.Devel.Index`)
skewness(aqua_select$`Total.renewable.water.resources.per.capita`)
skewness(aqua_select$`Internal.renewable.water.resources.per.capita`)
skewness(aqua_select$`Total.water.withdrawal.per.capita`)
skewness(aqua_select$`SDG.water.stress`)
skewness(aqua_select$`Longterm.avg.annual.precip.volumne`)
skewness(aqua_select$`Pop.with.access.to.safe.drinking.water`)
skewness(aqua_select$`Flood.occurance`)

# all variables are very skewed

# Vizualize skew with histograms
library(ggplot2)
check_skew<-gather(aqua_select, Measure, Value, -Country)

for (i in unique(check_skew$Measure)){
  plot<-ggplot(check_skew[check_skew$Measure==i,], aes(Value))+
    geom_histogram(bins = 100)+
    labs(title=paste(i))
  print(plot)
}

rm(check_skew) #remove this dataframe so it doesnt clutter our environment


# most of these variables are right skewed, so they could be transformed with a log transformation
aqua_log<-aqua_select%>%
  mutate_at(vars(-c(Country,`Pop.with.access.to.safe.drinking.water`,`Flood.occurance`,`Human.Devel.Index`)), funs(log(1+.)))%>%
  mutate_at(vars(`Pop.with.access.to.safe.drinking.water`), funs(log10(110-.))) # right skewed variable transformed after subtracted from 110 to turn it into a left skew

#check transformation
check_transform<-gather(aqua_log, Measure, Value, -Country)
check_transform$Measure<-as.factor(check_transform$Measure)
ggplot(check_transform, aes(Value))+
  geom_histogram(bins = 100)+
  facet_wrap(~Measure,strip.position = "bottom")
rm(check_transform) #remove this dataframe so it doesnt clutter our environment


# rescale data set to mean of 0, sd of 1
aqua_scaled<-aqua_log%>%
  mutate_at(funs(scale(.)%>% as.vector),.vars=vars(c('country.area.cultivated',
                                                     'Human.Devel.Index',
                                                     'Internal.renewable.water.resources.per.capita', 
                                                     'Total.renewable.water.resources.per.capita',
                                                     'Flood.occurance',
                                                     'Total.water.withdrawal.per.capita',
                                                     'SDG.water.stress',
                                                     'Longterm.avg.annual.precip.volumne',
                                                     'Pop.with.access.to.safe.drinking.water')))

#check scaling
check_scaling<-gather(aqua_scaled, Measure, Value, -Country)
check_scaling$Measure<-as.factor(check_scaling$Measure)
ggplot(check_scaling, aes(Value))+
  geom_histogram(bins = 100)+
  facet_wrap(~Measure,strip.position = "bottom")

# Write transformed data to a csv 


# Visualize some relationships between the data

library(corrplot)
corrplot(cor(aqua_scaled[2:10]),order="hclust",tl.col="black",tl.cex=.62)

log_long<-gather(aqua_scaled, Measure, Value, -Country, -`Pop.with.access.to.safe.drinking.water%`)
aqua_long$Measure<-as.factor(aqua_long$Measure)


library(ggplot2)
ggplot(log_long, aes(x=Value,y=`Pop.with.access.to.safe.drinking.water%`))+
  geom_point(size=1,color='forestgreen')+
  facet_wrap(~Measure,strip.position = "bottom")

library(psych)
pairs.panels(aqua_log[,2:10],
             method = "pearson",
             hist.col = "#00AFBB")


for_reg <- aqua_scaled

colnames(for_reg) <- c('Country',
                       'country.area.cultivated',
                       'Human.Devel.Index',
                       'Internal.renewable.water.resources.per.capita', 
                       'Total.renewable.water.resources.per.capita',
                       'Flood.occurance',
                       'Total.water.withdrawal.per.capita',
                       'SDG.water.stress',
                       'Longterm.avg.annual.precip.volumne',
                       'Pop.with.access.to.safe.drinking.water')

#stepwise model selection using backward elimination
fullmodel<-lm(Pop.with.access.to.safe.drinking.water ~ 
                country.area.cultivated + 
                Human.Devel.Index + 
                Internal.renewable.water.resources.per.capita + 
                Total.renewable.water.resources.per.capita +
                Flood.occurance +
                Total.water.withdrawal.per.capita +
                SDG.water.stress +
                Longterm.avg.annual.precip.volumne, data=for_reg)

step(fullmodel,direction="backward",trace=10)

#checking out the residuals of the model
plot(fitted(fullmodel),residuals(fullmodel))
hist(residuals(fullmodel))
qqnorm(residuals(fullmodel))


install.packages('devtools')
devtools::install_github("ricardo-bion/ggtech", 
                         dependencies=TRUE)


aqua_long<-gather(aqua_scaled, Measure, Value, -Country, -`Pop.with.access.to.safe.drinking.water%`)

ggplot(aqua_long, aes(x=Value,y=`Pop.with.access.to.safe.drinking.water%`,group=Measure))+
  geom_point(aes(color=Measure))+
  geom_smooth(aes(color=Measure), method=lm,size=.7,se=F)+
  labs(x="Normalized Measure Value",y="Percent of pop with access to safe drinking water")+
  