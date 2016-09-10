

select distinct COUNTY  from HUMARKETPLACE_zipmapping wHERE HUMARKETPLACE = 'Los Angeles-Long Beach, CA PMSA'


Create  table kurtis_HPIPredictions_raw
(property_identifier varchar(200),
address  varchar(200),
zipcode varchar(20),
HUMarketPlace  varchar(200),
sqft numeric(12,2),
bed  numeric(12,2),
bath numeric(12,2),
raw_200000 numeric(25,15),
raw_200025 numeric(25,15),
raw_200050 numeric(25,15),
raw_200075 numeric(25,15),
raw_200100 numeric(25,15),
raw_200125 numeric(25,15),
raw_200150 numeric(25,15),
raw_200175 numeric(25,15),
raw_200200 numeric(25,15),
raw_200225 numeric(25,15),
raw_200250 numeric(25,15),
raw_200275 numeric(25,15),
raw_200300 numeric(25,15),
raw_200325 numeric(25,15),
raw_200350 numeric(25,15),
raw_200375 numeric(25,15),
raw_200400 numeric(25,15),
raw_200425 numeric(25,15),
raw_200450 numeric(25,15),
raw_200475 numeric(25,15),
raw_200500 numeric(25,15),
raw_200525 numeric(25,15),
raw_200550 numeric(25,15),
raw_200575 numeric(25,15),
raw_200600 numeric(25,15),
raw_200625 numeric(25,15),
raw_200650 numeric(25,15),
raw_200675 numeric(25,15),
raw_200700 numeric(25,15),
raw_200725 numeric(25,15),
raw_200750 numeric(25,15),
raw_200775 numeric(25,15),
raw_200800 numeric(25,15),
raw_200825 numeric(25,15),
raw_200850 numeric(25,15),
raw_200875 numeric(25,15),
raw_200900 numeric(25,15),
raw_200925 numeric(25,15),
raw_200950 numeric(25,15),
raw_200975 numeric(25,15),
raw_201000 numeric(25,15),
raw_201025 numeric(25,15),
raw_201050 numeric(25,15),
raw_201075 numeric(25,15),
raw_201100 numeric(25,15),
raw_201125 numeric(25,15),
raw_201150 numeric(25,15),
raw_201175 numeric(25,15),
raw_201200 numeric(25,15),
raw_201225 numeric(25,15),
raw_201250 numeric(25,15),
raw_201275 numeric(25,15),
raw_201300 numeric(25,15),
raw_201325 numeric(25,15),
raw_201350 numeric(25,15),
raw_201375 numeric(25,15),
raw_201400 numeric(25,15),
raw_201425 numeric(25,15),
raw_201450 numeric(25,15),
raw_201475 numeric(25,15),
raw_201500 numeric(25,15),
raw_201525 numeric(25,15),
raw_201550 numeric(25,15),
raw_201575 numeric(25,15),
raw_201600 numeric(25,15),
raw_201625 numeric(25,15));

copy kurtis_HPIPredictions_raw from '/opt/DataScience/HPI/Data/rawhpi_*' 
 DELIMITER '|' enclosed by '"'  REJECTMAX 0 ; 

---join on normal HUMarketPlace
select 


UPDATE kurtis_HPIPredictions_raw k
 SET HUMarketPlace=h.HUMarketPlace
 FROM HUMarketPlace_zipmapping h
 WHERE  k.zipcode=h.zipcode;
 



















---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:
---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:
---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:
---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:---------OUTLIER REMOVAL:

create  table kurtis_HPIPredictions_cleaned
as
select property_identifier,address,zipcode,HUMarketPlace,sqft,bed,bath,
case when raw_200100> mean+2*stddev or raw_200100<mean-2*stddev then null else raw_200100 end as raw_200100,
case when raw_200125> mean+2*stddev or raw_200125<mean-2*stddev then null else raw_200125 end as raw_200125,
case when raw_200150> mean+2*stddev or raw_200150<mean-2*stddev then null else raw_200150 end as raw_200150,
case when raw_200175> mean+2*stddev or raw_200175<mean-2*stddev then null else raw_200175 end as raw_200175,
case when raw_200200> mean+2*stddev or raw_200200<mean-2*stddev then null else raw_200200 end as raw_200200,
case when raw_200225> mean+2*stddev or raw_200225<mean-2*stddev then null else raw_200225 end as raw_200225,
case when raw_200250> mean+2*stddev or raw_200250<mean-2*stddev then null else raw_200250 end as raw_200250,
case when raw_200275> mean+2*stddev or raw_200275<mean-2*stddev then null else raw_200275 end as raw_200275,
case when raw_200300> mean+2*stddev or raw_200300<mean-2*stddev then null else raw_200300 end as raw_200300,
case when raw_200325> mean+2*stddev or raw_200325<mean-2*stddev then null else raw_200325 end as raw_200325,
case when raw_200350> mean+2*stddev or raw_200350<mean-2*stddev then null else raw_200350 end as raw_200350,
case when raw_200375> mean+2*stddev or raw_200375<mean-2*stddev then null else raw_200375 end as raw_200375,
case when raw_200400> mean+2*stddev or raw_200400<mean-2*stddev then null else raw_200400 end as raw_200400,
case when raw_200425> mean+2*stddev or raw_200425<mean-2*stddev then null else raw_200425 end as raw_200425,
case when raw_200450> mean+2*stddev or raw_200450<mean-2*stddev then null else raw_200450 end as raw_200450,
case when raw_200475> mean+2*stddev or raw_200475<mean-2*stddev then null else raw_200475 end as raw_200475,
case when raw_200500> mean+2*stddev or raw_200500<mean-2*stddev then null else raw_200500 end as raw_200500,
case when raw_200525> mean+2*stddev or raw_200525<mean-2*stddev then null else raw_200525 end as raw_200525,
case when raw_200550> mean+2*stddev or raw_200550<mean-2*stddev then null else raw_200550 end as raw_200550,
case when raw_200575> mean+2*stddev or raw_200575<mean-2*stddev then null else raw_200575 end as raw_200575,
case when raw_200600> mean+2*stddev or raw_200600<mean-2*stddev then null else raw_200600 end as raw_200600,
case when raw_200625> mean+2*stddev or raw_200625<mean-2*stddev then null else raw_200625 end as raw_200625,
case when raw_200650> mean+2*stddev or raw_200650<mean-2*stddev then null else raw_200650 end as raw_200650,
case when raw_200675> mean+2*stddev or raw_200675<mean-2*stddev then null else raw_200675 end as raw_200675,
case when raw_200700> mean+2*stddev or raw_200700<mean-2*stddev then null else raw_200700 end as raw_200700,
case when raw_200725> mean+2*stddev or raw_200725<mean-2*stddev then null else raw_200725 end as raw_200725,
case when raw_200750> mean+2*stddev or raw_200750<mean-2*stddev then null else raw_200750 end as raw_200750,
case when raw_200775> mean+2*stddev or raw_200775<mean-2*stddev then null else raw_200775 end as raw_200775,
case when raw_200800> mean+2*stddev or raw_200800<mean-2*stddev then null else raw_200800 end as raw_200800,
case when raw_200825> mean+2*stddev or raw_200825<mean-2*stddev then null else raw_200825 end as raw_200825,
case when raw_200850> mean+2*stddev or raw_200850<mean-2*stddev then null else raw_200850 end as raw_200850,
case when raw_200875> mean+2*stddev or raw_200875<mean-2*stddev then null else raw_200875 end as raw_200875,
case when raw_200900> mean+2*stddev or raw_200900<mean-2*stddev then null else raw_200900 end as raw_200900,
case when raw_200925> mean+2*stddev or raw_200925<mean-2*stddev then null else raw_200925 end as raw_200925,
case when raw_200950> mean+2*stddev or raw_200950<mean-2*stddev then null else raw_200950 end as raw_200950,
case when raw_200975> mean+2*stddev or raw_200975<mean-2*stddev then null else raw_200975 end as raw_200975,
case when raw_201000> mean+2*stddev or raw_201000<mean-2*stddev then null else raw_201000 end as raw_201000,
case when raw_201025> mean+2*stddev or raw_201025<mean-2*stddev then null else raw_201025 end as raw_201025,
case when raw_201050> mean+2*stddev or raw_201050<mean-2*stddev then null else raw_201050 end as raw_201050,
case when raw_201075> mean+2*stddev or raw_201075<mean-2*stddev then null else raw_201075 end as raw_201075,
case when raw_201100> mean+2*stddev or raw_201100<mean-2*stddev then null else raw_201100 end as raw_201100,
case when raw_201125> mean+2*stddev or raw_201125<mean-2*stddev then null else raw_201125 end as raw_201125,
case when raw_201150> mean+2*stddev or raw_201150<mean-2*stddev then null else raw_201150 end as raw_201150,
case when raw_201175> mean+2*stddev or raw_201175<mean-2*stddev then null else raw_201175 end as raw_201175,
case when raw_201200> mean+2*stddev or raw_201200<mean-2*stddev then null else raw_201200 end as raw_201200,
case when raw_201225> mean+2*stddev or raw_201225<mean-2*stddev then null else raw_201225 end as raw_201225,
case when raw_201250> mean+2*stddev or raw_201250<mean-2*stddev then null else raw_201250 end as raw_201250,
case when raw_201275> mean+2*stddev or raw_201275<mean-2*stddev then null else raw_201275 end as raw_201275,
case when raw_201300> mean+2*stddev or raw_201300<mean-2*stddev then null else raw_201300 end as raw_201300,
case when raw_201325> mean+2*stddev or raw_201325<mean-2*stddev then null else raw_201325 end as raw_201325,
case when raw_201350> mean+2*stddev or raw_201350<mean-2*stddev then null else raw_201350 end as raw_201350,
case when raw_201375> mean+2*stddev or raw_201375<mean-2*stddev then null else raw_201375 end as raw_201375,
case when raw_201400> mean+2*stddev or raw_201400<mean-2*stddev then null else raw_201400 end as raw_201400,
case when raw_201425> mean+2*stddev or raw_201425<mean-2*stddev then null else raw_201425 end as raw_201425,
case when raw_201450> mean+2*stddev or raw_201450<mean-2*stddev then null else raw_201450 end as raw_201450,
case when raw_201475> mean+2*stddev or raw_201475<mean-2*stddev then null else raw_201475 end as raw_201475,
case when raw_201500> mean+2*stddev or raw_201500<mean-2*stddev then null else raw_201500 end as raw_201500,
case when raw_201525> mean+2*stddev or raw_201525<mean-2*stddev then null else raw_201525 end as raw_201525,
case when raw_201550> mean+2*stddev or raw_201550<mean-2*stddev then null else raw_201550 end as raw_201550,
case when raw_201575> mean+2*stddev or raw_201575<mean-2*stddev then null else raw_201575 end as raw_201575,
mean,stddev
from 
(
select m.*,sqrt(((raw_200100-mean)^2+(raw_200125-mean)^2+(raw_200150-mean)^2+(raw_200175-mean)^2+(raw_200200-mean)^2+(raw_200225-mean)^2+
(raw_200250-mean)^2+(raw_200275-mean)^2+(raw_200300-mean)^2+(raw_200325-mean)^2+(raw_200350-mean)^2+(raw_200375-mean)^2+
(raw_200400-mean)^2+(raw_200425-mean)^2+(raw_200450-mean)^2+(raw_200475-mean)^2+(raw_200500-mean)^2+(raw_200525-mean)^2+
(raw_200550-mean)^2+(raw_200575-mean)^2+(raw_200600-mean)^2+(raw_200625-mean)^2+(raw_200650-mean)^2+(raw_200675-mean)^2+
(raw_200700-mean)^2+(raw_200725-mean)^2+(raw_200750-mean)^2+(raw_200775-mean)^2+(raw_200800-mean)^2+(raw_200825-mean)^2+
(raw_200850-mean)^2+(raw_200875-mean)^2+(raw_200900-mean)^2+(raw_200925-mean)^2+(raw_200950-mean)^2+(raw_200975-mean)^2+
(raw_201000-mean)^2+(raw_201025-mean)^2+(raw_201050-mean)^2+(raw_201075-mean)^2+(raw_201100-mean)^2+(raw_201125-mean)^2+
(raw_201150-mean)^2+(raw_201175-mean)^2+(raw_201200-mean)^2+(raw_201225-mean)^2+(raw_201250-mean)^2+(raw_201275-mean)^2+
(raw_201300-mean)^2+(raw_201325-mean)^2+(raw_201350-mean)^2+(raw_201375-mean)^2+(raw_201400-mean)^2+(raw_201425-mean)^2+
(raw_201450-mean)^2+(raw_201475-mean)^2+(raw_201500-mean)^2+(raw_201525-mean)^2+(raw_201550-mean)^2+(raw_201575-mean)^2)/60) as stddev
from
(
    select k.*,mean from kurtis_HPIPredictions k
    left join (select property_identifier, 
              (raw_200100+raw_200125+raw_200150+raw_200175+raw_200200+raw_200225+raw_200250+raw_200275+raw_200300+
              raw_200325+raw_200350+raw_200375+raw_200400+raw_200425+raw_200450+raw_200475+raw_200500+raw_200525+
              raw_200550+raw_200575+raw_200600+raw_200625+raw_200650+raw_200675+raw_200700+raw_200725+raw_200750+
              raw_200775+raw_200800+raw_200825+raw_200850+raw_200875+raw_200900+raw_200925+raw_200950+raw_200975+
              raw_201000+raw_201025+raw_201050+raw_201075+raw_201100+raw_201125+raw_201150+raw_201175+raw_201200+
              raw_201225+raw_201250+raw_201275+raw_201300+raw_201325+raw_201350+raw_201375+raw_201400+raw_201425+
              raw_201450+raw_201475+raw_201500+raw_201525+raw_201550+raw_201575)/60 as mean from kurtis_HPIPredictions) m
    on k.property_identifier=m.property_identifier
) m
) zall


select count(1) from  kurtis_HPIPredictions_cleaned  

select count(1) from  kurtis_HPIRolledUp



------put on Tony's AVM for 2016Q1:
create table kurtis_HPIPredictions_2001
as
select p.*, hu_price as raw_201600
from (select * from kurtis_HPIPredictions order by property_identifier) p
left join (select property_identifier, hu_price from HU_AVM_Predicted order by property_identifier) h
on p.property_identifier=h.property_identifier

drop table kurtis_HPIPredictions

alter table kurtis_HPIPredictions_2016 rename to kurtis_HPIPredictions

select * from kurtis_HPIPredictions where zipcode = '92648' limit 400

--set to null f any value is 2 times the sd of values



select min(raw_200100),min(raw_200300) from kurtis_HPIPredictions


drop table kurtis_HPIPredictions_AVMadjusted

---aggregate to zipodes
---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  
---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  
---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  
---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  
---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  ---ROLL UP ----  
-----RUN THIS FOR EVERY YEAR!!! ON THE SERVER I RAN ALL OF THESE COD:
create table kurtis_HPIraw_neighborhoodlevel_2001
as
select distinct HUMarketPlace,zipcode as ID, 'zip' as source,
    percentile_cont(.5) within group (order by adjhpi_200100) over (partition by HUMarketPlace,zipcode) as hpi200100,
    percentile_cont(.5) within group (order by adjhpi_200125) over (partition by HUMarketPlace,zipcode) as hpi200125,
    percentile_cont(.5) within group (order by adjhpi_200150) over (partition by HUMarketPlace,zipcode) as hpi200150,
    percentile_cont(.5) within group (order by adjhpi_200175) over (partition by HUMarketPlace,zipcode) as hpi200175,  
  from  kurtis_HPIPredictions 
union
select HUMarketPlace,nid as ID, 'neighborhood' as source,
    percentile_cont(.5) within group (order by adjhpi_200100) over (partition by HUMarketPlace,nid) as hpi200100,
    percentile_cont(.5) within group (order by adjhpi_200125) over (partition by HUMarketPlace,nid) as hpi200125,
    percentile_cont(.5) within group (order by adjhpi_200150) over (partition by HUMarketPlace,nid) as hpi200150,
    percentile_cont(.5) within group (order by adjhpi_200175) over (partition by HUMarketPlace,nid) as hpi200175,
  from  kurtis_HPIPredictions_cleaned k
right join (select property_identifier,nid from property_maponics_mapping where nid is not null) pm
on k.property_identifier=pm.property_identifier

---THEN MERGE ALL THE YEARS TOGETHER:
create table kurtis_HPIRolledup
as
select k15.HUMarketPlace,k15.ID,k15.source,
k1.hpi200100,
k1.hpi200125,
k1.hpi200150,
k1.hpi200175,
k2.hpi200200,
k2.hpi200225,
k2.hpi200250,
k2.hpi200275,
k3.hpi200300,
k3.hpi200325,
k3.hpi200350,
k3.hpi200375,
k4.hpi200400,
k4.hpi200425,
k4.hpi200450,
k4.hpi200475,
k5.hpi200500,
k5.hpi200525,
k5.hpi200550,
k5.hpi200575,
k6.hpi200600,
k6.hpi200625,
k6.hpi200650,
k6.hpi200675,
k7.hpi200700,
k7.hpi200725,
k7.hpi200750,
k7.hpi200775,
k8.hpi200800,
k8.hpi200825,
k8.hpi200850,
k8.hpi200875,
k9.hpi200900,
k9.hpi200925,
k9.hpi200950,
k9.hpi200975,
k10.hpi201000,
k10.hpi201025,
k10.hpi201050,
k10.hpi201075,
k11.hpi201100,
k11.hpi201125,
k11.hpi201150,
k11.hpi201175,
k12.hpi201200,
k12.hpi201225,
k12.hpi201250,
k12.hpi201275,
k13.hpi201300,
k13.hpi201325,
k13.hpi201350,
k13.hpi201375,
k14.hpi201400,
k14.hpi201425,
k14.hpi201450,
k14.hpi201475,
k15.hpi201500,
k15.hpi201525,
k15.hpi201550,
k15.hpi201575
from kurtis_HPIRolledup_2015 k15
 join kurtis_HPIRolledup_2001 k1
on k15.HUMarketPlace=k1.HUMarketPlace and k15.ID=k1.ID and k15.source=k1.source

 join kurtis_HPIRolledup_2002 k2
on k15.HUMarketPlace=k2.HUMarketPlace and k15.ID=k2.ID and k15.source=k2.source

 join kurtis_HPIRolledup_2003 k3
on k15.HUMarketPlace=k3.HUMarketPlace and k15.ID=k3.ID and k15.source=k3.source

 join kurtis_HPIRolledup_2004 k4
on k15.HUMarketPlace=k4.HUMarketPlace and k15.ID=k4.ID and k15.source=k4.source

 join kurtis_HPIRolledup_2005 k5
on k15.HUMarketPlace=k5.HUMarketPlace and k15.ID=k5.ID and k15.source=k5.source

 join kurtis_HPIRolledup_2006 k6
on k15.HUMarketPlace=k6.HUMarketPlace and k15.ID=k6.ID and k15.source=k6.source

 join kurtis_HPIRolledup_2007 k7
on k15.HUMarketPlace=k7.HUMarketPlace and k15.ID=k7.ID and k15.source=k7.source

 join kurtis_HPIRolledup_2008 k8
on k15.HUMarketPlace=k8.HUMarketPlace and k15.ID=k8.ID and k15.source=k8.source

 join kurtis_HPIRolledup_2009 k9
on k15.HUMarketPlace=k9.HUMarketPlace and k15.ID=k9.ID and k15.source=k9.source

 join kurtis_HPIRolledup_2010 k10
on k15.HUMarketPlace=k10.HUMarketPlace and k15.ID=k10.ID and k15.source=k10.source

 join kurtis_HPIRolledup_2011 k11
on k15.HUMarketPlace=k11.HUMarketPlace and k15.ID=k11.ID and k15.source=k11.source

 join kurtis_HPIRolledup_2012 k12
on k15.HUMarketPlace=k12.HUMarketPlace and k15.ID=k12.ID and k15.source=k12.source

 join kurtis_HPIRolledup_2013 k13
on k15.HUMarketPlace=k13.HUMarketPlace and k15.ID=k13.ID and k15.source=k13.source

 join kurtis_HPIRolledup_2014 k14
on k15.HUMarketPlace=k14.HUMarketPlace and k15.ID=k14.ID and k15.source=k14.source



create table kurtis_HPIRolledup2
as
select k.*,case when n.MedianHUPriceAVM is not null then n.MedianHUPriceAVM else z.MedianHUPriceAVM end as hpi201600
from kurtis_HPIRolledUp k
left join (select *,'neighborhood' as source from eden_avm_nbhd) n
on k.ID=n.neighborhoodid and k.source=n.source
left join (select *,'zip' as source from eden_avm_zip) z
on k.ID=z.zipcode and k.source=z.source
limit 500

----- PULL IT OFF AND SMOOTH IT: write local R code:
----  IT HAS BEEN SMOOTHED AND IS BACK ON THE DATABASE -----  ----  IT HAS BEEN SMOOTHED AND IS BACK ON THE DATABASE ---------  IT HAS BEEN SMOOTHED AND IS BACK ON THE DATABASE -----
select count(1) from kurtis_HPIRolledUp_smooth  limit 500

create  table kurtis_HPIRolledUp
as
select a.HUMarketPlace,a.ID,a.source,
case when b.num is not null then b.num else c.num end as PropertyCount,
hpi200100,hpi200125,hpi200150,hpi200175,hpi200200,hpi200225,hpi200250,hpi200275,
hpi200300,hpi200325,hpi200350,hpi200375,hpi200400,hpi200425,hpi200450,hpi200475,
hpi200500,hpi200525,hpi200550,hpi200575,hpi200600,hpi200625,hpi200650,hpi200675,
hpi200700,hpi200725,hpi200750,hpi200775,hpi200800,hpi200825,hpi200850,hpi200875,
hpi200900,hpi200925,hpi200950,hpi200975,hpi201000,hpi201025,hpi201050,hpi201075,
hpi201100,hpi201125,hpi201150,hpi201175,hpi201200,hpi201225,hpi201250,hpi201275,
hpi201300,hpi201325,hpi201350,hpi201375,hpi201400,hpi201425,hpi201450,hpi201475,
hpi201500,hpi201525,hpi201550,hpi201575, 
case when abs(hpi201575-hpi201600)/hpi201575 >.25 then (hpi201575+hpi201600)/2
     else  hpi201600 end as hpi201600
 from kurtis_HPIRolledUp_smooth a
left join (select nid as neighborhoodid, count(1) as num,'neighborhood' as source from property_maponics_mapping group by nid) b
  on a.ID=b.neighborhoodid and a.source=b.source
left join (select zip as zipcode,count(1) as num,'zip' as source from property_maponics_mapping group by zip) c
  on a.ID=c.zipcode and a.source=c.source
   

select * from kurtis_HPIRolledUp limit 500

---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  
---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  
---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  
---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  
---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  ---ACCURACY ----  




select * from properties_salesdata  limit 5
select count(1),deed_absentee_indicator_code from properties_salesdata group by deed_absentee_indicator_code

-----Remove if outside 4 standard deviations:


select p.* from (
select property_identifier from property_maponics_mapping where nid = '174949') x
left join kurtis_HPIPredictions p
on x.property_identifier=p.property_identifier





selec



select year,sum(within5)/count(within5) as err5,
       sum(within10)/count(within10) as err10,
       sum(within20)/count(within20) as err20 from kurtis_HPIPred_SaleAdjustedbyAVMQC
         where HPIPrediction is not null
         group by year







