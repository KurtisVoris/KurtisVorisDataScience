--- THIS CODE WILL CHECK PROPERTY LEVEL ACCURACY
kurtis_HPI_accuracy_allyears

create  table kurtis_HPIPred_SaleQC
as
select property_identifier,HUMarketPlace,tax_assessor_living_square_feet as sqft,Year,Quarter,zipcode,deed_absentee_indicator_code,saleprice,HPIPrediction,(HPIPrediction-saleprice)/saleprice as pcnterr, 
case when abs(HPIPrediction-saleprice)/saleprice <=.05 then 1 else 0 end as within5,
case when abs(HPIPrediction-saleprice)/saleprice <=.1 then 1 else 0 end as within10,
case when abs(HPIPrediction-saleprice)/saleprice <=.15 then 1 else 0 end as within15,
case when abs(HPIPrediction-saleprice)/saleprice <=.2 then 1 else 0 end as within20
from (
select p.property_identifier,HUMarketplace,p.zipcode,deed_assessor_sale_amount as saleprice,year,Quarter,tax_assessor_living_square_feet,
case when p.year=2000 and p.quarter = 1 then smooth_200000
     when p.year=2000 and p.quarter = 2 then smooth_200025
     when p.year=2000 and p.quarter = 3 then smooth_200050
     when p.year=2000 and p.quarter = 4 then smooth_200075
              when p.year=2001 and p.quarter = 1 then smooth_200100
     when p.year=2001 and p.quarter = 2 then smooth_200125
     when p.year=2001 and p.quarter = 3 then smooth_200150
     when p.year=2001 and p.quarter = 4 then smooth_200175
              when p.year=2002 and p.quarter = 1 then smooth_200200
     when p.year=2002 and p.quarter = 2 then smooth_200225
     when p.year=2002 and p.quarter = 3 then smooth_200250
     when p.year=2002 and p.quarter = 4 then smooth_200275
              when p.year=2003 and p.quarter = 1 then smooth_200300
     when p.year=2003 and p.quarter = 2 then smooth_200325
     when p.year=2003 and p.quarter = 3 then smooth_200350
     when p.year=2003 and p.quarter = 4 then smooth_200375
               when p.year=2004 and p.quarter = 1 then smooth_200400
     when p.year=2004 and p.quarter = 2 then smooth_200425
     when p.year=2004 and p.quarter = 3 then smooth_200450
     when p.year=2004 and p.quarter = 4 then smooth_200475
              when p.year=2005 and p.quarter = 1 then smooth_200500
     when p.year=2005 and p.quarter = 2 then smooth_200525
     when p.year=2005 and p.quarter = 3 then smooth_200550
     when p.year=2005 and p.quarter = 4 then smooth_200575
              when p.year=2006 and p.quarter = 1 then smooth_200600
     when p.year=2006 and p.quarter = 2 then smooth_200625
     when p.year=2006 and p.quarter = 3 then smooth_200650
     when p.year=2006 and p.quarter = 4 then smooth_200675
          when p.year=2007 and p.quarter = 1 then smooth_200700
     when p.year=2007 and p.quarter = 2 then smooth_200725
     when p.year=2007 and p.quarter = 3 then smooth_200750
     when p.year=2007 and p.quarter = 4 then smooth_200775
             when p.year=2008 and p.quarter = 1 then smooth_200800
     when p.year=2008 and p.quarter = 2 then smooth_200825
     when p.year=2008 and p.quarter = 3 then smooth_200850
     when p.year=2008 and p.quarter = 4 then smooth_200875
             when p.year=2009 and p.quarter = 1 then smooth_200900
     when p.year=2009 and p.quarter = 2 then smooth_200925
     when p.year=2009 and p.quarter = 3 then smooth_200950
     when p.year=2009 and p.quarter = 4 then smooth_200975
            when p.year=2010 and p.quarter = 1 then smooth_201000
     when p.year=2010 and p.quarter = 2 then smooth_201025
     when p.year=2010 and p.quarter = 3 then smooth_201050
     when p.year=2010 and p.quarter = 4 then smooth_201075
            when p.year=2011 and p.quarter = 1 then smooth_201100
     when p.year=2011 and p.quarter = 2 then smooth_201125
     when p.year=2011 and p.quarter = 3 then smooth_201150
     when p.year=2011 and p.quarter = 4 then smooth_201175
            when p.year=2012 and p.quarter = 1 then smooth_201200
     when p.year=2012 and p.quarter = 2 then smooth_201225
     when p.year=2012 and p.quarter = 3 then smooth_201250
     when p.year=2012 and p.quarter = 4 then smooth_201275
            when p.year=2013 and p.quarter = 1 then smooth_201300
     when p.year=2013 and p.quarter = 2 then smooth_201325
     when p.year=2013 and p.quarter = 3 then smooth_201350
     when p.year=2013 and p.quarter = 4 then smooth_201375
            when p.year=2014 and p.quarter = 1 then smooth_201400
     when p.year=2014 and p.quarter = 2 then smooth_201425
     when p.year=2014 and p.quarter = 3 then smooth_201450
     when p.year=2014 and p.quarter = 4 then smooth_201475
            when p.year=2015 and p.quarter = 1 then smooth_201500
     when p.year=2015 and p.quarter = 2 then smooth_201525
     when p.year=2015 and p.quarter = 3 then smooth_201550
     when p.year=2015 and p.quarter = 4 then smooth_201575
            when p.year=2016 and p.quarter = 1 then smooth_201600
     when p.year=2016 and p.quarter = 2 then smooth_201625
     end as HPIPrediction,deed_absentee_indicator_code,
     Case When (deed_assessor_forclosure_code In ('P','Y') And deed_assessor_pri_cat_code In ('A','B')) 
					       Or deed_assessor_pri_cat_code = 'F' 
					       Or deed_assessor_deed_sec_cat_codes  like '%W%'
					       Or deed_assessor_deed_sec_cat_codes  like '%P%'
					       Or deed_assessor_deed_sec_cat_codes  like '%X%'
					       Then 'delete' 
					       Else 'keep' 
					End As deleter
from (select * from properties_salesdata where zipcode in (select distinct zipcode from HUMarketPlace_zipmapping where HUMarketPlace = 'Los Angeles-Long Beach, CA PMSA' ))p
inner join kurtis_HPIPredictions_LosAngeles k
on p.property_identifier=k.property_identifier
where sqft>0 and sqft!=1400
) x where deleter = 'keep' 

select count(1) from kurtis_HPIPred_SaleQC

--- MAPE METRIC:

select distinct HUMarketPlace,k.zipcode,counts,
percentile_cont(.5) within group (order by abs(pcnterr)) over (partition by HUMarketPlace,k.zipcode) as medianAPE
from kurtis_HPIPred_SaleQC  k
left join (select zipcode, count(pcnterr) as counts from kurtis_HPIPred_SaleQC  where sqft>0 and saleprice>30000 and saleprice<3000000 group by zipcode) c
on k.zipcode = c.zipcode
where sqft>0 and saleprice>30000 and saleprice<3000000





select zipcode,count(within5) as num,avg(saleprice) as avgprice,sum(within5)/count(within5) as err5,
       sum(within10)/count(within10) as err10,
       sum(within20)/count(within20) as err20 from kurtis_HPIPred_SaleQC
         where HPIPrediction is not null 
         group by zipcode



select HUMarketPlace,sum(within5)/count(within5) as err5,
       sum(within10)/count(within10) as err10,
       sum(within20)/count(within20) as err20 from kurtis_HPIPred_SaleQC
         where HPIPrediction is not null 
         group by HUMarketPlace


kurtis_HPI_accuracy_allyears


select * from kurtis_HPIPred_SaleQC limit 5
kurtis_HPIPredictions_LosAngeles

---Create Table hat has sales per property over time:

create table kurtis_delete_saleswithcounter
as
select property_identifier,year,quarter,zipcode,saleprice, row_number() over (partition by property_identifier)  as counter
from kurtis_HPIPred_SaleQC  where saleprice > 30000 and saleprice < 3000000

select count(1), counter from kurtis_delete_saleswithcounter group by counter

create table kurtis_LASales_with_hpitrend
as
select p1.property_identifier, p1.zipcode, 
smooth_200000,smooth_200025,smooth_200050,smooth_200075,smooth_200100,smooth_200125,smooth_200150,smooth_200175,smooth_200200,smooth_200225,smooth_200250,
smooth_200275,smooth_200300,smooth_200325,smooth_200350,smooth_200375,smooth_200400,smooth_200425,smooth_200450,smooth_200475,smooth_200500,smooth_200525,
smooth_200550,smooth_200575,smooth_200600,smooth_200625,smooth_200650,smooth_200675,smooth_200700,smooth_200725,smooth_200750,smooth_200775,smooth_200800,
smooth_200825,smooth_200850,smooth_200875,smooth_200900,smooth_200925,smooth_200950,smooth_200975,smooth_201000,smooth_201025,smooth_201050,smooth_201075,
smooth_201100,smooth_201125,smooth_201150,smooth_201175,smooth_201200,smooth_201225,smooth_201250,smooth_201275,smooth_201300,smooth_201325,smooth_201350,
smooth_201375,smooth_201400,smooth_201425,smooth_201450,smooth_201475,smooth_201500,smooth_201525,smooth_201550,smooth_201575,smooth_201600,smooth_201625,
sale1_time,sale1_price,sale2_time,sale2_price,sale3_time,sale3_price,sale4_time,sale4_price,k.bed,k.sqft,k.address
from (select property_identifier,zipcode, year+(quarter-1)/4 as sale1_time, saleprice as sale1_price from kurtis_delete_saleswithcounter where counter = 1) p1
left join (select property_identifier, year+(quarter-1)/4 as sale2_time, saleprice as sale2_price from kurtis_delete_saleswithcounter where counter = 2) p2
on p1.property_identifier = p2.property_identifier
left join (select property_identifier, year+(quarter-1)/4 as sale3_time, saleprice as sale3_price from kurtis_delete_saleswithcounter where counter = 3) p3
on p1.property_identifier = p3.property_identifier
left join (select property_identifier, year+(quarter-1)/4 as sale4_time, saleprice as sale4_price from kurtis_delete_saleswithcounter where counter = 4) p4
on p1.property_identifier = p4.property_identifier
left join kurtis_HPIPredictions_LosAngeles k
on p1.property_identifier=k.property_identifier

select * from kurtis_HPIPredictions_LosAngeles limit 5

select count(1) from kurtis_LASales_with_hpitrend limit 50

select * from kurtis_LASales_with_hpitrend where sale2_price is not null order by random() limit 5000






----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:
----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:
----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:
----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:
----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:
----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:
----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:
----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:
----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:----- Cross Sectional Accuracy from AVM:
create  table kurtis_HPI_accuracy_allyears
as
select k.property_identifier,HUMarketPlace,Year,Quarter,sqft,k.zipcode,saleprice,HPIPrediction,cl_price,hu_price, (hu_price-saleprice)/hu_price as pcnterr,
case when abs(hu_price-saleprice)/saleprice <=.05 then 1
     when abs(hu_price-saleprice)/saleprice >.05 then 0 end as within5_avm,
case when abs(hu_price-saleprice)/saleprice <=.1 then 1
     when abs(hu_price-saleprice)/saleprice >.1 then 0 end as within10_avm,
case when abs(hu_price-saleprice)/saleprice <=.2 then 1
     when abs(hu_price-saleprice)/saleprice >.2 then 0 end as within20_avm,
case when abs(HPIPrediction-saleprice)/saleprice <=.1 then 1
     when abs(HPIPrediction-saleprice)/saleprice >.1 then 0 end as within10_hpi,
case when abs(HPIPrediction-saleprice)/saleprice <=.2 then 1
     when abs(HPIPrediction-saleprice)/saleprice >.2 then 0 end as within20_hpi
from
(select * from kurtis_HPIPred_SaleQC where  saleprice>30000 and saleprice<3000000) k  ----year = 2016 or (year=2015 and quarter in (3,4))) and
left join HU_AVM_Predicted h 
on k.property_identifier=h.property_identifier


create table kurtis_HPI_accuracy_cross
as
select HUMarketPlace,
      count(within10_hpi) as zipcount,
       sum(within10_hpi)/count(within10_hpi) as err10_hpi,
       sum(within20_hpi)/count(within20_hpi) as err20_hpi,
       sum(within10_avm)/count(within10_avm) as err10_avm,
       sum(within20_avm)/count(within20_avm) as err20_avm
       from kurtis_HPI_accuracy_allyears
         where hu_price is not null 
         group by HUMarketPlace
         

select    distinct    percentile_disc(.5) within GROUP (ORDER BY pcnterr*hu_price) OVER (PARTITION BY HUMarketPlace) AS bias from kurtis_HPI_accuracy_allyears limit 500

select count(pcnterr) from kurtis_HPI_accuracy_allyears


