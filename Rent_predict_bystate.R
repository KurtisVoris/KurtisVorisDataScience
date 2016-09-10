####THIS PROGRAM WILL read ina  chunk of data, clean the columns and then run the predict function on the data

#This program will read in MLS data with zillow accuracy and HU accuracy
library(gbm)
library(methods)
sourcepath<-'/home/data-analysis/DataScience/RentAVM/Prediction/AVM_2_2/'

statelist = c(#"AK","AL","AR","AZ","CA","CO","CT","DC","DE","FL","GA","HI","IA","ID","IL","IN","KS","KY","LA","MA","MD","ME","MI","MN","MO","MS","MT","NC","ND","NE","NH","NJ","NM","NV","NY","OH","OK","OR","PA")#,
"RI","SC","SD","TN","TX","UT","VA","WA","WI","WV","WY","VT")

modelpath<-'/home/data-analysis/DataScience/RentAVM/Models/AVM_2_2/'
modeldate<-'04MAY2016'

setClass("num.with.quotes")
setAs("character", "num.with.quotes", function(from) as.numeric(gsub('"', '', from) ) )



for (statex in statelist){

#count rows in source file, determin how many loops of 100,000 we need to do:
nrows<-as.numeric(strsplit(system(paste('wc -l ',sourcepath,'ToPredict',statex,'.csv',sep=''),intern=T),' ')[[1]][1])

stfile<-file(paste(sourcepath,'ToPredict',statex,'.csv',sep=''))
open(stfile)

load(paste(modelpath,'boostzipfit',statex,'_',modeldate,'.rda',sep=''))
load(paste(modelpath,'boostcityfit',statex,'_',modeldate,'.rda',sep=''))
load(paste(modelpath,'boostcountyfit',statex,'_',modeldate,'.rda',sep=''))
load(paste(modelpath,'booststatefit',statex,'_',modeldate,'.rda',sep=''))


casts<-c('state'='character',
'county'='character',
'city'='character',
'property_identifier'='character',
'zipcode'='character',
'property_address'='character',
'time'='num.with.quotes',
'bed'='num.with.quotes',
'sqft'='num.with.quotes',
'bath'='num.with.quotes',
'halfbath'='num.with.quotes',
'yearbuilt'='num.with.quotes',
'carspace'='num.with.quotes',
'garage'='num.with.quotes',
'property_type'='character',
'longitude'='num.with.quotes',
'latitude'='num.with.quotes',
'nid'='character',
'nir_Score'='num.with.quotes',
'NIR'='character',
'medianprice'='num.with.quotes',
'medianincome'='num.with.quotes',
'collegegrads'='num.with.quotes',
'whitecollar'='num.with.quotes',
'schools'='num.with.quotes',
'vacancy'='num.with.quotes',
'hu_crime'='num.with.quotes',
'HospitalDist'='num.with.quotes',
'WalmartDist'='num.with.quotes',
'StarbucksDist'='num.with.quotes')


for (chunk in 1:ceiling(nrows/100000)){
	if(chunk == 1){ tp<-read.table(stfile,skip=1,nrow=100000,header=F,sep='|',quote='"',colClasses=casts)}
	if(chunk>1){tp<-read.table(stfile,nrow=100000,header=F,sep='|',quote='"',colClasses=casts)} 
       names(tp)<-c("state","county","city","property_identifier","zipcode","address","time","bed","sqft","bath","halfbath","yearbuilt","carspace","garage","property_type","longitude","latitude","nid","NIR_Score","NIR","medianprice","medianincome","collegegrads","whitecollar","schools","vacancy","hu_crime","HospitalDist","WalmartDist","StarbucksDist")


##Set up data for model prediction:
tp$city<-toupper(tp$city)
tp$county<-toupper(tp$county)
tp$state<-toupper(tp$state)
tp$HURentAVM<-NA

# ---- Predict for all zipcodes in the zipcode model:
    # Indicate which models to use
    valid_models = rep(TRUE, length(names(boostzipfit)))
    for(i in 1:length(names(boostzipfit))) {
      if(is.na(mean(boostzipfit[[i]]$valid.error)) == TRUE) {valid_models[i] = FALSE}
    }
    zips = unique(as.character(na.omit(tp$zipcode)))[unique(as.character(na.omit(tp$zipcode))) %in% na.omit(names(boostzipfit[valid_models]))]
    # Loop to predict for zipcodes with models
    if(length(zips) > 0) {
      for(i in 1:length(zips)) {
        print(paste(statex,'zip:', i, '/', length(zips)))
        tp[which(tp$zipcode == zips[i]), 'HURentAVM'] = exp(predict(eval(parse(text = paste('boostzipfit$`', zips[i], '`', sep = ''))), tp[which(tp$zipcode == zips[i]), ]))
        tp[which(tp$zipcode == zips[i]), 'level'] = 'zipcode'
      }
    }



# ---- For records whose zipcode does not have a model, predict at their city if their city has a model:
    valid_models = rep(TRUE, length(names(boostcityfit)))
    for(i in 1:length(names(boostcityfit))) {
      if(is.na(mean(boostcityfit[[i]]$valid.error)) == TRUE) {valid_models[i] = FALSE}
    }
    cities = unique(as.character(na.omit(tp$city)))[unique(as.character(na.omit(tp$city))) %in% na.omit(names(boostcityfit[valid_models]))]
    if(length(cities) > 0) {
      for(i in 1:length(cities)) {
        print(paste(statex,'city:', i,'/', length(cities)))
        tp[which(tp$city == cities[i] & is.na(tp$HURentAVM)), 'level'] = 'city'
        tp[which(tp$city == cities[i] & is.na(tp$HURentAVM)), 'HURentAVM'] = exp(predict(eval(parse(text = paste('boostcityfit$`', cities[i], '`', sep = ''))), tp[which(tp$city == cities[i] & is.na(tp$HURentAVM)),]))
      }
    }


    # ---- For records without a zip or citymodel, use thier county model:
    valid_models = rep(TRUE, length(names(boostcountyfit)))
    for(i in 1:length(names(boostcountyfit))) {
      if(is.na(mean(boostcountyfit[[i]]$valid.error)) == TRUE) {valid_models[i] = FALSE}
    }
    counties = unique(as.character(na.omit(tp$county)))[unique(as.character(na.omit(tp$county))) %in% na.omit(names(boostcountyfit[valid_models]))]
    if(length(counties) > 0) {
      for(i in 1:length(counties)) {
        print(paste(statex,'county:',counties[i],'/',length(counties)))
        tp[which(tp$county == counties[i] & is.na(tp$HURentAVM)), 'level'] = 'county'
        tp[which(tp$county == counties[i] & is.na(tp$HURentAVM)), 'HURentAVM'] = exp(predict(eval(parse(text = paste('boostcountyfit$`', counties[i], '`', sep = ''))), tp[which(tp$county == counties[i] & is.na(tp$HURentAVM)), ]))
      }
    }


    # For records without zip,city,county models, use the ovrall state model : (
    for(num in 1:length(names(booststatefit))) {
      print(paste('state:', names(booststatefit), '------------------------------- chunk: ', chunk))
      tp[which(tp$state==names(booststatefit)[num] & is.na(tp$HURentAVM)), 'level'] = 'state'
      tp[which(tp$state==names(booststatefit)[num] & is.na(tp$HURentAVM)), 'HURentAVM'] = exp(predict(booststatefit[[num]], tp[which(tp$state == names(booststatefit)[num] & is.na(tp$HURentAVM)),]))
    }

    tp$HURentAVM<-round(tp$HURentAVM)

write.table(tp[,c('property_identifier','state','city','zipcode','address','property_type','sqft','bed','bath','nid','HURentAVM','level')],paste(sourcepath,'Predicted',statex,'_01MAY2016.txt',sep=''),sep='|',row.names=F,col.names=F,quote=T,append=T)
tp<-NULL
}

close(stfile)###After we have looped the the file and output files to one large predicted file.

rm(boostzipfit)
rm(boostcityfit)
rm(boostcountyfit)
rm(booststatefit)


}




