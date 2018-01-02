select count(*) TOTAL_REGISTROS,
sum(case when length(trim(PRODUCT_ID))<>0 then 1 else 0 end) TOTAL_PRODUCT_ID,
count(distinct trim(PRODUCT_ID)) DISTINC_PRODUCT_ID,
sum(case when length(trim(CUSTOMER_ID))<>0 then 1 else 0 end) TOTAL_CUSTOMER_ID,
count(distinct (trim(CUSTOMER_ID))) DISTINC_CUSTOMER_ID,
sum(case when length(trim(PRODUCT_NAME))<>0 then 1 else 0 end) TOTAL_PRODUCT_NAME,
count(distinct (trim(PRODUCT_NAME))) DISTINC_PRODUCT_NAME,
sum(case when length(trim(ACCESS_POINT))<>0 then 1 else 0 end) TOTAL_ACCESS_POINT,
count(distinct (trim(ACCESS_POINT))) DISTINC_ACCESS_POINT,
sum(case when length(trim(`CHANNEL`))<>0 then 1 else 0 end) TOTAL_CHANNEL,
count(distinct (trim(`CHANNEL`))) DISTINC_CHANNEL,
sum(case when length(trim(AGENT_CODE))<>0 then 1 else 0 end) TOTAL_AGENT_CODE,
count(distinct (trim(AGENT_CODE))) DISTINC_AGENT_CODE,
sum(case when length(trim(START_DATE))<>0 then 1 else 0 end) TOTAL_START_DATE,
count(distinct (trim(START_DATE))) DISTINC_START_DATE,
sum(case when length(trim(INSTALL_DATE))<>0 then 1 else 0 end) TOTAL_INSTALL_DATE,
count(distinct (trim(INSTALL_DATE))) DISTINC_INSTALL_DATE,
sum(case when length(trim(END_DATE))<>0 then 1 else 0 end) TOTAL_END_DATE,
count(distinct (trim(END_DATE))) DISTINC_END_DATE,
sum(case when length(trim(PRODUCT_CITY))<>0 then 1 else 0 end) TOTAL_PRODUCT_CITY,
count(distinct (trim(PRODUCT_CITY))) DISTINC_PRODUCT_CITY,
sum(case when length(trim(PRODUCT_ADDRESS))<>0 then 1 else 0 end) TOTAL_PRODUCT_ADDRESS,
count(distinct (trim(PRODUCT_ADDRESS))) DISTINC_PRODUCT_ADDRESS,
sum(case when length(trim(PRODUCT_POSTAL_CODE))<>0 then 1 else 0 end) TOTAL_PRODUCT_POSTAL_CODE,
count(distinct (trim(PRODUCT_POSTAL_CODE))) DISTINC_PRODUCT_POSTAL_CODE,
sum(case when length(trim(PRODUCT_STATE))<>0 then 1 else 0 end) TOTAL_PRODUCT_STATE,
count(distinct (trim(PRODUCT_STATE))) DISTINC_PRODUCT_STATE,
sum(case when length(trim(PRODUCT_COUNTRY))<>0 then 1 else 0 end) TOTAL_PRODUCT_COUNTRY,
count(distinct (trim(PRODUCT_COUNTRY))) DISTINC_PRODUCT_COUNTRY
from STG.STG_PRODUCTOS_CRM PROD;


/* Customer Id que no estan en STG
*/
select distinct PROD.CUSTOMER_ID
from STG.STG_PRODUCTOS_CRM PROD
where trim(PROD.CUSTOMER_ID) not in 
(	select trim(CLI.CUSTOMER_ID)
	from STG.STG_CLIENTES_CRM CLI);

