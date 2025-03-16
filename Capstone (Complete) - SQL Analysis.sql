-- Creating table called Transaction_Location_Info (imported data from cc_cleaned)
CREATE TABLE Transaction_Location_Info(
	'index' INT PRIMARY KEY,
	street VARCHAR(60),
	city VARCHAR(60),
	state VARCHAR(3),
	zip INT,
	lat DECIMAL(6,6),
	long DECIMAL(6,6),
	city_pop INT ) ; 
	

-- Creating table called Transaction_Info (imported data from cc_cleaned)
CREATE TABLE Transaction_Info(
	trans_num VARCHAR(70) PRIMARY KEY,
	trans_date_trans_time DATETIME,
	trans_month VARCHAR(5),
	trans_year INT,
	cc_num INT,
	category VARCHAR(60),
	amt DECIMAL(6,6),
	Fraud VARCHAR(10) );
	

-- Creating table called Transactor_Info (imported data from cc_cleaned)
CREATE TABLE Transactor_Info(
	'index' INT PRIMARY KEY,
	trans_num VARCHAR(70),
	'first' VARCHAR(50),
	'last' VARCHAR(50),
	gender VARCHAR(2),
	job VARCHAR(80),
	dob DATE,
	FOREIGN KEY ('trans_num') REFERENCES Transaction_Info('trans_num'),
	FOREIGN KEY ('index') REFERENCES Transaction_Location_Info('index') );


-- Creating table called Merchant_Info (imported data from cc_cleaned)
CREATE TABLE Merchant_Info(
	'index' INT PRIMARY KEY,
	merchant VARCHAR(80),
	merch_lat DECIMAL(6,6),
	merch_long DECIMAL(6,6),
	FOREIGN KEY ('index') REFERENCES Transactor_Info('index') ) ;





-- SQL TASKS: 4. DATA EXPLORATION WITH SQL

-- Calculate total number of transactions
SELECT COUNT(trans_num) as 'Total_Number_of_Transactions' 
FROM Transaction_Info ti ;


-- Identify top 10 most frequented merchcants
SELECT mi.merchant as 'Merchant' , COUNT(ti2.trans_num) as 'Times_Visited'
FROM Merchant_Info mi 
LEFT JOIN Transactor_Info ti ON mi."index" = ti."index" 
LEFT JOIN Transaction_Info ti2 ON ti.trans_num = ti2.trans_num
GROUP BY mi.merchant
ORDER BY COUNT(ti2.trans_num) DESC 
LIMIT 10 ;


-- Calculate average transaction amount by category
SELECT category as 'Category' , ROUND(AVG(amt), 2) as 'Average_Transaction_Amount' 
FROM Transaction_Info ti
GROUP BY category
ORDER BY AVG(amt) DESC;


-- Calculate total number of fraudulent transactions and the percentage they make up of total transactions
SELECT (SELECT COUNT(trans_num) FROM Transaction_Info ti WHERE Fraud IS 'TRUE') AS 'Fraudulent_Transactions',
COUNT(trans_num) AS 'Total_Transactions',
((ROUND((SELECT COUNT(trans_num) FROM Transaction_Info ti WHERE Fraud IS 'TRUE'), 2) / COUNT(trans_num)) * 100) AS 'Percentage_of_Transactions_that_are_Fraudulent'
FROM Transaction_Info ti ;


-- Identify the latitude and longitude for each transaction
SELECT ti.trans_num AS 'Transaction_Number' , tli.lat AS 'Latitude' , tli.long AS 'Longitude'
FROM Transaction_Location_Info tli 
LEFT JOIN Transactor_Info ti ON tli."index" = ti."index" ;


-- Identify the city with the highest population
SELECT city , MAX(city_pop) AS 'city_population'
FROM Transaction_Location_Info tli ;


-- Identify the earliest transactions
SELECT trans_num AS 'Transaction_Number', MIN(trans_date_trans_time) AS 'Transaction_Date', 'Earliest' as 'Transaction_Order'
FROM Transaction_Info ti 
UNION
-- Identify the latest transactions
SELECT trans_num AS 'Transaction_Number', MAX(trans_date_trans_time) AS 'Transaction_Date', 'Latest'
FROM Transaction_Info ti ; 




-- 5. USING DATA AGGREGATION W/ SQL

-- Calculate the total amount spent across all transactions
SELECT SUM(amt) AS 'Total_Amount_Spent_Across_all_Transactions' 
FROM Transaction_Info ti 


-- Identify how many transactions occurred in each cateogory
SELECT category , COUNT(trans_num) as 'number_of_transactions' 
FROM Transaction_Info ti
GROUP BY category 
ORDER BY COUNT(trans_num) DESC ;


-- Calculate the average transaction amount by gender
SELECT ti2.gender , ROUND(AVG(ti.amt), 2) as 'avg_transaction_amt'
FROM Transaction_Info ti 
LEFT JOIN Transactor_Info ti2 ON ti.trans_num = ti2.trans_num 
GROUP BY ti2.gender 
ORDER BY AVG(ti.amt) DESC ;


-- Identify which day of the week has the highest average transaction amount                 
SELECT STRFTIME('%w', trans_date_trans_time) as 'Weekday Index' ,  
CASE CAST(strftime('%w', trans_date_trans_time) as integer)
	WHEN 0 THEN 'Sunday'
	WHEN 1 THEN 'Monday'
	WHEN 2 THEN 'Tuesday'
	WHEN 3 THEN 'Wednesday'
	WHEN 4 THEN 'Thursday'
	WHEN 5 THEN 'Friday'
	WHEN 6 THEN 'Saturday'
END AS Weekday , ROUND(AVG(amt), 2) as 'Avg_Transaction_Amt'
FROM Transaction_Info ti 
GROUP BY STRFTIME('%w', trans_date_trans_time)
ORDER BY AVG(amt) DESC
LIMIT 1 ;





-- EXTRA QUERIES/NOT REQUIRED

-- Looking at each unique credit card number to determine number of digits per cc_num
SELECT DISTINCT cc_num, LENGTH(cc_num) as 'number_of_digits'
FROM Transaction_Info ti
ORDER BY LENGTH(cc_num) DESC;


-- Looking at general transaction information 
SELECT ti.cc_num , ti.trans_num , ti.trans_date_trans_time , CONCAT(ti2.first,' ',ti2.last) as Name, tli.city , tli.state , tli.lat , tli.long , ti.category , ti.amt , ti.Fraud 
from Transaction_Info ti 
left join Transactor_Info ti2 ON ti.trans_num = ti2.trans_num 
left join Transaction_Location_Info tli ON ti2."index" = tli."index" ;



-- LOOKING AT SAMPLE OF INDIVIDUAL CC NUMS TO COMPARE AVG TRANSACTION AMT FOR FRAUD VS NON-FRAUD FOR A PARTICULAR CARD NUMBER

-- Looking at purchases with credit card number 4469777115158230000
SELECT ti.cc_num , ti.trans_num , ti.trans_date_trans_time , CONCAT(ti2.first,' ',ti2.last) as Name, tli.city , tli.state , tli.lat , tli.long , ti.category , ti.amt , ti.Fraud 
from Transaction_Info ti 
left join Transactor_Info ti2 ON ti.trans_num = ti2.trans_num 
left join Transaction_Location_Info tli ON ti2."index" = tli."index"
WHERE cc_num = 4469777115158230000 
ORDER BY Fraud DESC ;


-- Calculating avg transaction amount where fraud is true for cc num 4469777115158230000
SELECT cc_num , Fraud , AVG(amt) as 'avg_trans_amt'
FROM Transaction_Info ti 
WHERE cc_num = 4469777115158230000 AND Fraud = 'TRUE'
UNION
-- Calculating avg transaction amount where fraud is false for cc num 4469777115158230000
SELECT cc_num , Fraud , ROUND(AVG(amt), 2) as 'avg_trans_amt'
FROM Transaction_Info ti 
WHERE cc_num = 4469777115158230000 AND Fraud = 'FALSE';





-- Looking at purchases with credit card number 3595192916105580
SELECT ti.cc_num , ti.trans_num , ti.trans_date_trans_time , CONCAT(ti2.first,' ',ti2.last) as Name, tli.city , tli.state , tli.lat , tli.long , ti.category , ti.amt , ti.Fraud 
from Transaction_Info ti 
left join Transactor_Info ti2 ON ti.trans_num = ti2.trans_num 
left join Transaction_Location_Info tli ON ti2."index" = tli."index"
WHERE cc_num = 3595192916105580 
ORDER BY Fraud DESC ;


-- Calculating avg transaction amount where fraud is true for cc num 3595192916105580
SELECT cc_num , Fraud , ROUND(AVG(amt), 2) as 'avg_trans_amt'
FROM Transaction_Info ti 
WHERE cc_num = 3595192916105580 AND Fraud = 'TRUE'
UNION
-- Calculating avg transaction amount where fraud is false for cc num 3595192916105580
SELECT cc_num , Fraud , ROUND(AVG(amt), 2) as 'avg_trans_amt'
FROM Transaction_Info ti 
WHERE cc_num = 3595192916105580 AND Fraud = 'FALSE';





-- Looking at purchases with credit card number 2231186809828220
SELECT ti.cc_num , ti.trans_num , ti.trans_date_trans_time , CONCAT(ti2.first,' ',ti2.last) as Name, tli.city , tli.state , tli.lat , tli.long , ti.category , ti.amt , ti.Fraud 
from Transaction_Info ti 
left join Transactor_Info ti2 ON ti.trans_num = ti2.trans_num 
left join Transaction_Location_Info tli ON ti2."index" = tli."index"
WHERE cc_num = 2231186809828220 
ORDER BY Fraud DESC ;


-- Calculating avg transaction amount where fraud is true for cc num 2231186809828220
SELECT cc_num , Fraud , ROUND(AVG(amt), 2) as 'avg_trans_amt'
FROM Transaction_Info ti 
WHERE cc_num = 2231186809828220 AND Fraud = 'TRUE'
UNION
-- Calculating avg transaction amount where fraud is false for cc num 2231186809828220
SELECT cc_num , Fraud , ROUND(AVG(amt), 2) as 'avg_trans_amt'
FROM Transaction_Info ti 
WHERE cc_num = 2231186809828220 AND Fraud = 'FALSE';





-- Looking at purchases with credit card number 6517217825320610
SELECT ti.cc_num , ti.trans_num , ti.trans_date_trans_time , CONCAT(ti2.first,' ',ti2.last) as Name, tli.city , tli.state , tli.lat , tli.long , ti.category , ti.amt , ti.Fraud 
from Transaction_Info ti 
left join Transactor_Info ti2 ON ti.trans_num = ti2.trans_num 
left join Transaction_Location_Info tli ON ti2."index" = tli."index"
WHERE cc_num = 6517217825320610 
ORDER BY Fraud DESC ;


-- Calculating avg transaction amount where fraud is true for cc num 6517217825320610
SELECT cc_num , Fraud , ROUND(AVG(amt), 2) as 'avg_trans_amt'
FROM Transaction_Info ti 
WHERE cc_num = 6517217825320610 AND Fraud = 'TRUE'
UNION
-- Calculating avg transaction amount where fraud is false for cc num 6517217825320610
SELECT cc_num , Fraud , ROUND(AVG(amt), 2) as 'avg_trans_amt'
FROM Transaction_Info ti 
WHERE cc_num = 6517217825320610 AND Fraud = 'FALSE';





-- Looking at purchases with credit card number 580954173374
SELECT ti.cc_num , ti.trans_num , ti.trans_date_trans_time , CONCAT(ti2.first,' ',ti2.last) as Name, tli.city , tli.state , tli.lat , tli.long , ti.category , ti.amt , ti.Fraud 
from Transaction_Info ti 
left join Transactor_Info ti2 ON ti.trans_num = ti2.trans_num 
left join Transaction_Location_Info tli ON ti2."index" = tli."index"
WHERE cc_num = 580954173374 
ORDER BY Fraud DESC ;


-- Calculating avg transaction amount where fraud is true for cc num 580954173374
SELECT cc_num , Fraud , ROUND(AVG(amt), 2) as 'avg_trans_amt'
FROM Transaction_Info ti 
WHERE cc_num = 580954173374 AND Fraud = 'TRUE'
UNION
-- Calculating avg transaction amount where fraud is false for cc num 580954173374
SELECT cc_num , Fraud , ROUND(AVG(amt), 2) as 'avg_trans_amt'
FROM Transaction_Info ti 
WHERE cc_num = 580954173374 AND Fraud = 'FALSE';







