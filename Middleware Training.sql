--List all customers with the word "French" in their name.  Return customer name, dob, gender and phone number.
SELECT NAME, DOB, GENDER, MOBILE_NO FROM DW_CUSTOMER dc WHERE dc.name LIKE '%French%';

--List all customers under the age of 30
SELECT * FROM dw_customer dc WHERE dc.DOB > '01-jan-1991'

--List accounts with a balance greater than 500.  Return account number and balance
SELECT da.ACCOUNT_NO, da.BALANCE FROM DW_CUSTOMER dc, DW_ACCOUNT da WHERE dc.CUSTOMER_ID = da.ACCOUNT_ID ;

--List accounts with a balance between 500 and 1000 
SELECT * FROM DW_ACCOUNT da WHERE da.balance BETWEEN '500' AND '1000';

--List all financial transactions for account with id 45.  Return account id, transaction date, amount and  transaction code
SELECT da.ACCOUNT_ID, df.TRANSACTION_DATE, df.AMOUNT, df.TRANSACTION_CODE FROM DW_ACCOUNT da, DW_FINTRANSACTION df WHERE da.ACCOUNT_ID = df.ACCOUNT_ID and da.account_id = 45;

--How many accounts have had a deposit?  Note that deposits start with "DEP".
SELECT
	count(*) AS Total_Transactions
FROM
	DW_CUSTOMER dc,
	DW_ACCOUNT da,
	DW_FINTRANSACTION df,
	DW_FINTRANSACTIONTYPE df2 
WHERE
	dc.CUSTOMER_ID = da.ACCOUNT_ID
	AND da.ACCOUNT_ID = df.ACCOUNT_ID
	AND df.FIN_TRAN_TP_ID = df2.FIN_TRAN_TP_ID 
	AND df2.PREFIX = 'DEP';
	

--Select the maximum and total deposit made for all accounts.  Only return the columns max and total.
SELECT
	max(amount) AS Max,
	sum(amount) AS Total
FROM
	DW_CUSTOMER dc,
	DW_ACCOUNT da,
	DW_FINTRANSACTION df,
	DW_FINTRANSACTIONTYPE df2
WHERE
	dc.CUSTOMER_ID = da.ACCOUNT_ID
	AND da.ACCOUNT_ID = df.ACCOUNT_ID
	AND df.FIN_TRAN_TP_ID = df2.FIN_TRAN_TP_ID
	AND df2.PREFIX = 'DEP'
	
--List the maximum and minimum deposits by account
SELECT
	dc.CUSTOMER_ID ,
	max(amount) AS maxamount,
	min(amount) AS minamount
FROM
	DW_CUSTOMER dc,
	DW_ACCOUNT da,
	DW_FINTRANSACTION df,
	DW_FINTRANSACTIONTYPE df2
WHERE
	dc.CUSTOMER_ID = da.ACCOUNT_ID
	AND da.ACCOUNT_ID = df.ACCOUNT_ID
	AND df.FIN_TRAN_TP_ID = df2.FIN_TRAN_TP_ID
	AND df2.PREFIX = 'DEP'
GROUP BY
	dc.CUSTOMER_ID ;
--List all accounts with more than 2 deposits  
SELECT
dc.CUSTOMER_ID ,
	count(*) AS total_deposits
FROM
	DW_CUSTOMER dc,
	DW_ACCOUNT da,
	DW_FINTRANSACTION df,
	DW_FINTRANSACTIONTYPE df2
WHERE
	dc.CUSTOMER_ID = da.ACCOUNT_ID
	AND da.ACCOUNT_ID = df.ACCOUNT_ID
	AND df.FIN_TRAN_TP_ID = df2.FIN_TRAN_TP_ID
	AND df2.PREFIX = 'DEP'
GROUP BY
	dc.CUSTOMER_ID 
HAVING count(*) > 2;

--Show total cash outs by agent (user_id) per day 
SELECT
	da.USER_ID ,
	count(*) AS total,
	to_char(df.TRANSACTION_DATE , 'YYYY-MM-DD') AS transdate
	--(cast(df.TRANSACTION_DATE AS DATE))
FROM
	DW_FINTRANSACTION df,
	DW_FINTRANSACTIONTYPE df2,
	DW_AGENT da
WHERE
	df.FIN_TRAN_TP_ID = df2.FIN_TRAN_TP_ID
	AND da.USER_ID = df.USER_ID
GROUP BY
	da.USER_ID , to_char(df.TRANSACTION_DATE , 'YYYY-MM-DD') --cast(df.TRANSACTION_DATE AS DATE)
ORDER BY
	TRANSDATE ASC;

--List all customers that are either female or under the age of 30
SELECT * FROM dw_customer c WHERE c.DOB > '01-jan-1991' OR c.GENDER = 'F';
--List all customers born in the year 1981,1982,1983,1986
SELECT
	*
FROM
	dw_customer c
WHERE
	c.DOB BETWEEN '01-jan
-1981' AND '12-dec-1983'
	OR c.dob BETWEEN '01-jan
-1986' AND '12-dec-1986';

--Find the average deposit made.  Do not use the average function i.e. calculate the average
SELECT
	ROUND( (sum(amount) / count(*)), 2 ) AS average_desposit
FROM
	DW_FINTRANSACTION df,
	DW_FINTRANSACTIONTYPE df2
WHERE
	df.FIN_TRAN_TP_ID = '1';

--Inner Join
SELECT
	dc.CUSTOMER_ID ,
	count(*) AS total_deposits,
	sum (df.AMOUNT) AS sum
FROM
	DW_CUSTOMER dc
INNER JOIN DW_ACCOUNT da ON
	dc.CUSTOMER_ID = da.ACCOUNT_ID
INNER JOIN DW_FINTRANSACTION df ON
	da.ACCOUNT_ID = df.ACCOUNT_ID
INNER JOIN DW_FINTRANSACTIONTYPE df2 ON
	df.FIN_TRAN_TP_ID = df2.FIN_TRAN_TP_ID
WHERE
	df2.PREFIX = 'DEP'
GROUP BY
	dc.CUSTOMER_ID 
HAVING 
count(*) > 2
ORDER BY
	dc.CUSTOMER_ID;