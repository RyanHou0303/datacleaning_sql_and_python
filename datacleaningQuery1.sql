select * 
from portfolioproject..NashvilleHousing

-----------------------------------------------
--standardize data format
select Saledate, convert(Date,SaleDate)
from portfolioproject..NashvilleHousing

update NashvilleHousing
set SaleDate = convert(Date,SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date

Alter table NashvilleHousing
drop column SaleDateConvert

update NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)


-- populate property address data
select *
from portfolioproject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject..NashvilleHousing a
join portfolioproject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
	where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject..NashvilleHousing a
join portfolioproject..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID] <> b.[UniqueID ]
 where a.PropertyAddress is null

 --breaking out address into individual columns(address, city, state)
 Select PropertyAddress
 from portfolioproject..NashvilleHousing
 --
 select
 substring(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)  as Address
 from portfolioproject..NashvilleHousing

 select
 substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as address
 from portfolioproject..NashvilleHousing

 alter table portfolioproject..NashvilleHousing
 add Propertysplitcity Nvarchar(255);
 alter table portfolioproject..NashvilleHousing
 add Propertysplitaddress Nvarchar(255);
  update portfolioproject..NashvilleHousing
 set Propertysplitaddress = substring(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)
 update portfolioproject..NashvilleHousing
 set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

 SELECT *
 FROM portfolioproject..NashvilleHousing

 select 
 parsename(replace(owneraddress,',','.'),3),
 
 parsename(replace(owneraddress,',','.'),2),

 parsename(replace(owneraddress,',','.'),1)
 from portfolioproject..NashvilleHousing
 alter table portfolioproject..NashvilleHousing
 add Ownersplitcity Nvarchar(255);
 alter table portfolioproject..NashvilleHousing
 add Ownersplitaddress Nvarchar(255);
  alter table portfolioproject..NashvilleHousing
 add Ownerstate Nvarchar(255);
  update portfolioproject..NashvilleHousing
 set Ownersplitaddress = parsename(replace(owneraddress,',','.'),3)
 update portfolioproject..NashvilleHousing
 set Ownersplitcity = parsename(replace(owneraddress,',','.'),2)
 update portfolioproject..NashvilleHousing
 set Ownerstate = parsename(replace(owneraddress,',','.'),1)

 --similar as the substring method


 --change Yand N to yes and no in "sold as vacant" field
 select Distinct(soldasvacant),count(soldasvacant)
 from portfolioproject..NashvilleHousing
 group by SoldAsVacant
 order by 2

 update portfolioproject..NashvilleHousing
 set soldasvacant =
Case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 ELSE soldasvacant
	 end
from portfolioproject..NashvilleHousing

select * 
from portfolioproject..NashvilleHousing
--remove duplicates
WITH RowNumCTE AS(
select *,
	Row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
from portfolioproject..NashvilleHousing
	)
select *
from RowNumCTE
where row_num > 1
order by propertyaddress

-- delete unused columns
select*
from portfolioproject..NashvilleHousing

alter table portfolioproject..NashvilleHousing
drop column owneraddress,TaxDistrict, PropertyAddress
