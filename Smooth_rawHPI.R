library(RJDBC)
vDriver <- JDBC(driverClass="com.vertica.Driver", classPath="/Users/homeunion/Desktop/vertica-jdbc-4.1.14.jar")
vertica <- dbConnect(vDriver, "jdbc:vertica://192.168.10.104:5433/homeunion", "dbadmin", "1234")

############  SMOOTH OUT AND SEASONALLY ADJUST THE NEIGHBORHOOD TRENDS ## AVOID WEIRD plots
############  SMOOTH OUT AND SEASONALLY ADJUST THE NEIGHBORHOOD TRENDS ## AVOID WEIRD plots
############  SMOOTH OUT AND SEASONALLY ADJUST THE NEIGHBORHOOD TRENDS ## AVOID WEIRD plots
tobin_round_steveS
query<-"select * from kurtis_HPIRolledup2"
hpi<-dbGetQuery(vertica, query)
hpi2<-hpi
par(mfrow=c(2,2))
for(i in 154236:nrow(hpi)){
  print(i)
# plot(seq(2001,2016,by=.25),hpi[i,4:64],type='b',pch=20,col='blue',lty='dashed', 
#      main=paste(hpi[i,'HUMarketPlace'],hpi[i,'ID'],hpi[i,'source'],'span=.4'),xlim=c(2000,2020), ylab='Market Price',xlab='Time')
#   abline(v=2016,col='red')
# lines(seq(2001,2016,by=.25),
#       predict(
#         loess(as.numeric(hpi[i,4:63])~seq(2001,2015.75,by=.25),
#               span=.3,
#               control = loess.control(surface = "direct")),
#         seq(2001,2016,by=.25))
#       ,col='red',type='l',lwd=1)
# lines(seq(2001,2016,by=.25),
#       predict(
#         loess(as.numeric(hpi[i,4:63])~seq(2001,2015.75,by=.25),
#               span=.4,
#               control = loess.control(surface = "direct")),
#         seq(2001,2016,by=.25))
#       ,col='orange',type='l',lwd=1)
# lines(seq(2001,2016,by=.25),
#       predict(
#         loess(as.numeric(hpi[i,4:63])~seq(2001,2015.75,by=.25),
#               span=.5,
#               control = loess.control(surface = "direct")),
#         seq(2001,2016,by=.25))
#       ,col='grey',type='l',lwd=1)

hpi2[i,4:64]<-t(predict(
  loess(as.numeric(hpi[i,4:63])~seq(2001,2015.75,by=.25),
        span=.4,
        control = loess.control(surface = "direct")),
  seq(2001,2016,by=.25)))
}







#######PLOT THE SMOOTHED VAUE HPI:
query<-"select * from kurtis_HPIRolledup"
hpi<-dbGetQuery(vertica, query)

pdf(file='/Users/homeunion/Documents/HPI/Neighborhood HPIndex Plots.pdf')
par(mfrow=c(4,3))
for(i in sort(sample(1:nrow(hpi),size=10000))){
  plot(seq(2001,2016,by=.25),hpi[i,5:65]/hpi[i,5],type='l',pch=20,col='blue',
       main=paste(hpi[i,'HUMarketPlace'],'\n',hpi[i,'ID'],hpi[i,'PropertyCount'],'Props'),xlim=c(2000,2017), ylab='',xlab='Time',las=2)
}
dev.off()
  









pdf(file='/Users/homeunion/Documents/HPI/Neighborhood HPI Plots.pdf')
par(mfrow=c(4,4))
for(i in sample(1:nrow(hpi2),size=20000)){
plot(seq(2001,2016,by=.25),hpi2[i,4:64],type='l',pch=20,col='blue',
           main=paste(hpi2[i,'HUMarketPlace'],'\n',hpi2[i,'ID'],hpi[i,'source']),xlim=c(2000,2017), ylab='Market Price',xlab='Time')
points(seq(2001,2016,by=.25),hpi[i,4:64],pch='.')
  }
dev.off()

names(hpi2)<-c()
dbWriteTable(vertica, "kurtis_HPIRolledUp_smooth", hpi2)

pdf('/Users/homeunion/Documents/HPI/ClevelandSampleHPIs_span3_holtzloess.pdf')
par(mfrow=c(2,1))
for(i in sample(10000,100)){
plot(seq(2001,2015.75,by=.25),clev[i,8:67],type='b',pch=20,col='blue',lty='dashed', main=paste(clev[i,'address'],'sqft:',clev[i,'sqft']),xlim=c(2000,2020))
lines(seq(2001,2015.75,by=.25),
       predict(
         loess(as.numeric(clev[i,8:67])~seq(2001,2015.75,by=.25),
               span=.5,
               control = loess.control(surface = "direct")),
         seq(2001,2015.75,by=.25))
       ,col='red',type='l',lwd=5)
#plot(HoltWinters(ts(t(clev[i,8:67]),start=2001,end=2015.75,freq=4)),lwd=5,col='blue',xlim=c(2001,2020))
lines(predict(HoltWinters(ts(predict(
  loess(as.numeric(clev[i,8:67])~seq(2001,2015.75,by=.25),
        span=.5,
        control = loess.control(surface = "direct")),
  seq(2001,2015.75,by=.25)),start=2001,end=2015.75,freq=4)),n.ahead=15),lwd=5,col='pink')
lines(x=seq(2016,2020,by=.25),y=predict(loess(as.numeric(clev[i,8:67])~seq(2001,2015.75,by=.25),
                                              span=.5,
                                              control = loess.control(surface = "direct")),
                                        seq(2016,2020,by=.25)),col=637,lwd=5)
legend('topleft',c('HoltWinters','Loess'),fill=c('pink',637))
}
dev.off()


########LOESS PREDICTIONS:::
pdf('/Users/homeunion/Documents/HPI/ClevelandSampleHPIs_span3_loess.pdf')
par(mfrow=c(2,1))

for(i in sample(50000,50)){
  plot(seq(2001,2015.75,by=.25),clev[i,8:67],type='b',pch=20,col='blue',lty='dashed', main=paste(clev[i,'address'],'sqft:',clev[i,'sqft']),xlim=c(2000,2020))
  lines(seq(2001,2015.75,by=.25),
        predict(
          loess(as.numeric(clev[i,8:67])~seq(2001,2015.75,by=.25),
                span=.5,
                control = loess.control(surface = "direct")),
          seq(2001,2015.75,by=.25))
        ,col='red',type='l',lwd=5)
  #plot(HoltWinters(ts(t(clev[i,8:67]),start=2001,end=2015.75,freq=4)),lwd=5,col='blue',xlim=c(2001,2020))
  lines(x=seq(2016,2020,by=.25),y=predict(loess(as.numeric(clev[i,8:67])~seq(2001,2015.75,by=.25),
          span=.5,
          control = loess.control(surface = "direct")),
           seq(2016,2020,by=.25)),col='dark green',lwd=5)
}
dev.off()




####outlier Detection::
library(RJDBC)
vDriver <- JDBC(driverClass="com.vertica.Driver", classPath="/Users/homeunion/Desktop/vertica-jdbc-4.1.14.jar")
vertica <- dbConnect(vDriver, "jdbc:vertica://192.168.10.104:5433/homeunion", "dbadmin", "1234")

query<-"select * from kurtis_HPIPredictions  where  zipcode = '92128'"


query<-"select * from kurtis_HPIRolledup  where id = '92128' limit 50"
hpi<-dbGetQuery(vertica, query)

plot(seq(2001,2015.75,by=.25),hpi[1,4:63],type='b',pch=20,col='blue',lty='dashed', 
     main=paste(hpi[1,'address'],'sqft:',hpi[1,'sqft']),xlim=c(2000,2020), ylab='Market Price',xlab='Time')
lines(seq(2001,2015.75,by=.25),
      predict(
        loess(as.numeric(hpi[1,4:63])~seq(2001,2015.75,by=.25),
              span=.5,
              control = loess.control(surface = "direct")),
        seq(2001,2015.75,by=.25))
      ,col='red',type='l',lwd=5)








plot(seq(2001,2015.75,by=.25),hpi[1,8:67],type='l',pch=20,col='blue',lty='dashed', ylim=c(100000,1200000),
     main=paste(hpi[1,'address'],'sqft:',hpi[1,'sqft']),xlim=c(2000,2020), ylab='Market Price',xlab='Time')
for( i in 1:300){
lines(seq(2001,2015.75,by=.25),hpi[i,8:67],type='l',alpha=.01)
}

lines(seq(2001,2015.75,by=.25),
      predict(
        loess(as.numeric(hpi[i,8:67])~seq(2001,2015.75,by=.25),
              span=.5,
              control = loess.control(surface = "direct")),
        seq(2001,2015.75,by=.25))
      ,col='red',type='l',lwd=5)
lines(x=seq(2016,2020,by=.25),y=predict(loess(as.numeric(hpi[i,8:67])~seq(2001,2015.75,by=.25),
                                              span=.5,
                                              control = loess.control(surface = "direct")),
                                        seq(2016,2020,by=.25)),col=637,lwd=5)













for (i in 1:50){
plot(t(hpi[1,4:63]))
}


hpi$mean<-apply(hpi[,4:63],1,mean)
hpi$median<-apply(hpi[,4:63],1,median)

plot(hpi$median,hpi$mean)
abline(a=0,b=1)
x<-"select *,sqrt(stddev) as sd from kurtis_HPIPredictions_withmeanSD where zipcode like '9%' limit 50"
black<-dbGetQuery(vertica, x)

i=3
for(i in 1:50){
plot(t(black[i,8:67]),type='b',pch=20)
abline(h=black[i,'mean'],col='red')
abline(h=black[i,'mean']+4*black[i,'sd'],col='blue')
abline(h=black[i,'mean']-4*black[i,'sd'],col='blue')
}


query<-"select * from kurtis_HPIPredictions  where zipcode = '95661' and address like '2748 CA%'"
blacks<-dbGetQuery(vertica, query)
ar(mfrow=c(1,1))
plot(t(blacks[,8:67]),type='b',pch=20,ylab='Market Price',xlab='Time',main='2748 Carradale Dr Roseville, CA 95661')
points()

plot(seq(2001,2015.75,by=.25),blacks[i,8:67],type='b',pch=20,col='blue',lty='dashed', 
     main=paste(blacks[i,'address'],'sqft:',blacks[i,'sqft']),xlim=c(2000,2020), ylab='Market Price',xlab='Time')
lines(seq(2001,2015.75,by=.25),
      predict(
        loess(as.numeric(blacks[i,8:67])~seq(2001,2015.75,by=.25),
              span=.5,
              control = loess.control(surface = "direct")),
        seq(2001,2015.75,by=.25))
      ,col='red',type='l',lwd=5)
lines(x=seq(2016,2020,by=.25),y=predict(loess(as.numeric(blacks[i,8:67])~seq(2001,2015.75,by=.25),
                                              span=.5,
                                              control = loess.control(surface = "direct")),
                                        seq(2016,2020,by=.25)),col=637,lwd=5)











