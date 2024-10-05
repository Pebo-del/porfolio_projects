/*
cleaning data in SQL Queries
*/

select * 
from portfolio_projects..NashvileHousing

---------------------------------------------------------------------------------------------------------------------------
---standardizing date format

select saledateconverted,convert(date,SaleDate) 
from portfolio_projects..NashvileHousing

alter table portfolio_projects..NashvileHousing
add saledateconverted date

update portfolio_projects..NashvileHousing
set saledateconverted = convert(date,SaleDate)

-------------------------------------------------------------------------------------------------------------------

---populate property address data

select *
from portfolio_projects..NashvileHousing
---where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolio_projects..NashvileHousing a
join portfolio_projects..NashvileHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolio_projects..NashvileHousing a
join portfolio_projects..NashvileHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null  

----------------------------------------------------------------------------------------------------------------------------

---Breaking up Adress into Indivitual Columns(Adress, City, State)

select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as address
from portfolio_projects..NashvileHousing
---where PropertyAddress is null
---order by ParcelID

alter table portfolio_projects..NashvileHousing
add propertysplitAdress nvarchar(255)

update portfolio_projects..NashvileHousing
set propertysplitAdress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

alter table portfolio_projects..NashvileHousing
add propertyCity nvarchar(255)


update portfolio_projects..NashvileHousing
set propertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))




select 
PARSENAME(replace(OwnerAddress,',','.'),3) as address,
PARSENAME(replace(OwnerAddress,',','.'),2) as city,
PARSENAME(replace(OwnerAddress,',','.'),1) as state
from portfolio_projects..NashvileHousing 


alter table portfolio_projects..NashvileHousing
add OwnersplitAdress nvarchar(255)

update portfolio_projects..NashvileHousing
set OwnersplitAdress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table portfolio_projects..NashvileHousing
add OwnerCity nvarchar(255)

update portfolio_projects..NashvileHousing
set OwnerCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table portfolio_projects..NashvileHousing
add OwnerState nvarchar(255)

update portfolio_projects..NashvileHousing
set OwnerState =PARSENAME(replace(OwnerAddress,',','.'),1)


--------------------------------------------------------------------------------------------------------------------

---change Y and N to YES and NO in "SoldAsVacant" field

select SoldAsVacant,
case when SoldAsVacant = 'N' THEN 'NO'
     when SoldAsVacant = 'Y' THEN 'YES'
	 ELSE SoldAsVacant
END
from portfolio_projects..NashvileHousing  

update portfolio_projects..NashvileHousing
set SoldAsVacant = case when SoldAsVacant = 'N' THEN 'NO'
     when SoldAsVacant = 'Y' THEN 'YES'
	 ELSE SoldAsVacant
END

------------------------------------------------------------------------------------------------------

---Remove Duplicates

with dupCTE as (
select *,
ROW_NUMBER() OVER(
    PARTITION BY ParcelID, PropertyAddress,SaleDate,SalePrice,LegalReference
	order by UniqueID) row_num
from portfolio_projects..NashvileHousing 
) 
select * from dupCTE
where row_num =1

--------------------------------------------------------------------------------------------------------------------------

---Delete unused Columns

alter table portfolio_projects..NashvileHousing 
drop column PropertyAddress,SaleDate, OwnerAddress,TaxDistrict


select * from  portfolio_projects..NashvileHousing 


