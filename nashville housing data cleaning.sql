--Fill the vacant property address data

select a."parcelID",a.property_address, b."parcelID", b.property_address,
coalesce(a.property_address,b.property_address)
from nashville_housing a
join nashville_housing b
on a."parcelID"=b."parcelID"
and a."uniqueID"!=b."uniqueID"
where a.property_address is null


--updating the table
update nashville_housing
set property_address= coalesce(a.property_address,b.property_address)
from nashville_housing a
join nashville_housing b
on a."parcelID"=b."parcelID"
and a."uniqueID"!=b."uniqueID"
where a.property_address is null

--------------------------------------------------------------------



--Breaking the address into individual columns as per address, city and state
select 
split_part(property_address,',',1) as address, 
split_part(property_address,',',2) as city,
property_address
from nashville_housing


--updating the table as per the above breakdown of property address
-- first add two new columns for the brokendown data
alter table nashville_housing
add column property_area varchar

alter table nashville_housing
add column property_city varchar

update nashville_housing
set property_area=split_part(property_address,',',1)

update nashville_housing
set property_city=split_part(property_address,',',2)

-------------------------------------------------------------------------



--updating the owner_address by breaking it down into three different columns
select 
split_part(owner_address,',',1) as area,
split_part(owner_address,',',2) as city,
split_part(owner_address,',',3) as state
from nashville_housing

--First add three new columns
alter table nashville_housing
add column owner_area varchar

alter table nashville_housing
add column owner_city varchar

alter table nashville_housing
add column owner_state varchar



--now putting the brokendown data into newly added columns accordingly
update nashville_housing
set owner_area=split_part(owner_address,',',1)

update nashville_housing
set owner_city=split_part(owner_address,',',2)

update nashville_housing
set owner_state= split_part(owner_address,',',3)


select * from nashville_housing
order by "parcelID"

-------------------------------------------------------------------

--changing the sold as vacant column data into appropriate form
select distinct(soldasvacant), count(soldasvacant)
from nashville_housing
group by soldasvacant
order by 2

select soldasvacant,
case
  when soldasvacant='Y' then 'Yes'
  when soldasvacant='N' then 'No'
  else soldasvacant
  end
from nashville_housing

-- updating
update nashville_housing
set soldasvacant=case
  when soldasvacant='Y' then 'Yes'
  when soldasvacant='N' then 'No'
  else soldasvacant
  end
  
-----------------------------------------------------------------------------
--Delete duplicates
with cte as
(
select *,
row_number() over(partition by "parcelID",
				 property_address,
				 sale_price,
				 sale_date,
				 legal_reference
				 order by 
				 "uniqueID") 
from nashville_housing
)
delete from cte
where cte.row_num>1



--------------------------------------------------------------------
-- deleting unnecessary columns
alter table nashville_housing
drop column property_address, owner_address, tax_district, sale_date



