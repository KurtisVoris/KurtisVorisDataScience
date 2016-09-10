#!/bin/bash

states=("AK" "AL" "AR" "AZ" "CA" "CO" "CT" "DC" "DE" "FL" "GA" "HI" "IA" "ID" "IL" "IN" "KS" "KY" "LA" "MA" "MD" "ME" "MI" "MN" "MO" "MS" "MT" "NC" "ND" "NE" "NH" "NJ" "NM" "NV" "NY" "OH" "OK" "OR" "PA" "RI" "SC" "SD" "TN" "TX" "UT" "VA" "VT" "WA" "WI" "WV" "WY")

for state in "${states[@]}"
do
  echo $state;
  /opt/vertica/opt/vertica/bin/vsql -d homeunion -h 192.168.10.104  -A -P footer=off -U dbadmin -w 1234 -c " select * from kurtis_rentAVM_topredict where state = '$state'" | sed -e 's/\r//g' -e 's/\"//g' -e 's/[\"]/\\&/g' -e 's/|/"&"/g' -e 's/^\|$/"/g' > /home/data-analysis/DataScience/RentAVM/Prediction/AVM_2_2/ToPredict$state.csv
done

