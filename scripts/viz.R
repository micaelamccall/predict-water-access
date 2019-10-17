library(plotly)
library(ggplot2)
library(dplyr)
library(tidyr)

# Read in transformed data 
wb_transformed<-read.csv("data/wb_transformed.csv",row.names = 1)

# Read in non-transformed outcome
wb_outcome<-read.csv("data/wb_tidy.csv", row.names = 1)%>%
  select(Country, Life.expectancy.at.birth)

# Make dataframe with predictors from model plus non-transformed outcome
for_plot<-left_join(wb_transformed, wb_outcome, by='Country')%>%
  select(Country, 
         Renewable.electricity.output, 
         Agricultural.land, 
         CO2.emissions, 
         Government.Effectiveness, 
         Proportion.of.seats.held.by.women.in.parliaments, 
         Access.to.clean.fuels.and.technologies.for.cooking,
         Unemployment, 
         Cause.of.death.communicable.diseases.and.maternal.prenatal.and.nutrition.conditions,
         Life.expectancy.at.birth.y)
                                                                    
# pretty column names
colnames(for_plot) <- c('Country',
                        'Renewable energy consumption (% of total)',
                        'Agricultural land (% of land area)', 
                        'CO2 emissions (metric tons per capita)',
                        'Government Effectiveness: Estimate',
                        'Seats held by women in national parliaments (%)',
                        'Access to clean fuels and technologies for cooking (%)',
                        'Unemployment (% of total labor force)',
                        'CoD by communicable diseases, maternal, and prenatal cond (%)',
                        'Life expectancy at birth, total (years)')

# Reshape for ggplot
for_plot<-gather(for_plot, Measure, Value, -Country, -`Life expectancy at birth, total (years)`)
for_plot$Measure<-as.factor(for_plot$Measure)

# ggplot 
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
  theme(title=element_text(size=20), axis.title.y = element_text(size=10), axis.title.x = element_text(size=10), legend.title = element_text(size = 15), legend.text = element_text(size=10), legend.position=c(.5,-0.2),  plot.margin = unit(c(.5, 1, 4, 1), "cm"));pg
ggsave(pg, file="fig/life_exp_plot.png")

# Plotly version
p <-ggplotly(ggplot(for_plot, 
                    aes(x = Value, 
                        y = `Life expectancy at birth, total (years)`, 
                        group = Measure, 
                        text = paste("Country:",Country,'<br>', Measure, ':', Value, '<br>Life Expectancy:', `Life expectancy at birth, total (years)`, ' years')))+
               geom_point(aes(color=Measure))+
               geom_smooth(aes(color=Measure), method=lm,size=.7,se=F)+
               labs(title= "Normalized predictors of life expectancy", x="Normalized Measure Value", y="Life expectancy at birth, total (years)")+
               theme_minimal(), tooltip = "text")%>%
  layout(legend = list(x=1,y=1,font=list(size=8)))

