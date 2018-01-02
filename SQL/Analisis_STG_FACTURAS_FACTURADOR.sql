select count(*) TOTAL_REGISTROS,
sum(case when length(trim(BILL_REF_NO))<>0 then 1 else 0 end) TOTAL_BILL_REF_NO,
count(distinct trim(BILL_REF_NO)) DISTINC_BILL_REF_NO,
sum(case when length(trim(CUSTOMER_ID))<>0 then 1 else 0 end) TOTAL_CUSTOMER_ID,
count(distinct (trim(CUSTOMER_ID))) DISTINC_CUSTOMER_ID,
sum(case when length(trim(START_DATE))<>0 then 1 else 0 end) TOTAL_START_DATE,
count(distinct (trim(START_DATE))) DISTINC_START_DATE,
sum(case when length(trim(END_DATE))<>0 then 1 else 0 end) TOTAL_END_DATE,
count(distinct (trim(END_DATE))) DISTINC_END_DATE,
sum(case when length(trim(STATEMENT_DATE))<>0 then 1 else 0 end) TOTAL_STATEMENT_DATE,
count(distinct (trim(STATEMENT_DATE))) DISTINC_STATEMENT_DATE,
sum(case when length(trim(PAYMENT_DATE))<>0 then 1 else 0 end) TOTAL_PAYMENT_DATE,
count(distinct (trim(PAYMENT_DATE))) DISTINC_PAYMENT_DATE,
sum(case when length(trim(BILL_CYCLE))<>0 then 1 else 0 end) TOTAL_BILL_CYCLE,
count(distinct (trim(BILL_CYCLE))) DISTINC_BILL_CYCLE,
sum(case when length(trim(AMOUNT))<>0 then 1 else 0 end) TOTAL_AMOUNT,
count(distinct (trim(AMOUNT))) DISTINC_AMOUNT,
sum(case when length(trim(BILL_METHOD))<>0 then 1 else 0 end) TOTAL_BILL_METHOD,
count(distinct (trim(BILL_METHOD))) DISTINC_BILL_METHOD
from STG.STG_FACTURAS_FACTURADOR;


select count(distinct PROD.CUSTOMER_ID)
from STG.STG_FACTURAS_FACTURADOR PROD
where trim(PROD.CUSTOMER_ID) not in 
(	select trim(CLI.CUSTOMER_ID)
	from STG.STG_CLIENTES_CRM CLI);