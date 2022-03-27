SELECT *
FROM [HousingData].dbo.[NashvilleHousing]

------------------------- ######################### -------------------------
-- Standardize Date Format of the dataset
-- Convert DateTime to just Date Format

-- Check How the Converted Data Looks like
SELECT saledate, CONVERT(date, saledate)
FROM [HousingData].dbo.[NashvilleHousing]

-- One method is to update the whole column itself using the CONVERT method
-- Not reliable sometimes
UPDATE [HousingData].dbo.[NashvilleHousing]
SET SaleDate = CONVERT(date, saledate)

-- ALTER the table and add a null column named SaleDateConverted
-- This column is the preferred way of saving just date
-- Check whether a particular column is there in a particular table
IF COL_LENGTH('NashvilleHousing', 'SaleDateConverted') IS NULL
BEGIN
	ALTER TABLE [HousingData].dbo.[NashvilleHousing]
	ADD SaleDateConverted Date;
END

-- Update the particular column and visualize it
UPDATE [HousingData].dbo.[NashvilleHousing]
SET SaleDateConverted = CONVERT(date, saledate)

SELECT SaleDateConverted, CONVERT(date, saledate)
FROM [HousingData].dbo.[NashvilleHousing]

-- Delete the column from the dataset at the end


------------------------- ######################### -------------------------
-- Populate Property Address date
-- From the data we can say that Parcel ID is nothing but Property Address.
-- Thus using the Parcel ID we can populate the Property Address
SELECT *
FROM [HousingData].dbo.[NashvilleHousing]
WHERE PropertyAddress is NULL
ORDER BY ParcelID


-- This part shows us the updated value of the data_1 (NashvilleHousing)
-- That is our original table named NashvilleHousing
SELECT data_1.ParcelID, data_1.PropertyAddress, data_2.ParcelID, data_2.PropertyAddress,
	ISNULL(data_1.PropertyAddress, data_2.PropertyAddress)
FROM [HousingData].dbo.[NashvilleHousing] data_1
JOIN [HousingData].dbo.[NashvilleHousing] data_2
	ON data_1.ParcelID = data_2.ParcelID
	AND data_1.[UniqueID] <> data_2.[UniqueID]
WHERE data_1.PropertyAddress IS NULL

UPDATE data_1
SET PropertyAddress = ISNULL(data_1.PropertyAddress, data_2.PropertyAddress)
FROM [HousingData].dbo.[NashvilleHousing] data_1
JOIN [HousingData].dbo.[NashvilleHousing] data_2
	ON data_1.ParcelID = data_2.ParcelID
	AND data_1.[UniqueID] <> data_2.[UniqueID]

-- Let's check now there are any NULL PropertyAddress in the database
SELECT *
FROM [HousingData].dbo.[NashvilleHousing]
WHERE PropertyAddress is NULL
ORDER BY ParcelID


------------------------- ######################### -------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM [HousingData].dbo.[NashvilleHousing]
ORDER BY ParcelID

-- From Property Address there is just one delimeter a comma which separates out address and city
-- There is no state in the Property Address
-- Finally we will filter it out using a substring and character index
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM [HousingData].dbo.[NashvilleHousing]

-- We will create two new columns for Property Address and Property City
-- Update these both tables with what we did in the above query
IF COL_LENGTH('NashvilleHousing', 'PropertySplitAddress') IS NULL
BEGIN
	ALTER TABLE [HousingData].dbo.[NashvilleHousing]
	ADD PropertySplitAddress NVARCHAR(255);
END

UPDATE [HousingData].dbo.[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

---- Similary we do the same for the Property City as well
IF COL_LENGTH('NashvilleHousing', 'PropertySplitCity') IS NULL
BEGIN
	ALTER TABLE [HousingData].dbo.[NashvilleHousing]
	ADD PropertySplitCity NVARCHAR(255);
END

UPDATE [HousingData].dbo.[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


------------------------- ######################### -------------------------
-- Now lets do the same things for the owner address
-- In the case of owner address there are 3 attributes (Adress, City, State)
SELECT OwnerAddress
FROM [HousingData].dbo.[NashvilleHousing]

-- Now we will use Parse name instead of Substring
-- ParseName is only used for periods ('.' or full stop)
-- Thus we replace the Comma with period
-- But Parsename does everything backwards Thus we do 3, 2, 1
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerState
FROM [HousingData].dbo.[NashvilleHousing]

-- Add the column OwnerSplitAddress if it is not there in the Dataset
IF NOT EXISTS 
(
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME='NashvilleHousing' AND COLUMN_NAME='OwnerSplitAddress'
)
BEGIN
	ALTER TABLE NashvilleHousing
	ADD OwnerSplitAddress NVARCHAR(255);
END

UPDATE [HousingData].dbo.[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- Add the column OwnerSplitCity if it is not there in the Dataset
IF NOT EXISTS 
(
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME='NashvilleHousing' AND COLUMN_NAME='OwnerSplitCity'
)
BEGIN
	ALTER TABLE NashvilleHousing
	ADD OwnerSplitCity NVARCHAR(255);
END

UPDATE [HousingData].dbo.[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- Add the column OwnerSplitState if it is not there in the Dataset
IF NOT EXISTS 
(
	SELECT *
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME='NashvilleHousing' AND COLUMN_NAME='OwnerSplitState'
)
BEGIN
	ALTER TABLE NashvilleHousing
	ADD OwnerSplitState NVARCHAR(255);
END

UPDATE [HousingData].dbo.[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

SELECT *
FROM [HousingData].dbo.[NashvilleHousing]


------------------------- ######################### -------------------------
-- Make Sold As Vacant Column to just Yes and No
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [HousingData].dbo.[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [HousingData].dbo.[NashvilleHousing]

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


------------------------- ######################### -------------------------
-- Remove the Duplicates from th dataset
-- Usually we should create a duplicate table and store the distinct data in them.
-- Because that's the standard practice for SQL
-- But as of this project we are going to delete the duplicate the data

-- We are going to use CTE and windows functions to find the duplicate
WITH RowNumCTE AS
(
SELECT *,
	ROW_NUMBER() OVER
	(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
	) row_num
FROM [HousingData].dbo.[NashvilleHousing]
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Lets DELETE wherever there were duplicates and store it in a new table
DROP TABLE IF EXISTS NashvilleHousingNoDuplicates
-- Create new table same as NashvilleHousing Table 
SELECT * 
INTO [HousingData].dbo.[NashvilleHousingNoDuplicates]
FROM [HousingData].dbo.[NashvilleHousing];

-- Now let's remove the duplicates from new table
-- As RowNumRemoveCTE is temp table we need to create it and delete it
-- and later in order to view things we need to again create it and display it.

-- This time in order to delete the duplicates
WITH RowNumRemoveCTE AS
(
SELECT *,
	ROW_NUMBER() OVER
	(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
	) row_num
FROM [HousingData].dbo.[NashvilleHousingNoDuplicates]
)
DELETE
FROM RowNumRemoveCTE
WHERE row_num > 1;

-- This time in order to check there are no duplicates
WITH RowNumRemoveCTE AS
(
SELECT *,
	ROW_NUMBER() OVER
	(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
	) row_num
FROM [HousingData].dbo.[NashvilleHousingNoDuplicates]
)
SELECT *
FROM RowNumRemoveCTE
WHERE row_num > 1


------------------------- ######################### -------------------------
-- Delete Unused Columns
SELECT *
FROM [HousingData].dbo.[NashvilleHousingNoDuplicates]

ALTER TABLE [HousingData].dbo.[NashvilleHousingNoDuplicates]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAdress

ALTER TABLE [HousingData].dbo.[NashvilleHousingNoDuplicates]
DROP COLUMN SaleDate
