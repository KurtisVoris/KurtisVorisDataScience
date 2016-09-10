
vDriver <- JDBC(driverClass="com.vertica.Driver", classPath="/Users/homeunion/Desktop/vertica-jdbc-4.1.14.jar")
vertica <- dbConnect(vDriver, "jdbc:vertica://192.168.10.104:5433/homeunion", "dbadmin", "1234")

query<-"select * from kurtis_HPI_accuracy_cross"
acc<-dbGetQuery(vertica, query)

library(rgdal)
shapes<-readOGR('/Users/homeunion/Documents/Ad Hoc/Crime Scores/Data/cb_2014_us_zcta510_500k/','cb_2014_us_zcta510_500k')

library(ggplot2)
library(rgeos)
library(maptools)
library(gpclib)
library(ggmap)
library(RColorBrewer)


shapes1<-shapes[shapes[["GEOID10"]] %in% unique(acc$zipcode),]
shapes.f<-fortify(shapes1,region='GEOID10')
acc1<-merge(acc[,c('zipcode','zipcount',"err10_hpi","err20_hpi","err10_avm","err20_avm")],shapes.f,by.x='zipcode',by.y='id')
acc1<-acc1[order(acc1$order),]

map<-get_map(location='Los Angeles County, CA',maptype='terrain',zoom=10)

acc1[which(acc1$zipcount>475),'zipcount']<-450

####zipcode count
ggmap(map) + 
  geom_polygon(aes(fill = zipcount, x = long, y = lat, group = group)
               , data = acc1
               , alpha = .6
               , color = "black"
               , size = 0.2) +
  #scale_fill_gradient2('Number of Sales', midpoint=.6,low='yellow',high='red' ,na.value = 'orange') +
  scale_fill_gradientn('Sale\nCount', colours = brewer.pal(9, 'YlOrRd'), na.value = 'grey80') +
  ggtitle(paste('Los Angeles Sales Volume\nfrom October 2015 through March 2016'))

####  within 10%
ggmap(map) + 
  geom_polygon(aes(fill = err10_avm*100, x = long, y = lat, group = group)
               , data = acc1
               , alpha = .6
               , color = "black"
               , size = 0.2) +
  #scale_fill_gradient2('Accuracy within 10%', midpoint=.6,low='white',mid='red',high='dark red' , na.value = 'grey80') +
  scale_fill_gradientn('Accuracy\nwithin 10%', colours = brewer.pal(9, 'YlOrRd'), na.value = 'grey80',limits=c(0,100)) +
  ggtitle(paste('Los Angeles percent of predictions within 10%\nof sale price from October 2015 through March 2016'))

####   within 20%
ggmap(map) + 
  geom_polygon(aes(fill = err20_avm*100, x = long, y = lat, group = group)
               , data = acc1
               , alpha = .6
               , color = "black"
               , size = 0.2) +
  #scale_fill_gradient2('Accuracy within 20%', midpoint=.5,low='yellow',high='red' , na.value = 'grey80') +
  scale_fill_gradientn('Accuracy\nwithin 20%', colours = brewer.pal(9, 'YlGn'), na.value = 'grey80',limits=c(0,100)) +
  ggtitle(paste('Los Angeles percent of predictions within 20%\nof sale price from October 2015 through March 2016'))





acctrend<-read.csv('/Users/homeunion/Documents/HPI/Output/HPI_1.7_LosAngelesPrediction Error 28JUN2016.csv')

acctrend$time<-acctrend$year+(acctrend$quarter-1)/4
acctrend<-acctrend[order(acctrend$time),]
plot(x=acctrend$time,
     y=acctrend$err10,type='l',ylim=c(0,1),col='blue',xlab='Year',ylab='Accuracy',main='Accuracy within 10% and 20% of Sale Prices')
lines(x=acctrend$time,
     y=acctrend$err20,col='red')
legend(x=2002,y=.2,legend = c("Accuracy within 20%","Accuracy within 10%"),col=c('red','blue'),lty=1)



###  MAPE   METRIC  

query<-'select pcnterr from kurtis_HPIPred_SaleQC where pcnterr is not null order by random() limit 100000'
acc<-dbGetQuery(vertica, query)

acc<-read.csv('/Users/homeunion/Documents/HPI/Output/mapeaccuracy_1_7_losangeles.csv')


shapes1<-shapes[shapes[["GEOID10"]] %in% unique(acc$zipcode),]
shapes.f<-fortify(shapes1,region='GEOID10')
acc1<-merge(acc,shapes.f,by.x='zipcode',by.y='id')
acc1<-acc1[order(acc1$order),]

map<-get_map(location='Los Angeles County, CA',maptype='terrain',zoom=10)

acc1[which(abs(acc1$medianAPE)>.2),'medianAPE']<-NA

####zipcode count
ggmap(map) + 
  geom_polygon(aes(fill = medianAPE*100, x = long, y = lat, group = group)
               , data = acc1
               , alpha = .6
               , color = "black"
               , size = 0.2) +
  #scale_fill_gradient2('Number of Sales', midpoint=.6,low='yellow',high='red' ,na.value = 'orange') +
  scale_fill_gradientn('50% of \nPredictions \nare within', colours = brewer.pal(9, 'YlOrRd'), na.value = 'grey80') +
  ggtitle(paste('Los Angeles Median Absolute Percent Error\nof sale price prediction from 2000-2016'))


hist(acc1$medianAPE)


