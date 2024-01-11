-- Milestone 4: Querying the data.

-- Your boss is excited that you now have the schema for the database and all the sales data is in one location.
-- Since you've done such a great job they would like 

-- The business can then start making more data-driven decisions and get a better understanding of its sales.
-- In this milestone, you will be tasked with answering business questions and extracting the data from the database using SQL.

-- The Operations team would like to know which countries we currently operate in and which country now has the most stores. 
-- Perform a query on the database to get the information, it should return the following information:

-- Task 1: How many stores does the business have and in which countries?
-- the query counts the number of stores for each country, groups the results by country, 
--and then orders the output in descending order based on the total number of stores. 
--This is useful for identifying which countries have the highest number of stores.

SELECT country_code, COUNT(*) AS total_no_stores
FROM dim_store_details
GROUP BY country_code
ORDER BY total_no_stores DESC;

-- The Operations team would like to know which countries we currently operate in and 
--which country now has the most stores. Perform a query on the database to get the information, 
--it should return the following information:
country total_no_stores
"GB"	266
"DE"	141
"US"	34
Note: DE is short for Deutschland(Germany)

-- Task 2: Which locations currently have the most stores?
--the query counts the number of stores for each locality, groups the results by locality, 
--orders the output in descending order based on the total number of stores, and finally, 
--limits the result to the top 7 localities. 
--This is useful for identifying the most prominent localities in terms of the number of stores.
SELECT locality, COUNT(*) AS total_no_stores
FROM dim_store_details
GROUP BY locality
ORDER BY total_no_stores DESC
LIMIT 7;  -- To limit the result to the top 7 locations

-- The business stakeholders would like to know which locations currently have the most stores.
--They would like to close some stores before opening more in other locations.
--Find out which locations have the most stores currently. The query should return the following:
locality		total_no_stores
"Chapletown"	14
"Belper"		13
"Bushey"		12
"Exeter"		11
"Arbroath"		10
"High Wycombe"	10
"Rutherglen"	10

--Task 3: Which months produced the largest amount of sales?
-- the query calculates the total sales for each month by joining information from different tables, 
--groups the results by month, orders the output in descending order based on total sales, and finally, 
--limits the result to the top 6 months. 
--This is useful for identifying the most profitable months based on total sales.

SELECT
  SUM(o.product_quantity * p.product_price_pound) AS total_sales,
  d.month AS months
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_date_times AS d ON d.date_uuid = o.date_uuid
GROUP BY
  d.month
ORDER BY
  total_sales DESC
LIMIT 6;

--Query the database to find out which months have produced the most sales. 
--The query should return the following information:

total_sales			month
673295.6800000012	"8"
668041.4500000016	"1"
657335.8400000016	"10"
650321.4300000013	"5"
645741.7000000014	"7"
645463.0000000012	"3"

-- Task 4: How many sales are coming from online?
--the query is used to fetch all unique store types present in the dim_store_details table. 
--The result set will contain each unique value found in the store_type column of the specified table.
SELECT DISTINCT store_type
FROM public.dim_store_details
--WHERE store_type = "Web Portal";
"Web Portal"
"Mall Kiosk"
"Super Store"
"Local"
"Outlet"

--The company is looking to increase its online sales.
--They want to know how many sales are happening online vs offline.
--Part 1 filters specific store types, and 
SELECT store_type
FROM public.dim_store_details
WHERE store_type in ('Mall Kiosk', 'Super Store', 'Local', 'Outlet');
--Part 2 performs aggregations and classifications based on store types, providing sales-related metrics.
SELECT
  CASE
    WHEN s.store_type = 'Web Portal' THEN 'Online'
    ELSE 'Offline'
  END AS location,
  COUNT(*) AS numbers_of_sales,
  SUM(o.product_quantity) AS product_quantity_count,
  SUM(o.product_quantity * p.product_price_pound) AS total_sales
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_store_details AS s ON o.store_code = s.store_code
GROUP BY
  location
ORDER BY
  total_sales DESC;
  
--Calculate how many products were sold and the amount of sales made for online and offline purchases.
--You should get the following information:
  location	numbers_of_sales	product_quantity_count	total_sales
"Offline"	93166				374047					5995786.589999987
"Online"	26957				107739					1726547.0499999681

--Task 5: What percentage of sales come through each type of store?
--this query calculates the total sales and the percentage of total sales for each specified store type, 
--considering the overall total sales. 
--The results are grouped by store type and ordered by total sales in descending order.
SELECT
  s.store_type,
  SUM(o.product_quantity * p.product_price_pound) AS total_sales,
  (SUM(o.product_quantity * p.product_price_pound) / total.total_sales) * 100 AS percentage_total
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_store_details AS s ON o.store_code = s.store_code,
  (SELECT SUM(o.product_quantity * p.product_price_pound) AS total_sales
   FROM public.orders_table AS o
   JOIN public.dim_products AS p ON o.product_code = p.product_code) AS total
WHERE s.store_type IN ('Web Portal', 'Mall Kiosk', 'Super Store', 'Local', 'Outlet')
GROUP BY
  s.store_type, total.total_sales
ORDER BY
  total_sales DESC;

--The sales team wants to know which of the different store types is generated the most revenue so they know where to focus.
--Find out the total and percentage of sales coming from each of the different store types.
--The query should return:

store_type  	total_sales 		percentage_total(%)
"Local"			3440896.5200001546	44.557729313541586
"Web Portal"	1726547.0499999095	22.35784065397766
"Super Store"	1224293.6499999538	15.8539336303503
"Mall Kiosk"	698791.6099999876	9.04896942525664
"Outlet"		631804.8099999899	8.181526976862372

-- Task 6: Which month in each year produced the highest cost of sales?
--this query calculates the total sales for each combination of year and month, 
--presenting the results in descending order of total sales, and limiting the output to the top 10 records.
SELECT
  SUM(o.product_quantity * p.product_price_pound) AS total_sales,
  d.year AS years,
  d.month AS months
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_date_times AS d ON d.date_uuid = o.date_uuid
GROUP BY
  d.year, d.month
ORDER BY
  total_sales DESC
LIMIT 10;

--The company stakeholders want assurances that the company has been doing well recently.
--Find which months in which years have had the most sales historically.
---The query should return the following information:

total_sales			years	months
27936.769999999993	"1994"	"3"
27356.139999999985	"2019"	"1"
27091.669999999984	"2009"	"8"
26679.97999999999	"1997"	"11"
26310.969999999994	"2018"	"12"
26277.71999999999	"2019"	"8"
26236.669999999984	"2017"	"9"
25798.119999999988	"2010"	"5"
25648.289999999994	"1996"	"8"
25614.53999999998	"2000"	"1"

-- Task 7: What is our staff headcount?
--this query calculates the total staff numbers for each country (country_code) in the public.dim_store_details table, 
--presenting the results in descending order based on the total staff numbers.

SELECT
  SUM(staff_numbers) AS total_staff_numbers,
  country_code
FROM
  public.dim_store_details
GROUP BY
  country_code
ORDER BY
  total_staff_numbers DESC;

--The operations team would like to know the overall staff numbers in each location around the world. Perform a query to determine the staff numbers in each of the countries the company sells in.
--The query should return the values:
total_staff_numbers	country_code
13132				"GB"
6054				"DE"
1304				"US"




-- Task 8: Which German store type is selling the most?
--this query retrieves and aggregates sales data for specific store types ('Mall Kiosk', 'Super Store', 'Local', 'Outlet') in Germany ('DE'),
--presenting the results grouped by store type and country code, and ordered by total sales in descending order.
SELECT
  s.store_type,
  s.country_code, 
  SUM(o.product_quantity * p.product_price_pound) AS total_sales
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_store_details AS s ON o.store_code = s.store_code,
  (SELECT SUM(o.product_quantity * p.product_price_pound) AS total_sales
   FROM public.orders_table AS o
   JOIN public.dim_products AS p ON o.product_code = p.product_code) AS total
WHERE s.store_type IN ('Mall Kiosk', 'Super Store', 'Local', 'Outlet') AND country_code = 'DE'
GROUP BY
  s.store_type, s.country_code, total.total_sales
ORDER BY
  total_sales DESC;

--The sales team is looking to expand their territory in Germany. 
--Determine which type of store is generating the most sales in Germany.
-- The query will return:
store_type		country_code	 total_sales 
"Local"			"DE"			1109909.5899999626
"Super Store"	"DE"			384625.02999999834
"Mall Kiosk"	"DE"			247634.20000000042
"Outlet"		"DE"			198373.5700000005

-- Task 9: How quickly is the company making sales?
-- Alter the data type of the timestamp column to timestamp
ALTER TABLE public.dim_date_times
ALTER COLUMN timestamp TYPE TIMESTAMP USING to_timestamp(timestamp, 'HH24:MI:SS');

ALTER TABLE public.dim_date_times
ALTER COLUMN timestamp TYPE TIME USING timestamp::TIME;

--this query calculates the average time difference, hours, minutes, seconds, and milliseconds between consecutive datetime values 
--for each year in the public.dim_date_times table, presenting the results grouped by year and 
--ordered by the average time difference in descending order.
--Subquery:
--SELECT year, datetime, datetime - LAG(datetime) OVER (ORDER BY datetime) AS time_difference FROM cte: 
--Uses the CTE to calculate the time difference between consecutive datetime values using the LAG window function.

WITH cte AS (
  SELECT
    year,
	month,
	day,
	timestamp,
    TO_TIMESTAMP(CONCAT(year, '-', month, '-', day, ' ', timestamp), 'YYYY-MM-DD HH24:MI:SS') AS datetime
  FROM
    public.dim_date_times
  ORDER BY
    year, month, day, timestamp
)

SELECT
  year,
  AVG(time_difference) AS actual_time_taken,
  AVG(EXTRACT(HOUR FROM time_difference)::numeric) AS avg_hours,
  AVG(EXTRACT(MINUTE FROM time_difference)::numeric) AS avg_minutes,
  AVG(EXTRACT(SECOND FROM time_difference)::numeric) AS avg_seconds,
  AVG(EXTRACT(MILLISECONDS FROM time_difference)::numeric) AS avg_milliseconds
FROM (
  SELECT
    year,
    datetime,
    datetime - LAG(datetime) OVER (ORDER BY datetime) AS time_difference
  FROM
    cte
) AS subquery

GROUP BY
  year
ORDER BY
  actual_time_taken DESC;


year	actual_time_taken
"2013"	"02:17:12.300182"
"1993"	"02:15:35.857327"
"2002"	"02:13:50.412529"
"2022"	"02:13:06.313993"
"2008"	"02:13:02.80308"
"1995"	"02:12:58.972925"
"2016"	"02:12:58.124905"
"2011"	"02:12:19.017623"
"2020"	"02:12:03.535204"
"2012"	"02:11:58.069104"
"2021"	"02:11:56.199548"
"2009"	"02:11:18.413543"
"2010"	"02:11:13.985272"
"2007"	"02:11:08.939122"
"1999"	"02:11:06.563482"
"1996"	"02:10:59.163022"
"2000"	"02:10:54.498758"
"2019"	"02:10:47.079871"
"1994"	"02:10:43.552599"
"2001"	"02:10:38.953766"
"2018"	"02:10:35.807157"
"2004"	"02:10:32.996037"
"2006"	"02:10:20.328044"
"2014"	"02:10:07.507304"
"1997"	"02:09:58.199308"
"2015"	"02:09:37.417016"
"1992"	"02:09:32.062921"
"2005"	"02:08:59.66053"
"2017"	"02:08:46.828025"
"2003"	"02:08:45.491916"
"1998"	"02:08:07.956363"




