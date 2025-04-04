/*1.As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data. Your Task is to know how many people were
 employed IN different types of companies AS per their size IN 2021.*/
-- Select company size and count of employees for each size.
SELECT company_size, COUNT(company_size) AS 'COUNT of employees' 
FROM salaries 
WHERE work_year = 2021 
GROUP BY company_size;
             -- OR
-- Alternatively, use a subquery to achieve the same result.
SELECT company_size, COUNT(company_size) 
FROM
(
    -- Subquery selects data for the year 2021.
    SELECT * FROM salaries WHERE work_year = 2021
) t 
GROUP BY company_size;





/*2.Imagine you are a talent Acquisition specialist Working for an International recruitment agency. Your Task is to identify the top 3 job titles that 
command the highest average salary Among part-time Positions IN the year 2023.*/
SELECT job_title, AVG(salary_in_usd) AS 'average' 
FROM salaries  
WHERE employment_type = 'PT'  
GROUP BY job_title 
ORDER BY AVG(salary_IN_usd) DESC 
LIMIT 3;   -- limiting only top 3






/*3.As a database analyst you have been assigned the task to Select Countries where average mid-level salary is higher than overall mid-level salary for the year 2023.*/

-- Calculate the average mid-level salary and store it in a variable
SET @average = (SELECT AVG(salary_IN_usd) AS 'average' FROM salaries WHERE experience_level='MI');

-- Select company location and average mid-level salary for countries where the salary exceeds the calculated average.
SELECT company_location, AVG(salary_IN_usd) 
FROM salaries 
WHERE experience_level = 'MI' AND salary_IN_usd > @average 
GROUP BY company_location;





/*4.As a database analyst you have been assigned the task to Identify the company locations with the highest and lowest average salary for 
senior-level (SE) employees in 2023.*/

-- Set the delimiter for the stored procedure
DELIMITER //

CREATE PROCEDURE GetSeniorSalaryStats()
BEGIN
    -- Query to find the highest average salary for senior-level employees in 2023
    SELECT company_location AS highest_location, AVG(salary_in_usd) AS highest_avg_salary
    FROM  salaries
    WHERE work_year = 2023 AND experience_level = 'SE'
    GROUP BY company_location
    ORDER BY highest_avg_salary DESC
    LIMIT 1;

    -- Query to find the lowest average salary for senior-level employees in 2023
    SELECT company_location AS lowest_location, AVG(salary_in_usd) AS lowest_avg_salary
    FROM  salaries
    WHERE work_year = 2023 AND experience_level = 'SE'
    GROUP BY company_location
    ORDER BY lowest_avg_salary ASC
    LIMIT 1;
END //

-- Reset the delimiter back to semicolon
DELIMITER ;

-- Call the stored procedure to get the results
CALL GetSeniorSalaryStats();




/*5. You're a Financial analyst Working for a leading HR Consultancy, and your Task is to Assess the annual salary growth rate for various job titles. 
By Calculating the percentage Increase IN salary FROM previous year to this year, you aim to provide valuable Insights Into salary trends WITHIN different job roles.*/

WITH t AS    -- creating common table expression.
(
    -- Subquery to calculate average salary for each job title in 2023 and 2024
    SELECT a.job_title, average_2023, average_2024 FROM
    (
        -- Subquery to calculate average salary for each job title in 2023
        SELECT job_title , AVG(salary_IN_usd) AS average_2023 
        FROM salaries 
        WHERE work_year = 2023 
        GROUP BY job_title
    ) a
    -- Inner join with subquery to calculate average salary for each job title in 2024
    INNER JOIN
    (
        -- Subquery to calculate average salary for each job title in 2024
        SELECT job_title , AVG(salary_IN_usd) AS average_2024 
        FROM salaries 
        WHERE work_year = 2024 
        GROUP BY job_title
    ) b ON a.job_title = b.job_title
)
-- Final query to calculate percentage change in salary from 2023 to 2024 for each job title
SELECT *, ROUND((((average_2024-average_2023)/average_2023)*100),2) AS 'percentage_change' 
FROM t;

 
 
 
 
 /*6. You've been hired by a global HR Consultancy to identify Countries experiencing significant salary growth for entry-level roles. Your task is to list the top three 
 Countries with the highest salary growth rate FROM 2020 to 2023, helping multinational Corporations identify  Emerging talent markets.*/

WITH t AS   -- creating CTE
(
    -- Subquery to calculate average salary for entry-level roles in 2021 and 2023
    SELECT 
        company_location, 
        work_year, 
        AVG(salary_in_usd) as average 
    FROM 
        salaries 
    WHERE 
        experience_level = 'EN' 
        AND (work_year = 2021 OR work_year = 2023)
    GROUP BY  
        company_location, 
        work_year
)
-- Main query to calculate percentage change in salary from 2021 to 2023 for each country
SELECT 
    *, 
    (((AVG_salary_2023 - AVG_salary_2021) / AVG_salary_2021) * 100) AS changes
FROM
(
    -- Subquery to pivot the data and calculate average salary for each country in 2021 and 2023
    SELECT 
        company_location,
        MAX(CASE WHEN work_year = 2021 THEN average END) AS AVG_salary_2021,
        MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023
    FROM 
        t 
    GROUP BY 
        company_location
) a 
-- Filter out null values and select the top three countries with the highest salary growth rate
WHERE 
    (((AVG_salary_2023 - AVG_salary_2021) / AVG_salary_2021) * 100) IS NOT NULL  
ORDER BY 
    (((AVG_salary_2023 - AVG_salary_2021) / AVG_salary_2021) * 100) DESC 
    limit 3 ;







/* 7.Picture yourself as a data architect responsible for database management. Companies in US and AU(Australia) decided to create a hybrid model for employees 
 they decided that employees earning salaries exceeding $90000 USD, will be given work from home. You now need to update the remote work ratio for eligible employees,
 ensuring efficient remote work management while implementing appropriate error handling mechanisms for invalid input parameters.*/
 
 
 create  table camp  as select * from   salaries;  -- creating temporary table so that changes are not made in actual table as actual table is being used in other cases also.
 
 -- by default mysql runs on safe update mode , this mode  is a safeguard against updating
 -- or deleting large portion of  a table.
 -- We will turn off safe update mode using set_sql_safe_updates
 
SET SQL_SAFE_UPDATES = 0;
 

UPDATE camp 
SET remote_ratio = 100
WHERE (company_location = 'AU' OR company_location ='US')AND salary_in_usd > 90000;

select * from camp where (company_location = 'AU' OR company_location ='US')AND salary_in_usd > 90000;



/* 8. In year 2024, due to increase demand in data industry , there was  increase in salaries of data field employees.
                   Entry Level-35%  of the salary.
                   Mid junior – 30% of the salary.
                   Immediate senior level- 22% of the salary.
                   Expert level- 20% of the salary.
                   Director – 15% of the salary.
you have to update the salaries accordingly and update it back in the original database. */

UPDATE camp
SET salary_in_usd = 
    CASE 
        WHEN experience_level = 'EN' THEN salary_in_usd * 1.35  -- Increase salary for Entry Level by 35%
        WHEN experience_level = 'MI' THEN salary_in_usd * 1.30  -- Increase salary for Mid Junior by 30%
        WHEN experience_level = 'SE' THEN salary_in_usd * 1.22  -- Increase salary for Immediate Senior Level by 22%
        WHEN experience_level = 'EX' THEN salary_in_usd * 1.20  -- Increase salary for Expert Level by 20%
        WHEN experience_level = 'DX' THEN salary_in_usd * 1.15  -- Increase salary for Director by 15%
        ELSE salary_in_usd  -- Keep salary unchanged for other experience levels
    END
WHERE work_year = 2024;  -- Update salaries only for the year 2024





/*9. You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title.*/
WITH avg_salary_per_year AS 
(
    -- Calculate the average salary for each job title in each year
    SELECT work_year, job_title, AVG(salary_in_usd) AS avg_salary 
    FROM salaries
    GROUP BY work_year, job_title
)

SELECT job_title, work_year, avg_salary FROM 
    (
       -- Rank the average salaries for each job title in each year
       SELECT job_title, work_year, avg_salary, RANK() OVER (PARTITION BY job_title ORDER BY avg_salary DESC) AS rank_by_salary
	   FROM avg_salary_per_year
    ) AS ranked_salary
WHERE 
    rank_by_salary = 1; -- Select the records where the rank of average salary is 1 (highest)
    
    
    
    
    
/*10. You have been hired by a market research agency where you been assigned the task to show the percentage of different employment type (full time, part time) in 
Different job roles, in the format where each row will be job title, each column will be type of employment type and  cell value  for that row and column will show 
the % value*/
SELECT 
    job_title,
    ROUND((SUM(CASE WHEN employment_type = 'PT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS PT_percentage, -- Calculate percentage of part-time employment
    ROUND((SUM(CASE WHEN employment_type = 'FT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS FT_percentage, -- Calculate percentage of full-time employment
    ROUND((SUM(CASE WHEN employment_type = 'CT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS CT_percentage, -- Calculate percentage of contract employment
    ROUND((SUM(CASE WHEN employment_type = 'FL' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS FL_percentage -- Calculate percentage of freelance employment
FROM 
    salaries
GROUP BY 
    job_title; -- Group the result by job title
   