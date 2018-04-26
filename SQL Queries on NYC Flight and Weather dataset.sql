/* Queries for some questions that might be worth exploring in NYC database */
/* Author : MANAS THAKRE */
/* Date : 22-Apr-2018 */
/* Source of this database : 
https://sqlshare.uw.edu/detail/rodriglr/flights.csv
https://sqlshare.uw.edu/detail/rodriglr/weather.csv  */

/*==============================================================*/

/* How many flights were there from NYC airports to Seattle in 2013? */

SELECT COUNT (dest)
FROM rodriglr."flights.csv"
WHERE (dest='SEA' AND year=2013)

/* How many airlines fly from NYC to Seattle? */

SELECT COUNT (distinct carrier) AS "Number of unique airlines"
FROM rodriglr."flights.csv"
WHERE dest='SEA'

/* How many unique air planes fly from NYC to Seattle? */

SELECT COUNT (DISTINCT tailnum) AS "Number of unique airplanes"
FROM rodriglr."flights.csv"
WHERE dest='SEA'

/* What is the average arrival delay for flights from NYC to Seattle? */

SELECT AVG (arr_delay) AS "Average arrival delay"
FROM rodriglr."flights.csv"
WHERE dest='SEA'

/* What proportion of flights to Seattle come from each NYC airport? */

SELECT origin, (COUNT(dest)* 1.0  / 
    (SELECT COUNT (origin)
    FROM rodriglr."flights.csv"
    WHERE dest = 'SEA')) AS "Proportion" 
FROM rodriglr."flights.csv"
WHERE dest='SEA'
GROUP BY origin

/*================================================================*/

/* Which date has the largest average departure delay? */

SELECT year, month, day, AVG(dep_delay) as Average_dep_delay
FROM rodriglr."flights.csv"
GROUP BY year, month, day
ORDER BY Average_dep_delay DESC
LIMIT 1

/* Which date has the largest average arrival delay? */

SELECT year, month, day, AVG(arr_delay) as Average_arr_delay
FROM rodriglr."flights.csv"
GROUP BY year, month, day
ORDER BY Average_arr_delay DESC
LIMIT 1

/* What was the worst day to fly out of NYC in 2013 if you dislike delayed flights? */

SELECT year, month, day, COUNT(flight) AS number_of_delayed_flights
FROM rodriglr."flights.csv"
WHERE dep_delay > 0
GROUP BY year,month,day
ORDER BY number_of_delayed_flights DESC
LIMIT 1

/* Is Autumn (September, October, November) worse than Summer (June, July, August) for flight delays for flights from NYC? */

SELECT AVG ("Avg. Monthly Dep Delay") AS "Average Autumn Dep Delay" 
FROM 
    (SELECT month, AVG (dep_delay) AS "Avg. Monthly Dep Delay"
    FROM rodriglr."flights.csv"
    WHERE month IN (9,10,11)
    GROUP BY month) as temp



SELECT AVG ("Avg. Monthly Dep Delay") AS "Average Summer Dep Delay" 
FROM 
    (SELECT month, AVG (dep_delay) AS "Avg. Monthly Dep Delay"
    FROM rodriglr."flights.csv"
    WHERE month IN (6,7,8)
    GROUP BY month) as temp    

/* On average, how do departure delays vary over the course of a day?  You can compute the average delay by hour of day, 
such that your result will have 24 records (be careful -- there are records with hour 0 and hour 24. 
Consider lumping these together, or justify any other solution you come up with.) */

SELECT
    (CASE
    WHEN hour = 24 THEN 0
    ELSE hour
    END) AS grouped_hour,
AVG(dep_delay) as Mean_Hourly_Delays
FROM rodriglr."flights.csv"
GROUP BY grouped_hour 

/*===========================================================================*/

/* Which flight departing NYC in 2013 flew the fastest? */

SELECT year, month, day, carrier, tailnum, flight, origin, dest, 
    (distance * 1.0 / air_time) AS Miles_per_minute
FROM rodriglr."table_flights.csv" 
ORDER BY Miles_per_minute DESC
LIMIT 1

/*============================================================================*/

/* Which flights (i.e. carrier + flight + dest) happen every day? */

SELECT newname, COUNT (DISTINCT newdate)
FROM
    (SELECT CONCAT (day, '-', month, '-', year) AS newdate, 
            CONCAT(carrier, ' ', flight, ' ', dest) AS newname
    FROM rodriglr."table_flights.csv"
    GROUP BY newname,newdate) AS temp
GROUP BY newname
ORDER BY COUNT DESC
LIMIT 1

/*=============================================================================*/

/* Is there any link between visibility and delay? What about temperature?
Answer: Let’s check the visibility and temperature data for top few flights delayed by more than 2 hours 
(threshold chosen for this problem as humans become impatient after this)
 */

SELECT carrier, flight, tailnum, AVG(temp) as avg_temp, 
        AVG(visib) as avg_visib, AVG(dep_delay) as avg_delay
FROM
    (SELECT *
    FROM rodriglr."table_weather.csv" as weather
    LEFT JOIN rodriglr."table_flights.csv" as flight
        ON (weather.month = flight.month AND
            weather.day = flight.day AND 
            weather.hour = flight.hour AND 
            weather.origin = flight.origin)) as temp
WHERE dep_delay > 120
GROUP BY carrier, flight,tailnum
ORDER BY avg_delay desc

/*  */

SELECT carrier, flight, tailnum, AVG(temp) as avg_temp, 
        AVG(visib) as avg_visib, Round(AVG(dep_delay),2) as avg_delay
FROM
    (SELECT *
    FROM rodriglr."table_weather.csv" as weather
    LEFT JOIN rodriglr."table_flights.csv" as flight
        ON (weather.month = flight.month AND
            weather.day = flight.day AND 
            weather.hour = flight.hour AND 
            weather.origin = flight.origin)) as temp
WHERE dep_delay BETWEEN -60 AND 0
GROUP BY carrier, flight,tailnum
ORDER BY avg_delay desc

/*=======================================================================*/

/* Which two airlines flying to Seattle were most reliable in terms of having the minimum average departure delay in 2013? */

SELECT carrier, dest, ROUND(AVG (dep_delay),2) AS Mean_Dep_Delay, 
        COUNT(*) AS Number_of_Operated_flights
FROM rodriglr."table_flights.csv" 
WHERE dest='SEA'
GROUP BY carrier, dest
ORDER BY Mean_Dep_Delay ASC