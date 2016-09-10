

select * from kurtis_rentAVM_topredict limit 60

Create  Table kurtis_rentAVM_topredict
As
Select       z.state,z.county,z.city,p.*, a.nid,
            case when b.source = 'neighborhood' then b.nir_Score 
                 when c.source = 'zip' then c.nir_Score end as nir_Score,
            case when b.source = 'neighborhood' then b.NIR 
                 when c.source = 'zip' then c.NIR end as NIR,
            case when b.source = 'neighborhood' then b.medianprice 
                 when c.source = 'zip' then c.medianprice end as medianprice,
            case when b.source = 'neighborhood' then b.medianincome 
                 when c.source = 'zip' then c.medianincome end as medianincome,
            case when b.source = 'neighborhood' then b.collegegrads 
                 when c.source = 'zip' then c.collegegrads end as collegegrads,
            case when b.source = 'neighborhood' then b.whitecollar 
                 when c.source = 'zip' then c.whitecollar end as whitecollar,
            case when b.source = 'neighborhood' then b.schools 
                 when c.source = 'zip' then c.schools end as schools,
            case when b.source = 'neighborhood' then b.census_vacancy 
                 when c.source = 'zip' then c.census_vacancy end as vacancy,
            case when b.source = 'neighborhood' then b.hu_crime 
                 when c.source = 'zip' then c.hu_crime end as hu_crime,
            case when b.source = 'neighborhood' then b.HospitalDist 
                 when c.source = 'zip' then c.HospitalDist end as HospitalDist,
            case when b.source = 'neighborhood' then b.WalmartDist 
                 when c.source = 'zip' then c.WalmartDist end as WalmartDist,
            case when b.source = 'neighborhood' then b.StarbucksDist 
                 when c.source = 'zip' then c.StarbucksDist end as StarbucksDist
From         (select property_identifier,property_zipcode as zipcode,property_address,
              '2016' as time,
              case when assessor_bedrooms<1 and assessor_living_square_feet>1800 then 3
                   when assessor_bedrooms<1 and (assessor_living_square_feet>1200 or assessor_living_square_feet is null) then 2
                   when assessor_bedrooms<1 and assessor_living_square_feet<1200 then 1
                   when assessor_bedrooms>8 then 6
                   else assessor_bedrooms end as bed,
              case when assessor_living_square_feet>8000 and universal_land_use_code_desc in ('APARTMENT','APARTMENT/HOTEL','CONDOMINIUM','CONDOMINIUM PROJECT','COOPERATIVE','GROUP QUARTERS','HIGH RISE CONDO','HOTEL',
                                                     'MID RISE CONDO','MIXED COMPLEX','MOTEL','MULTI FAMILY 10 UNITS LESS','MULTI FAMILY 10 UNITS PLUS','MULTI FAMILY DWELLING',
                                                        'NURSING HOME','ORPHANAGE','RESIDENCE HALL/DORMITORIES','RESORT HOTEL','TIME SHARE','TIME SHARE CONDO')
                                                         then 1000 else assessor_living_square_feet end as sqft,
              case when assessor_full_baths<1 then 1 else assessor_full_baths end as bath, 
              case when assessor_half_baths <5 then assessor_half_baths else 5 end as halfbath,
        case when assessor_effective_year_built>assessor_year_built then assessor_effective_year_built
             else assessor_year_built end as yearbuilt,
        case when  assessor_parking_spaces <10 then assessor_parking_spaces else 5 end as carspace,
        case when assessor_garage_code_desc like '%GARA%' then 1 else 0 end as garage,
        case when universal_land_use_code_desc in ('CABIN','PUD','RESIDENTIAL (NEC)','RURAL HOMESITE','SFR') then 'SFR'
             when universal_land_use_code_desc in ('DUPLEX','FRAT/SORORITY HOUSE','MANUFACTURED HOME','MOBILE HOME','MOBILE HOME LOT','MOBILE HOME PARK','QUADRUPLEX','TOWNHOUSE/ROWHOUSE','TRIPLEX','TRANSIENT LODGING') then 'Cluster'
             when universal_land_use_code_desc in ('APARTMENT','APARTMENT/HOTEL','CONDOMINIUM','CONDOMINIUM PROJECT','COOPERATIVE','GROUP QUARTERS','HIGH RISE CONDO','HOTEL',
                                                     'MID RISE CONDO','MIXED COMPLEX','MOTEL','MULTI FAMILY 10 UNITS LESS','MULTI FAMILY 10 UNITS PLUS','MULTI FAMILY DWELLING',
                                                        'NURSING HOME','ORPHANAGE','RESIDENCE HALL/DORMITORIES','RESORT HOTEL','TIME SHARE','TIME SHARE CONDO') then 'Condo'
                                                        end as property_type,
                  longitude,latitude from properties) p
left join (select property_identifier,nid from property_maponics_mapping) a
on p.property_identifier=a.property_identifier
Left Join    (select id,source,percentile_rank_national as nir_Score,
             NIR, cl_medianavm as medianprice,census_medianincome as medianincome,
             collegegrads,whitecollar,schools ,census_vacancy,hu_crime,
             HospitalDist,WalmartDist,StarbucksDist 
             from NIR_v3_0_0 b  where source = 'neighborhood') b
On           a.nid = b.id 
Left Join    (select id,source,percentile_rank_national as nir_Score,
             NIR, cl_medianavm as medianprice,census_medianincome as medianincome,
             collegegrads,whitecollar,schools ,census_vacancy,hu_crime,
             HospitalDist,WalmartDist,StarbucksDist 
             from NIR_v3_0_0 b  where source = 'zip') c
On           p.zipcode = c.id 
left join (select * from tblzipcodes where primaryrecord='P' ) z
on p.zipcode=z.zipcode  ;


select count(1),state from kurtis_rentAVM_topredict  group by state


select * from propertysearchmatrix where zipcode = '44121' and address like '%MAPLE%'



select * from ds_rentalavm_20160527_id 
