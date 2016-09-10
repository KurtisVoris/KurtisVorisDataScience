##This program will: For each state:
#  1) Impute: beds, baths, yearbuilt
#  2) Trim and upper and standardize geography variables
#  3) Make variables correct types:
#  4) Clean latitude/longitude to be inside USA and drop many duplicate latitudes longitudes
#  5) Run regression at each city
#  6) Calculate residuals and remove values with high leverage causing overprediction.

library(gbm)
path = '/home/data-analysis/DataScience/RentAVM/Input/Normalized_Input/AVM_2_2/'
library(methods)
setClass("num.with.quotes")
setAs("character", "num.with.quotes", function(from) as.numeric(gsub('"', '', from) ) )

files<-system(paste('cd ',path,'; ls | grep Dirty',sep=''),intern=T)

for (file in files){
print(file)
df<-read.table(paste(path,file,sep=''),sep='|',header=TRUE,quote='"',colClasses=c('state'='character',
'city'='character',
'county'='character',
'property_identifier'='character',
'Source'='character',
'address'='character',
'zipcode'='character',
'property_type'='character',
'clustertype'='factor',
'sqft'='num.with.quotes',
'bed'='num.with.quotes',
'bath'='num.with.quotes',
'halfbath'='num.with.quotes',
'rent'='num.with.quotes',
'garage'='num.with.quotes',
'carspace'='num.with.quotes',
'yearbuilt'='num.with.quotes',
'numphotos'='num.with.quotes',
'listingstatus'='factor',
'year'='num.with.quotes',
'month'='num.with.quotes',
'latitude'='num.with.quotes',
'longitude'='num.with.quotes',
'neighborhoodid'='character',
'neighborhood_source'='factor',
'NIR_Score'='num.with.quotes',
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
'StarbucksDist'='num.with.quotes'))


#  2)  Fix zipcode:
df[which(nchar(df$zipcode)!=5),'zipcode']<-NA

#  2)  Trim and uppercase:
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
dedot <- function (x) gsub("[.]", "", x)


######### 1) Impute beds baths yearbuilt
######### Create model then predict for records where beds is missing:::

fitbed<-lm(bed~sqft+latitude+longitude,data=df[which(df$bed!=-1 & !is.na(df$bed)),])
df[which(df$bed==-1|is.na(df$bed)),'imputefl']<-'bed'
df[which(df$bed==-1|is.na(df$bed)),'bed']<-round(predict(fitbed,df[which(df$bed==-1|is.na(df$bed)),]))

fitbed2<-lm(bed~sqft,data=df[which(df$bed!=-1 & !is.na(df$bed)),])
df[which(df$bed==-1|is.na(df$bed)),'imputefl']<-'bed'
df[which(df$bed==-1|is.na(df$bed)),'bed']<-round(predict(fitbed2,df[which(df$bed==-1|is.na(df$bed)),]))

fitbath<-lm(bath~sqft+bed+latitude+longitude,data=df[which(df$bath!=-1 & !is.na(df$bath)),])
df[which(df$bath==-1|is.na(df$bath)),'imputefl']<-paste(df[which(df$bath==-1|is.na(df$bath)),'imputefl'],'bath',sep='+')
df[which(df$bath==-1|is.na(df$bath)),'bath']<-round(predict(fitbath,df[which(df$bath==-1|is.na(df$bath)),]))

fitbath2<-lm(bath~sqft+latitude+longitude,data=df[which(df$bath!=-1 & !is.na(df$bath)),])
df[which(df$bath==-1|is.na(df$bath)),'imputefl']<-paste(df[which(df$bath==-1|is.na(df$bath)),'imputefl'],'bath',sep='+')
df[which(df$bath==-1|is.na(df$bath)),'bath']<-round(predict(fitbath2,df[which(df$bath==-1|is.na(df$bath)),]))

fityr<-lm(yearbuilt~sqft+bed+latitude+longitude,data=df[which(df$yearbuilt!=-1 & !is.na(df$yearbuilt)),])
df[which(df$yearbuilt==-1 | is.na(df$yearbuilt)),'imputefl']<-paste(df[which(df$yearbuilt==-1 | is.na(df$yearbuilt)),'imputefl'],'yearbuilt',sep='+')
df[which(df$yearbuilt==-1|is.na(df$yearbuilt)),'yearbuilt']<-round(predict(fityr,df[which(df$yearbuilt==-1|is.na(df$yearbuilt)),]))
df[which(grepl('yearbuilt',df$imputefl) & df$yearbuilt>2015),'yearbuilt']<-2015

df[which(df$carspace==-1|is.na(df$carspace)),'carspace']<-1


###Run Regression at each location:

##Create group variable, which determines which model to put it into for regression testing:
#If city count>50 then city, if countycount >50 then county, else state

zipcount<-as.data.frame(table(df[which(!is.na(df$zipcode) & (!is.na(df$sqft) | !is.na(df$latitude)) ),'zipcode']))
names(zipcount)<-c('zipcode','zipcount')
citycount<-as.data.frame(table(df[which(!is.na(df$city)&(!is.na(df$sqft) | !is.na(df$latitude))),'city']))
names(citycount)<-c('city','citycount')
countycount<-as.data.frame(table(df[which(!is.na(df$county) & (!is.na(df$sqft) | !is.na(df$latitude))),'county']))
names(countycount)<-c('county','countycount')

df<-merge(df,zipcount,by='zipcode',all.x=TRUE)
df<-merge(df,citycount,by=c('city'),all.x=TRUE)
df<-merge(df,countycount,by=c('county'),all.x=TRUE)


df[which(df$zipcount>40),'modelgroup']<-df[which(df$zipcount>40),'zipcode']
df[which(df$citycount>80 & is.na(df$modelgroup)),'modelgroup']<-df[which(df$citycount>80 & is.na(df$modelgroup)),'city']
df[which(df$countycount>100 & is.na(df$modelgroup)),'modelgroup']<-df[which(df$countycount>100 & is.na(df$modelgroup)),'county']
df[which(is.na(df$modelgroup) | df$modelgroup == ''),'modelgroup']<-df[which(is.na(df$modelgroup)| df$modelgroup == ''),'state']

df$time<-df$year+df$month/12

for(group in sort(unique(df$modelgroup))) {
    print(paste(group,nrow(df[which(df$zipcode==group | df$city==group |df$county==group|df$state==group),]),sep='-'))
    if(nrow(df[which((df$zipcode == group | df$city == group | df$county == group | df$state == group) & !is.na(df$NIR_Score)),])==0 | is.na(sd(df[which((df$zipcode == group | df$city == group | df$county == group | df$state == group) & !is.na(df$NIR_Score)),'NIR_Score'])))
{df[which(df$modelgroup == group),'NIR_Score'] <- runif(nrow( df[which(df$modelgroup == group),]), 0, 1)}
    fit = gbm(log(rent) ~ bath + bed + sqft +NIR_Score + time,
              data = df[which(df$zipcode == group | df$city == group | df$county == group| df$state == group),],
              var.monotone = c(0,0,0,0,0),
              distribution = "gaussian", # see the help for other choices
              n.trees = 1000, # number of trees
              shrinkage = 0.01, # shrinkage or learning rate,# 0.001 to 0.1 usually work
              interaction.depth = 2, # 1: additive model, 2: two-way interactions, etc.
              bag.fraction = 0.5, # subsampling fraction, 0.5 is probably best
              train.fraction = 0.75, # fraction of data for training, # first train.fraction*N used for training
              n.minobsinnode = 5, # minimum total weight needed in each node
              cv.folds = 0, # do 3-fold cross-validation
              keep.data = FALSE, # keep a copy of the dataset with the object
              verbose = FALSE, # don't print out progress
              n.cores = 1)
              df[which(df$zipcode == group | df$city == group | df$county == group | df$state == group), 'fitted'] <- predict(fit,df[which(df$zipcode == group | df$city == group | df$county == group | df$state == group),])
  }

  df$pcnterr = (exp(df$fitted)-df$rent)/df$rent

  df<-df[which(df$pcnterr > mean(df$pcnterr)-2.5*sd(df$pcnterr) &
                 df$pcnterr < mean(df$pcnterr)+2.5*sd(df$pcnterr)  &
                 df$pcnterr < .75 & df$pcnterr>-.75),]
###subset columns for modeling:
df<-df[,c('property_identifier','state','county','city','zipcode','address','Source','property_type','sqft','bed','bath','halfbath','rent','garage','carspace','yearbuilt','numphotos','listingstatus','year','month','latitude','longitude','NIR_Score','NIR','medianprice','medianincome','collegegrads','whitecollar','schools','vacancy','hu_crime','HospitalDist','WalmartDist','StarbucksDist','pcnterr')]

write.table(df,paste("/home/data-analysis/DataScience/RentAVM/Input/Normalized_Input/AVM_2_2/","CleanRentTraining",unique(df$state),".txt",sep=""),sep='|',quote=T,row.names=F)
print(file)
}


















