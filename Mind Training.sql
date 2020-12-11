---New GL Verification Script
SELECT
	a.id said,
	(
	SELECT
		acc.code
	FROM
		ACCOUNTS acc
	WHERE
		acc.id = actb.PARENT ) ma,
	actb.code parent,
	a.code sa,
	a.accountname,
	a.cyclecode,
	to_char( a.ACTIVATIONDATE , 'YYYY-MM-DD HH:MI:SS') account_activation_date,
	/*Changes to date and time*/
	a.OWNSTATUS account_status,
	p.code productcode,
	p.description prod_desc,
	s.code svc_code,
	s.description svc_desc,
	(
	SELECT
		t2.RCFORZEROUNITS
	FROM
		TARIFFCOMMON t2
	WHERE
		t2.code = s.code)  +
	/*Retrieves recurring cost*/
	(
	SELECT
		round(((t2.RCFORZEROUNITS / 100) * 12.5), 2)
	FROM
		TARIFFCOMMON t2
	WHERE
		t2.code = s.code) recurring_service_charge,
	/*Calculates recurring charge tax*/
	(
	SELECT
		t3.SF_FORZEROUNITS
	FROM
		TARIFFCOMMON t3
	WHERE
		t3.code = s.code)/*Retrieves one time charge*/  +
	(
	SELECT
		round(((t3.SF_FORZEROUNITS / 100) * 12.5), 2)
	FROM
		TARIFFCOMMON t3
	WHERE
		t3.code = s.code) one_time_service_charge,
	/*Calculates one time charge tax*/
	(
	SELECT
		max(aq.QUANTITY)
	FROM
		ASQUANTITY aq
	WHERE
		aq.ASID = acs.id) AS service_quantity,
	/*Retrieves service quantity*/
	(
	SELECT
		min (a4.FROMDATE)
	FROM
		ASSTATUS a4
	WHERE
		acs.ID = a4.ASID
		AND a4.STATUS = 'A') service_activation_date,
	/*Retrieves the first activation date of service*/
	(
	SELECT
		min (a3.FROMDATE)
	FROM
		ASSTATUS a3
	WHERE
		acs.id = a3.ASID
		AND a3.STATUS = 'C') service_terminated_date,
	/*Retrieves the first termination date of service*/
	I.ID INV_ID,
	I2.INVROW,
	i2.AMOUNT AS inv_charge,
	i.begindate,
	i.enddate,
	gt.transaction_date,
	gt.charge_type,
	gt.amount GL_Amount,
	(
	SELECT
		gc.DESCRIPTION
	FROM
		GL_CODES gc
	WHERE
		gc.CODE = gt.DEBIT_GL_CODE
		AND gc.MAPPING_TYPE = 'D') debit_gl_code_desc, /*Retrieves GL Description*/
	gt.debit_gl_code,
	(
	SELECT
		gc.DESCRIPTION
	FROM
		GL_CODES gc
	WHERE
		gc.CODE = gt.CREDIT_GL_CODE
		AND gc.MAPPING_TYPE = 'C') credit_gl_code_desc, /*Retrieves GL Description*/
	gt.credit_gl_code,
	gtx.charge_type,
	gtx.amount GL_Amount,
	gtx.debit_gl_code,
	gtx.credit_gl_code
FROM
	accounts a
INNER JOIN accounts actb ON
	a.PARENT = actb.ID
INNER JOIN accountservices acs ON
	a.ID = acs.ACCOUNTID
INNER JOIN services s ON
	acs.SERVICECODE = s.CODE
INNER JOIN products p ON
	acs.PRODUCTCODE = p.CODE
INNER JOIN IBINVROW i2 ON
	acs.ID = i2.ASID
	AND i2.REC_TYPE NOT LIKE '%TAX%'
INNER JOIN IBINV i ON
	i2.INVID = i.ID
INNER JOIN gl_transactions gt ON
	i2.GL_TRANS_ID = gt.ID
INNER JOIN IBINVROW it2 ON
	i.id = it2.INVID
	AND acs.ID = it2.ASID
	AND it2.REC_TYPE LIKE '%TAX%'
INNER JOIN gl_transactions gtx ON
	it2.GL_TRANS_ID = gtx.ID
WHERE
	--p.code = 'DIGIPRO'; -- Professional Services; 00258126533
	--p.prod_type = 'MITV' AND I.BEGINDATE >= '01-jul-2020' AND p.code = 'MITVPP';
 P.CODE IN ('SIPS', 'SIPM','SIPMAP','SIPMP','SIPMPP','SIPAG','SIPL','SIPLP','SIPLPP','SIPEP','SIPEPP') AND gt.TRANSACTION_DATE BETWEEN '01-jul-2020' AND '31-jul-2020';
    

    
---Adjustment GL Verification Script (Adjustments)
SELECT
	a.id SAID,
	a.code ACCOUNTCODE,
	a.accountname,
	i2.AMOUNT INV_CHARGE,
	a2.NOTE ,
	a2.INSERTDATETIME ADJUSTMENTDATE,
	gt.transaction_date GL_TRANSDATE,
	gt.charge_type,
	a2.ADJUSTMENTTYPE ADJUSTMENTCODE ,
	(
	SELECT
		a3.DESCR
	FROM
		ADJUSTMENTTYPE a3
	WHERE
		a2.ADJUSTMENTTYPE = a3.CODE ) ADJUSTMENTDESCR ,/*Retrieves Adjustment Description*/
	gt.amount GL_Amount,
	(
	SELECT
		gc.DESCRIPTION
	FROM
		GL_CODES gc
	WHERE
		gc.CODE = gt.DEBIT_GL_CODE
		AND gc.MAPPING_TYPE = 'D') DEBIT_GL_CODE_DESCR, /*Retrieves GL Description*/
	gt.debit_gl_code,
	(
	SELECT
		gc.DESCRIPTION
	FROM
		GL_CODES gc
	WHERE
		gc.CODE = gt.CREDIT_GL_CODE
		AND gc.MAPPING_TYPE = 'C') CREDIT_GL_CODE_DESCR, /*Retrieves GL Description*/
	gt.credit_gl_code,
	gtx.charge_type,
	gtx.amount GL_Amount,
	gtx.debit_gl_code,
	gtx.credit_gl_code
FROM
	accounts a
INNER JOIN ADJUSTMENT a2 ON
	a.id = a2.accountid
INNER JOIN IBINVROW i2 ON
	a.ID = i2.ACCOUNTID
	AND i2.ITEMKEY = a2.id
	AND i2.REC_TYPE NOT LIKE '%TAX%'
INNER JOIN IBINV i ON
	i2.INVID = i.ID
INNER JOIN gl_transactions gt ON
	i2.GL_TRANS_ID = gt.ID
INNER JOIN IBINVROW it2 ON
	i.id = it2.INVID
	AND a.ID = it2.ACCOUNTID
	AND a2.id = it2.valnum9 /*Where Adjustment ID equals IBINVROW VALNUM9*/
	AND it2.REC_TYPE LIKE '%ADJUSTTAX%'
INNER JOIN gl_transactions gtx ON
	it2.GL_TRANS_ID = gtx.ID
WHERE
	a.code = '35043488296';
	

--Opt Out DigiLoan
SELECT
	DISTINCT a.id,
	a3.DESCRIPTION AS account_class ,
	a2.ACCOUNTANI AS Phone_number
FROM
	accounts a
INNER JOIN ASANI a2 ON
	a.id = a2.ACCOUNTID
INNER JOIN ACCOUNTCLASSTYPE a3 ON
	A.CLASS = A3.ID
WHERE
	a.CLASS = '1509'
	AND a.OWNSTATUS = 'A'
	AND a2.TODATE > SYSDATE ;


---change of number script
SELECT
	ac.ID,
	ac.CODE,
	ac.ACCOUNTNAME,
	a.ACCOUNTANI AS PHONENUMBER,
	to_char(a.FROMDATE, 'DD-MM-YYYY') AS FROMDATE,
	to_char(a.TODATE, 'DD-MM-YYYY') AS TODATE
FROM
	accounts ac
INNER JOIN ASANI a ON
	ac.id = a.ACCOUNTID
WHERE
	a.SERVICETYPE = 'MOBILEOUT'
	AND ac.PRODUCTCODE = 'DIGIPR'
	--AND a.FROMDATE BETWEEN trunc(sysdate) AND SYSDATE --between start of date and to current time
	--AND a.TODATE > SYSDATE 
	--AND EXISTS (SELECT 1 FROM asani WHERE accountid = a.ACCOUNTID AND ACCOUNTANI != a.ACCOUNTANI AND TODATE = a.FROMDATE)
	--ORDER BY FROMDATE ASC
	AND ac.CODE = '83921799871';



---Recharge Report
 SELECT
	i2.ACCOUNTID ,
	a2.ACCOUNTANI,
	i2.AMOUNT ,
	trunc(i2.PAYDATE) AS topupdate
FROM
	accounts a
INNER JOIN ASANI a2 ON
	a.id = a2.ACCOUNTID
INNER JOIN IBPAY i2 ON
	a.id = i2.ACCOUNTID
WHERE
	a.PRODUCTCODE = 'DIGIPR'
	AND a2.SERVICETYPE = 'MOBILEOUT'
	AND a.OWNSTATUS = 'A'
	AND i2.PAYDATE BETWEEN TRUNC(SYSDATE) AND SYSDATE;

---Credit Confiscation Script
SELECT
	to_char(a.ADJUSTDATE , 'YYYY-MM-DD') AS MONTH,
	a.ADJUSTMENTTYPE ,
	round(sum(a.ADJUSTAMOUNT), 2) total
FROM
	ADJUSTMENT a
WHERE
	ADJUSTMENTTYPE IN ('CLR', 'CLRB')
	AND ADJUSTDATE BETWEEN '01-jul-2020' AND '30-sep-2020'
GROUP BY
	to_char(a.ADJUSTDATE , 'YYYY-MM-DD'),
	a.ADJUSTMENTTYPE 
ORDER BY
	to_char(a.ADJUSTDATE , 'YYYY-MM-DD') DESC;

	

---Prepaid Bill to account
SELECT
	(
	SELECT
		acc.code
	FROM
		ACCOUNTS acc
	WHERE
		acc.id = a.PARENT ) ma,
	a.CODE,
	a.ACCOUNTNAME ,
	a.REGISTRATIONDATE ,
	a.PRODUCTCODE ,
	ap.PRODUCT subproduct,
	ap.SUBPRODUCT,
	a2.SERVICECODE,
	a2.ACCTSTATUS 
FROM
	accounts a
INNER JOIN ACCOUNTPRODUCTS ap ON
	ap.ACCOUNTID = a.id
INNER JOIN ACCTSERVICES a2 ON
	ap.ACCOUNTID = a2.ACCOUNTID
WHERE
	A.OWNSTATUS = 'A'
	AND ap.SUBPRODUCT IN ('DATAPRPLUS', 'PRDATAPLUS')
	AND a2.EXPIRATIONDATE > sysdate;




---Exercise 2.1 - Account and Contact
SELECT
	(SELECT acc.code FROM ACCOUNTS acc WHERE acc.id = a.PARENT) AS MA,
	a.CODE sa,
	a.ACCOUNTNAME ,
	(SELECT a3.SHORTDESC FROM ACCOUNTSTATUSTYPE a3 WHERE a.OWNSTATUS = a3.CODE ) status ,
	act.FIRSTNAME || '' || act.MIDDLENAME || ' ' || act.LASTNAME fullname,
	act.GENDER ,
	act.BIRTHDAY,
	(SELECT ai.ACCOUNTANI FROM asani ai WHERE ai.ACCOUNTID = a.ID AND AI.SERVICETYPE = 'MOBILEOUT') account_ani
FROM
	accounts a
INNER JOIN ACCTCONTACTS act ON
	A.ID = Act.ACCOUNTID
WHERE
	a.parent = '6821472' AND a.OWNSTATUS = 'A';
	
---Exercise 2.2 - Account Package and Service Account 	
SELECT
	a.CODE,
	a.ACCOUNTNAME ,
	a.REGISTRATIONDATE ,
	P.CODE productcode,
	P.DESCRIPTION,
	s.CODE servicecode,
	S.DESCRIPTION
FROM
	accounts a
INNER JOIN PRODUCTS p ON
	a.PRODUCTCODE = p.CODE
INNER JOIN PRODUCTSERVICES p2 ON
	P.CODE = P2.PRODUCTCODE
INNER JOIN SERVICES s ON
	P2.SERVICECODE = S.CODE
WHERE
	a.code = '00304849210';

SELECT
	a.CODE,
	a.ACCOUNTNAME ,
	a.REGISTRATIONDATE ,
	(SELECT ai.ACCOUNTANI FROM asani ai WHERE ai.ACCOUNTID = a.ID AND AI.SERVICETYPE = 'MOBILEOUT') account_ani,
	a.PRODUCTCODE ,
	(SELECT p.DESCRIPTION FROM products p WHERE p.code = a.PRODUCTCODE ) description,
	ap.PRODUCT subproduct,
	(SELECT p.DESCRIPTION FROM products p WHERE p.code = ap.PRODUCT ) description,
	ap.SUBPRODUCT ,
	(SELECT p.DESCRIPTION FROM products p WHERE p.code = ap.SUBPRODUCT ) description
FROM
	accounts a 
INNER JOIN 
	ACCOUNTPRODUCTS ap ON ap.ACCOUNTID = a.id 
WHERE 
a.parent = '6821472' AND a.OWNSTATUS = 'A' ORDER BY a.PRODUCTCODE asc;



---Exercise 2.3 - Service Account Phone Numbers
SELECT
	a.CODE accountcode,
	a.ACCOUNTNAME ,
	a.REGISTRATIONDATE ,
	(
	SELECT
		a3.SHORTDESC
	FROM
		ACCOUNTSTATUSTYPE a3
	WHERE
		a.OWNSTATUS = a3.CODE ) status ,
	(
	SELECT
		ai.ACCOUNTANI
	FROM
		asani ai
	WHERE
		ai.ACCOUNTID = a.ID
		AND AI.SERVICETYPE = 'MOBILEOUT') phonenumber,
	a.PRODUCTCODE ,
	(
	SELECT
		p.description
	FROM
		products p
	WHERE
		p.CODE = a.PRODUCTCODE ) productdescription,
	(
	SELECT
		s.servicecode
	FROM
		accountservices s
	WHERE
		a.id = s.ACCOUNTID
		AND a.PRODUCTCODE = s.PRODUCTCODE
		AND s.SERVICETYPE = 'MDATA') accountservice,
	ap.SUBPRODUCT,
	(
	SELECT
		p.description
	FROM
		products p
	WHERE
		p.CODE = ap.SUBPRODUCT ) subproductdescription
FROM
	accounts a
INNER JOIN ACCOUNTPRODUCTS ap ON
	ap.ACCOUNTID = a.id
WHERE
	a.parent = '6821472'
	AND a.OWNSTATUS = 'A';




SELECT VT.RESERVED CODE, V.SKUCODE "TYPE" , V.KEY "NUMBER" FROM  VNT_ITEMS V, VNT_ITEM_INST VT WHERE
V.ID = VT.ITEMID
AND V.SKUCODE IN (SELECT CODE FROM VNT_ITEM_GROUP where RESOURCE_TYPE = 'PHONE_NUMBER')
AND VT.RESERVED IN (SELECT CODE FROM ACCOUNTS WHERE PARENT = '4326719');

---Exercise 2.4 - Account Package/Product Services


---Exercise 2.5 - Account Contact Address