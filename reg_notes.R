library(lme4)
library(dplyr)
library(ggplot2)



# rescale

cols_to_scale<-c('country.area.cultivated%',
                 'Human.Devel.Index(0-1)',
                 'Internal.renewable.water.resources.per.capita(m3/inhab/yr)', 
                 'Total.renewable.water.resources.per.capita(m3/inhab/yr)',
                 'Flood.occurance(WRI.index.0-5)',
                 'Total.water.withdrawal.per.capita(m3/inhab/yr)',
                 'SDG.water.stress%',
                 'Longterm.avg.annual.precip.volumne(10^9m3/year)')
#create rescaled data set
aqua_scaled<-aqua_select%>%mutate_at(funs(scale(.)%>% as.vector),.vars=vars(cols_to_scale))



#import scaled factor scores for all time points 

fac.full<-read.csv("CFA scores for all time points scaled.csv")
colnames(fac.full)<-c("ID","time","react","engage.fidget","disengage","BDI")

#ID : subj # (int)
#time : factor with 3 levels
#react : continuous/real scaled to avg 0 sd 1
#engage/fidget : "
#disengage: "
#BDI : int; not scaled 


#multiple linear regression
#checking and then removing interactions if they arent significant
lm2.1<-lm(BDI~react+time,data=fac.full)
summary(lm2.1)
lm2.2<-lm(BDI~engage.fidget+time,data=fac.full)
summary(lm2.2)
lm2.3<-lm(BDI~disengage+time+disengage*time,data=fac.full)
summary(lm2.3)

#stepwise model selection using backward elimination
fullmodel3<-lm(BDI~disengage+engage.fidget+react+time+time*react,data=fac.full)
step(fullmodel3,direction="backward",trace=10)

#checking out the residuals of the model
plot(fitted(lm2.1),residuals(lm2.1))
hist(residuals(lm2.1))
qqnorm(residuals(lm2.1))


