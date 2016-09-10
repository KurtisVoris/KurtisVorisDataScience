# This program is written Nov 11th - Veterans Day
#  This program will read in a clean file for each state and build the state's models.
#  Zipcode models, city models, county models, and state models are built

Subset_Empty_Vars <- function(data_in) {
  n = nrow(data_in)
  p = ncol(data_in)
  na = is.na(data_in)
  none_empty_col_index = rep(TRUE, p)
  for(j in 1:p) {
    if(sum(na[, j]) > 0.8*n | length(na.omit(unique(data_in[, j]))) == 1) { none_empty_col_index[j] = FALSE }
  }
  return(as.data.frame(data_in[, none_empty_col_index]))
}

library(plyr)
library(xgboost)

path = '/home/data-analysis/DataScience/RentAVM/Input/Normalized_Input/AVM_2_2/'

files<-system(paste('cd ',path,'; ls | grep Clean',sep=''),intern=T)

for (file in files){####[45:51]##
print(file)
df<-read.table(paste(path,file,sep=''),header=TRUE,quote='"',sep='|',colClasses=c("property_identifier"='character',"state"='character',"county"='character',"city"='character',"zipcode"='character',"address"='character',"Source"='character',"property_type"='factor',"sqft"='numeric',"bed"='numeric',"bath"='numeric',"halfbath"='numeric',"rent"='numeric',"garage"='numeric',"carspace"='numeric',"yearbuilt"='numeric',"numphotos"='numeric',"listingstatus"='character',"year"='numeric',"month"='numeric',"latitude"='numeric',"longitude"='numeric',"LNIR_Score"='numeric',"NIR"='factor',"medianprice"='numeric',"medianincome"='numeric',"collegegrads"='numeric',"whitecollar"='numeric',"schools"='numeric',"vacancy"='numeric',"hu_crime"='numeric',"HospitalDist"='numeric',"WalmartDist"='numeric',"StarbucksDist"='numeric','pcnterr'='numeric'))

state<-unique(df$state)
######LIMIT COUNTS:::
citycounts<-as.data.frame(table(as.character(df$city)))
names(citycounts)=c('city','cityFreq')
citycounts<-citycounts[which(citycounts$cityFreq>0 & citycounts$city !=''),]

zipcounts<-as.data.frame(table(df$zipcode))
names(zipcounts)=c('zipcode','zipFreq')
zipcounts<-zipcounts[which(zipcounts$zipFreq>0 & zipcounts$zipcode !=''),]

countycounts<-as.data.frame(table(as.character(df$county)))
names(countycounts)=c('county','countyFreq')
countycounts<-countycounts[which(countycounts$countyFreq>0 & countycounts$county !=''),]
df<-merge(df,zipcounts,all.x=TRUE,by='zipcode')
df<-merge(df,citycounts,all.x=TRUE,by=c('city'))
df<-merge(df,countycounts,all.x=TRUE,by=c('county'))


#####Gradient Boosting Regression::
###set all zips cities or counties with less that 55 adds to be blank;

df[which(df$zipFreq<40),'zipcode']=NA
df[which(df$cityFreq<60),'city']=NA
df[which(df$countyFreq<80),'county']=NA

df$time<-df$year+df$month/12


#### BOOSTED MODEL PER ZIPCODE:
mpath<-'/home/data-analysis/DataScience/RentAVM/Models/AVM_2_2/'

vars = c("rent","time","bed","sqft" ,"bath","halfbath","yearbuilt" ,"carspace" ,"garage","property_type","latitude","longitude"  ,"NIR_Score" ,"NIR","medianprice","whitecollar","hu_crime","StarbucksDist","collegegrads","vacancy","WalmartDist","medianincome","schools","HospitalDist")

boostzipfit <- dlply(df[which(!is.na(df$zipcode)&df$zipcode!=''),], "zipcode", function(x){
  print(unique(x$zipcode))
    x = Subset_Empty_Vars(x[, vars])
    designmx<-data.matrix(x)
     xgboost(data =designmx ,label = x[,'rent'], eta = .01,missing=NaN,max_depth = 4,
                 nround=5000,early.stop.round=50,subsample = 0.5,colsample_bytree = 0.5,seed = 5,
                 verbose = 1, print.every.n = 100, eval_metric = "rmse",
                 objective = "reg:linear",nthread = 15) 
})


#for each model in boostzipfit, get vector of prediction errors and output standard deviation
   modelerrors<-NULL
for (z in seq(1,length(names(boostzipfit)))){
   zip<-names(boostzipfit)[z]
   pcnterr<- (predict(boostzipfit[[z]],data.matrix(df[which(df$zipcode==zip),]),missing=NaN) - df[which(df$zipcode==zip),'rent'])/df[which(df$zipcode==zip),'rent']
   modelerrors<-rbind(modelerrors,c(state,'zipcode',zip,sd(pcnterr)))
}
write.table(modelerrors,paste(mpath,'XGB_PredictionError',state,'.txt',sep=''),sep='|',row.names=F,col.names=F)
print('savingzipfile')
##save(boostzipfit,file=paste(mpath,'boostzipfit',state,'_04MAY2016.rda',sep=''))



vars = c("rent","time","zipcode","bed","sqft" ,"bath","halfbath","yearbuilt" ,"carspace" ,"garage","property_type","latitude","longitude"  ,"NIR_Score" ,"NIR","medianprice","whitecollar","hu_crime","StarbucksDist","collegegrads","vacancy","WalmartDist","medianincome","schools","HospitalDist")


boostcityfit <- dlply(df[which(!is.na(df$city)&df$city!=''),], c("city"), function(x){
print(unique(x$city))
  x = Subset_Empty_Vars(x[, vars])
  designmx<-data.matrix(x)
  xgboost(data =designmx ,label = x[,'rent'], eta = .01,missing=NaN,max_depth = 4,
          nround=5000,early.stop.round=50,subsample = 0.5,colsample_bytree = 0.5,seed = 5,
          verbose = 1, print.every.n = 100, eval_metric = "rmse",
          objective = "reg:linear",nthread = 15)
})


#for each model in boostzipfit, get vector of prediction errors and output standard deviation
modelerrors<-NULL
for (z in seq(1,length(names(boostcityfit)))){
  city<-names(boostcityfit)[z]
  pcnterr<- (predict(boostcityfit[[z]],data.matrix(df[which(df$city==city),]),missing=NaN) - df[which(df$city==city),'rent'])/df[which(df$city==city),'rent']
  modelerrors<-rbind(modelerrors,c(state,"city",city,sd(pcnterr)))
}
write.table(modelerrors,paste(mpath,'XGB_PredictionError',state,'.txt',sep=''),sep='|',row.names=F,col.names=F,append=T)
print('savingcityfile')
##save(boostcityfit,file=paste(mpath,'boostcityfit',state,'_04MAY2016.rda',sep=''))


boostcountyfit <- dlply(df[which(!is.na(df$county)&df$county!=''),], c("county"), function(x){
print(unique(x$county))
  x = Subset_Empty_Vars(x[, vars])
  designmx<-data.matrix(x)
  xgboost(data =designmx ,label = x[,'rent'], eta = .01,missing=NaN,max_depth = 4,
          nround=5000,early.stop.round=50,subsample = 0.5,colsample_bytree = 0.5,seed = 5,
          verbose = 1, print.every.n = 100, eval_metric = "rmse",
          objective = "reg:linear",nthread = 15)
})


#for each model in boostzipfit, get vector of prediction errors and output standard deviation
modelerrors<-NULL
for (z in seq(1,length(names(boostcountyfit)))){
  county<-names(boostcountyfit)[z]
  pcnterr<- (predict(boostcountyfit[[z]],data.matrix(df[which(df$county==county),]),missing=NaN) - df[which(df$county==county),'rent'])/df[which(df$county==county),'rent']
  modelerrors<-rbind(modelerrors,c(state,"county",county,sd(pcnterr)))
}
write.table(modelerrors,paste(mpath,'XGB_PredictionError',state,'.txt',sep=''),sep='|',row.names=F,col.names=F,append=T)
print('savingcountyfile')
##save(boostcountyfit,file=paste(mpath,'boostcountyfit',state,'_04MAY2016.rda',sep=''))



booststatefit <- dlply(df[which(!is.na(df$state)&df$state!=''),], c("state"), function(x){
print(unique(x$state))
  x = Subset_Empty_Vars(x[, vars])
  designmx<-data.matrix(x)
  xgboost(data =designmx ,label = x[,'rent'], eta = .01,missing=NaN,max_depth = 4,
          nround=5000,early.stop.round=50,subsample = 0.5,colsample_bytree = 0.5,seed = 5,
          verbose = 1, print.every.n = 100, eval_metric = "rmse",
          objective = "reg:linear",nthread = 15)
})


#for each model in boostzipfit, get vector of prediction errors and output standard deviation
modelerrors<-NULL
for (z in seq(1,length(names(booststatefit)))){
  state<-names(booststatefit)[z]
  pcnterr<- (predict(booststatefit[[z]],data.matrix(df[which(df$state==state),]),missing=NaN) - df[which(df$state==state),'rent'])/df[which(df$state==state),'rent']
  modelerrors<-rbind(modelerrors,c(state,"county",state,sd(pcnterr)))
}
write.table(modelerrors,paste(mpath,'XGB_PredictionError',state,'.txt',sep=''),sep='|',row.names=F,col.names=F,append=T)
print('savingcountyfile')
##save(boostcountyfit,file=paste(mpath,'boostcountyfit',state,'_04MAY2016.rda',sep=''))



























boostcountyfit <- dlply(df[which(!is.na(df$county)&df$county!=''),], c("county"), function(x){
  #print(unique(paste(x$county,nrow(x),sep = '|')))
x = Subset_Empty_Vars(x[, vars])
  gbm(log(rent)~., # formula

      data=x, # dataset
      distribution="gaussian", # see the help for other choices
      n.trees=5000, # number of trees
      shrinkage=0.01, # shrinkage or learning rate,# 0.001 to 0.1 usually work
      interaction.depth=5, # 1: additive model, 2: two-way interactions, etc.
      bag.fraction = 0.75, # subsampling fraction, 0.5 is probably best
      train.fraction = 0.75, # fraction of data for training, # first train.fraction*N used for training
      n.minobsinnode = 5, # minimum total weight needed in each node
      cv.folds = 0, # do 3-fold cross-validation
      keep.data=FALSE, # keep a copy of the dataset with the object
      verbose=FALSE, # don't print out progress
      n.cores=1)
})

   modelerrors<-NULL
for (z in seq(1,length(names(boostcountyfit)))){
   county<-names(boostcountyfit)[z]
   pcnterr<- (exp(predict(boostcountyfit[[z]],df[which(df$county==county),])) - df[which(df$county==county),'rent'])/df[which(df$county==county),'rent']
   modelerrors<-rbind(modelerrors,c(state,'county',county,sd(pcnterr)))
}
write.table(modelerrors,paste(mpath,'PredictionError',state,'.txt',sep=''),sep='|',row.names=F,col.names=F,append=T)
print('savingcountymodel')
print(state)
save(boostcountyfit,file=paste(mpath,'boostcountyfit',state,'_04MAY2016.rda',sep=''))
booststatefit <- dlply(df, "state", function(x){
  #print(unique(x$state))
    x = Subset_Empty_Vars(x[, vars])
  gbm(log(rent)~., # formula

     data=x, # dataset
      distribution="gaussian", # see the help for other choices
      n.trees=5000, # number of trees
      shrinkage=0.008, # shrinkage or learning rate,# 0.001 to 0.1 usually work
      interaction.depth=5, # 1: additive model, 2: two-way interactions, etc.
      bag.fraction = 0.5, # subsampling fraction, 0.5 is probably best
      train.fraction = 0.75, # fraction of data for training, # first train.fraction*N used for training
      n.minobsinnode = 5, # minimum total weight needed in each node
      cv.folds = 0, # do 3-fold cross-validation
      keep.data=FALSE, # keep a copy of the dataset with the object
      verbose=FALSE, # don't print out progress
      n.cores=1)
})
modelerrors<-NULL
for (z in seq(1,length(names(booststatefit)))){
   pcnterr<- (exp(predict(booststatefit[[z]],df[which(df$state==state),])) - df[which(df$state==state),'rent'])/df[which(df$state==state),'rent']
   modelerrors<-rbind(modelerrors,c(state,'state',state,sd(pcnterr)))
}
write.table(modelerrors,paste(mpath,'PredictionError',state,'.txt',sep=''),sep='|',row.names=F,col.names=F,append=T)

print('savingstatemodel')
print(state)
save(booststatefit,file=paste(mpath,'booststatefit',state,'_04MAY2016.rda',sep=''))

}
