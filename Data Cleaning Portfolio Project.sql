/*

Cleaning Data in SQL Queries

*/

Select *
from PortfolioProjects..NashvilleHousing

-----------------------------------------------------------------------------------------------
--Standardize Date Format

Select SaleDate, Convert(Date,SaleDate)
from PortfolioProjects..NashvilleHousing


Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;
Update NashvilleHousing
Set SaleDateConverted = Convert(Date,Saledate)
Select *
from NashvilleHousing


-----------------------------------------------------------------------------------------------
--Popuate Property Address data
Select *
from PortfolioProjects..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID
--determine entries where property address is null; I notice that these entries have a duplicate lines where Parcel ID is the same


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
Join PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
order by a.ParcelID

Update a
Set a.PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
Join PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--Update table a by populating PropertyAddress null values with the addresses from the same parcel ID

-----------------------------------------------------------------------------------------------
--Breaking out Address into individual columns (Street, City, State)

Select PropertyAddress
From PortfolioProjects..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) as PropertyStreet
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as PropertyCity
from PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertyStreet nvarchar(255);
Update NashvilleHousing
Set PropertyStreet = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertyCity nvarchar(255);
Update NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProjects..NashvilleHousing
--using SUBSTRING to separate PropertyAddress into separate columns and updating the table

Select OwnerAddress
From PortfolioProjects..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerStreet
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerCity
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerState
From PortfolioProjects..NashvilleHousing
--PARSENAME defaults to look for periods, so I replaced the commas to periods; position is relative to the end of the field
ALTER TABLE NashvilleHousing
Add OwnerStreet nvarchar(255);
Update NashvilleHousing
Set OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerCity nvarchar(255);
Update NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerState nvarchar(255);
Update NashvilleHousing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--updating the table with new parced fields

Select *
From PortfolioProjects..NashvilleHousing

------------------------------------------------------------------------------------------------
--Change Y/N values to Yes/No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects..NashvilleHousing
group by SoldAsVacant

Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END
From PortfolioProjects..NashvilleHousing

Update PortfolioProjects..NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END

------------------------------------------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE As (
Select *,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
		) as row_num
From PortfolioProjects..NashvilleHousing
--order by ParcelID
)

DELETE
From RowNumCTE
Where row_num > 1

Select *
From RowNumCTE
Where row_num > 1

--created CTE with row_num column designating duplicates as >1; selected columns where row_num >1; deleted where row_num >1

--------------------------------------------------------------------------------------------------
--Delete Unused Columns

select *
from PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN SaleDate

--deleted the original columns that were since parced or converted
