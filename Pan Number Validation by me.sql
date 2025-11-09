use pan_card_validation;
select *from `stg_pan_number_dataset`;
select count(*) from `stg_pan_number_dataset`;

-- Identify and handle missing data:
select * from stg_pan_number_dataset where pan_number = "";
select count(*) from stg_pan_number_dataset where pan_number = "";

-- check for duplicates
select pan_number,count(*)as cnt from stg_pan_number_dataset
group by pan_number
having count(*) >1;

-- handling leading and trailing spaces
select pan_number from stg_pan_number_dataset
where pan_number <> trim(pan_number);

-- Correct letter case
select * from stg_pan_number_dataset
where binary pan_number <> UPPER(pan_number);

-- Cleaned Pan Numbers

select distinct upper(trim(pan_number)) as pan_number
from stg_pan_number_dataset where pan_number <> "" ;

select distinct count(upper(trim(pan_number))) as pan_number
from stg_pan_number_dataset where pan_number <> "" ;

-- Update Clean Data
/*update stg_pan_number_dataset
set pan_number = Upper(trim(pan_number))
where pan_number <> "";*/

-- function to check if adjacent characters are the same
-- Step 1: Set a new delimiter so we can write function body
DELIMITER $$

-- Step 2: Create a function to check adjacent duplicate characters
CREATE FUNCTION fun_check_adjacent_characters(p_str TEXT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    -- Declare loop counter
    DECLARE i INT DEFAULT 1;

-- Function to check if sequencial characters are used

    -- Step 3: Loop through the string from first character to second-last character
    WHILE i < CHAR_LENGTH(p_str) DO -- DO kahta h ki condition true h to niche wali statement execute kro

        -- Step 4: Compare current character with the next character
        IF SUBSTRING(p_str, i, 1) = SUBSTRING(p_str, i + 1, 1) THEN
            -- If adjacent characters are same, return TRUE immediately
            RETURN TRUE;
        END IF;

        -- Step 5: Move to the next character
        SET i = i + 1;
    END WHILE;

    -- Step 6: If loop completes without finding duplicates, return FALSE
    RETURN FALSE;
END$$

-- Step 7: Reset delimiter back to default
DELIMITER ;

select fun_check_adjacent_characters('AADER')



-- Function to check if sequencial characters are used

DELIMITER $$
CREATE FUNCTION fn_check_strict_sequence(p_str TEXT) RETURNS BOOLEAN DETERMINISTIC
BEGIN
    DECLARE i INT DEFAULT 1; -- loop counter
    DECLARE curr CHAR(1);
    DECLARE next CHAR(1);
    
    IF p_str IS NULL OR CHAR_LENGTH(p_str) = 0 THEN
        RETURN FALSE;
    END IF;
    
    SET curr = SUBSTRING(p_str, 1, 1);
    
    -- Loop through string from first to second-last character
    WHILE i < CHAR_LENGTH(p_str) DO
        SET next = SUBSTRING(p_str, i+1, 1);
        
        -- Check if next character is exactly +1 in ASCII
        IF ASCII(next) != ASCII(curr) + 1 THEN
            RETURN FALSE; -- sequence broken
        END IF;
        
        SET curr = next;
        SET i = i + 1; -- move to next character
    END WHILE;
    
    RETURN TRUE; -- entire string is a single sequence
END$$
DELIMITER ;

select fn_check_strict_sequence("ADCE");
select fn_check_strict_sequence("ABCDE");

-- Regular expression to validate the pattern or structure of PAN Numbers -- AAAAA1234A
SELECT *
FROM stg_pan_number_dataset
WHERE pan_number REGEXP '^[A-Z]{5}[0-9]{4}[A-Z]$';

-- Valid and Invalid Pan categorization
with cte_valid_pan as (
select distinct upper(trim(pan_number)) as pan_number
from stg_pan_number_dataset where pan_number <> "")
select * 
from cte_valid_pan
where fun_check_adjacent_characters(pan_number) = false
and fn_check_strict_sequence(substring(pan_number,1,5)) = false
and fn_check_strict_sequence(substring(pan_number,6,4)) = false
and pan_number REGEXP '^[A-Z]{5}[0-9]{4}[A-Z]$';

with cte_valid_pan as (
select distinct upper(trim(pan_number)) as pan_number
from stg_pan_number_dataset where pan_number <> "")
select count(*)
from cte_valid_pan
where fun_check_adjacent_characters(pan_number) = false
and fn_check_strict_sequence(substring(pan_number,1,5)) = false
and fn_check_strict_sequence(substring(pan_number,6,4)) = false
and pan_number REGEXP '^[A-Z]{5}[0-9]{4}[A-Z]$';

-- VALID /INVALID PAN NUMBER STATUS
WITH cte_cleaned_pan AS (
    SELECT DISTINCT UPPER(TRIM(pan_number)) AS pan_number
    FROM stg_pan_number_dataset
    WHERE pan_number <> ''
),
cte_valid_pan AS (
    SELECT *
    FROM cte_cleaned_pan
    WHERE fun_check_adjacent_characters(pan_number) = FALSE
      AND fn_check_strict_sequence(SUBSTRING(pan_number,1,5)) = FALSE
      AND fn_check_strict_sequence(SUBSTRING(pan_number,6,4)) = FALSE
      AND pan_number REGEXP '^[A-Z]{5}[0-9]{4}[A-Z]$'
)
SELECT 
    cln.pan_number,
    CASE 
        WHEN vld.pan_number IS NOT NULL THEN 'Valid PAN'
        ELSE 'Invalid PAN'
    END AS Status
FROM cte_cleaned_pan AS cln
LEFT JOIN cte_valid_pan AS vld 
       ON vld.pan_number = cln.pan_number;


-- CREATE VIEW FOR PAN VALIDATION
create view vw_valid_invalid_pans
as 
WITH cte_cleaned_pan AS (
    SELECT DISTINCT UPPER(TRIM(pan_number)) AS pan_number
    FROM stg_pan_number_dataset
    WHERE pan_number <> ''
),
cte_valid_pan AS (
    SELECT *
    FROM cte_cleaned_pan
    WHERE fun_check_adjacent_characters(pan_number) = FALSE
      AND fn_check_strict_sequence(SUBSTRING(pan_number,1,5)) = FALSE
      AND fn_check_strict_sequence(SUBSTRING(pan_number,6,4)) = FALSE
      AND pan_number REGEXP '^[A-Z]{5}[0-9]{4}[A-Z]$'
)
SELECT 
    cln.pan_number,
    CASE 
        WHEN vld.pan_number IS NOT NULL THEN 'Valid PAN'
        ELSE 'Invalid PAN'
    END AS Status
FROM cte_cleaned_pan AS cln
LEFT JOIN cte_valid_pan AS vld 
       ON vld.pan_number = cln.pan_number;

select * from vw_valid_invalid_pans;


-- SUMMARY REPORT
-- `stg_pan_number_dataset`
-- vw_valid_invalid_pans

SELECT
	(select count(*) FROM `stg_pan_number_dataset`) AS total_processed_records,
    SUM(CASE WHEN status = 'Valid PAN'   THEN 1 ELSE 0 END) AS total_valid_pans,
    SUM(CASE WHEN status = 'Invalid PAN' THEN 1 ELSE 0 END) AS total_invalid_pans
FROM vw_valid_invalid_pans;



-- MISSING PAN RECORD
with cte as (
SELECT
	(select count(*) FROM `stg_pan_number_dataset`) AS total_processed_records,
    SUM(CASE WHEN status = 'Valid PAN'   THEN 1 ELSE 0 END) AS total_valid_pans,
    SUM(CASE WHEN status = 'Invalid PAN' THEN 1 ELSE 0 END) AS total_invalid_pans
FROM vw_valid_invalid_pans)
select total_processed_records,total_valid_pans,total_invalid_pans,
(total_processed_records -(total_valid_pans + total_invalid_pans)) as total_missing_pans
from cte;

