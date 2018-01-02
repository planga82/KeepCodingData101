select count(*) TOTAL_REGISTROS,
sum(case when length(trim(ID))<>0 then 1 else 0 end) TOTAL_ID,
count(distinct trim(ID)) DISTINC_ID,
sum(case when length(trim(PHONE_NUMBER))<>0 then 1 else 0 end) TOTAL_PHONE_NUMBER,
count(distinct (trim(PHONE_NUMBER))) DISTINC_PHONE_NUMBER,
sum(case when length(trim(START_DATETIME))<>0 then 1 else 0 end) TOTAL_START_DATETIME,
count(distinct (trim(START_DATETIME))) DISTINC_START_DATETIME,
sum(case when length(trim(END_DATETIME))<>0 then 1 else 0 end) TOTAL_END_DATETIME,
count(distinct (trim(END_DATETIME))) DISTINC_END_DATETIME,
sum(case when length(trim(SERVICE))<>0 then 1 else 0 end) TOTAL_SERVICE,
count(distinct (trim(SERVICE))) DISTINC_SERVICE,
sum(case when length(trim(FLG_TRANSFER))<>0 then 1 else 0 end) TOTAL_FLG_TRANSFER,
count(distinct (trim(FLG_TRANSFER))) DISTINC_FLG_TRANSFER,
sum(case when length(trim(AGENT))<>0 then 1 else 0 end) TOTAL_AGENT,
count(distinct (trim(AGENT))) DISTINC_AGENT
from STG.STG_CONTACTOS_IVR;


USE ODS;


DROP TABLE if exists TMP_PHONE;
create table TMP_PHONE
select 
case when IVR.PHONE_NUMBER='' then 999999999 else convert(IVR.PHONE_NUMBER,unsigned integer) end TELEFONO_CLIENTE
from STG.STG_CONTACTOS_IVR IVR;


select count(*)
from ODS.TMP_PHONE tmp
where tmp.TELEFONO_CLIENTE not in
(select distinct TELEFONO_CLIENTE 
from ODS.ODS_HC_CLIENTES);

select distinct TELEFONO_CLIENTE
from ODS.TMP_PHONE order by TELEFONO_CLIENTE desc;
select distinct TELEFONO_CLIENTE 
from ODS.ODS_HC_CLIENTES order by TELEFONO_CLIENTE desc;