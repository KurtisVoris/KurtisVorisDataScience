

options(java.parameters = "-Xmx8048m")
options(scipen=999)
library("RJDBC")
vDriver <- JDBC(driverClass="com.vertica.Driver", classPath="/Users/homeunion/Desktop/vertica-jdbc-4.1.14.jar")
vertica <- dbConnect(vDriver, "jdbc:vertica://192.168.10.104:5433/homeunion", "dbadmin", "1234")

query<-"select * from kurtis_LASales_with_hpitrend where sale2_price is not null order by random() limit 5000"
p<-dbGetQuery(vertica, query) 


which(p$zipcode == '90278')

par(mfrow=c(3,2))
for(i in c(757,1185,1081,3151,4397,4061)){
plot(x=seq(2000,2016.25,by=.25),
     y=as.numeric(p[i,3:68])/1000,
     type='l',lwd=3,col='blue',
     ylab='Price ($1,000s)',
     xlab='Year',xaxt='n',yaxt='n',
     main=paste(gsub("\\s*\\w*$", "", p[i,'address']),'\nsqft:',p[i,'sqft'],'beds:',p[i,'bed']))
axis(side = 1, at = seq(2000, 2016))  
axis(side = 2, at=,  las=2)  

points(x=as.numeric(p[i,c(69,71,73,75)]),
       y=as.numeric(p[i,c(70,72,74,76)])/1000,
       pch=20,cex=2,col='red')
abline(v=seq(2000,2050),lty=2,col='grey')
}



'93550'

axis(side = 1, at = seq(2000, 2016))
 = ‘n





mquery<-"select * from kurtis_HPI_zipcodetrends_LosAngeles"
z<-dbGetQuery(vertica, mquery) 
par(mfrow=c(1,1))
plot(x=seq(2000,2016,by=.25),
     y=sapply(z[,3:67],median,na.rm=T)*100/(sapply(z[,3:67],median,na.rm=T)[1]),
     type='l',lwd=5,col='black',ylim=c(100,500),ylab='Index',
     xlab='Year',main='Los Angeles Metro\nGradient Boosted Indexes by ZIP Code',xaxt='n')
axis(side = 1, at = seq(2000, 2016))  

for(i in 1:nrow(z)){
  lines(x=seq(2000,2016,by=.25),y=as.numeric(z[i,3:67])*100/as.numeric(z[i,3:67])[1],lwd=.5,col='blue',lty=3)
}

plot(x=seq(2000,2016,by=.25),
     y=sapply(z[,3:67],median,na.rm=T)*100/(sapply(z[,3:67],median,na.rm=T)[1]),
     type='l',lwd=5,col='black',ylim=c(0,5),ylab='Index',xlab='Year',
     main='Los Angeles Metro\nMedian Sale Price Indexes by ZIP Code',xaxt='n')
axis(side = 1, at = seq(2000, 2016))  

for(i in 1:nrow(z)){
  lines(x=seq(2000,2016,by=.25),y=as.numeric(z[i,3:67])*100/as.numeric(z[i,3:67])[1],lwd=.5,col='blue',lty=3)
}






head(z)
i<-cbind(z[,c("HUMarketPlace","zipcode")],sapply(z[,3:68],FUN=function(x) {(x/z[,3])*100}))

library(reshape)
x<-melt(i)
x$time <- as.numeric(substr(x$variable,5,11))/100

x<-x[,c(1,2,5,4)]
names(x)<-c("HUMarketPlace","zipcode","time","Boosted")

dbWriteTable(vertica, "kurtis_HPI_zip_LosAngeles", x)




mquery<-"select * from Indexes_LA"
ek<-dbGetQuery(vertica, mquery) 

zips<-unique(ek$zipcode)

par(mfrow=c(3,3))
for( i in 1:length(zips)){
plot(x = seq(2000,2016.25,by=.25),
     y = ek[which(ek$zipcode==zips[i]),'Boosted'],
     col='blue',type='l',main=zips[i],ylab='Index',xlab='Year',
     ylim=c(
       min(ek[which(ek$zipcode==zips[i]),'Boosted'],ek[which(ek$zipcode==zips[i]),'repeatsales_index'],na.rm=T),
       max(ek[which(ek$zipcode==zips[i]),'Boosted'],ek[which(ek$zipcode==zips[i]),'repeatsales_index'],na.rm=T)))
lines(x = seq(2000,2016.25,by=.25),
     y =ek[which(ek$zipcode==zips[i]),'repeatsales_index'],
     col='purple')
lines(x = seq(2000,2016.25,by=.25),
      y =ek[which(ek$zipcode==zips[i]),'medianpriceindex'],
      col='green')
}


for( i in 1:length(zips)){
lines(x = seq(2000,2016.25,by=.25),ylim=c(-1,1),
     y =(ek[which(ek$zipcode==zips[i]),'repeatsales_index']-ek[which(ek$zipcode==zips[i]),'Boosted'])/ek[which(ek$zipcode==zips[i]),'Boosted'],
     col='blue',type='l',main=zips[i])
}
abline(h=0,col='red',lwd=5)




mquery<-"select sqft,smooth_201625 from kurtis_HPIPredictions_LosAngeles order by random() limit 1000"
props<-dbGetQuery(vertica, mquery) 


hist(log(props$smooth_201625/props$sqft),breaks=50)

plot(x=seq(2000,2016.25,by=.25),
     y=as.numeric(props[1,3:68])/props[1,3],
     type='l',lwd=5,col='grey',ylim=c(1,3),xaxt='n')
axis(side = 1, at = seq(2000, 2016))  
for(i in 1:nrow(z)){
  lines(x=seq(2000,2016.25,by=.25),y=as.numeric(z[i,3:68])/as.numeric(z[i,3:68])[1],lwd=.5,col='blue',lty=3)
}

load('/Users/homeunion/Documents/HPI/Output/model_LosAngeles-LongBeach,CAPMSA201600.rda')
library(gbm)
relative.influence(boostfit)








#Overall Sales Accuracy:
xquery<-"select year,saleprice,HPIPrediction from kurtis_HPI_accuracy_allyears where year >2010"
errors<-dbGetQuery(vertica, xquery) 
errors$pcnterr<-(errors$HPIPrediction-errors$saleprice)/errors$saleprice
errors<-errors[which(abs(errors$pcnterr)<.5),]
hist(errors$pcnterr*100,xlim=c(-50,50),breaks=5000,main='Distribution of Prediction Errors',xlab='Percent Error (%)')
abline(v=c(-10,10),col='red')

boxplot(errors$pcnterr*100~as.factor(errors$year),ylim=c(-50,50),
        main='Box Plots of Percent Errors for \nProperty Sale Predictions with HomeUnion HPI',
        pch='',ylab='% Error for Sale Price Prediction',xlab='Year')
abline(h=0,col='red')
mtext(at=c(2000,-20),side=2,text="Under Predict")
mtext(at=c(2000,20),side=2,text="Over Predict")
agg<-aggregate(x=errors$pcnterr,by=list(errors$year),mean,na.rm=T)
points(x=as.factor(agg$Group.1),y=agg$x*100,col='blue',pch='-',cex=3)
segments(x0=agg$Group.1-.25, y0=agg$x*100, 
          x1 = agg$Group.1+.25,y1=agg$x*100,col = 'blue')



tall<-read.csv('/Users/homeunion/Documents/HPI/Data/zipcode_median_pricetrend.csv')
tall$time<-tall$year*100+(tall$quarter-1)*100/4
wide<-t(tall)

####rMSPE
rmspe<-sqrt(median((errors$pcnterr*100)^2))

median(abs(errors$pcnterr*100))

rmspe




