#!/bin/bash

export date=`date +%Y%m%d`

echo_time() {
   date +"%Y-%m-%d %H:%M:%S $*"
}

unload_dir=/home/data-analysis/DataScience/RentAVM/Input/MLS_Input
integrationfilename=$unload_dir/"AVM_MLSIntegrationData_"$date.csv
productionfilename=$unload_dir/"AVM_MLSProductionData_"$date.csv

echo "select property_id,propertysource,type,propertyaddress,city,state,zipcode,bed,bath,sqft,yearbuilt,saleprice,rent,lotsize,carspace,mlsnumber,propertytypeorstatus,unit_number,lot_measure,numphotos,listing_type,listingstatus,listing_date,latitude,longitude,listing_class,property_type,date_created,date_modified,date_mls_modified,m_halfBathCount from properties.tblstgrawinventory;" | mysql -h investordbinstance.cfgncecsykm0.us-west-2.rds.amazonaws.com -uhudbreaduser -phudbreadpwd -A |sed -e 's/\t/"|"/g' -e 's/^/"/' -e 's/$/"/' >> $productionfilename
echo "imported data from production server into "$productionfilename

echo "select property_id,propertysource,type,propertyaddress,city,state,zipcode,bed,bath,sqft,yearbuilt,saleprice,rent,lotsize,carspace,mlsnumber,propertytypeorstatus,unit_number,lot_measure,numphotos,listing_type,listingstatus,listing_date,latitude,longitude,listing_class,property_type,date_created,date_modified,date_mls_modified,m_halfBathCount from properties.tblstgrawinventory where mlsname = "'"nefmls"'";" | mysql -h 192.168.10.12 -uhumapuser -phumappwd -A |sed -e 's/\t/"|"/g' -e 's/^/"/' -e 's/$/"/' >> $integrationfilename
echo "imported data from integration server into "$integrationfilename









