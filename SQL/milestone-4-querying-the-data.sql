-- Milestone 4: Querying the data.

-- Your boss is excited that you now have the schema for the database and all the sales data is in one location.
-- Since you've done such a great job they would like 

-- The business can then start making more data-driven decisions and get a better understanding of its sales.
-- In this milestone, you will be tasked with answering business questions and extracting the data from the database using SQL.

-- The Operations team would like to know which countries we currently operate in and which country now has the most stores. 
-- Perform a query on the database to get the information, it should return the following information:


SELECT country_code, COUNT(*) AS total_no_stores
FROM dim_store_details
GROUP BY country_code
ORDER BY total_no_stores DESC;

country total_no_stores
"GB"	266
"DE"	141
"US"	34
Note: DE is short for Deutschland(Germany)


SELECT locality, COUNT(*) AS total_no_stores
FROM dim_store_details
GROUP BY locality
ORDER BY total_no_stores DESC
LIMIT 7;  -- To limit the result to the top 7 locations

"Chapletown"	14
"Belper"	13
"Bushey"	12
"Exeter"	11
"Arbroath"	10
"High Wycombe"	10
"Rutherglen"	10

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

total_sales			month
673295.6800000012	"8"
668041.4500000016	"1"
657335.8400000016	"10"
650321.4300000013	"5"
645741.7000000014	"7"
645463.0000000012	"3"


-- get all Web location 
SELECT DISTINCT store_type
FROM public.dim_store_details
WHERE store_type = "Web Portal";
"Web Portal"
"Mall Kiosk"
"Super Store"
"Local"
"Outlet"

SELECT store_type
FROM public.dim_store_details
WHERE store_type in ('Mall Kiosk', 'Super Store', 'Local', 'Outlet');

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
  
  location	numbers_of_sales	product_quantity_count	total_sales
"Offline"	93166				374047					5995786.589999987
"Online"	26957				107739					1726547.0499999681

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

store_type  total_sales percentage_total(%)
"Local"	3440896.5200001546	44.557729313541586
"Web Portal"	1726547.0499999095	22.35784065397766
"Super Store"	1224293.6499999538	15.8539336303503
"Mall Kiosk"	698791.6099999876	9.04896942525664
"Outlet"	631804.8099999899	8.181526976862372

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

"Local"	"DE"	1109909.5899999626
"Super Store"	"DE"	384625.02999999834
"Mall Kiosk"	"DE"	247634.20000000042
"Outlet"	"DE"	198373.5700000005

-- Alter the data type of the timestamp column to timestamp
ALTER TABLE public.dim_date_times
ALTER COLUMN timestamp TYPE TIMESTAMP USING to_timestamp(timestamp, 'HH24:MI:SS');


-- Assuming your table is named 'your_table_name'
ALTER TABLE public.dim_date_times
ALTER COLUMN timestamp TYPE TIME USING timestamp::TIME;

-- Update the new column with the combined values
UPDATE public.dim_date_times
SET new_timestamp = TO_TIMESTAMP(CONCAT(year, '-', month, '-', day, ' ', timestamp), 'YYYY-MM-DD HH24:MI:SS');

SELECT *
FROM 


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
  AVG(time_difference) AS avg_time,
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
  avg_time DESC;


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
  month,
  day,
  timestamp,
  TO_TIMESTAMP(CONCAT(year, '-', month, '-', day, ' ', timestamp), 'YYYY-MM-DD HH24:MI:SS') AS datetime,
  TO_CHAR(TO_TIMESTAMP(CONCAT(year, '-', month, '-', day, ' ', timestamp), 'YYYY-MM-DD HH24:MI:SS'), 'HH24:MI:SS') AS time_only
FROM
  cte
ORDER BY
  year, month, day, timestamp;























WITH cte AS (
  SELECT
    year,
    TO_TIMESTAMP(CONCAT(year, '-', month, '-', day, ' ', timestamp), 'YYYY-MM-DD HH24:MI:SS') AS datetime
  FROM
    public.dim_date_times
  ORDER BY
    year, month, day, timestamp
)

SELECT
  year,
  AVG(EXTRACT(HOUR FROM time_diff)::numeric) AS avg_hours,
  AVG(EXTRACT(MINUTE FROM time_diff)::numeric) AS avg_minutes,
  AVG(EXTRACT(SECOND FROM time_diff)::numeric) AS avg_seconds,
  AVG(EXTRACT(MILLISECONDS FROM time_diff)::numeric) AS avg_milliseconds
FROM (
  SELECT
    year,
    datetime,
    LEAD(datetime) OVER (ORDER BY year, datetime) AS next_datetime,
    (LEAD(datetime) OVER (ORDER BY year, datetime) - datetime) AS time_diff
  FROM
    cte
) AS subquery
WHERE
  next_datetime IS NOT NULL
GROUP BY
  year
ORDER BY
  year;




WITH cte AS (
  SELECT
    year,
    TO_TIMESTAMP(CONCAT(year, '-', month, '-', day, ' ', timestamp), 'YYYY-MM-DD HH24:MI:SS') AS datetime
  FROM
    public.dim_date_times
  ORDER BY
    year, month, day, timestamp
)

SELECT
  year,
  AVG(EXTRACT(HOUR FROM time_diff)::numeric) AS avg_hours,
  AVG(EXTRACT(MINUTE FROM time_diff)::numeric) AS avg_minutes,
  AVG(EXTRACT(SECOND FROM time_diff)::numeric) AS avg_seconds,
  AVG(EXTRACT(MILLISECONDS FROM time_diff)::numeric) AS avg_milliseconds
FROM (
  SELECT
    year,
    datetime,
    LEAD(datetime) OVER (ORDER BY year, datetime) AS next_datetime,
    (LEAD(datetime) OVER (ORDER BY year, datetime) - datetime) AS time_diff
  FROM
    cte
) AS subquery
WHERE
  next_datetime IS NOT NULL AND next_datetime > datetime
GROUP BY
  year
ORDER BY
  year;






WITH cte AS (
  SELECT
    year,
    TO_TIMESTAMP(CONCAT(year, '-', month, '-', day, ' ', timestamp), 'YYYY-MM-DD HH24:MI:SS') AS datetime
  FROM
    public.dim_date_times
  ORDER BY
    year, month, day, timestamp
)

SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)::numeric),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)::numeric),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)::numeric),
    'milliseconds', AVG(EXTRACT(MILLISECONDS FROM time_diff)::numeric)
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    datetime,
    LEAD(datetime) OVER (ORDER BY year, datetime) AS next_datetime,
    (LEAD(datetime) OVER (ORDER BY year, datetime) - datetime) AS time_diff
  FROM
    cte
) AS subquery
WHERE
  next_datetime IS NOT NULL AND next_datetime > datetime
GROUP BY
  year
ORDER BY
  year;






WITH cte AS (
  SELECT
    TO_TIMESTAMP(CONCAT(year, '-', month, '-', day, ' ', timestamp), 'YYYY-MM-DD HH24:MI:SS') AS datetimes,
    year
  FROM
    dim_date_times
  ORDER BY
    datetimes DESC
)

SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)::numeric),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)::numeric),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)::numeric),
    'milliseconds', AVG(EXTRACT(MILLISECONDS FROM time_diff)::numeric)
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    datetimes,
    LEAD(datetimes) OVER (ORDER BY datetimes) AS next_datetimes,
    (LEAD(datetimes) OVER (ORDER BY datetimes) - datetimes) AS time_diff
  FROM
    cte
) AS subquery
WHERE
  next_datetimes IS NOT NULL AND next_datetimes > datetimes
GROUP BY
  year
ORDER BY
  year;



SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECONDS FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) - timestamp) AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp IS NOT NULL AND next_timestamp > timestamp
GROUP BY
  year
ORDER BY
  year;

---
SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)::numeric),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)::numeric),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)::numeric),
    'milliseconds', AVG(EXTRACT(MILLISECONDS FROM time_diff)::numeric)
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) - timestamp) AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp IS NOT NULL AND next_timestamp > timestamp
GROUP BY
  year
ORDER BY
  year;




SELECT
year,
TO_JSONB(json_build_object(
'hours', AVG(EXTRACT(HOUR FROM time_diff)),
'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
)) AS actual_time_taken
FROM (
SELECT
year,
timestamp,
LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
(LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) - timestamp) AS time_diff
FROM
public.dim_date_times
) AS subquery
WHERE
next_timestamp IS NOT NULL
GROUP BY
year
ORDER BY
year;



SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)::numeric),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)::numeric),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)::numeric),
    'milliseconds', AVG(EXTRACT(MILLISECONDS FROM time_diff)::numeric)
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    (EXTRACT(EPOCH FROM LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) - timestamp) * 1000)::numeric AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp IS NOT NULL
GROUP BY
  year
ORDER BY
  year;




SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)::numeric),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)::numeric),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)::numeric),
    'milliseconds', AVG(EXTRACT(MILLISECONDS FROM time_diff)::numeric)
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    EXTRACT(EPOCH FROM (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) - timestamp)) * 1000 AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp IS NOT NULL
GROUP BY
  year
ORDER BY
  year;



SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    EXTRACT(EPOCH FROM (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) - timestamp))::numeric * 1000 AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp IS NOT NULL
GROUP BY
  year
ORDER BY
  year;



SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    EXTRACT(EPOCH FROM (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) - timestamp)) * 1000 AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp IS NOT NULL
GROUP BY
  year
ORDER BY
  year;




SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) - timestamp) AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp IS NOT NULL
GROUP BY
  year
ORDER BY
  year;






SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) - timestamp) AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp IS NOT NULL
GROUP BY
  year
ORDER BY
  year;




SELECT
  year,
  CONCAT(
    '"hours": ', EXTRACT(HOUR FROM avg_time_diff)::TEXT, ', ',
    '"minutes": ', EXTRACT(MINUTE FROM avg_time_diff)::TEXT, ', ',
    '"seconds": ', EXTRACT(SECOND FROM avg_time_diff)::TEXT, ', ',
    '"milliseconds": ', EXTRACT(MILLISECOND FROM avg_time_diff)::TEXT
  ) AS actual_time_taken
FROM (
  SELECT
    year,
    AVG(next_timestamp - timestamp) AS avg_time_diff
  FROM (
    SELECT
      year,
      timestamp,
      LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp
    FROM
      public.dim_date_times
  ) AS subquery
  WHERE
    next_timestamp IS NOT NULL
  GROUP BY
    year
) AS final_query
ORDER BY
  year;




SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp)::time - timestamp::time) AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp > timestamp
GROUP BY
  year
ORDER BY
  year;


















SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp)::time - timestamp::time) AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp IS NOT NULL
GROUP BY
  year
ORDER BY
  year;






SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp)::time - timestamp::time) AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp IS NOT NULL -- Ensures there is a next timestamp
GROUP BY
  year
ORDER BY
  year;






SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp)::time - timestamp::time) AS time_diff
  FROM
    public.dim_date_times
) AS subquery
WHERE
  next_timestamp > timestamp
GROUP BY
  year
ORDER BY
  year;





SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    (LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp)::time - timestamp::time) AS time_diff
  FROM
    public.dim_date_times
) AS subquery
GROUP BY
  year
ORDER BY
  year;





SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    TO_TIMESTAMP(LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp), 'HH24:MI:SS') - TO_TIMESTAMP(timestamp, 'HH24:MI:SS') AS time_diff
  FROM
    public.dim_date_times
) AS subquery
GROUP BY
  year
ORDER BY
  year;






SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp::timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    (LEAD(timestamp::timestamp) OVER (ORDER BY year, month, day, timestamp) - timestamp::timestamp) AS time_diff
  FROM
    public.dim_date_times
) AS subquery
GROUP BY
  year
ORDER BY
  year;







SELECT
  year,
  TO_JSONB(json_build_object(
    'hours', AVG(EXTRACT(HOUR FROM time_diff)),
    'minutes', AVG(EXTRACT(MINUTE FROM time_diff)),
    'seconds', AVG(EXTRACT(SECOND FROM time_diff)),
    'milliseconds', AVG(EXTRACT(MILLISECOND FROM time_diff))
  )) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp,
    TO_TIMESTAMP(LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp), 'HH24:MI:SS') - TO_TIMESTAMP(timestamp, 'HH24:MI:SS') AS time_diff
  FROM
    public.dim_date_times
) AS subquery
GROUP BY
  year
ORDER BY
  year;





SELECT
  year,
  AVG(EXTRACT(EPOCH FROM (TO_TIMESTAMP(next_timestamp, 'HH24:MI:SS') - TO_TIMESTAMP(timestamp, 'HH24:MI:SS'))::interval)) AS actual_time_taken
FROM (
  SELECT
    year,
    timestamp,
    LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp) AS next_timestamp
  FROM
    public.dim_date_times
) AS subquery
GROUP BY
  year
ORDER BY
  year;






SELECT
  year,
  AVG(EXTRACT(EPOCH FROM (TO_TIMESTAMP(LEAD(timestamp) OVER (ORDER BY year, month, day, timestamp), 'HH24:MI:SS') - TO_TIMESTAMP(timestamp, 'HH24:MI:SS'))::interval)) AS actual_time_taken
FROM
  public.dim_date_times
GROUP BY
  year
ORDER BY
  year;






SELECT
  EXTRACT(YEAR FROM timestamp) AS year,
  AVG(EXTRACT(EPOCH FROM (LEAD(timestamp) OVER (ORDER BY timestamp)) - timestamp)) AS actual_time_taken
FROM
  public.dim_date_times
GROUP BY
  year
ORDER BY
  year;




-- Add a new column with the correct timestamp type
ALTER TABLE public.dim_date_times
ADD COLUMN new_timestamp TIMESTAMP;

SELECT DISTINCT date_uuid
FROM public.dim_date_times
WHERE (
    SELECT pg_typeof(date_uuid)
) != 'uuid' OR POSITION('-' IN date_uuid::text) > 0;



SELECT DISTINCT date_uuid
FROM public.dim_date_times
WHERE pg_typeof(date_uuid::text) != 'uuid' OR POSITION('-' IN date_uuid::text) > 0;



SELECT DISTINCT date_uuid
FROM public.dim_date_times
WHERE pg_typeof(date_uuid) != 'uuid' OR POSITION('-' IN date_uuid) > 0;



SELECT DISTINCT date_uuid
FROM public.dim_date_times
WHERE LENGTH(date_uuid) != 36 OR POSITION('-' IN date_uuid) > 0;


SELECT DISTINCT date_uuid
FROM public.dim_date_times
WHERE regexp_replace(date_uuid, '\d', '', 'g') != '';



-- Update the new column by combining date and time
UPDATE public.dim_date_times
SET new_timestamp = TO_TIMESTAMP(date_uuid || ' ' || "timestamp", 'YYYY-MM-DD HH24:MI:SS');

-- Drop the old columns
ALTER TABLE public.dim_date_times
DROP COLUMN date_uuid,
DROP COLUMN "timestamp";

-- Rename the new column to the original name
ALTER TABLE public.dim_date_times
RENAME COLUMN new_timestamp TO "timestamp";

-- Verify the changes
SELECT "timestamp", month, year, day, time_period
FROM public.dim_date_times;



-- Add a new column with the correct timestamp type
ALTER TABLE public.dim_date_times
ADD COLUMN new_timestamp TIMESTAMP;

-- Update the new column by combining date and time
UPDATE public.dim_date_times
SET new_timestamp = TO_TIMESTAMP(date_uuid || ' ' || "timestamp", 'YYYY-MM-DD HH24:MI:SS');

-- Drop the old column
ALTER TABLE public.dim_date_times
DROP COLUMN "timestamp";

-- Rename the new column to the original name
ALTER TABLE public.dim_date_times
RENAME COLUMN new_timestamp TO "timestamp";

-- Verify the changes
SELECT "timestamp", month, year, day, time_period, date_uuid
FROM public.dim_date_times;







-- Alter the column type to timestamp
ALTER TABLE public.dim_date_times
ALTER COLUMN timestamp TYPE TIMESTAMP USING timestamp::timestamp;

-- Verify the changes
SELECT "timestamp", month, year, day, time_period, date_uuid
FROM public.dim_date_times;





SELECT "timestamp", month, year, day, time_period, date_uuid
FROM public.dim_date_times;




SELECT
  EXTRACT(YEAR FROM timestamp) AS year,
  AVG(EXTRACT(EPOCH FROM (LEAD(timestamp) OVER (ORDER BY timestamp) - timestamp))) AS actual_time_taken
FROM
  public.dim_date_times
GROUP BY
  year
ORDER BY
  year;



SELECT
  EXTRACT(YEAR FROM timestamp::timestamp) AS year,
  AVG(time_difference) AS average_time_taken
FROM (
  SELECT
    timestamp::timestamp,
    EXTRACT(EPOCH FROM (LEAD(timestamp::timestamp) OVER (ORDER BY timestamp::timestamp) - timestamp::timestamp)) AS time_difference
  FROM
    public.dim_date_times
) AS subquery
GROUP BY
  year
ORDER BY
  year;





SELECT
  EXTRACT(YEAR FROM timestamp::timestamp) AS year,
  AVG(EXTRACT(EPOCH FROM (LEAD(timestamp::timestamp) OVER (ORDER BY timestamp::timestamp) - timestamp::timestamp))) AS actual_time_taken
FROM
  public.dim_date_times
GROUP BY
  year
ORDER BY
  year;






SELECT
  EXTRACT(YEAR FROM timestamp) AS year,
  AVG(EXTRACT(EPOCH FROM (LEAD(timestamp) OVER (ORDER BY timestamp) - timestamp))) AS actual_time_taken
FROM
  public.dim_date_times
GROUP BY
  year
ORDER BY
  year;





SELECT
  year,
  AVG(EXTRACT(EPOCH FROM (timestamp - LAG(timestamp) OVER (ORDER BY timestamp))::interval)) AS actual_time_taken
FROM
  public.dim_date_times
GROUP BY
  year
ORDER BY
  year;








SELECT
  SUM(o.product_quantity * p.product_price_pound) AS total_sales,
  d.year AS years

FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_date_times AS d ON d.date_uuid = o.date_uuid
GROUP BY
  d.year
ORDER BY
  total_sales DESC
LIMIT 10;

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














SELECT
  SUM(staff_numbers) AS total_staff_numbers,
  country_code
FROM
  public.dim_store_details
WHERE
	country_code = 'DE'
GROUP BY
  country_code
ORDER BY
  total_staff_numbers DESC;
  
total_staff_numbers	country_code
13132				"GB"
6054				"DE"
1304				"US"










SELECT index, address, longitude, locality, store_code, staff_numbers, opening_date, store_type, latitude, country_code, continent
	FROM public.dim_store_details;







SELECT
  SUM(o.product_quantity * p.product_price_pound) AS total_sales,
  EXTRACT(month FROM d.dim_date_times) AS months,
  EXTRACT(year FROM d.dim_date_times) AS years
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_date_times AS d ON d.date_uuid = o.date_uuid
GROUP BY
  months, years
ORDER BY
  years, months;  -- This orders the result first by year and then by month





SELECT
  SUM(o.product_quantity * p.product_price_pound) AS total_sales,
  EXTRACT(MONTH FROM d.date_uuid::timestamp) AS months,
  EXTRACT(YEAR FROM d.date_uuid::timestamp) AS years
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_date_times AS d ON d.date_uuid = o.date_uuid
GROUP BY
  months, years
ORDER BY
  total_sales DESC;




SELECT
  SUM(o.product_quantity * p.product_price_pound) AS total_sales,
  d.month AS months,
  d.year AS years,
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_date_times AS d ON d.date_uuid = o.date_uuid
GROUP BY
  d.month, d.year
ORDER BY
  total_sales DESC
LIMIT 6;







SELECT
  s.store_type,
  COUNT(*) AS store_count,
  SUM(o.product_quantity * p.product_price_pound) AS total_sales
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_store_details AS s ON o.store_code = s.store_code
WHERE s.store_type IN ('Mall Kiosk', 'Super Store', 'Local', 'Outlet')
GROUP BY
  s.store_type
ORDER BY
  total_sales DESC
LIMIT 6;













SELECT
  SUM(o.product_quantity * p.product_price_pound) AS total_sales,
  month d.month AS months
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_date_times AS d ON d.date_uuid = o.date_uuid
--GROUP BY
  --EXTRACT(month FROM d.month)
ORDER BY
  total_sales DESC
LIMIT 6;

SELECT
  EXTRACT(MONTH FROM o.date_uuid::timestamptz) AS month,
  SUM(o.product_quantity * p.product_price_pound) AS total_sales
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
GROUP BY
  month
ORDER BY
  total_sales DESC
LIMIT 6;



SELECT
  SUM(o.product_quantity * p.product_price_pound) AS total_sales
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_date_times AS d ON d.date_uuid = o.date_uuid
--GROUP BY
  --EXTRACT(MONTH FROM d.date_uuid::timestamptz)
ORDER BY
  total_sales DESC
LIMIT 20;










SELECT
  SUM(o.product_quantity * p.product_price_pound) AS total_sales,
  EXTRACT(MONTH FROM d.timestamp) AS month
FROM
  public.orders_table AS o
  JOIN public.dim_products AS p ON o.product_code = p.product_code
  JOIN public.dim_date_times AS d ON d.date_uuid = o.date_uuid
GROUP BY
  month
ORDER BY
  total_sales DESC
LIMIT 6;







SELECT
  SUM(orders.product_quantity * products.product_price_pound) AS total_sales,
  EXTRACT(MONTH FROM orders.date_uuid::text::timestamp) AS month
FROM
  public.orders_table AS orders
  JOIN public.dim_products AS products ON orders.product_code = products.product_code
GROUP BY
  month
ORDER BY
  total_sales DESC
LIMIT 6;




SELECT
  SUM(orders.product_quantity * products.product_price_pound) AS total_sales,
  EXTRACT(MONTH FROM orders.date_uuid::timestamp) AS month
FROM
  public.orders_table AS orders
  JOIN public.dim_products AS products ON orders.product_code = products.product_code
GROUP BY
  month
ORDER BY
  total_sales DESC
LIMIT 6;

SELECT "timestamp", month, year, day, time_period, date_uuid
	FROM public.dim_date_times;

SELECT
  SUM(orders.product_quantity * products.product_price_pound) AS total_sales,
  EXTRACT(MONTH FROM times.timestamp_column) AS month
FROM
  public.orders_table AS orders
  JOIN public.dim_products AS products ON orders.product_code = products.product_code
  JOIN public.dim_date_times AS times ON times.date_uuid = orders.date_uuid
GROUP BY
  month
ORDER BY
  total_sales DESC
LIMIT 6;


SELECT
  SUM(orders.product_quantity * products.product_price_pound) AS total_sales,
  EXTRACT(MONTH FROM times.month) AS months
FROM
  public.orders_table AS orders
  JOIN public.dim_products AS products ON orders.product_code = products.product_code
  JOIN public.dim_date_times AS times ON times.date_uuid = orders.date_uuid
GROUP BY
  month
ORDER BY
  total_sales DESC
LIMIT 6;


SELECT
  SUM(orders.product_quantity * products.product_price_pound) AS total_sales,
  SUBSTRING(times.month) AS months
FROM
  public.orders_table AS orders
  JOIN public.dim_products AS products ON orders.product_code = products.product_code
  JOIN public.dim_date_times AS times ON times.date_uuid = orders.date_uuid
GROUP BY
  months
ORDER BY
  total_sales DESC
LIMIT 6;





SELECT
  SUM(orders.product_quantity * products.product_price_pound) AS total_sales,
  EXTRACT(MONTH FROM orders.date_uuid) AS month
FROM
  public.orders_table AS orders
  JOIN public.dim_products AS products ON orders.product_code = products.product_code
  JOIN public.dim_date_times AS times ON times.date_uuid =  orders.date_uuid
GROUP BY
  month
ORDER BY
  total_sales DESC
LIMIT 6;




SELECT
  SUM(product_quantity * product_price) AS total_sales,
  EXTRACT(MONTH FROM date_uuid) AS month
FROM
  public.orders_table
GROUP BY
  month
ORDER BY
  total_sales DESC
LIMIT 6;


SELECT
  SUM(order.product_quantity * products.product_price_pound) AS total_sales,
  EXTRACT(MONTH FROM date_uuid) AS month
FROM
  public.orders_table AS order
  public.dim_products AS products
  
GROUP BY
  month
ORDER BY
  total_sales DESC
LIMIT 6;

