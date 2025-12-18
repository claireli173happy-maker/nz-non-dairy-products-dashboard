
-- create id and set PK
Create table non_dairy_products(
id serial primary key,

company_name text,
company_address text,

product_name text,
product_description text,

code text,
code_decsription text,

approval_data date,
expiry_data date
);

-- check imported table
select *from non_dairy_products;
SELECT COUNT(*) FROM non_dairy_products;
select *from non_dairy_products limit 10;

-- Non-null completeness check
select 
count(*) AS total_rows,
count(company_name) AS company_name_non_null,
count(product_name) AS product_name_non_null,
count(code) AS code_non_null,
count(approval_data) AS approval_data_non_null,
count(expiry_data) AS expiry_data_non_null
from non_dairy_products;

-- duplicate check
select 
company_name,product_name,
code,
approval_data,
expiry_data,
count(*) AS common
from non_dairy_products
Group by 
company_name,
product_name,
code,
approval_data,
expiry_data
Having count(*)>1;

--  check suspected duplicate group
SELECT *
FROM non_dairy_products
WHERE company_name = 'Alpha Environmental Limited'
  AND product_name = 'Alphasan'
  AND code = 'C 102'
  AND approval_data = '2021-10-15'
  AND expiry_data = '2026-10-15';

-----------ANALYSIS

--Analyse the distribution of codes
--to identify the most commonly approved product categories
SELECT
code,
COUNT(*) AS code_count
FROM non_dairy_products
GROUP BY code
ORDER BY code_count DESC;

--show top 10 of codes
SELECT
code,
COUNT(*) AS code_count
FROM non_dairy_products
GROUP BY code
ORDER BY code_count DESC
limit 10;

--Top Companies by Product Count
SELECT
  company_name,
  COUNT(*) AS product_count
FROM non_dairy_products
GROUP BY company_name
ORDER BY product_count DESC
LIMIT 10;

--identifies products that are approaching their expiry dates 
--within the next year
select*
from non_dairy_products
where expiry_data< current_date + interval '1 year'
order by expiry_data;

----------Expiry Risk Distribution
--classifies products into expiry risk categories
--and calculates the number of products in each category

select
case 
when expiry_data< current_date then 'Expired'
when expiry_data< current_date + interval '6 months' then 'Expiring in 6 months'
when expiry_data< current_date + interval '1 years' then 'Expiring in 1 year'
else 'valid beyond 1 year'
end as expiry_status,
count(*) AS expiry_status_count
from non_dairy_products
group by expiry_status
ORDER BY expiry_status;

--product expiry risk at company-level
SELECT
company_name,
CASE
WHEN expiry_data < CURRENT_DATE THEN 'Expired'
WHEN expiry_data < CURRENT_DATE + INTERVAL '6 months' THEN 'Expiring in 6 months'
WHEN expiry_data < CURRENT_DATE + INTERVAL '1 year' THEN 'Expiring in 1 year'
ELSE 'Valid beyond 1 year'
END AS expiry_status,
COUNT(*) AS expiry_status_count
FROM non_dairy_products
GROUP BY company_name, expiry_status
ORDER BY company_name, expiry_status;


--generates a detailed product-level view by assigning an expiry status to each product 
--based on its expiry date
select
company_name,
product_name,
expiry_data,
case 
when expiry_data< current_date then 'Expired'
when expiry_data< current_date + interval '6 months' then 'Expiring in 6 months'
when expiry_data< current_date + interval '1 years' then 'Expiring in 1 year'
else 'valid beyond 1 year'
end as expiry_status
from non_dairy_products;

---choose product expired or expiring in 6 months 
select * 
from (
select
company_name,
product_name,
code,
expiry_data,
case 
when expiry_data< current_date then 'Expired'
when expiry_data< current_date + interval '6 months' then 'Expiring in 6 months'
when expiry_data< current_date + interval '1 years' then 'Expiring in 1 year'
else 'valid beyond 1 year'
end as expiry_status
from non_dairy_products
) where expiry_status IN ('Expired', 'Expiring in 6 months')
ORDER BY expiry_data;

----- choose product expiring in 6 months 
select * 
from (
select
company_name,
product_name,
code,
expiry_data,
case 
when expiry_data< current_date then 'Expired'
when expiry_data< current_date + interval '6 months' then 'Expiring in 6 months'
when expiry_data< current_date + interval '1 years' then 'Expiring in 1 year'
else 'valid beyond 1 year'
end as expiry_status
from non_dairy_products
) where expiry_status IN ('Expiring in 6 months')
ORDER BY expiry_data;

----choose directly product expiring in 6 months
SELECT
  company_name,
  product_name,
  product_description,
  code,
  expiry_data
FROM non_dairy_products
WHERE expiry_data < CURRENT_DATE + INTERVAL '6 months'
ORDER BY expiry_data; 

--Expiry duration
SELECT
product_name,
company_name,
expiry_data - approval_data AS valid_days
FROM non_dairy_products;

--the most popular company (top10)
Select
company_name,
COUNT(*) AS product_count
from non_dairy_products
group by company_name
order by product_count DESC
limit 10;

-- the most popular description/function (10)
select
product_description,
count(*) AS description_count
from non_dairy_products
group by product_description
order by description_count DESC;
limit 10;

-- Relationship between code and product function:
-- checks whether certain codes align with specific product descriptions.
select 
code, product_description,
count(*) AS cnt
from non_dairy_products
group by code, product_description
order by code, cnt DESC;


---kpls

SELECT
COUNT(*) AS total_products,
COUNT(DISTINCT company_name) AS total_companies,
SUM(CASE WHEN expiry_data < CURRENT_DATE THEN 1 ELSE 0 END) AS expired_products
FROM non_dairy_products;

