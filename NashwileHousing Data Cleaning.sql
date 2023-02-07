/*
Cleaning Data in SQL Queries
*/

Select * from PortfolioProject..NashwileHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDate,CONVERT(Date,SaleDate) 
from PortfolioProject..NashwileHousing

update NashwileHousing
SET SaleDate= CONVERT(Date,SaleDate) 

Alter Table NashwileHousing
Add SaleDateConverted Date; 

Update NashwileHousing 
SET SaleDateConverted = Convert(Date,SaleDate)



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select * 
from PortfolioProject..NashwileHousing
--where PropertyAddress is NULL
order by ParcelID


Select a.ParcelID,a.PropertyAddress,B.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashwileHousing a
join PortfolioProject..NashwileHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashwileHousing a
join PortfolioProject..NashwileHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)




Select PropertyAddress
from PortfolioProject..NashwileHousing
--where PropertyAddress is NULL
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from PortfolioProject..NashwileHousing

Alter Table NashwileHousing
Add PropertySplitAddresss Varchar(255); 

Update NashwileHousing 
SET PropertySplitAddresss = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)


Alter Table NashwileHousing
Add PropertySplitCity Varchar(255); 

Update NashwileHousing 
SET PropertySplitCity = 	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))



---Other Step For this 


Select OwnerAddress 
From PortfolioProject..NashwileHousing


Select PARSENAME(Replace(OwnerAddress,',','.'),3) ,
PARSENAME(Replace(OwnerAddress,',','.'),2) ,
PARSENAME(Replace(OwnerAddress,',','.'),1) 
From PortfolioProject..NashwileHousing



Alter Table NashwileHousing
Add OwnerSplitAddresss Varchar(255); 

Update NashwileHousing 
SET OwnerSplitAddresss = PARSENAME(Replace(OwnerAddress,',','.'),3)


Alter Table NashwileHousing
Add OwnerSplitCity Varchar(255); 

Update NashwileHousing 
SET OwnerSplitCity = 	PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashwileHousing
Add OwnerSplitState Varchar(255); 

Update NashwileHousing 
SET OwnerSplitState = 	PARSENAME(Replace(OwnerAddress,',','.'),1)












--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant
,Case When SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END     
 from PortfolioProject..NashwileHousing


Update NashwileHousing 
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END 

 from PortfolioProject..NashwileHousing




 Select Distinct(SoldasVacant),COUNT(SoldasVacant)
 From PortfolioProject..NashwileHousing
 Group by SoldAsVacant

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
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
	
 From PortfolioProject..NashwileHousing
 --Order by ParcelID
 ) 
 
 Select * from RowNumCTE 
 Where row_num>1
 Order by PropertyAddress





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



ALTER TABLE PortfolioProject..NashwileHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject..NashwileHousing
DROP COLUMN SaleDate


Select * from PortfolioProject..NashwileHousing









Select * from PortfolioProject..NashwileHousing
Where OwnerName is NULL 
and Acreage is NULL 
and LandValue is NULL




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


