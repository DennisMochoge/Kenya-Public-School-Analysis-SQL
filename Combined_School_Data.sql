SELECT COUNT(*)
FROM dennis_projects.school_data
;

select *
from dennis_projects.school_data
LIMIT 10
;

-- To get to know where i will save the other files I proceed as follows:
SHOW VARIABLES LIKE 'secure_file_priv';

-- To see the column names proceed as follows:
SHOW COLUMNS FROM dennis_projects.school_data;

-- To add new files: 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tabula-C4 Senior Schools.csv'
INTO TABLE dennis_projects.school_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(`S/No.`, `REGION`, `COUNTY`, `SUB COUNTY`, `UIC`, `KNEC`, `SCHOOL NAME`, `CLUSTER`, `TYPE`,`(Regular/`, `DISABILITY`, `ACCOMODATI`, `GENDER`);

ALTER TABLE dennis_projects.school_data
ADD COLUMN id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

-- Just to be safe CREATE DUPLICATE before we start with data cleaning
CREATE TABLE backup_school_data AS
SELECT * 
FROM dennis_projects.school_data
;
-- Step 1: Drop the existing table
-- Step 2: Recreate the original table from the backup
DROP TABLE IF EXISTS dennis_projects.school_data;
CREATE TABLE dennis_projects.school_data AS
SELECT * FROM dennis_projects.backup_school_data;


-- to idenfify duplicates
SELECT 
    `S/No.`, `REGION`, `COUNTY`, `SUB COUNTY`, `UIC`, `KNEC`,
    `SCHOOL NAME`, `CLUSTER`, `TYPE`, `DISABILITY`, `ACCOMODATI`, `GENDER`,
    COUNT(*) AS repetitions	
FROM dennis_projects.school_data
GROUP BY 
    `S/No.`, `REGION`, `COUNTY`, `SUB COUNTY`, `UIC`, `KNEC`,
    `SCHOOL NAME`, `CLUSTER`, `TYPE`, `DISABILITY`, `ACCOMODATI`, `GENDER`
HAVING COUNT(*) > 1;
-- to delete the duplicates
DELETE s1
FROM dennis_projects.school_data s1
JOIN dennis_projects.school_data s2
  ON s1.`SCHOOL NAME` = s2.`SCHOOL NAME`
  AND s1.`UIC` = s2.`UIC`
  AND s1.`CLUSTER` = 'C3'
  AND s2.`CLUSTER` = 'C3'
  AND s1.id > s2.id;

-- since the above refused in the first intance and led to server disconnecting
-- I will find duplicate rows where both are "C3", Keeps the one with the lowest id (which means ill create a new ID column), Deletes the rest


-- I noticed that the column title for ACCOMODATION was wrongly misspelt
ALTER TABLE dennis_projects.school_data
CHANGE COLUMN `ACCOMODATI` `ACCOMODATION` text;

-- Now i want to identify potential typo
SELECT DISTINCT `REGION` 
FROM dennis_projects.school_data 
ORDER BY `REGION`;
-- to update the correct regions i proceed as follows
UPDATE dennis_projects.school_data
SET REGION = CASE
  WHEN REGION IN ('NORTH', 'EASNTEORNTH', 'ENAOSRTTEHR N', 'ENAOSTRETRHN', 'NOERATSHT ERN', 'NEAOSRTTEHR N') THEN 'NORTH EASTERN'
  WHEN REGION IN ('EASSTERN', 'EEASSTEERN', 'EEASSTTEERN') THEN 'EASTERN'
  WHEN REGION IN ('ENAYSATNEZRAN', 'NEAYSATNEZRAN') THEN 'NYANZA'
  WHEN REGION IN ('ERAIFSTT EVRANLLEY', 'RIFETA VSTAELRLENY') THEN 'RIFT VALLEY'
  ELSE REGION  -- Keep original if no match
END;

-- if i was just to update one set then i would have used this script to update
UPDATE dennis_projects.school_data SET REGION = 'NORTH EASTERN' WHERE REGION IN ('NORTH', 'EASNTEORNTH', 'ENAOSRTTEHR N', 'ENAOSTRETRHN', 'NOERATSHT ERN');

SELECT DISTINCT `COUNTY` 
FROM dennis_projects.school_data 
ORDER BY `COUNTY`;
-- Now i would like to update error county names
UPDATE dennis_projects.school_data
SET COUNTY = CASE
  WHEN COUNTY IN ('ELGMEAYROA KW', 'ELMGEAYROA KW', 'EMLAGREAYKOW', 'MARELAGKEWYO', 'MEALRGAEYKOW', 'MELAGREAYKOW') THEN 'ELGEYO'
  WHEN COUNTY IN ('EMMABRUAKW', 'MEMABRUAKW') THEN 'EMBU'
  WHEN COUNTY IN ('NITHIARAKA', 'NTHITAHRIAKA', 'THARAKA', 'THARNAITKHAI', 'THNAIRTHAKI A', 'TNHITAHRIAKA') THEN 'THARAKA NITHI'
  WHEN COUNTY IN ('TAIVTEAT A', 'TAVITEAT A', 'TTAIVTEAT A', 'TTAVITEAT A') THEN 'TAITA'
  WHEN COUNTY IN ('TAVNEAT RAIVER', 'TTANVEAT RAIVER') THEN 'TANA RIVER'
  WHEN COUNTY = 'TNRITAHNIS NZOIA' THEN 'TRANS NZOIA'
  ELSE COUNTY
END;

select *
from dennis_projects.school_data
LIMIT 10
;

CREATE TABLE backup_school_data2 AS
SELECT * 
FROM dennis_projects.school_data;

SELECT DISTINCT `GENDER` 
FROM dennis_projects.school_data 
ORDER BY `GENDER`;
-- make the data names we remove be capital letters
UPDATE dennis_projects.school_data
SET GENDER = UPPER(GENDER);
-- i still got a list of gender dubpplicate, hence use TRIM + Replace
UPDATE dennis_projects.school_data
SET GENDER = UPPER(TRIM(REPLACE(REPLACE(GENDER, '\r', ''), '\n', '')));

-- To backup my data while keeping the same table structure, instead of full DROP
-- Step 1: Delete old data
TRUNCATE TABLE dennis_projects.backup_school_data2;
-- Step 2: Insert new data
INSERT INTO dennis_projects.backup_school_data2
SELECT * FROM dennis_projects.school_data;

SELECT DISTINCT `SUB COUNTY` 
FROM dennis_projects.school_data 
ORDER BY `SUB COUNTY`
;
-- I have found more than 700 errors in sub-county, so ill just create another table with the updated names vs error names, and update using UPDATE JOIN
-- I CREATE table as follows:
CREATE TABLE dennis_projects.sub_county_mapping (
    error_sub_county VARCHAR(255),
    correct_sub_county VARCHAR(255)
);
-- Now i upload the data from csv file to the table i just created
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Updated Sub County.csv'
INTO TABLE dennis_projects.sub_county_mapping
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(`error_sub_county`, `correct_sub_county`)
;
-- confirm the table is updated
SELECT *
FROM dennis_projects.sub_county_mapping
;
-- Now I just want to update the main data with the updated names
UPDATE dennis_projects.school_data s
JOIN dennis_projects.sub_county_mapping m 
  ON TRIM(UPPER(s.`SUB COUNTY`)) = TRIM(UPPER(m.error_sub_county))
SET s.`SUB COUNTY` = m.correct_sub_county
;
-- i still got a list of gender dubpplicate, hence use TRIM + Replace
UPDATE dennis_projects.school_data
SET `SUB COUNTY` = UPPER(TRIM(REPLACE(REPLACE(`SUB COUNTY`, '\r', ''), '\n', '')))
;
-- Now i just need to update three more accounts
UPDATE dennis_projects.school_data SET `SUB COUNTY` = 'ATHI-RIVER' WHERE `SUB COUNTY` = 'ATHI-';
UPDATE dennis_projects.school_data SET `SUB COUNTY` = 'MUKURWE-INI' WHERE `SUB COUNTY` = 'MUKURWE-';
UPDATE dennis_projects.school_data SET `SUB COUNTY` = 'MUTITU' WHERE `SUB COUNTY` = 'MUTITU''';


SELECT DISTINCT `(Regular/` 
FROM dennis_projects.school_data 
ORDER BY `(Regular/` 
;
-- Update some fields in regular
UPDATE dennis_projects.school_data
SET `(Regular/` = CASE
  WHEN `(Regular/` IN ('DREGULAR', 'RDEGULAR', 'RSNEEG/ULAR', 'RSNEGE/ULAR') THEN 'REGULAR'
  WHEN `(Regular/` = 'SDNE' THEN 'SNE'
  ELSE `(Regular/`
END;


SELECT DISTINCT `DISABILITY` 
FROM dennis_projects.school_data 
ORDER BY `DISABILITY` 
;
UPDATE dennis_projects.school_data
SET DISABILITY = CASE
  WHEN DISABILITY IN ('NTOYNPE', 'NTOYNPEE', 'NTOYPNE', 'NTOYPNEE') THEN 'NONE'
  WHEN DISABILITY = 'HI' THEN 'H.I'
  WHEN DISABILITY = 'HIPHVI' THEN 'HI/PH/VI'
  WHEN DISABILITY = 'PH' THEN 'P.H'
  WHEN DISABILITY = 'VI' THEN 'V.I'
  ELSE DISABILITY
END;

SELECT DISTINCT `ACCOMODATION` 
FROM dennis_projects.school_data 
ORDER BY `ACCOMODATION`
;
-- Update some fields in Accomodation
UPDATE dennis_projects.school_data
SET `ACCOMODATION` = CASE
  WHEN `ACCOMODATION` IN ('BAORDING', 'BOONA TRYDPIENG') THEN 'BOARDING'
  WHEN `ACCOMODATION` = 'DOANY TYPE' THEN 'DAY'
  ELSE `ACCOMODATION`
END;

select *
from dennis_projects.school_data
;

-- Below is a way to assist me in getting the database to assist for POWER BI
SHOW DATABASES;	
USE dennis_projects;
SHOW TABLES;
