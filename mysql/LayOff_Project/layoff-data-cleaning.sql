select * from layoffs;
-- Create a Duplicate data (layoffs_staging) of layoffs so that if something happens to the current data we can have raw data safe.

-- Data Cleaning 
-- 1. Remove Duplicates 
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns

-- creating columns same as layoffs.
create table layoffs_staging
like layoffs;

select * from layoffs_staging;

-- Inserting the layoffs data in layoffs_staging.
INSERT layoffs_staging
select * 
from layoffs;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q1. Finding duplicates and removing

WITH duplicate_cte AS (
select *, ROW_NUMBER() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ) as row_num
from layoffs_staging
)
select * from duplicate_cte
where row_num > 1;

-- creating a new duplicate table to delete the duplicate row that occurs multiple time in a sheet. 
-- (Right click on layoffs_staging select copy to clipboard and then select create statement and then paste it. this is how you can create duplicate table.)

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int                                                       -- /// added new coloumn in duplicate table
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------  we did not have a unique coloumn that is why we have to add a row_no that is unique and with the help of row_no we can delete theduplicate data

INSERT INTO layoffs_staging2
select *, ROW_NUMBER() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ) as row_num
from layoffs_staging;

select * from layoffs_staging2;

-- checking the duplicate data existance
select * from layoffs_staging2
where row_num > 1;

-- Deleting the duplicate data
DELETE 
from layoffs_staging2
where row_num > 1;

-- checking duplicate data deleted or not (Yes it is deleted)
select * from layoffs_staging2
where row_num > 1;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Q2. Standardizing the Data (means finding issues and then fixing it).

-- The TRIM function in SQL is used to remove unwanted spaces or specific characters from the beginning (LEADING), end (TRAILING), or both sides (BOTH) of a string. 
-- It is commonly used for cleaning up data by eliminating extra spaces or characters.

select company, TRIM(company) from layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Industry coloumn
select DISTINCT(industry) from layoffs_staging2
order by 1;

-- There are multiple industry name called crypto and crypto Currency 
select * from layoffs_staging2
where industry LIKE 'Crypto%';

-- Now we have to update the data to crypto name only
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Country Coloumn
select DISTINCT(country) 
from layoffs_staging2
order by 1;

-- United States occur two time now need to fix this.

update layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


 -- ---------------------------------------------------------------------------------------------------------------------------------------------
-- date is in text formate. need to change it in dateandtime formate

select `date`
from layoffs_staging2;

 
select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

-- converting
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

-- output is in now date and time but layoffs_staging2 date coloumn is in still text to changethat
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

select *
from layoffs_staging2;


 -- ---------------------------------------------------------------------------------------------------------------------------------------------

-- Q3. Removing Null Values or Blank Values.


select *
from layoffs_staging2 
where industry is null or industry = '';


select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2  t2
on t1.company = t2.company
where (t1.industry is null or t1.industry = '') and t2.industry is not null;

-- now to remove the blank value first have to make blank value a null value 
UPDATE layoffs_staging2 
set industry = NULL
where industry = '';

-- now it is null we remove the null value 

update layoffs_staging2 t1
join layoffs_staging2  t2 on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null  and t2.industry is not null;

select *
from layoffs_staging2 
where company = 'Airbnb';

-- ---------------------------------------------------------------------------------------------------------------------------------------------

-- Q4. Remove Any Columns

select *
from layoffs_staging2 
where total_laid_off is null and percentage_laid_off is null;

DELETE 
from layoffs_staging2 
where total_laid_off is null and percentage_laid_off is null;

select *
from layoffs_staging2 ;






