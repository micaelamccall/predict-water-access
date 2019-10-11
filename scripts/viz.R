library(plotly)
library(dplyr)
library(tidyr)
# 
wb_transformed<-read.csv("data/wb_transformed.csv",row.names = 1)

wb_outcome<-read.csv("data/wb_tidy.csv", row.names = 1)%>%
  select(Country, Life.expectancy.at.birth)

for_plot<-left_join(wb_transformed, wb_outcome, by='Country')%>%
  select(Country, 
         Access.to.electricity, 
         Renewable.energy.consumption, 
         Agricultural.land, 
         CO2.emissions, 
         Government.Effectiveness, 
         PM2.5.air.pollution, 
         Proportion.of.seats.held.by.women.in.parliaments, 
         Unemployment, 
         Cause.of.death.communicable.diseases.and.maternal.prenatal.and.nutrition.conditions, 
         natural.resources.depletion, 
         Life.expectancy.at.birth.y)
colnames(for_plot) <- c('Country',
                        'Access to electricity (% of pop)',
                        'Renewable energy consumption (% of total)',
                        'Agricultural land (% of land area)', 
                        'CO2 emissions (metric tons per capita)',
                        'Government Effectiveness: Estimate',
                        'Mean annual exposure to air pollution (ug/m^3)',
                        'Seats held by women in national parliaments (%)',
                        'Unemployment (% of total labor force)',
                        'CoD by communicable diseases, maternal, and prenatal cond (%)',
                        'Adjusted savings: natural resources depletion (% of GNI)',
                        'Life expectancy at birth, total (years)')


for_plot<-gather(for_plot, Measure, Value, -Country, -`Life expectancy at birth, total (years)`)
for_plot$Measure<-as.factor(for_plot$Measure)

pg <- ggplot(for_plot, 
             aes(x = Value,
                 y = `Life expectancy at birth, total (years)`,
                 group = Measure))+
  geom_point(aes(color=Measure))+
  geom_smooth(aes(color=Measure), method=lm,size=.7,se=F)+
  labs(title= "Normalized predictors of life expectancy",
       x="Normalized Measure Value",
       y="Life expectancy at birth, total (years)")+
  theme_minimal()+
  guides(color=guide_legend(ncol=2))+
  theme(axis.title.x = element_text(size=10), legend.title = element_text(size = 10), legend.text = element_text(size=8), legend.position=c(.5,-.4),  plot.margin = unit(c(.5, 1, 4, 1), "cm"));pg

p <-ggplotly(ggplot(for_plot, 
                    aes(x = Value, 
                        y = `Life expectancy at birth, total (years)`, 
                        group = Measure, 
                        text = paste("Country:",Country,'<br>', Measure, ':', Value, '<br>Life Expectancy:', `Life expectancy at birth, total (years)`, ' years')))+
               geom_point(aes(color=Measure))+
               geom_smooth(aes(color=Measure), method=lm,size=.7,se=F)+
               labs(title= "Normalized predictors of life expectancy", x="Normalized Measure Value", y="Life expectancy at birth, total (years)")+
               theme_minimal(), tooltip = "text")%>%
  layout(legend = list(font=list(size=10)))


