SELECT * FROM housing_data;

-- Standarize date format --
ALTER TABLE housing_data
MODIFY SaleDate DATE;

-- Populate Property ADdress --
SELECT t1.ParcelId,t1.PropertyAddress,t2.ParcelID,t2.PropertyAddress
FROM housing_data t1
JOIN housing_data t2
	ON t1.ParcelId = t2.ParcelId
	AND t1.UniqueId != t2.UniqueId
WHERE t1.PropertyAddress is null;

UPDATE housing_data t1
JOIN housing_data t2
    ON t1.ParcelId = t2.ParcelId
SET t1.PropertyAddress = t2.PropertyAddress
WHERE t1.PropertyAddress IS NULL
AND t2.PropertyAddress IS NOT NULL;


-- Breaking out address into individual columns (Address,City, State) --
SELECT PropertyAddress,SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress,LOCATE(',', PropertyAddress)+1,length(propertyaddress)) AS Address2
FROM housing_data;


ALTER TABLE housing_data
ADD Address TEXT;
UPDATE housing_data
SET Address = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE housing_data
ADD City TEXT;
UPDATE housing_data
SET City = SUBSTRING(PropertyAddress,LOCATE(',', PropertyAddress)+1,length(propertyaddress));


-- Breaking out owner address into individual columns --
SELECT OwnerAddress,
SUBSTRING_INDEX(OwnerAddress,',', 1) AS street_address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS city_address,
SUBSTRING_INDEX(OwnerAddress,',', -1) AS state_address
FROM housing_data;

ALTER TABLE housing_data
ADD street_address TEXT;
UPDATE housing_data
SET street_address = SUBSTRING_INDEX(OwnerAddress,',', 1);

ALTER TABLE housing_data
ADD city_address TEXT;
UPDATE housing_data
SET city_address = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1);

ALTER TABLE housing_data
ADD state_address TEXT;
UPDATE housing_data
SET state_address = SUBSTRING_INDEX(OwnerAddress,',', -1);

-- Change Y and N to YES and NO --
SELECT DISTINCT(SoldAsVacant) from housing_data;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM housing_data;

UPDATE housing_data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END;
     
-- Remove Duplicates --
SELECT * FROM housing_data;
 
SELECT UniqueID, COUNT(*) AS total_duplicados
FROM housing_data
GROUP BY LegalReference
HAVING COUNT(*) > 1;

WITH CTE AS (
SELECT *,
ROW_NUMBER() OVER( PARTITION BY 
ParcelId,PropertyAddress,SaleDate,SalePrice,LegalReference
ORDER BY UniqueID) AS row_num
FROM housing_data)
SELECT * 
FROM CTE
WHERE row_num>1;

DELETE FROM housing_data 
WHERE UniqueID IN (
    SELECT UniqueID FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (PARTITION BY ParcelId, PropertyAddress, SaleDate, SalePrice, LegalReference 
                                  ORDER BY UniqueID) AS row_num
        FROM housing_data
    ) AS subquery
    WHERE row_num > 1
);

