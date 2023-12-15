/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardizing Date Format

Select SaleDateConverted, Convert(Date, SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

--Alternative method because the first method did not work
Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From NashvilleHousing




Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.') ,3) as Address
, PARSENAME(Replace(OwnerAddress, ',', '.') ,2) as City
, PARSENAME(Replace(OwnerAddress, ',', '.') ,1) as State
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress  = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState  nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)

Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End

--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE as(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

From NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate