--As a Channel Sales Rep I want to see all Prism topups (online vs retail )
SELECT
	(
	SELECT
		RU.VL_USERNAME
	FROM
		MIDWARE.RREMIT_USER ru
	WHERE
		RU.ID = RT.ID_USER ) AS DISTRIBUTOR,
	(
	SELECT
		ACCOUNTID
	FROM
		ibpay@minddb
	WHERE
		PAYMENT_NUMBER = rt.ID_MIND_RECEIPT ) ACCOUNTID,
	(
	SELECT
		a.accountani
	FROM
		accounts@minddb aa, ibpay@minddb b, ASANI@minddb a
	WHERE
		aa.id = b.accountid
		AND a.accountid = aa.id
		AND a.SERVICETYPE = 'MOBILEOUT'
		AND a.todate > sysdate
		AND b.PAYMENT_NUMBER = rt.ID_MIND_RECEIPT ) phonnum,
	(
	SELECT
		AMOUNT
	FROM
		ibpay@minddb
	WHERE
		PAYMENT_NUMBER = rt.ID_MIND_RECEIPT ) AMOUNT,
	RT.ID_MIND_RECEIPT,
	RT.DT_TRANS,	
	RT.TP_TYPE
FROM
	midware.RREMIT_TRANS rt ;
