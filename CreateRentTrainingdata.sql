----THIS WILL CREATE THE SEMI-CLEANED, DE-DUPED, CASTED Training DATA

Create Table kurtis_All_MLS_Integration (
property_id varchar(100), 
propertysource varchar(100), 
type varchar(100), 
propertyaddress varchar(100), 
city varchar(100), 
state varchar(100), 
zipcode varchar(10), 
bed varchar(10),
bath varchar(20),
sqft varchar(100), 
yearbuilt varchar(100), 
saleprice varchar(100), 
rent varchar(100), 
lotsize varchar(100), 
carspace varchar(100), 
mlsnumber varchar(100), 
propertytypeorstatus varchar(100), 
unit_number varchar(100), 
lot_measure varchar(100), 
numphotos varchar(100), 
listing_type varchar(100), 
listingstatus varchar(100), 
listing_date varchar(100), 
latitude varchar(100), 
longitude varchar(100), 
listing_class varchar(100), 
property_type varchar(100), 
date_created varchar(100), 
date_modified varchar(100), 
date_mls_modified varchar(100), 
m_halfBathCount varchar(100)
);

Copy  kurtis_All_MLS_Integration From '/home/data-analysis/DataScience/PriceAVM/Data/MLS_Raw_Data/AVM_MLSIntegrationData_20160405.csv' 
Delimiter '|' Enclosed By '"' Skip 1 Rejectmax 0 Null as 'NULL';


------------------------------------------------- Copy the production table 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
Create  Table kurtis_All_MLS_Production (
	property_id varchar(100), 
propertysource varchar(100), 
type varchar(100), 
propertyaddress varchar(100), 
city varchar(100), 
state varchar(100), 
zipcode varchar(10), 
bed varchar(10),
bath varchar(20),
sqft varchar(100), 
yearbuilt varchar(100), 
saleprice varchar(100), 
rent varchar(100), 
lotsize varchar(100), 
carspace varchar(100), 
mlsnumber varchar(100), 
propertytypeorstatus varchar(100), 
unit_number varchar(100), 
lot_measure varchar(100), 
numphotos varchar(100), 
listing_type varchar(100), 
listingstatus varchar(100), 
listing_date varchar(100), 
latitude varchar(100), 
longitude varchar(100), 
listing_class varchar(100), 
property_type varchar(100), 
date_created varchar(100), 
date_modified varchar(100), 
date_mls_modified varchar(100), 
m_halfBathCount varchar(100)  
);


Copy kurtis_All_MLS_Production From '/home/data-analysis/DataScience/PriceAVM/Data/MLS_Raw_Data//AVM_MLSProductionData_20160405.csv' 
Delimiter '|'  enclosed by '"' Skip 1 Rejectmax 0 null as 'NULL';

---MLS
select distinct type,property_type from kurtis_All_MLS_Production limit 500

---SHELL 1---SHELL 1---SHELL 1---SHELL 1---SHELL 1---SHELL 1---SHELL 1---SHELL 1---SHELL 1---SHELL 1---SHELL 1---SHELL 1---SHELL 1

----MLS Production

select property_id as property_identifier, 
'MLS Feed' as Source, 
propertyaddress|| ' ' || unit_number as address,
zipcode,
Case When (Upper(property_type) Like ('%SINGLE FAMILY%') and Upper(property_type) Not Like '%SHARED%')
                         Or Upper(property_type) Like ('%FREE STANDING%') 
                         Or Upper(property_type) Like ('%FREESTANDING%')
                         Or (Upper(type) Like ('%SINGLE%') and upper(Property_type) !='MANUFACTURED')
                         Or Upper(property_type) Like ('%SNGL%') 
                         Or Upper(property_type) Like ('%HOUSE%') 
                         --Or Upper(property_type) Like ('%RESIDENTIAL%') 
                         Or Upper(property_type) Like ('%RENTAL%') 
                       Then 'SFR'
                       When Upper(property_type) Like ('%DUPLEX%') Or Upper(property_type) Like ('%CLUSTER%') Or Upper(property_type) Like ('%TOWNHOUSE%') 
                         Or Upper(property_type) Like ('%TOWNHOME%') Or Upper(property_type) Like ('%MULTI%') Or Upper(property_type) Like ('%TRIPLEX%') 
                         Or Upper(property_type) Like ('%FOURPLEX%') Or Upper(property_type) Like ('%MANUFACTURED%') Or Upper(property_type) Like ('%MODULAR%')
                         Or Upper(property_type) Like ('%MUL-MULTIPLE SINGLE UNITS%')   
                         Or Upper(property_type) Like ('%SHARED%')                    
                       Then 'Cluster'
                       When Upper(property_type) Like ('%CONDOMINIUM%')
                         Or Upper(property_type) Like ('%CONDO%') 
                         Or Upper(property_type) Like ('%LOW-RISE%')
                         Or Upper(property_type) Like ('%MID-RISE%')
                         Or Upper(property_type) Like ('%MULTI FAMILY%')
                         Or Upper(type) Like ('%MULTI FAMILY%')
                         Or upper(type) Like ('%APART%')
                         Or upper(type) Like ('%CONDO%')
                       Then 'Condo' 
                       when upper(type) Like ('%SINGLE%')
                         Or upper(type) Like ('%SFH%')
                       Then 'SFR'           
                       Else Null end as property_type,
case when Upper(property_type) Like ('%DUPLEX%') then 'Duplex'
     when Upper(property_type) Like ('%TRIPLEX%') then 'Triplex'
     when Upper(property_type) Like ('%FOURPLEX%') then 'Fourplex'
     else NULL  end as clustertype,
case when sqft = '' or sqft = 'NULL' or sqft is NULL or sqft = '0.00' or sqft = '0' then NULL
    else sqft end as sqft,
    bed, bath,m_halfBathCount as halfbath, 
case when rent is not NULL and rent !='NULL' and rent!='' then cast(rent as numeric)
     when saleprice !='NULL' and saleprice is not null and cast(saleprice as numeric) <10000 then cast(saleprice as numeric)
     else null end as rent,
case when upper(carspace) like '%GARAGE%' 
       Or upper(carspace) like '%CARPORT%' then 1
     when carspace is not null then 0
                          else null end as garage,
Case When Upper(carspace) Like ('%0%') 
                         Or Upper(carspace) Like ('%ZERO%')
                         Or Upper(carspace) Like ('%NO%') 
                         Or Upper(carspace) Like ('%PAD%') 
                         Or Upper(carspace) Like ('%UNPAVED DRIVE%') 
                         Or Upper(carspace) Like ('%STREET%')
                       Then 0
                       When Upper(carspace) Like ('%1%') 
                         Or Upper(carspace) Like ('%ONE%') 
                       Then 1
                       When Upper(carspace) Like ('%2%') 
                         Or Upper(carspace) Like ('%TWO%') --Or Upper(carspace) Like ('%DETACHED%')
                       Then 2
                       When Upper(carspace) Like ('%3%') 
                         Or Upper(carspace) Like ('%THREE%') 
                       Then 3
                       When Upper(carspace) Like ('%4%') 
                         Or Upper(carspace) Like ('%FOUR%') 
                       Then 4
                       When Upper(carspace) Like ('%5%') 
                         Or Upper(carspace) Like ('%FIVE%') 
                       Then 5
                       When Upper(carspace) Like ('%6%') 
                         Or Upper(carspace) Like ('%SIX%') 
                       Then 6
                       When Upper(carspace) Like ('%7%') 
                         Or Upper(carspace) Like ('%SEVEN%') 
                       Then 7 
                       When Upper(carspace) Like ('%8%') 
                         Or Upper(carspace) Like ('%EIGHT%') 
                       Then 8     
                       When Upper(carspace) Like ('%9%') 
                         Or Upper(carspace) Like ('%NINE%') 
                       Then 9                 
                     Else 1
                  End As carspace,
case when yearbuilt in ('','NULL','U') then NULL
     when cast(yearbuilt as numeric) <100 and cast(yearbuilt as numeric)>16 then '19'||yearbuilt
     when cast(yearbuilt as numeric) <16 and cast(yearbuilt as numeric)>0 then '20'||yearbuilt
     when (cast(yearbuilt as numeric)>2016 or cast(yearbuilt as numeric) = -1) then 'NULL'
     when (cast(yearbuilt as numeric)>1000 and cast(yearbuilt as numeric)<1700) then 'NULL'
     else yearbuilt
     end as yearbuilt,
case when (numphotos = 'NULL' or numphotos = '') then NULL
     when cast(numphotos as numeric) > 0 and cast(numphotos as numeric) <10 then 5
     when cast(numphotos as numeric) >=10 and cast(numphotos as numeric) <20 then 15
     when cast(numphotos as numeric) >=20  then 25
     else null end as numphotos,
case when listingstatus in ('Sold','Leased','RENTED','SOLD','Rented') then 'Leased/Sold'
     when listingstatus in ('Active','Active Option Contract','Active W Contingency','Active Option','Pending Continue to Show','Active Contingent','Backup Offer') then 'Active'
     when listingstatus in ('Expired','Pending','Withdrawn','Cancelled','Cancel','Option Pending','Terminated','Temp Off Market',
     'Expired Cancelled','Withdrawn, Withdrawn Temp','Released','Deleted','Pending/Expired','Pending SB','Active Kick Out') then 'Withdrawn'
     else null end as listingstatus,
extract(year from cast(date_mls_modified as datetime)) as year,
extract(month from cast(date_mls_modified as datetime)) as month,
case when latitude = '0' or latitude = '' or latitude = 'NULL' or  cast(latitude as numeric)=0 then NULL
     else latitude end as latitude,
case when longitude = '0' or longitude = '' or longitude = 'NULL' or cast(longitude as numeric)=0 then NULL
     else longitude end as longitude
into kurtis_shell1
from kurtis_All_MLS_Production 

select count(1),clustertype from kurtis_shell1 group by clustertype  limit 50

---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2---SHELL 2

-----MLS INTEGRATION:

select property_id as property_identifier, 
'MLS Feed' as Source, 
propertyaddress|| ' ' || unit_number as address,
zipcode,
Case When (Upper(property_type) Like ('%SINGLE FAMILY%') and Upper(property_type) Not Like '%SHARED%')
                         Or Upper(property_type) Like ('%FREE STANDING%') 
                         Or Upper(property_type) Like ('%FREESTANDING%')
                         Or (Upper(type) Like ('%SINGLE%') and upper(Property_type) !='MANUFACTURED')
                         Or Upper(property_type) Like ('%SNGL%') 
                         Or Upper(property_type) Like ('%HOUSE%') 
                         --Or Upper(property_type) Like ('%RESIDENTIAL%') 
                         Or Upper(property_type) Like ('%RENTAL%') 
                       Then 'SFR'
                       When Upper(property_type) Like ('%DUPLEX%')
                         Or Upper(property_type) Like ('%CLUSTER%') 
                         Or Upper(property_type) Like ('%TOWNHOUSE%') 
                         Or Upper(property_type) Like ('%TOWNHOME%') 
                         Or Upper(property_type) Like ('%MULTI%') 
                         Or Upper(property_type) Like ('%TRIPLEX%') 
                         Or Upper(property_type) Like ('%FOURPLEX%')  
                         Or Upper(property_type) Like ('%MANUFACTURED%')
                         Or Upper(property_type) Like ('%MODULAR%')
                         Or Upper(property_type) Like ('%MUL-MULTIPLE SINGLE UNITS%')   
                         Or Upper(property_type) Like ('%SHARED%')                    
                       Then 'Cluster'
                       When Upper(property_type) Like ('%CONDOMINIUM%')
                         Or Upper(property_type) Like ('%CONDO%') 
                         Or Upper(property_type) Like ('%LOW-RISE%')
                         Or Upper(property_type) Like ('%MID-RISE%')
                         Or Upper(property_type) Like ('%MULTI FAMILY%')
                         Or Upper(type) Like ('%MULTI FAMILY%')
                         Or upper(type) Like ('%APART%')
                         Or upper(type) Like ('%CONDO%')
                       Then 'Condo' 
                       when upper(type) Like ('%SINGLE%')
                         Or upper(type) Like ('%SFH%')
                       Then 'SFR'           
                       Else Null end as property_type,
case when Upper(property_type) Like ('%DUPLEX%') then 'Duplex'
     when Upper(property_type) Like ('%TRIPLEX%') then 'Triplex'
     when Upper(property_type) Like ('%FOURPLEX%') then 'Fourplex'
     else NULL  end as clustertype,
case when sqft = '' or sqft = 'NULL' or sqft is NULL or sqft = '0.00' or sqft = '0' then NULL
    else sqft end as sqft
,bed, bath,m_halfBathCount as halfbath, 
case when rent is not NULL and rent !='NULL' and rent!='' then cast(rent as numeric)
     when saleprice !='NULL' and saleprice is not null and cast(saleprice as numeric) <10000 then cast(saleprice as numeric)
     else null end as rent,
case when upper(carspace) like '%GARAGE%' 
       Or upper(carspace) like '%CARPORT%' then 1
     when carspace is not null then 0
                          else null end as garage,
Case When Upper(carspace) Like ('%0%') 
                         Or Upper(carspace) Like ('%ZERO%')
                         Or Upper(carspace) Like ('%NO%') 
                         Or Upper(carspace) Like ('%PAD%') 
                         Or Upper(carspace) Like ('%UNPAVED DRIVE%') 
                         Or Upper(carspace) Like ('%STREET%')
                       Then 0
                       When Upper(carspace) Like ('%1%') 
                         Or Upper(carspace) Like ('%ONE%') 
                       Then 1
                       When Upper(carspace) Like ('%2%') 
                         Or Upper(carspace) Like ('%TWO%') --Or Upper(carspace) Like ('%DETACHED%')
                       Then 2
                       When Upper(carspace) Like ('%3%') 
                         Or Upper(carspace) Like ('%THREE%') 
                       Then 3
                       When Upper(carspace) Like ('%4%') 
                         Or Upper(carspace) Like ('%FOUR%') 
                       Then 4
                       When Upper(carspace) Like ('%5%') 
                         Or Upper(carspace) Like ('%FIVE%') 
                       Then 5
                       When Upper(carspace) Like ('%6%') 
                         Or Upper(carspace) Like ('%SIX%') 
                       Then 6
                       When Upper(carspace) Like ('%7%') 
                         Or Upper(carspace) Like ('%SEVEN%') 
                       Then 7
                       When Upper(carspace) Like ('%8%') 
                         Or Upper(carspace) Like ('%EIGHT%') 
                       Then 8     
                       When Upper(carspace) Like ('%9%') 
                         Or Upper(carspace) Like ('%NINE%') 
                       Then 9                 
                     Else 1
                  End As carspace,
case when yearbuilt in ('','NULL','U') then NULL
     when cast(yearbuilt as numeric) <100 and cast(yearbuilt as numeric)>16 then '19'||yearbuilt
     when cast(yearbuilt as numeric) <16 and cast(yearbuilt as numeric)>0 then '20'||yearbuilt
     when (cast(yearbuilt as numeric)>2016 or cast(yearbuilt as numeric) = -1) then 'NULL'
     when (cast(yearbuilt as numeric)>1000 and cast(yearbuilt as numeric)<1700) then 'NULL'
     else yearbuilt
     end as yearbuilt,
case when (numphotos = 'NULL' or numphotos = '') then NULL
     when cast(numphotos as numeric) > 0 and cast(numphotos as numeric) <10 then 5
     when cast(numphotos as numeric) >=10 and cast(numphotos as numeric) <20 then 15
     when cast(numphotos as numeric) >=20  then 25
     else null end as numphotos,
case when listingstatus in ('Sold','Leased','RENTED','SOLD','Rented') then 'Leased/Sold'
     when listingstatus in ('Active','Active Option Contract','Active W Contingency','Active Option','Pending Continue to Show','Active Contingent','Backup Offer') then 'Active'
     when listingstatus in ('Expired','Pending','Withdrawn','Cancelled','Cancel','Option Pending','Terminated','Temp Off Market',
     'Expired Cancelled','Withdrawn, Withdrawn Temp','Released','Deleted','Pending/Expired','Pending SB','Active Kick Out') then 'Withdrawn'
     else null end as listingstatus,
extract(year from cast(date_mls_modified as datetime)) as year,
extract(month from cast(date_mls_modified as datetime)) as month,
case when latitude = '0' or latitude = '' or latitude = 'NULL' or cast(latitude as numeric)=0 then NULL
     else latitude end as latitude,
case when longitude = '0' or longitude = '' or longitude = 'NULL' or cast(longitude as numeric)=0 then NULL
     else longitude end as longitude
into kurtis_shell2
from kurtis_All_MLS_Integration 

select count(1),clustertype from kurtis_shell2 group by clustertype  limit 50

----SHELL 3----SHELL 3----SHELL 3----SHELL 3----SHELL 3----SHELL 3----SHELL 3----SHELL 3----SHELL 3----SHELL 3----SHELL 3----SHELL 3

-----BPO

select NULL as property_identifier,
case when upper(SourceSheet) like '%CRAIGSLIST%' then 'BPO-Craigslist'
     when upper(SourceSheet) like '%ZILLOW%' then 'BPO-Zillow'
     else 'BPO' end as source,
address,zip as zipcode,
case when upper(hometype) in (' SFR','COTTAGE','HOUSE','SFR','SFR ','SINGLE FAMILY') then 'SFR'
     when upper(hometype) in ('APARTMENT ','APARTMENT','APARTMENTT','CONDO','CONDO ','1') then 'Condo'
     when upper(hometype) in ('DUPLEX','DUPLEX ','FLAT','TOWNHOUSE','TOWNHOUSE ') then 'Cluster'
     else 'SFR' end as property_type,
case when upper(hometype) in  ( 'DUPLEX','DUPLEX ')  then 'Duplex'
     when upper(hometype) in  ( 'TRIPLEX','TRIPLEX ')  then 'Triplex'
     when upper(hometype) in  ( 'FOURPLEX','QUADPLEX')  then 'Fourplex'
     else NULL end as clustertype,
cast(sqft as varchar), beds as bed, 
case when baths like '%1 %' or baths like '%split%' then '1' 
    when baths is not NULL and baths !='' and baths !='1  ' then cast(floor(cast(baths as numeric)) as varchar)
    end as bath,
case when baths like '%1 %' or baths like '%split%' then '0' 
    when baths is not NULL and baths !='' and baths !='1  ' then cast(round((cast(baths as numeric)- floor(cast(baths as numeric)))*2) as varchar)
    end as halfbath,
rent,
case when upper(Garage) like '%GARAGE%' then 1
     when upper(Garage) like '%CARPORT%' then 1
     when Garage is not null then 0
     else NULL end as garage,
case when upper(Garage) like '%OFF%' or upper(Garage) like '%0%' or upper(Garage) like '%ON ST%' then 0
     when upper(Garage) like '%1 SPACE%' or upper(Garage) like '%CARPORT%' then 1
     when upper(Garage) like '%2 SPACES%' or upper(Garage) like '%4%' then 2
     when upper(Garage) like '%GARAGE%' then 2
     else 2 end as carspace,
cast(yrbuilt as varchar) as yearbuilt,
cast(NULL as integer) as numphotos, 'Active' as listingstatus,
cast(substr(date,6,10) as numeric) as year,
case when substr(date,3,3) = 'JAN' then 1
     when substr(date,3,3) = 'FEB' then 2
     when substr(date,3,3) = 'MAR' then 3
     when substr(date,3,3) = 'APR' then 4
     when substr(date,3,3) = 'MAY' then 5
     when substr(date,3,3) = 'JUN' then 6
     when substr(date,3,3) = 'JUL' then 7
     when substr(date,3,3) = 'AUG' then 8
     when substr(date,3,3) = 'SEP' then 9
     when substr(date,3,3) = 'OCT' then 10
     when substr(date,3,3) = 'NOV' then 11
     when substr(date,3,3) = 'DEC' then 12 else NULL end as month,
cast(latitude as varchar) as latitude,longitude 
into kurtis_shell3
from RentAVM_bpo_09NOV2015  

select count(1),length(split_part(zipcode,'.',1)) from kurtis_shell3 group by length(split_part(zipcode,'.',1))  limit 50

---SHELL 4---SHELL 4---SHELL 4---SHELL 4---SHELL 4---SHELL 4---SHELL 4---SHELL 4---SHELL 4---SHELL 4

--- UCR DATA NEEDS TO BE MOLDED

select NULL as property_identifier,
case when source like '%craigslist%' then 'UCR-Craigslist'
     when source like '%trulia%' then  'UCR-Trulia'
     when source like '%oodle%' then  'UCR-Oodle'
     else 'UCR' end as source,
address || city || state as address,
case when zip in ('-1','-2','N/A') or length(zip) != 5 then NULL
     else zip end as zipcode,
case when property_type in ('single_family_home','') then 'SFR'
     when property_type in ('apt_condo_twnhm','multi_family_home') then 'Cluster'
     when property_type in ('apartment','condo') then 'Condo'
     end as property_type,
NULL as clustertype,
case when sqft ='0' or sqft ='-1' then NULL
     else sqft end as sqft,
case when beds = '0' or beds = '-1' then NULL
     else beds end as bed,
case when baths != '-1' and baths !='0' then baths
     else NULL end as bath,
case when num_bath_part !='-1' then num_bath_part
     else '0' end as halfbath,
case when rent !='-1' and rent !='0' and rent != '' then cast(rent as numeric)
     else NULL end as rent,
case when garage = '1' then 1
    else NULL end as garage,
case when numofparking = 'N/A' or numofparking = '' then NULL
     when cast(numofparking as numeric) <10 then cast(numofparking as numeric)
     when cast(numofparking as numeric)=10 then 10
     end as carspace,
case when yearbuilt !='-1' and yearbuilt !='N/A' then yearbuilt
    else NULL end as yearbuilt,
cast(NULL as int) as numphotos,
'Active' as listingstatus,
extract(year from cast(v36 as timestamp)) as year,
extract(month from cast(v36 as timestamp)) as month,
case when latitude not in ('N/A','-1','') and cast(latitude as numeric) !=-1 then latitude
     end as latitude,
case when longitude not in ('N/A','-1','') and cast(longitude as numeric) !=-1 then longitude
     end as longitude
     into kurtis_shell4
from  UCR_11JAN2016 where property_type !='sharing_sublet' and rent !='' and cast(rent as numeric)>0 


select count(1),zipcode is null from kurtis_shell4 group by zipcode is null limit 50


------------------------------------------------- Union the four tables 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
Create Table kurtis_rentdirty_01FEB2015
As
Select a.*  
From
(
	Select    * 
	From      kurtis_shell1--MLSProduction
	Union All
	Select    *
	From      kurtis_shell2--MLSIntegration
	Union All
	Select    *
	From      kurtis_shell3
	Union All
	Select    *
	From      kurtis_shell4
) a;


select * from kurtis_rentdirty_01FEB2015  limit 500

----Remove Duplicates:
select *
,row_number() over (partition by a.latitude,a.longitude,a.sqft,substr(bed,1,1),a.rent order by a.year desc, a.month desc, a.Source, a.listingstatus) as house_duplicate
into kurtis_rentdirty_02FEB2015
from kurtis_rentdirty_01FEB2015 a
where (cast(sqft as numeric) > 0 or (bed!='' and bed is not null and bath!='' and bath is not null)) --#Either it has sqft or it has both bed and bath;
and rent is not null and rent >200 and rent <10000   -- has useable rent value 
order by a.zipcode,a.latitude,a.longitude,a.sqft,a.bed,a.rent



----cast and stuff:
select property_identifier,Source,address,zipcode,
property_type,clustertype,
sqft::numeric::int as sqft,
case when bed = 'NULL' or bed = '' then NULL
     when upper(bed) = 'STUDIO' then 0
     else bed::numeric::int end as bed,
case when bath = '' or bath='NULL' then NULL
     else bath::int end as bath,
case when halfbath = 'NULL' or halfbath = '' or halfbath::numeric = 0 then NULL
     else halfbath::numeric::int end as halfbath,
rent,
garage,
carspace::numeric::int as carspace,
case when yearbuilt = 'NULL' or yearbuilt is NULL or yearbuilt <1600   then NULL
     else yearbuilt end as yearbuilt,
numphotos, listingstatus,
year::int as year,month,
case when length(split_part(latitude,'.',2))>=4 then latitude::numeric 
     else NULL end as latitude,
case when longitude = '-96.814200"' then -96.814200
     when length(split_part(longitude,'.',2))>=4 then longitude::numeric 
     else NULL end as longitude
into kurtis_rentdirty_01FEB2015
from kurtis_rentdirty_02FEB2015 
where house_duplicate= 1

select * from kurtis_rentdirty_01FEB2015 limit 5000


------------------------------------------------- Append Nbhd Id (New Way)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
Select Count(1) From kurtis_rentdirty_01FEB2015 Where longitude is not null And latitude Is Not Null

Create Table kurtis_rentdirty_nid1
As
Select b.*,
       Case When STV_Intersect(latlonggeom Using Parameters Index = 'maponics_neighborhoods_R') Is Not Null 
            Then STV_Intersect(latlonggeom Using Parameters Index = 'maponics_neighborhoods_R')  
	          When STV_Intersect(latlonggeom Using Parameters Index = 'maponics_neighborhoods_S') Is Not Null
	          Then STV_Intersect(latlonggeom Using Parameters Index = 'maponics_neighborhoods_S')  
	          When STV_Intersect(latlonggeom Using Parameters Index = 'maponics_neighborhoods_N') Is Not Null
	          Then STV_Intersect(latlonggeom Using Parameters Index = 'maponics_neighborhoods_N')  
	          When STV_Intersect(latlonggeom Using Parameters Index = 'maponics_neighborhoods_M') Is Not Null 
	          Then STV_Intersect(latlonggeom Using Parameters Index = 'maponics_neighborhoods_M')  
            Else Null 
       End As nid,
       To_Char(STV_Intersect(latlonggeom Using Parameters Index = 'maponics_places'),'0000000') As plcidfp,
       To_Char(STV_Intersect(latlonggeom Using Parameters Index = 'maponics_mcds'),'0000000000') As cosbidfp
From   (Select *, ST_GeomFromText('POINT('||longitude||' '||latitude||')') As latlonggeom
        From   kurtis_rentdirty_01FEB2015 
        --Where  longitude Is Not Null And latitude Is Not Null
        ) b;

select * from kurtis_rentdirty_nid1  limit 50 
select count(1) from kurtis_rentdirty_nid1  limit 50 

------------------------------------------------- Combine all Nbhd sources
Create Table kurtis_rentdirty_nid2
As           
Select       b.*
		       , Case When b.nid !='' And b.nid Is Not Null Then b.nid
                  When b.plcidfp !='' And b.plcidfp Is Not Null Then b.plcidfp
                  When b.cosbidfp !='' And b.cosbidfp Is Not Null Then b.cosbidfp
                  Else Null
             End As neighborhoodid
           , Case When b.nid !='' And b.nid Is Not Null Then 'neighborhood'
                  When b.plcidfp !='' And b.plcidfp Is Not Null Then 'place'
                  When b.cosbidfp !='' And b.cosbidfp Is Not Null Then 'mcd'
                  Else Null
             End As neighborhood_source
From        (Select property_identifier,Source,address,zipcode,property_type,clustertype,sqft,bed,bath
,halfbath,rent,garage,carspace,yearbuilt,numphotos,listingstatus,year,month,latitude,longitude
,Cast(nid As Varchar(200)) As nid, Cast(plcidfp As Varchar(200)) As plcidfp, Cast(cosbidfp As Varchar(200)) As cosbidfp
		         From kurtis_rentdirty_nid1
		        ) b;

Update kurtis_rentdirty_nid2
Set    neighborhoodid = Trim(Both From neighborhoodid);

-- ^^^Done mapping to neigborhood id!


------------------------------------------------- Appending Nbhd Features
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
Create Table kurtis_rentdirtyfull_01FEB215 
As
Select       a.*, 
             case when LNIR_Score = 'NA' then NULL
                  else LNIR_Score::numeric end as LNIR_Score,
             case when neighborhoodclass like 'A%' then 'A'
                  when neighborhoodclass like 'B%' then 'B'
                  when neighborhoodclass like 'C%' then 'C'
                  when neighborhoodclass like 'L%' then 'L'
                  when neighborhoodclass like 'D%' then 'D' end as NIR, 
             b.medianavm::numeric as medianprice,
             b.medianavmcounty::numeric as medianpricecounty,
             medianincomenbhd::numeric as medianincome,
             collegegrads::numeric,
             whitecollar::numeric,
             schools::numeric ,
             unemployment::numeric,
             occupancy::numeric,
             case when safety ='0' then NULL
                  else safety::numeric end as safety,
             HospitalDist::numeric,
             WalmartDist::numeric,
             StarbucksDist::numeric
From         kurtis_rentdirty_nid2 a
Left Join    LNIR_v2_1 b
On           a.neighborhoodid = b.neighborhoodid;

select count(2),neighborhood_source from kurtis_rentdirtyfull_01FEB215 group by neighborhood_source






