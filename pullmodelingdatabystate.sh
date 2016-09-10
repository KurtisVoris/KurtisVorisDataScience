#!/bin/bash


states=("AK" "AL" "AR" "AZ" "CA" "CO" "CT" "DC" "DE" "FL" "GA" "GU" "HI" "IA" "ID" "IL" "IN" "KS" "KY" "LA" "MA" "MD" "ME" "MI" "MN" "MO" "MS" "MT" "NC" "ND" "NE" "NH" "NJ" "NM" "NV" "NY" "OH" "OK" "OR" "PA" "RI" "SC" "SD" "TN" "TX" "UT" "VA" "VI" "VT" "WA" "WI" "WV" "WY")

###Print al states:
#printf "%s\n" "${states[@]}"

###Print a specific state:
#printf "%s\n" "${states[5]}"

for state in "${states[@]}"
do
  echo $state;
  /opt/vertica/opt/vertica/bin/vsql -d homeunion -h 192.168.10.104  -A -P footer=off -U dbadmin -w 1234 -c " select * from kurtis_rentdirtyfull_04MAY2016 where state = '$state'" | sed -e 's/\r//g' -e 's/\"//g' -e 's/[\"]/\\&/g' -e 's/|/"&"/g' -e 's/^\|$/"/g' > DirtyRentTraining$state.csv
done

