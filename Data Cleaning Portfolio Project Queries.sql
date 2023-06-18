-- Start of data cleaning queries

-- Select all data from NashvilleHousing for initial review
Select *
From PortfolioProject.dbo.NashvilleHousing

-- Begin standardizing date format

-- Convert SaleDate to standard Date format
Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- In case of update failure, create a new column for standardized date
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

-- Assign converted SaleDate to new column
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Begin populating missing property address data

-- Extract all records, ordered by ParcelID for review
Select *
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID

-- Update null PropertyAddress based on the same ParcelID
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Begin breaking out address into individual columns (Address, City, State)

-- Create new columns for split address components
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

-- Update new columns with split address components
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- Begin splitting OwnerAddress into individual components (Address, City, State)

-- Create new columns for split OwnerAddress components
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

-- Update new columns with split OwnerAddress components
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Begin changing 'Y' and 'N' to 'Yes' and 'No' in "Sold as Vacant" field

-- Convert 'Y' and 'N' to 'Yes' and 'No' respectively
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Begin removing duplicate records

-- Create a temporary table with row numbers for each record partitioned by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
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

From PortfolioProject.dbo.NashvilleHousing
)

-- Select duplicates for review
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Begin deleting unused columns

-- Drop unused columns
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
