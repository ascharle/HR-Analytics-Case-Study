SELECT *
FROM employees.employee
LIMIT 5;

-- Let’s inspect the titles for the 5th row of data from our 
-- employee table for and employee named Kyoichi Maliniak 
-- with employee_id = 10005

SELECT * 
FROM employees.title
WHERE employee_id = 10005
ORDER BY from_date;

--- Check employee_id 10005’s records for this table ordered by the 
---from_date ascending from earliest to latest to checkout his salary
--- growth over the years with the company

SELECT *
FROM employees.salary
WHERE employee_id = 10005
ORDER BY from_date;

--- Let’s continue with Kyoichi’s records to see if he’s 
--- moved around the company

SELECT * 
FROM employees.department_employee
WHERE employee_id = 10005
ORDER BY from_date;

--- It seems that Kyoichi has been loyal to department_id = 'd003' 
--- throughout his career so far. Let’s quickly look for another employee 
--- who has been in the most departments!

SELECT 
  employee_id,
  COUNT(DISTINCT department_id) AS unique_departments
FROM employees.department_employee
GROUP BY employee_id
ORDER BY unique_departments DESC
LIMIT 5;

--- It looks like the most number of departments for any employee is a
--- max of 2 - so let’s just quickly take a look at employee_id = 10029

SELECT *
FROM employees.department_employee
WHERE employee_id = 10029
ORDER BY from_date;

--- Great we can see that they’ve changed departments from d004 to d006 
---in 1999-07-08 

--- the employees.department_manager table shows the employee_id of the 
---manager of each department throughout time 
--- To inspect this dataset - how about we take a look at that department_id = 'd004' record:

SELECT *
FROM employees.department_manager
WHERE department_id = 'd004'
ORDER BY from_date;

--- Now we know the current and previous managers of department_id d004 - 
--- Well at least we know their employee_id, we’ll need to join back onto the 
--- employees.employee table to grab out more of their personal details.

--- Inspecting how many departments we are dealing with here sorting by 
--- that id string field just so we can see that final number increasing:

--- make a copy of the employees.department table just for completeness 
--- and uniformity in our approach!

-- employee
DROP TABLE IF EXISTS temp_employee;
CREATE TABLE temp_employee AS
SELECT * FROM employees.employee;

-- temp department employee
DROP TABLE IF EXISTS temp_department;
CREATE TEMP TABLE temp_department AS
SELECT * FROM employees.department;

-- temp department employee
DROP TABLE IF EXISTS temp_department_employee;
CREATE TEMP TABLE temp_department_employee AS
SELECT * FROM employees.department_employee;

-- department manager
DROP TABLE IF EXISTS temp_department_manager;
CREATE TEMP TABLE temp_department_manager AS
SELECT * FROM employees.department_manager;

-- salary
DROP TABLE IF EXISTS temp_salary;
CREATE TEMP TABLE temp_salary AS
SELECT * FROM employees.salary;

-- title
DROP TABLE IF EXISTS temp_title;
CREATE TEMP TABLE temp_title AS
SELECT * FROM employees.title;


--- We also need to use the + INTERVAL '18 YEARS' syntax to update our 
--- date values.

-- update temp_employee
-- ??? Why don't we need to check the date = '9999-01-01' for these columns
UPDATE temp_employee
SET hire_date = hire_date + INTERVAL '18 YEARS';

UPDATE temp_employee
SET birth_date = birth_date + INTERVAL '18 YEARS';

-- update temp_department_employee
-- ??? Why don't we need to check the date = '9999-01-01' for this column
UPDATE temp_department_employee SET
from_date = from_date + INTERVAL '18 YEARS';

UPDATE temp_department_employee
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';

-- update temp_department_manager
UPDATE temp_department_manager
SET from_date = from_date + INTERVAL '18 YEARS';

UPDATE temp_department_manager
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';

-- update temp_salary
UPDATE temp_salary
SET from_date = from_date + INTERVAL '18 YEARS';

UPDATE temp_salary
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';

-- update temp_title
UPDATE temp_title
SET from_date = from_date + INTERVAL '18 YEARS';

UPDATE temp_title
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';


--- Comparing the top few rows from original employees.employee table 
--- with the updated temp_employee to make sure our dates are corrected as expected

SELECT * FROM employees.employee ORDER BY id LIMIT 10;
SELECT * FROM temp_employee ORDER BY id LIMIT 10;

-- Creating Views 

DROP SCHEMA IF EXISTS v_employees CASCADE;
CREATE SCHEMA v_employees;

-- department
DROP VIEW IF EXISTS v_employee.department;
CREATE VIEW v_employees.department AS
SELECT * FROM employees.department;

-- department employee
DROP VIEW IF EXISTS v_employees.department_employee;
CREATE VIEW v_employees.department_employee AS
SELECT
  employee_id,
  department_id,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.department_employee;

-- department manager
DROP VIEW IF EXISTS v_employees.department_manager;
CREATE VIEW v_employees.department_manager AS
SELECT
  employee_id,
  department_id,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.department_manager;

-- employee
DROP VIEW IF EXISTS v_employees.employee;
CREATE VIEW v_employees.employee AS
SELECT
  id,
  birth_date + interval '18 years' AS birth_date,
  first_name,
  last_name,
  gender,
  hire_date + interval '18 years' AS hire_date
FROM employees.employee;

-- salary
DROP VIEW IF EXISTS v_employees.salary;
CREATE VIEW v_employees.salary AS
SELECT
  employee_id,
  amount,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.salary;

-- title
DROP VIEW IF EXISTS v_employees.title;
CREATE VIEW v_employees.title AS
SELECT
  employee_id,
  title,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.title;

