/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProjects.dbo.NashvilleHousing

-- Standardize Date Format
Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProjects.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

-- If this is not working for you then try altering

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProjects.dbo.NashvilleHousing

-- Populate Property Address Data

Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing
Where PropertyAddress is null

Select *
From PortfolioProjects.dbo.NashvilleHousing
order by ParcelID

-- for this we need to join the table with itself - self join 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
Join PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID        -- Parcel Id is same
	AND a.[UniqueID ] <> b.[UniqueID ]  -- but it is not the  same row
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
Join PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID     
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing

-- if we notice here there are two things - first is address and after comma we have city name.
-- this can be done using substring and Parsename as well

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing 
ADD PropertysplitAddress NVARCHAR(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET PropertysplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing 
ADD PropertysplitCity NVARCHAR(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET PropertysplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

-- Using PARSENAME for Splitting OwnerAddress

SELECT OwnerAddress
FROM PortfolioProjects.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing 
ADD OwnersplitAddress NVARCHAR(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing 
ADD OwnersplitCity NVARCHAR(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET OwnersplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing 
ADD OwnersplitState NVARCHAR(255);

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET OwnersplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProjects.dbo.NashvilleHousing

-- Changing Y and N to Yes and No in 'Sold as vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- This can be done using a Case Statement

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END 
FROM PortfolioProjects.dbo.NashvilleHousing

UPDATE PortfolioProjects.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- REMOVE DUPLICATES 

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER ( )   
    OVER ( PARTITION BY ParcelID,
	                    PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY UniqueID) Row_num
FROM PortfolioProjects.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE Row_num > 1
-- All the rows here are duplicates and we need to delete them

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER ( )   
    OVER ( PARTITION BY ParcelID,
	                    PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY UniqueID) Row_num
FROM PortfolioProjects.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_num > 1

-----------------------------------------------------------------------------------------
-- Delete unused Columns - USUALLY NOT RECOMMENDED

SELECT *
FROM PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress