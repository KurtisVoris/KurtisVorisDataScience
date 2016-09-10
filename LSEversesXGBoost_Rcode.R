
###PULL IN DATA::
flag<-dbGetQuery(vertica, 'select * from Tony_flagstaff2') 
flag<-flag[which(flag$saleprice<1000000),]
flag[,c('sqft','yearbuilt','bed','bath')]<-sapply(flag[,c('sqft','yearbuilt','bed','bath')],as.numeric)
flag$time<-flag$year+(flag$quarter-1)/4
flag[which(is.na(flag$NDS)),'NDS']<-median(flag$NDS,na.rm=T)


############Each Property should run and build models and predict :

soldtwice<-as.data.frame(table(flag$property_identifier))
soldtwice<-as.character(soldtwice[which(as.numeric(soldtwice$Freq)>1),1])
topred<-which(flag$property_identifier %in% soldtwice & flag$ranks==2)

start<-Sys.time()
for(home in topred[1:1000]){
  for (timepoint in seq(2001,2015.75,by=.25)){
    print(timepoint)
    timebound<-.5
    comps<-which(flag$zipcode==flag[home,'zipcode']
                 & abs(flag[home,'sqft']-flag$sqft)<=flag[home,'sqft']*.15
                 & flag$tax_assessor_land_square_footage<20000
                 & abs(timepoint-flag$time)<=timebound)
    while(length(comps)<20 & timebound<1.5){
      print(paste('exception loop',timebound))
      comps<-which(flag$zipcode==flag[home,'city']
                   & abs(flag[home,'sqft']-flag$sqft)<=flag[home,'sqft']*.35
                   & flag$tax_assessor_land_square_footage<20000
                   & abs(timepoint-flag$time)<=timebound)
      timebound=timebound+.25
    }
    timebound=.5
    while(length(comps)<20 & timebound<1.5){
      print(paste('2nd exception loop',timebound))
      comps<-which(flag$city==flag[home,'city']
                   & abs(flag[home,'sqft']-flag$sqft)<=flag[home,'sqft']*.35
                   & flag$tax_assessor_land_square_footage<20000
                   & abs(timepoint-flag$time)<=timebound)
      timebound=timebound+.25
    }
    if( length(comps)<20 ){
      
      comps<-which(flag$zipcode==flag[home,'zipcode'] & abs(timepoint-flag$time)<=1)
    }
    if(length(comps)<20 ){
      comps<-which(flag$city==flag[home,'city'] & abs(timepoint-flag$time)<=1)
    }
    if(length(comps)<20 ){
      comps<-1:nrow(flag)
    }
    comps<-flag[comps,]
    ### Outlier Removal wrt saleprice Next:################################################
    comps$zscore<-scale(comps$saleprice) ### ZSCORE OUTLIER REMOVAL
    comps<-comps[which(abs(comps$zscore)<1.2),]
    compfit<-lm(log(saleprice)~sqft+yearbuilt+NDS+tax_assessor_land_square_footage,data=comps)
    flag[home,paste('fit_',timepoint*100,sep='')]<-exp(predict(compfit,
                                                                 flag[home,c('sqft','yearbuilt','NDS','tax_assessor_land_square_footage')]))
    print(paste('House #',home,'at',timepoint,'output'))
    comps<-NA
  }
}
Sys.time()-start

###########################  XGBOOST  ##################################
###########################  XGBOOST  ##################################
###########################  XGBOOST  ##################################
vars = c('latitude', 'longitude', 'sqft', 'bed', 'bath','assessor_full_baths', 'assessor_half_baths', 
         'carspace', 'basement_sqft',  'stories', 
         'fixed_property_type', 'yearbuilt', 'pcnt_of_marketvalue',  
         'assessor_front_footage',  'tax', 'CL_Price','CL_Rent',
         'cemetery_dist_mtrs', 'nationalhighway_mtrs', 'railline_mtrs', 'starbucks_mtrs', 'walmart_mtrs', 
         'tax_assessor_land_square_footage', 
          'universal_land_use_code_desc', 
         'HospitalDist', 'WalmartDist',  'medianincomenbhd', 'collegegrads', 
         'safety', 'NDS', 'medianavm', 'employmentdiversity','zipcode','time')


stime<-Sys.time()
for (timepoint in seq(2001,2015.75,by=.25)){
  print(timepoint)
  window<-flag[which(flag$time-timepoint<0 & flag$time-timepoint>-2),]
  designmx<-data.matrix(window[,vars])
  boostfit = xgboost(data =designmx , 
                         label = window[,c('saleprice')], eta = 0.2,missing=NaN,max_depth = 5, nround=505,subsample = 0.5,
                         colsample_bytree = 0.5,seed = 5,eval_metric = "rmse",objective = "reg:linear",nthread = 15)
  print(paste('--------------',timepoint,"Model is Built",timepoint,'---------------'))
  #save(boostfit,'')
  predict<-data.matrix(cbind(flag[topred,vars],rep(timepoint,length(topred))))
  flag[topred,paste('xfit_',timepoint*100,sep='')]<-predict(boostfit,predict,missing=NaN)#,missing=NaN)
  window<-NULL
}
Sys.time()-stime

######REMOVE CRAZY PREDICTIONS > 1 million
for(col in 57:176){
  flag[which(flag[,col]>1000000),col]<-NA
}
######   PLOT EACH PROPERTY AND THE SALES PRICES:

    pdf('/Users/homeunion/Documents/HPIndex/Flagstaff Index Plots LSE twice.pdf')
    par(mfrow=c(2,2))
    for(num in topred[1:500]){
        plot(seq(2001,2015.75,by=.25),
             predict(
               loess(as.numeric(flag[num,57:116])~seq(2001,2015.75,by=.25),
                     span=.4,
                     control = loess.control(surface = "direct")),
               seq(2001,2015.75,by=.25))
             ,col='grey',type='l',lwd=10,main=paste(flag[num,'tax_property_address'],': LSE \n',flag[num,'sqft'],'sqft'),ylab='HPI LSE',xlab='Time',
             ylim=c(min(as.numeric(flag[num,57:116]),flag[num,'saleprice'],as.numeric(flag[num,117:176]),na.rm=T),
                    max(as.numeric(flag[num,57:116]),flag[num,'saleprice'],as.numeric(flag[num,117:176]),na.rm=T)))
        points(x=seq(2001,2015.75,by=.25),y=as.numeric(flag[num,57:116]),pch=20)
        points(x=flag[which(flag[num,'property_identifier']==flag$property_identifier),'time'],y=flag[which(flag[num,'property_identifier']==flag$property_identifier),'saleprice'],col='red',pch=20,lwd=10)
        
#         plot(seq(2001,2015.75,by=.25),
#              predict(
#                loess(as.numeric(flag[num,117:176])~seq(2001,2015.75,by=.25),
#                      span=.4,
#                      control = loess.control(surface = "direct")),
#                seq(2001,2015.75,by=.25))
#              ,col='grey',type='l',lwd=10,main=paste(flag[num,'tax_property_address'],': XGBOOST \n',flag[num,'sqft'],'sqft'),ylab='HPI LSE',xlab='Time',
#              ylim=c(min(as.numeric(flag[num,117:176]),flag[num,'saleprice'],as.numeric(flag[num,57:116]),na.rm=T),
#                     max(as.numeric(flag[num,117:176]),flag[num,'saleprice'],as.numeric(flag[num,57:116]),na.rm = T)))
#         points(x=seq(2001,2015.75,by=.25),y=as.numeric(flag[num,117:176]),pch=20)
#         points(x=flag[which(flag[num,'property_identifier']==flag$property_identifier),'time'],y=flag[which(flag[num,'property_identifier']==flag$property_identifier),'saleprice'],col='red',pch=20,lwd=10)
    }
    dev.off()

####
    par(mfrow=c(2,1))
flag$pcnterr<-NA
for( i in which(flag$time>2001 & !is.na(flag$fit_200150))){
  flag[i,'pcnterr']<-(flag[i,paste('fit_',flag[i,'time']*100,sep='')]   -  flag[i,'saleprice'])/flag[i,'saleprice']
}
hist(flag$pcnterr,xlim=c(-1,1),breaks=100,xlab='% Error',main=paste('LSE HPI Accuracy=',round(nrow(flag[which(abs(flag$pcnterr)<=.1),])/nrow(flag[which(!is.na(flag$pcnterr)),])*100,1),'%',sep=''))
abline(v=c(-.1,.1),col='red')
####
flag$xpcnterr<-NA
for( i in which(flag$time>2001 & !is.na(flag$xfit_200150))){
  flag[i,'xpcnterr']<-(flag[i,paste('xfit_',flag[i,'time']*100,sep='')]   -  flag[i,'saleprice'])/flag[i,'saleprice']
}
hist(flag$xpcnterr,xlim=c(-1,1),breaks=300,xlab='% Error',main=paste('XGboost HPI Accuracy=',round(nrow(flag[which(abs(flag$xpcnterr)<=.1),])/nrow(flag[which(!is.na(flag$xpcnterr)),])*100,1),'%',sep=''))
abline(v=c(-.1,.1),col='red')











sales<-as.data.frame(aggregate(flag$saleprice,by=list(flag$year,flag$quarter),FUN=median,na.rm=T))
sales$time<-sales$Group.1+(sales$Group.2 - 1)/4
sales<-sales[order(sales$time),]
par(mfrow=c(1,1))
plot(seq(2000,2014.75,by=.25),as.numeric(sapply(flag[,117:176],median,na.rm=T)),type='l',col='green',lwd=5)
lines(seq(2001,2015.75,by=.25),as.numeric(sapply(flag[,57:116],median,na.rm=T)),type='l',col='blue',lwd=5)
lines(sales$time,sales$x,type='l',col='black',lwd=5)

legend(x=2001,y=300000,legend=c('GBM','Regression','saleprice'),fill=c('blue','green','black'),col=c('blue','green','black'))
abline(v=seq(2000,2020),col='grey')


aggregate(flag$saleprice,by=list(flag$year,flag$quarter),FUN=median,na.rm=T)[,3]




1:4



































##########################################################################################################################################################################
#####################################################################################
##########################################################################################################################################################################
#####################################################################################
##########################################################################################################################################################################
#####################################################################################
##########################################################################################################################################################################
