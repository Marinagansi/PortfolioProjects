--cleaning data in sql queries
select *
from PortfolioProject..NashvilleHousing

--stadardlize Date format

Alter Table NashvilleHousing
Add SaleDatecoverted Date;

update NashvilleHousing
set SaleDatecoverted= Convert(Date, SaleDate)

--populate property address data

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

--breaking out address into individual columns(Address, City, state)

select 
Substring(PropertyAddress,1,charIndex(',',PropertyAddress)-1 ) as address,
Substring(PropertyAddress,charIndex(',',PropertyAddress)+1,len(PropertyAddress) )
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add propertySplitAddress varchar(255) ;

update NashvilleHousing
set propertySplitAddress= Substring(PropertyAddress,1,charIndex(',',PropertyAddress)-1 )


Alter Table NashvilleHousing
Add propertySplitCity varchar(255) ;

update NashvilleHousing
set propertySplitCity= Substring(PropertyAddress,charIndex(',',PropertyAddress)+1,len(PropertyAddress) )


--populate owner address
select OwnerAddress
from PortfolioProject..NashvilleHousing

select
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress varchar(255),
	OwnerSplitCity varchar(255),
	OwnerSplitState varchar(255) ;

update NashvilleHousing
set OwnerSplitAddress= parsename(replace(OwnerAddress,',','.'),3)

update NashvilleHousing
set	OwnerSplitCity= parsename(replace(OwnerAddress,',','.'),2)
	
	
update NashvilleHousing
set OwnerSplitState=parsename(replace(OwnerAddress,',','.'),1)

--chnage Y and N to yes to No in 'sold as vacant' field
select Distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

update NashvilleHousing
set SoldAsVacant= case when SoldAsVacant='y' Then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end

--remove duplicates
with RowNumCTE as(
select *,
row_number() over(
partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			Legalreference
			order  by uniqueID)row_num
from PortfolioProject..NashvilleHousing
)
Delete 
from RowNumCTE
where row_num>1

---delete unused columns
Alter Table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict,PropertyAddress

