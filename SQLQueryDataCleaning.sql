--SELECT *
--FROM [HousingData].dbo.[NashvilleHousing]

------------------------- ######################### -------------------------
-- Standardize Date Format of the dataset
-- Convert DateTime to just Date Format

-- Check How the Converted Data Looks like
--SELECT saledate, CONVERT(date, saledate)
--FROM [HousingData].dbo.[NashvilleHousing]

-- One method is to update the whole column itself using the CONVERT method
-- Not reliable sometimes
--UPDATE [HousingData].dbo.[NashvilleHousing]
--SET SaleDate = CONVERT(date, saledate)

-- ALTER the table and add a null column named SaleDateConverted
-- This column is the preferred way of saving just date
-- Check whether a particular column is there in a particular table
--IF COL_LENGTH('NashvilleHousing', 'SaleDateConverted') IS NULL
--BEGIN
--	ALTER TABLE [HousingData].dbo.[NashvilleHousing]
--	ADD SaleDateConverted Date;
--END

-- Update the particular column and visualize it
--UPDATE [HousingData].dbo.[NashvilleHousing]
--SET SaleDateConverted = CONVERT(date, saledate)

--SELECT SaleDateConverted, CONVERT(date, saledate)
--FROM [HousingData].dbo.[NashvilleHousing]

-- Delete the column from the dataset at the end


------------------------- ######################### -------------------------
-- Populate Property Address date
-- From the data we can say that Parcel ID is nothing but Property Address.
-- Thus using the Parcel ID we can populate the Property Address
--SELECT *
--FROM [HousingData].dbo.[NashvilleHousing]
--ORDER BY ParcelID
--WHERE PropertyAddress is NULL


-- This part shows us the updated value of the data_1 (NashvilleHousing)
-- That is our original table named NashvilleHousing
--SELECT data_1.ParcelID, data_1.PropertyAddress, data_2.ParcelID, data_2.PropertyAddress,
--	ISNULL(data_1.PropertyAddress, data_2.PropertyAddress)
--FROM [HousingData].dbo.[NashvilleHousing] data_1
--JOIN [HousingData].dbo.[NashvilleHousing] data_2
--	ON data_1.ParcelID = data_2.ParcelID
--	AND data_1.[UniqueID] <> data_2.[UniqueID]
--WHERE data_1.PropertyAddress IS NULL

UPDATE data_1
SET PropertyAddress = ISNULL(data_1.PropertyAddress, data_2.PropertyAddress)
FROM [HousingData].dbo.[NashvilleHousing] data_1
JOIN [HousingData].dbo.[NashvilleHousing] data_2
	ON data_1.ParcelID = data_2.ParcelID
	AND data_1.[UniqueID] <> data_2.[UniqueID]