select count(*) TOTAL_REGISTROS,
sum(case when length(trim(ID))<>0 then 1 else 0 end) TOTAL_ID,
count(distinct trim(ID)) DISTINC_ID,
sum(case when length(trim(`ORDER`))<>0 then 1 else 0 end) TOTAL_ORDER,
count(distinct (trim(`ORDER`))) DISTINC_ORDER,
sum(case when length(trim(`PHASE`))<>0 then 1 else 0 end) TOTAL_PHASE,
count(distinct (trim(`PHASE`))) DISTINC_PHASE,
sum(case when length(trim(AGENT))<>0 then 1 else 0 end) TOTAL_AGENT,
count(distinct (trim(AGENT))) DISTINC_AGENT,
sum(case when length(trim(START_DT))<>0 then 1 else 0 end) TOTAL_START_DT,
count(distinct (trim(START_DT))) DISTINC_START_DT,
sum(case when length(trim(END_DT))<>0 then 1 else 0 end) TOTAL_END_DT,
count(distinct (trim(END_DT))) DISTINC_END_DT
from STG.STG_ORDERS_CRM;

select * from STG.STG_ORDERS_CRM
where ID in (
select ID
from STG.STG_ORDERS_CRM
group by ID
having count(*)>4 )
;

use ODS;

drop  table if exists TMP_ORDERS ;
create table TMP_ORDERS as 
select distinct trim(ID) ORDERS_ID from STG.STG_ORDERS_CRM;

create index auxORDERS on ODS.TMP_ORDERS(ORDERS_ID);

create table TMP_PROD as 
select distinct trim(PRODUCT_ID) PRODUCT_ID from STG.STG_PRODUCTOS_CRM;

create index auxPRODS on ODS.TMP_PROD(PRODUCT_ID);


/* Todos los id de producto que no estan en orders*/
select count(*) 
from TMP_PROD P 
where P.PRODUCT_ID not in (select ORDERS_ID from TMP_ORDERS);

select * from STG.STG_PRODUCTOS_CRM
where PRODUCT_ID in (
select *
from TMP_PROD P 
where P.PRODUCT_ID not in (select ORDERS_ID from TMP_ORDERS)
);

/*Todos los ordes que no estan en prodcutos*/
select count(*) 
from TMP_ORDERS P 
where P.ORDERS_ID not in (select PRODUCT_ID from TMP_PROD);

select * from STG.STG_ORDERS_CRM 
where ID in (select *
from TMP_ORDERS P 
where P.ORDERS_ID not in (select PRODUCT_ID from TMP_PROD));

