
USE ODS;

set FOREIGN_KEY_CHECKS=0;

/*******************************************************************************************************
Carga tabla SEXOS

Se insertan los valores a pelo porque son pocos
*/

INSERT INTO ODS_DM_SEXOS VALUES(1,'MALE', current_date(), current_date());
INSERT INTO ODS_DM_SEXOS VALUES(2,'FEMALE', current_date(), current_date());
INSERT INTO ODS_DM_SEXOS VALUES(99,'DESCONOCIDO', current_date(), current_date());
INSERT INTO ODS_DM_SEXOS VALUES(98,'NO APLICA', current_date(), current_date());
commit;


/*******************************************************************************************************
Carga tabla profesiones
*/

INSERT INTO ODS_DM_PROFESIONES(DE_PROFESION, FC_INSERT, FC_MODIFICACION)
select distinct UPPER(TRIM(PROFESION)) PROFESION, current_date(), current_date()
FROM STG.STG_CLIENTES_CRM
WHERE LENGTH(TRIM(PROFESION))<>0;
INSERT INTO ODS_DM_PROFESIONES VALUES(999,'DESCONOCIDO', current_date(), current_date());
INSERT INTO ODS_DM_PROFESIONES VALUES(998,'NO APLICA', current_date(), current_date());
commit;

/*******************************************************************************************************
Carga tabla compañias
*/

INSERT INTO ODS_DM_COMPANYIAS(DE_COMPANYIA, FC_INSERT, FC_MODIFICACION)
select distinct UPPER(TRIM(COMPANY)) DE_COMPANYIA, current_date(), current_date()
FROM STG.STG_CLIENTES_CRM
WHERE LENGTH(TRIM(COMPANY))<>0;
INSERT INTO ODS_DM_COMPANYIAS VALUES(999,'DESCONOCIDO', current_date(), current_date());
INSERT INTO ODS_DM_COMPANYIAS VALUES(998,'NO APLICA', current_date(), current_date());
commit;

/*******************************************************************************************************
Carga tablas direcciones

No coinciden los codigos de pauses US en una tabla y UNITED STATES en la otra, por eso lo transformo

En todas las tablas de direcciones se cargan las direcciones de la tabla clientes y de las de productos

*/
INSERT INTO ODS_DM_PAIS(DE_PAIS, FC_INSERT, FC_MODIFICACION)
(select distinct UPPER(TRIM(COUNTRY)) DE_PAIS, current_date(), current_date()
FROM STG.STG_CLIENTES_CRM
WHERE LENGTH(TRIM(COUNTRY))<>0)
union
(select case when (UPPER(TRIM(PRODUCT_COUNTRY))='UNITED STATES') then 'US' else UPPER(TRIM(PRODUCT_COUNTRY)) end DE_PAIS, current_date(), current_date()
FROM STG.STG_PRODUCTOS_CRM
WHERE LENGTH(TRIM(PRODUCT_COUNTRY))<>0)
;


INSERT INTO ODS_DM_PAIS VALUES(999,'DESCONOCIDO', current_date(), current_date());
INSERT INTO ODS_DM_PAIS VALUES(998,'NO APLICA', current_date(), current_date());
commit;

/*
	Se juntan las ciudades y los estados en una unica tabla, porque hay ciudades con el mismo 
    nombre en diferentes estados
*/

INSERT INTO ODS_DM_CIUDADES_ESTADO(DE_CIUDAD, DE_ESTADO, ID_PAIS, FC_INSERT, FC_MODIFICACION)
(select distinct UPPER(TRIM(CLI.CITY)) DE_CIUDAD, 
		UPPER(TRIM(CLI.STATE)) DE_ESTADO, 
        PAI.ID_PAIS,
		current_date(), 
        current_date()
FROM STG.STG_CLIENTES_CRM CLI
INNER JOIN ODS.ODS_DM_PAIS PAI ON PAI.DE_PAIS=case when  LENGTH(TRIM(CLI.COUNTRY))<>0 then CLI.COUNTRY else 'DESCONOCIDO' end
WHERE LENGTH(TRIM(CITY))<>0)
UNION
(select distinct UPPER(TRIM(PROD.PRODUCT_CITY)) DE_CIUDAD, 
		UPPER(TRIM(PROD.PRODUCT_STATE)) DE_ESTADO, 
        PAI.ID_PAIS,
		current_date(), 
        current_date()
FROM STG.STG_PRODUCTOS_CRM PROD
INNER JOIN ODS.ODS_DM_PAIS PAI ON PAI.DE_PAIS=case when  LENGTH(TRIM(PROD.PRODUCT_COUNTRY))<>0 then PROD.PRODUCT_COUNTRY else 'DESCONOCIDO' end
WHERE LENGTH(TRIM(PROD.PRODUCT_CITY))<>0);

INSERT INTO ODS_DM_CIUDADES_ESTADO VALUES(999,'DESCONOCIDO', 99, 99, current_date(), current_date());
INSERT INTO ODS_DM_CIUDADES_ESTADO VALUES(998,'NO APLICA', 98, 98, current_date(), current_date());
commit;




INSERT INTO ODS_HC_DIRECCIONES(DE_DIRECCION ,DE_CP,ID_CIUDAD,FLG_DIRECCION_CLIENTE,FLG_DIRECCION_FACTURACION,FC_INSERT,FC_MODIFICACION)
(select distinct UPPER(TRIM(CLI.ADDRESS)) DIRECCION,
		case when length(trim(CLI.POSTAL_CODE)) then trim(CLI.POSTAL_CODE) else 99999 end CP, 
        CIU.ID_CIUDAD,
        1,
        0, 
        current_date(), 
        current_date()
from STG.STG_CLIENTES_CRM CLI
inner join ODS_DM_CIUDADES_ESTADO CIU on DE_CIUDAD=case when  LENGTH(TRIM(CLI.CITY))<>0 then UPPER(TRIM(CLI.CITY)) else 'DESCONOCIDO' end
									and DE_ESTADO=case when  LENGTH(TRIM(CLI.STATE))<>0 then UPPER(TRIM(CLI.STATE)) else 'DESCONOCIDO' end
where length(trim(CLI.ADDRESS))<>0)
UNION
(select distinct UPPER(TRIM(PROD.PRODUCT_ADDRESS)) DIRECCION,
		case when length(trim(PROD.PRODUCT_POSTAL_CODE)) then trim(PROD.PRODUCT_POSTAL_CODE) else 99999 end CP, 
        CIU.ID_CIUDAD,
        1,
        0, 
        current_date(), 
        current_date()
from STG.STG_PRODUCTOS_CRM PROD
inner join ODS_DM_CIUDADES_ESTADO CIU on DE_CIUDAD=case when  LENGTH(TRIM(PROD.PRODUCT_CITY))<>0 then UPPER(TRIM(PROD.PRODUCT_CITY)) else 'DESCONOCIDO' end
									and DE_ESTADO=case when  LENGTH(TRIM(PROD.PRODUCT_STATE))<>0 then UPPER(TRIM(PROD.PRODUCT_STATE)) else 'DESCONOCIDO' end
where length(trim(PROD.PRODUCT_ADDRESS))<>0);

INSERT INTO ODS_HC_DIRECCIONES VALUES(999999,'DESCONOCIDO', 99999,999, 0, 0, current_date(), current_date());
INSERT INTO ODS_HC_DIRECCIONES VALUES(999998,'NO APLICA', 99998,999, 0, 0, current_date(), current_date());

commit;




/*******************************************************************************************************
Carga tabla telefonos 

Esta tabla almacena los telefonos tanto de la tabla clientes como de la de contactos

*/
insert into ODS.ODS_HC_TELEFONOS(DE_TELEFONO,FC_INSERT,FC_MODIFICACION)
select distinct AUX.DE_TELEFONO,current_date(),current_date()
from 
((select convert(IVR.PHONE_NUMBER,unsigned integer) DE_TELEFONO 
	from STG.STG_CONTACTOS_IVR IVR 
    where IVR.PHONE_NUMBER<>'')
union
(select convert(replace(CLI.PHONE,'-',''),unsigned integer) DE_TELEFONO
	from STG.STG_CLIENTES_CRM CLI
    where CLI.PHONE <>'')) AUX;

INSERT INTO ODS_HC_TELEFONOS VALUES(999999,999999999, current_date(), current_date());
INSERT INTO ODS_HC_TELEFONOS VALUES(999998,999999998, current_date(), current_date());

commit;

/*******************************************************************************************************
Carga tabla Departamentos 
*/
insert into ODS.ODS_DM_DEPARTAMENTOS(DE_DEPARTAMENTO,FC_INSERT,FC_MODIFICACION)
select distinct UPPER(TRIM(CON.SERVICE)), current_date(), current_date()
FROM STG.STG_CONTACTOS_IVR CON
WHERE LENGTH(TRIM(CON.SERVICE))<>0;

INSERT INTO ODS_DM_DEPARTAMENTOS VALUES(9999,'DESCONOCIDO', current_date(), current_date());
INSERT INTO ODS_DM_DEPARTAMENTOS VALUES(9998,'NO APLICA', current_date(), current_date());

commit;

/*******************************************************************************************************
Carga tabla Metodos facturacion 
*/
insert into ODS.ODS_DM_METODO_FACTURACION(DE_METODO_FACTURACION,FC_INSERT,FC_MODIFICACION)
select distinct UPPER(TRIM(FAC.BILL_METHOD)), current_date(), current_date()
FROM STG.STG_FACTURAS_FACTURADOR FAC
WHERE LENGTH(TRIM(FAC.BILL_METHOD))<>0;

INSERT INTO ODS.ODS_DM_METODO_FACTURACION VALUES(9999,'DESCONOCIDO', current_date(), current_date());
INSERT INTO ODS.ODS_DM_METODO_FACTURACION VALUES(9998,'NO APLICA', current_date(), current_date());

commit;

/*******************************************************************************************************
Carga tabla ciclos facturacion 
*/
insert into ODS.ODS_DM_CICLO_FACTURACION(DE_CICLO_FACTURACION,FC_INSERT,FC_MODIFICACION)
select distinct UPPER(TRIM(FAC.BILL_CYCLE)), current_date(), current_date()
FROM STG.STG_FACTURAS_FACTURADOR FAC
WHERE LENGTH(TRIM(FAC.BILL_CYCLE))<>0;

INSERT INTO ODS.ODS_DM_CICLO_FACTURACION VALUES(9999,'DESCONOCIDO', current_date(), current_date());
INSERT INTO ODS.ODS_DM_CICLO_FACTURACION VALUES(9998,'NO APLICA', current_date(), current_date());

commit;

/*******************************************************************************************************
Carga tabla Agentes 
*/
insert into ODS.ODS_DM_AGENTES(COD_AGENTE,FC_INSERT,FC_MODIFICACION)
select distinct convert(TRIM(PROD.AGENT_CODE),unsigned integer), current_date(), current_date()
FROM STG.STG_PRODUCTOS_CRM PROD
WHERE LENGTH(TRIM(PROD.AGENT_CODE))<>0;

INSERT INTO ODS.ODS_DM_AGENTES VALUES(9999,9999, current_date(), current_date());
INSERT INTO ODS.ODS_DM_AGENTES VALUES(9998,9998, current_date(), current_date());

commit;

/*******************************************************************************************************
Carga tabla canales 
*/
insert into ODS.ODS_DM_CANALES(DE_CANAL,FC_INSERT,FC_MODIFICACION)
select distinct UPPER(TRIM(PROD.CHANNEL)), current_date(), current_date()
FROM STG.STG_PRODUCTOS_CRM PROD
WHERE LENGTH(TRIM(PROD.CHANNEL))<>0;

INSERT INTO ODS.ODS_DM_CANALES VALUES(9999,'DESCONOCIDO', current_date(), current_date());
INSERT INTO ODS.ODS_DM_CANALES VALUES(9998,'NO APLICA', current_date(), current_date());

commit;



/*******************************************************************************************************
Carga tabla productos 
*/
insert into ODS.ODS_DM_PRODUCTOS(DE_PRODUCTO,FC_INSERT,FC_MODIFICACION)
select distinct UPPER(TRIM(PROD.PRODUCT_NAME)), current_date(), current_date()
FROM STG.STG_PRODUCTOS_CRM PROD
WHERE LENGTH(TRIM(PROD.PRODUCT_NAME))<>0;

INSERT INTO ODS.ODS_DM_PRODUCTOS VALUES(9999,'DESCONOCIDO', current_date(), current_date());
INSERT INTO ODS.ODS_DM_PRODUCTOS VALUES(9998,'NO APLICA', current_date(), current_date());

commit;


/**
 Carga de la tabla de fases relacionada con orders
*/
insert into ODS.ODS_DM_FASES(DE_PHASE,FC_INSERT,FC_MODIFICACION)
select distinct UPPER(TRIM(ORD.PHASE)), current_date(), current_date()
FROM STG.STG_ORDERS_CRM ORD
WHERE LENGTH(TRIM(ORD.PHASE))<>0;

INSERT INTO ODS.ODS_DM_FASES VALUES(9999,'DESCONOCIDO', current_date(), current_date());
INSERT INTO ODS.ODS_DM_FASES VALUES(9998,'NO APLICA', current_date(), current_date());


/*******************************************************************************************************
Anlaliza tablas para tener mejor rendimiento en las cargas posteriores
*/

set FOREIGN_KEY_CHECKS=1;

analyze table ODS_DM_SEXOS;
analyze table ODS_DM_PROFESIONES;
analyze table ODS_DM_COMPANYIAS;
analyze table ODS_DM_PAIS;
analyze table ODS_DM_CIUDADES_ESTADO;
analyze table ODS_HC_DIRECCIONES;
analyze table ODS_HC_TELEFONOS;
analyze table ODS_DM_DEPARTAMENTOS;
analyze table ODS_DM_METODO_FACTURACION;
analyze table ODS_DM_CICLO_FACTURACION;
analyze table ODS.ODS_DM_AGENTES;
analyze table ODS.ODS_DM_CANALES;
analyze table ODS_DM_FASES;

set FOREIGN_KEY_CHECKS=0;

/*******************************************************************************************************
Carga tabla llamadas 

Se crean estos 2 indices para acelerar los inner join

Se tratan las fechas para solo quedarnos con el dia, el mes y el año
*/
create index indice_telefonos on  ODS.ODS_HC_TELEFONOS(DE_TELEFONO);
create index indice_departamentos on  ODS.ODS_DM_DEPARTAMENTOS(DE_DEPARTAMENTO);


insert into ODS_HC_LLAMADAS(ID,ID_TELEFONO,DIA_INICIO,DIA_FINALIZACION,ID_DEPARTAMENTO,FLG_TRANSFER,AGENTE)
select 
convert(trim(CON.ID),unsigned integer)
,TEL.ID_TELEFONO
,case when CON.START_DATETIME='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date( substring_index(CON.START_DATETIME," ",1), '%Y-%m-%d') end DIA_INICIO
,case when CON.END_DATETIME='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date(substring_index(CON.END_DATETIME," ",1), '%Y-%m-%d') end DIA_FINALIZACION
,DEP.ID_DEPARTAMENTO
,case when upper(CON.FLG_TRANSFER)='TRUE' then true else false end 
,case when CON.AGENT='' then 'DESCONOCIDO' else upper(trim(CON.AGENT)) end AGENTE
from STG.STG_CONTACTOS_IVR CON 
	inner join ODS.ODS_DM_DEPARTAMENTOS DEP on case when  LENGTH(TRIM(CON.SERVICE))<>0 then UPPER(TRIM(CON.SERVICE)) else 'DESCONOCIDO' end=DEP.DE_DEPARTAMENTO
    inner join ODS.ODS_HC_TELEFONOS TEL on case when  LENGTH(TRIM(CON.PHONE_NUMBER))<>0 then convert(TRIM(CON.PHONE_NUMBER), unsigned integer) else '999999999' end=TEL.DE_TELEFONO
;

commit;

analyze table ODS_HC_LLAMADAS;

/*******************************************************************************************************
Carga tablas de clientes 
Primero se crean unas tablas temporales para hacer mas eficiente la carga de clientes y 
no hacerlo todo en la misma query
Se crean estos indices para acelerar los inner join
*/ 
create index dir1 on ODS_HC_DIRECCIONES(ID_CIUDAD);
create index dir2 on ODS_DM_CIUDADES_ESTADO(ID_CIUDAD);
create index dir3 on ODS_DM_CIUDADES_ESTADO(ID_PAIS);
create index dir4 on ODS_DM_PAIS(ID_PAIS);

create table TMP_DIRECCIONES_CLIENTE as
select DIR.ID_DIRECCION,
	DIR.DE_DIRECCION,
    DIR.DE_CP,
    CIU.DE_CIUDAD,
    CIU.DE_ESTADO,
    PAI.DE_PAIS
from ODS_HC_DIRECCIONES DIR 
	inner join ODS_DM_CIUDADES_ESTADO CIU on DIR.ID_CIUDAD=CIU.ID_CIUDAD 
    inner join ODS_DM_PAIS PAI on PAI.ID_PAIS=CIU.ID_PAIS
where DIR.FLG_DIRECCION_CLIENTE=1;

create index dir5 on TMP_DIRECCIONES_CLIENTE(DE_DIRECCION);
create index dir6 on TMP_DIRECCIONES_CLIENTE(DE_CP);
create index dir7 on TMP_DIRECCIONES_CLIENTE(DE_CIUDAD);
create index dir8 on TMP_DIRECCIONES_CLIENTE(DE_ESTADO);
create index dir9 on TMP_DIRECCIONES_CLIENTE(DE_PAIS);

create table TMP_DIRECCIONES_CLIENTE2 as
select CLI.CUSTOMER_ID, TMP.ID_DIRECCION
from STG.STG_CLIENTES_CRM CLI
inner join TMP_DIRECCIONES_CLIENTE TMP on
	case when  LENGTH(TRIM(CLI.ADDRESS))<>0 then UPPER(TRIM(CLI.ADDRESS)) else 'DESCONOCIDO' end=TMP.DE_DIRECCION and
    case when  LENGTH(TRIM(CLI.POSTAL_CODE))<>0 then UPPER(TRIM(CLI.POSTAL_CODE)) else 'DESCONOCIDO' end=TMP.DE_CP  and
    case when  LENGTH(TRIM(CLI.CITY))<>0 then UPPER(TRIM(CLI.CITY)) else 'DESCONOCIDO' end=TMP.DE_CIUDAD and
    case when  LENGTH(TRIM(CLI.STATE))<>0 then UPPER(TRIM(CLI.STATE)) else 'DESCONOCIDO' end=TMP.DE_ESTADO and
    case when  LENGTH(TRIM(CLI.COUNTRY))<>0 then UPPER(TRIM(CLI.COUNTRY)) else 'DESCONOCIDO' end=TMP.DE_PAIS;

set FOREIGN_KEY_CHECKS=1;

analyze table TMP_DIRECCIONES_CLIENTE;
analyze table TMP_DIRECCIONES_CLIENTE2;

set FOREIGN_KEY_CHECKS=0;

create index aux1 on ODS.ODS_DM_SEXOS(DE_SEXO);
create index aux2 on ODS.ODS_DM_PROFESIONES(DE_PROFESION);
create index aux3 on ODS.ODS_DM_COMPANYIAS(DE_COMPANYIA);
create index aux4 on ODS.TMP_DIRECCIONES_CLIENTE2(CUSTOMER_ID);


insert into ODS_HC_CLIENTES 
select CLI.CUSTOMER_ID as ID_CLIENTE,
case when CLI.FIRST_NAME='' then 'DESCONOCIDO' else upper(trim(CLI.FIRST_NAME)) end NOMBRE_CLIENTE,
case when CLI.LAST_NAME='' then 'DESCONOCIDO' else upper(trim(CLI.LAST_NAME)) end APELLIDOS_CLIENTE,
case when CLI.IDENTIFIED_DOC='' then '99-999-9999' else upper(trim(CLI.IDENTIFIED_DOC)) end NUM_DOC_CLIENTE,
SEXOS.ID_SEXO,
DIR.ID_DIRECCION,
case when CLI.EMAIL='' then 'DESCONOCIDO' else upper(trim(CLI.EMAIL)) end EMAIL,
case when CLI.BIRTHDAY='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date( CLI.BIRTHDAY, '%d/%m/%Y') end FC_NACIMIENTO,
PROF.ID_PROFESION,
COM.ID_COMPANYIA,
current_date(),
current_date()
from STG.STG_CLIENTES_CRM CLI 
	inner join ODS.ODS_DM_SEXOS SEXOS on case when  LENGTH(TRIM(CLI.GENDER))<>0 then UPPER(TRIM(CLI.GENDER)) else 'DESCONOCIDO' end=SEXOS.DE_SEXO
    inner join ODS.ODS_DM_PROFESIONES PROF on case when  LENGTH(TRIM(CLI.PROFESION))<>0 then UPPER(TRIM(CLI.PROFESION)) else 'DESCONOCIDO' end=PROF.DE_PROFESION
    inner join ODS.ODS_DM_COMPANYIAS COM on case when  LENGTH(TRIM(CLI.COMPANY))<>0 then UPPER(TRIM(CLI.COMPANY)) else 'DESCONOCIDO' end=COM.DE_COMPANYIA
	left outer join ODS.TMP_DIRECCIONES_CLIENTE2 DIR on CLI.CUSTOMER_ID=DIR.CUSTOMER_ID;
commit;

analyze table ODS_HC_CLIENTES;

/**
esta tabla relaciona los telefonos con las personas. Asumimos que un telefono puede pertenecer a 
varios clientes y un cliente puee tener varios telefonos
*/

insert into ODS.ODS_HC_TELEFONOS_PERSONAS(ID_CLIENTE,ID_TELEFONO,FC_INSERT,FC_MODIFICACION)
select CLI.CUSTOMER_ID as ID_CLIENTE,
 TEL.ID_TELEFONO,
 current_date(),
 current_date()
from STG.STG_CLIENTES_CRM CLI 
	inner join ODS.ODS_HC_TELEFONOS TEL on case when CLI.PHONE='' then 999999999 else convert(replace(CLI.PHONE,'-',''),unsigned integer) end=TEL.DE_TELEFONO;
    
/*
 Carga de tabla de facturacion
 Creamos os indices para acelerar el inner join
 
*/
create index fac1 on ODS.ODS_DM_METODO_FACTURACION(DE_METODO_FACTURACION);
create index fac2 on ODS.ODS_DM_CICLO_FACTURACION(DE_CICLO_FACTURACION);

insert into ODS.ODS_HC_FACTURACION(BILL_REF_NO,ID_CLIENTE,DIA_INICIO,DIA_FINALIZACION,DIA_DECLARACION,DIA_PAGO,CANTIDAD,ID_METODO_FACTURACION,ID_CICLO_FACTURACION,FC_INSERT,FC_MODIFICACION) 
select convert(trim(FAC.BILL_REF_NO),unsigned integer),
	convert(trim(FAC.CUSTOMER_ID),unsigned integer) as ID_CLIENTE,
    case when FAC.START_DATE='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date( substring_index(FAC.START_DATE," ",1), '%Y-%m-%d') end DIA_INICIO,
    case when FAC.END_DATE='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date(FAC.END_DATE, '%Y-%m-%d') end DIA_FINALIZACION,
    case when FAC.STATEMENT_DATE='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date( substring_index(FAC.STATEMENT_DATE," ",1), '%Y-%m-%d') end DIA_DECLARACION,
    case when FAC.PAYMENT_DATE='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date( substring_index(FAC.PAYMENT_DATE," ",1), '%Y-%m-%d') end DIA_PAGO,
	cast(trim(FAC.AMOUNT) as decimal(10,2)) CANTIDAD,
    MFAC.ID_METODO_FACTURACION,
    CFAC.ID_CICLO_FACTURACION,
    current_date(),
	current_date()
from STG.STG_FACTURAS_FACTURADOR FAC 
	inner join ODS.ODS_DM_METODO_FACTURACION MFAC on UPPER(TRIM(FAC.BILL_METHOD))=MFAC.DE_METODO_FACTURACION
	inner join ODS.ODS_DM_CICLO_FACTURACION CFAC on UPPER(TRIM(FAC.BILL_CYCLE))=CFAC.DE_CICLO_FACTURACION;

/*
Tabla temporal para acelerar la carga de la tabla servicios al cruzarla con la de direcciones
*/

create table TMP_DIRECCIONES_SERVICIOS as
select PROD.PRODUCT_ID, TMP.ID_DIRECCION
from STG.STG_PRODUCTOS_CRM PROD
inner join TMP_DIRECCIONES_CLIENTE TMP on
	case when  LENGTH(TRIM(PROD.PRODUCT_ADDRESS))<>0 then UPPER(TRIM(PROD.PRODUCT_ADDRESS)) else 'DESCONOCIDO' end=TMP.DE_DIRECCION and
    case when  LENGTH(TRIM(PROD.PRODUCT_POSTAL_CODE))<>0 then UPPER(TRIM(PROD.PRODUCT_POSTAL_CODE)) else 'DESCONOCIDO' end=TMP.DE_CP and
    case when  LENGTH(TRIM(PROD.PRODUCT_CITY))<>0 then UPPER(TRIM(PROD.PRODUCT_CITY)) else 'DESCONOCIDO' end=TMP.DE_CIUDAD and
    case when  LENGTH(TRIM(PROD.PRODUCT_STATE))<>0 then UPPER(TRIM(PROD.PRODUCT_STATE)) else 'DESCONOCIDO' end=TMP.DE_ESTADO and
    case when (UPPER(TRIM(PROD.PRODUCT_COUNTRY))='UNITED STATES') then 'US' else 
				case when  LENGTH(TRIM(PROD.PRODUCT_COUNTRY))<>0 then UPPER(TRIM(PROD.PRODUCT_COUNTRY)) else 'DESCONOCIDO' end
				end=TMP.DE_PAIS;
	
/*
Indices para acelerar los join
*/

create index cli1 on ODS.ODS_HC_CLIENTES(ID_CLIENTE);
create index prodIn1 on ODS.ODS_DM_PRODUCTOS(DE_PRODUCTO);
create index prodIn2 on ODS.ODS_DM_CANALES(DE_CANAL);
create index prodIn3 on ODS.ODS_DM_AGENTES(COD_AGENTE);
create index prodIn4 on ODS.TMP_DIRECCIONES_SERVICIOS(PRODUCT_ID);

insert into ODS.ODS_HC_SERVICIOS(ID_SERVICIO,ID_CLIENTE,ID_PRODUCTO,PUNTO_ACCESO,ID_CANAL,ID_AGENTE,DIA_INICIO,DIA_INSTALACION,DIA_FINALIZACION,FC_INSERT,FC_MODIFICACION,ID_DIRECCION_CLIENTE)
select PROD.PRODUCT_ID
	,convert(trim(PROD.CUSTOMER_ID),unsigned integer) ID_CLIENTE
	,ODSPROD.ID_PRODUCTO ID_PRODUCTO
	, case when  LENGTH(TRIM(PROD.ACCESS_POINT))<>0 then cast(TRIM(PROD.ACCESS_POINT) as decimal(65,2)) else 9999999999 end PUNTO_ACCESO
	,ODSCANALES.ID_CANAL  ID_CANAL
	,ODSAGENTES.ID_AGENTE ID_AGENTE
	,case when PROD.START_DATE='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date( PROD.START_DATE, '%d/%m/%Y') end DIA_INICIO
	,case when PROD.INSTALL_DATE='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date( substring_index(PROD.INSTALL_DATE," ",1), '%Y-%m-%d') end DIA_INSTALACION
	,case when PROD.END_DATE='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date( substring_index(PROD.END_DATE," ",1), '%Y-%m-%d') end DIA_FINALIZACION
	,current_date()
    ,current_date()
    ,TMP.ID_DIRECCION ID_DIRECCION
from STG.STG_PRODUCTOS_CRM PROD
inner join ODS.ODS_DM_PRODUCTOS ODSPROD on case when length(UPPER(TRIM(PROD.PRODUCT_NAME)))<>0 then UPPER(TRIM(PROD.PRODUCT_NAME)) else 'DESCONOCIDO' end = ODSPROD.DE_PRODUCTO
inner join ODS.ODS_DM_CANALES ODSCANALES on case when length(UPPER(TRIM(PROD.CHANNEL)))<>0 then UPPER(TRIM(PROD.CHANNEL)) else 'DESCONOCIDO' end  = ODSCANALES.DE_CANAL
inner join ODS.ODS_DM_AGENTES ODSAGENTES on case when length(TRIM(PROD.AGENT_CODE))<>0 then convert(TRIM(PROD.AGENT_CODE),unsigned integer) else 9999 end = ODSAGENTES.COD_AGENTE
left outer join TMP_DIRECCIONES_SERVICIOS TMP on PROD.PRODUCT_ID=TMP.PRODUCT_ID
where trim(PROD.CUSTOMER_ID) not in 
(	select distinct PROD.CUSTOMER_ID
	from STG.STG_PRODUCTOS_CRM PROD
	where trim(PROD.CUSTOMER_ID) not in 
	(	select trim(CLI.CUSTOMER_ID)
	from STG.STG_CLIENTES_CRM CLI));


/*
Carga de la tabla de ORDERS
*/

create index auxORD1 on ODS.ODS_DM_FASES(DE_PHASE);

insert into ODS_HC_ENCARGOS(ID_SERVICIO,ORDERID,ID_PHASE,AGENTE,DIA_COMIENZO,DIA_FINALIZACION,FC_INSERT,FC_MODIFICACION)
select 
convert(trim(ORD.ID),unsigned integer) ID_SERVICIO
,convert(trim(ORD.ORDER),unsigned integer) ORDERID
,FAS.ID_PHASE
,case when ORD.AGENT='' then 'DESCONOCIDO' else upper(trim(ORD.AGENT)) end AGENTE
,case when ORD.START_DT='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date( substring_index(ORD.START_DT," ",1), '%Y-%m-%d') end DIA_COMIENZO
,case when ORD.END_DT='' then str_to_date('31/12/9999','%d/%m/%Y') else str_to_date( substring_index(ORD.END_DT," ",1), '%Y-%m-%d') end DIA_FINALIZACION
,current_date()
,current_date()
from STG.STG_ORDERS_CRM ORD
inner join ODS.ODS_DM_FASES FAS on UPPER(TRIM(ORD.PHASE))=FAS.DE_PHASE;


insert into ODS_HC_ENCARGOS_FINALIZADOS
select ENC.NEWID ID,
case when ENC.NEWID in (select ENC.NEWID
						from ODS.ODS_HC_ENCARGOS ENC
						where ENC.DIA_FINALIZACION=str_to_date('31/12/9999','%d/%m/%Y'))
	 then false
     else true
     end FINALIZADO,
current_date() FC_INSERT,
current_date() FC_MODIFICACION
from ODS.ODS_HC_ENCARGOS ENC;


create index auxHSSERV2 on ODS.ODS_HC_ENCARGOS(ID_SERVICIO);

insert into ODS_HC_ENCARGOS_SERVICIOS(ID_ENCARGO,ID_SERVICIO)
select SER.ID_SERVICIO, ENC.NEWID
from ODS.ODS_HC_SERVICIOS SER
inner join ODS.ODS_HC_ENCARGOS ENC on SER.ID_SERVICIO = ENC.ID_SERVICIO;


set FOREIGN_KEY_CHECKS=1;


