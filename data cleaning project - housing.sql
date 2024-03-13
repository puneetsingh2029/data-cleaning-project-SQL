select * 
from [Nashville Housing Data for Data Cleaning 1]
where PropertyAddress is null

--populate property address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.propertyaddress)
from [Nashville Housing Data for Data Cleaning 1] as a
join [Nashville Housing Data for Data Cleaning 1] as b
on a.ParcelID = b.ParcelID
where a.UniqueID <> b.UniqueID
and a.PropertyAddress is null

update a
set propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing Data for Data Cleaning 1] a
join [Nashville Housing Data for Data Cleaning 1] b
on a.ParcelID = b.ParcelID
where a.UniqueID <> b.UniqueID
and a.PropertyAddress is null

--breaking out addresses into individual columns(address, city, state)

--for property address - using substrig
select PropertyAddress
from [Nashville Housing Data for Data Cleaning 1]

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress), LEN(propertyaddress)) as address
from [Nashville Housing Data for Data Cleaning 1]

alter table [Nashville Housing Data for Data Cleaning 1]
add propertysplitaddress Nvarchar(255);

update [Nashville Housing Data for Data Cleaning 1]
set propertysplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress))

alter table [Nashville Housing Data for Data Cleaning 1]
add propertysplitcity Nvarchar(255);

update [Nashville Housing Data for Data Cleaning 1]
set propertysplitcity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress), LEN(propertyaddress))

select *
from [Nashville Housing Data for Data Cleaning 1]

--for owner address - using parsename -- note parsename works with period and from the end.

select OwnerAddress
from [Nashville Housing Data for Data Cleaning 1]

select 
PARSENAME(REPLACE(owneraddress, ',' , '.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
from [Nashville Housing Data for Data Cleaning 1]

alter table [Nashville Housing Data for Data Cleaning 1]
add ownersplitaddress nvarchar(255)

alter table [Nashville Housing Data for Data Cleaning 1]
add ownerspitcity nvarchar(255)

alter table [Nashville Housing Data for Data Cleaning 1]
add ownerspitstate nvarchar(255)

update [Nashville Housing Data for Data Cleaning 1]
set ownersplitaddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

update [Nashville Housing Data for Data Cleaning 1]
set ownerspitcity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

update [Nashville Housing Data for Data Cleaning 1]
set ownerspitstate = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


----change 'Y' AND 'N' TO 'YES' AND 'NO' in soldAsVacant field -- using case statement

select distinct(SoldAsVacant), count(SoldAsVacant)
from [Nashville Housing Data for Data Cleaning 1]
group by SoldAsVacant
order by 1

select SoldAsVacant,
case 
	when SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
from [Nashville Housing Data for Data Cleaning 1]

UPDATE [Nashville Housing Data for Data Cleaning 1]
SET SoldAsVacant = case 
	when SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

--removing duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from [Nashville Housing Data for Data Cleaning 1]
)
select *
From RowNumCTE
Where row_num > 1

 
--drop unused columns

alter table [Nashville Housing Data for Data Cleaning 1]
drop column owneraddress, taxdistrict, propertyaddress


select * 
from [Nashville Housing Data for Data Cleaning 1]