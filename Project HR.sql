-- Set project as default
USE projects;
-- View a sample of our data
SELECT * FROM hr;

-- Start our data cleaning by renaming the id column to employer id
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

-- Check the data types of all the columns
DESCRIBE hr;

-- Next is the birthdate column which has multiple text pattern for the dates
SELECT birthdate FROM hr;
-- Using a case when statement to change this, but this code will not work because of the restriction on this column, so
-- we remove this with set sql code and change this back to 1 after because of security
SET sql_safe_updates = 0;
UPDATE hr
	SET birthdate = CASE
			WHEN birthdate LIKE '%/%' THEN date_format( str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
            WHEN birthdate LIKE '%-%' THEN date_format( str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d') 
            ELSE NULL
		END;
        
-- Now you can change the data type of the birthdate column because it is initially in text data type
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;   

-- Make the same changes to the hire date   
UPDATE hr
	SET hire_date = CASE
			WHEN hire_date LIKE '%/%' THEN date_format( str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
            WHEN hire_date LIKE '%-%' THEN date_format( str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d') 
            ELSE NULL
		END;  
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

SELECT hire_date FROM hr;


-- Make changes to the termination date column by removing the time stamp
SELECT termdate FROM hr;

UPDATE hr 
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

-- Change termdate column to date data type
ALTER TABLE hr
MODIFY COLUMN termdate DATE;
 
 -- Adding an age column and calculate the age
 ALTER TABLE hr
 ADD COLUMN age INT; 
 
 UPDATE hr
 SET age = timestampdiff(YEAR, birthdate, CURDATE());
 SELECT birthdate, age FROM hr;
 
 -- Check the age range for outliers
 SELECT 
	MIN(age) as youngest,
    MAX(age) as oldest
FROM hr;

-- ANALYSIS
-- 1. Calculating the gender break down of the company
SELECT gender, COUNT(gender) FROM hr as gender_count
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of the employees
SELECT race, COUNT(race) FROM hr AS race_count
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY COUNT(race) DESC;

-- 3. What is the age distribution of the employees
  SELECT 
	MIN(age) as youngest,
    MAX(age) as oldest
FROM hr
WHERE age >=18 AND termdate = '0000-00-00';

SELECT CASE
		WHEN age >=18 AND age <= 24 THEN '18-24'
		WHEN age >=25 AND age <= 34 THEN '25-34'
		WHEN age >=35 AND age <= 44 THEN '35-44'
		WHEN age >=45 AND age <= 54 THEN '45-54'
		WHEN age >=55 AND age <= 64 THEN '55-64'
	ELSE '65+'
    END AS age_group,
    COUNT(age) AS age_count
    FROM hr
    WHERE age >=18 AND termdate = '0000-00-00'
    GROUP BY age_group
    ORDER BY age_group;
    
    
    SELECT CASE
		WHEN age >=18 AND age <= 24 THEN '18-24'
		WHEN age >=25 AND age <= 34 THEN '25-34'
		WHEN age >=35 AND age <= 44 THEN '35-44'
		WHEN age >=45 AND age <= 54 THEN '45-54'
		WHEN age >=55 AND age <= 64 THEN '55-64'
	ELSE '65+'
    END AS age_group,
    COUNT(age) AS age_count, gender
    FROM hr
    WHERE age >=18 AND termdate = '0000-00-00'
    GROUP BY age_group, gender
    ORDER BY age_group, gender;
    
-- 4.  How many employees work at the headquarters as against remotely
SELECT location, COUNT(location) FROM hr AS location_count  
 WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY location;
  
-- 5. How does the gernder distribution vary across department and job titles
 SELECT department, gender, COUNT(*) AS count FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department;

-- 6. What is the distribution of job titles in the company
SELECT jobtitle, COUNT(jobtitle) FROM hr 
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle; 

-- 7. What is the distribution of employees across city and state
SELECT location_state, COUNT(*) FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY COUNT(*);
 
-- 8. What is the average tenure distribution of each department
SELECT department, round(avg(datediff(termdate,hire_date)/365),0 ) AS avg_tenure FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >=18
GROUP BY department

 

