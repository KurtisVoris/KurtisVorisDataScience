###REGRESSION TREE WITH LAT LONG:

library(RJDBC)
vDriver <- JDBC(driverClass="com.vertica.Driver", classPath="/Users/homeunion/Desktop/vertica-jdbc-4.1.14.jar")
vertica <- dbConnect(vDriver, "jdbc:vertica://192.168.10.104:5433/homeunion", "dbadmin", "1234")

options(scipen=999)
library(rpart)

query<-"select saleprice,latitude::numeric,longitude::numeric from Tony_Final_PriceAVMData where bed = 3 and year = 2016 and county='LOS ANGELES'"
data<-dbGetQuery(vertica,query)
data=data[-which(data$latitude<33.6),]###REMOVE CATALINA::::


sd(data$saleprice,na.rm=T)

fit<-rpart(saleprice~longitude+latitude,data=data)
data$fitted<-predict(fit,data)

data<-data[which(data$saleprice<2000000),]

library(ggmap)

map1 = get_map(location = 'Los Angeles', zoom = 8, source = 'google', 
               maptype = 'roadmap')#'hybrid')#"roadmap"), col = 'bw')

pdf('/Users/homeunion/Documents/HPI/Output/TreeSplittingMaps1.pdf')
plot(fit)
text(fit,)
dev.off()


pdf('/Users/homeunion/Documents/HPI/Output/TreeSplittingMaps1.pdf')
ggmap(map1) + 
  geom_point(aes(x = data$longitude, y = data$latitude, color = data$saleprice), size = 2,pch=20, data = data) + 
  scale_colour_gradient2('Sale Price of\n3-bed SFRs',low = "blue", mid = "white", high = "red",midpoint = 700000) 
dev.off()


pdf('/Users/homeunion/Documents/HPI/Output/TreeSplittingMaps2.pdf')
range<-aggregate(data[,c('latitude','longitude')],by=list(data$fitted),FUN=function(x){return(c(min(x,na.rm=T),max(x,na.rm=T)))})
mids<-aggregate(data[,c('latitude','longitude')],by=list(data$fitted),mean,na.rm=T)

ggmap(map1) + 
  geom_point(aes(x = data$longitude, y = data$latitude, color = data$fitted), size = 2,pch=20, data = data) + 
  scale_colour_gradient2('Tree\nFitted\nValues',low = "blue", mid = "white", high = "red",midpoint = 700000) +
  geom_text(aes(x = longitude, y = latitude, label = paste(round(Group.1/1000,0),'k',sep='')),data = mids,size=8)
dev.off()

library(rpart.plot)
options(scipen=999)
rpart.plot(fit,type=3,tweak=.8,xcompact=TRUE,  ycompact=TRUE,digits=4)
mtext(side = 1,'Tree Prediction in Thousands of Dollars',line = 1)




sbbox <- make_bbox(lon = range$longitude, lat = range$latitude, f = 0.2)

map1 = get_map(location = sbbox, source = 'google', 
               maptype = 'roadmap')#'hybrid')#"roadmap"), col = 'bw')

pdf('/Users/homeunion/Documents/HPI/Output/TreeSplittingMaps2.pdf')

ggmap(map1) + 
  geom_point(aes(x = data$longitude, y = data$latitude, color = data$fitted), size = 2,pch=20, data = data) + 
  scale_colour_gradient2('Tree\nFitted\nValues',low = "blue", mid = "white", high = "red",midpoint = 700000) +
  annotate('rect', xmin = range$longitude[, 1], xmax = range$longitude[, 2], ymin = range$latitude[, 1], ymax = range$latitude[,2], alpha = 0.01, col = 'black', lwd = 1.2)
dev.off()



+
  geom_text(aes(x = longitude, y = latitude, label = paste(round(Group.1/1000,0),'k',sep='')),data = mids,size=8.5) 





