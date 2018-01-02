USE ODS;

/*
Se eliminan todas la tabla para crear la estructura de nuevo
*/

set FOREIGN_KEY_CHECKS=0;
drop table if exists  ODS_DM_SEXOS;
drop table if exists  ODS_DM_PROFESIONES;
drop table if exists  ODS_HC_LLAMADAS;
drop table if exists  ODS_DM_COMPANYIAS;
drop table if exists  ODS_DM_PAIS;
drop table if exists  ODS_HC_CLIENTES;
drop table if exists  ODS_DM_CIUDADES_ESTADO;
drop table if exists  ODS_DM_PRODUCTOS;
drop table if exists  ODS_DM_CANALES;
drop table if exists  ODS_DM_AGENTES;
drop table if exists  ODS_DM_DEPARTAMENTOS;
drop table if exists  ODS_HC_SERVICIOS;
drop table if exists  ODS_HC_TELEFONOS;
drop table if exists  ODS_HC_TELEFONOS_PERSONAS;
drop table if exists  ODS_DM_CICLO_FACTURACION;
drop table if exists  ODS_DM_METODO_FACTURACION;
drop table if exists  ODS_HC_FACTURACION;
drop table if exists  ODS_HC_DIRECCIONES;
drop table if exists  TMP_DIRECCIONES_CLIENTE;
drop table if exists  TMP_DIRECCIONES_CLIENTE2;
drop table if exists TMP_DIRECCIONES_SERVICIOS;
drop table if exists ODS_DM_FASES;
drop table if exists ODS_HC_ENCARGOS;
drop table if exists ODS_HC_ENCARGOS_FINALIZADOS;
drop table if exists ODS_HC_ENCARGOS_SERVICIOS;
set FOREIGN_KEY_CHECKS=1;


create table if not exists ODS_DM_SEXOS
(ID_SEXO int unsigned not null primary key,
DE_SEXO varchar(64),
FC_INSERT date,
FC_MODIFICACION date);


create table if not exists ODS_DM_PROFESIONES
(ID_PROFESION int unsigned auto_increment not null primary key,
DE_PROFESION varchar(512),
FC_INSERT date,
FC_MODIFICACION date);


create table if not exists ODS_DM_COMPANYIAS
(ID_COMPANYIA int unsigned auto_increment not null primary key,
DE_COMPANYIA varchar(512),
FC_INSERT date,
FC_MODIFICACION date);

create table if not exists ODS_DM_FASES(
ID_PHASE int unsigned auto_increment not null primary key,
DE_PHASE varchar(512),
FC_INSERT date,
FC_MODIFICACION date
);


create table if not exists ODS_DM_PAIS
(ID_PAIS int unsigned auto_increment not null primary key,
DE_PAIS varchar(512),
FC_INSERT date,
FC_MODIFICACION date);


create table if not exists ODS_DM_CIUDADES_ESTADO
(ID_CIUDAD int unsigned auto_increment not null primary key,
DE_CIUDAD varchar(512),
DE_ESTADO varchar(512),
ID_PAIS int unsigned,
FC_INSERT date,
FC_MODIFICACION date,
foreign key(ID_PAIS) references ODS_DM_PAIS(ID_PAIS) on delete no action on update no action);


create table if not exists ODS_HC_DIRECCIONES
(ID_DIRECCION int unsigned auto_increment not null primary key,
DE_DIRECCION varchar(512),
DE_CP int,
ID_CIUDAD int unsigned,
FLG_DIRECCION_CLIENTE bool,
FLG_DIRECCION_FACTURACION bool,
FC_INSERT date,
FC_MODIFICACION date,
foreign key(ID_CIUDAD) references ODS_DM_CIUDADES_ESTADO(ID_CIUDAD) on delete no action on update no action);



create table if not exists ODS_HC_CLIENTES 
(ID_CLIENTE int not null primary key,
NOMBRE_CLIENTE varchar(512),
APELLIDOS_CLIENTE varchar(512),
NUM_DOC_CLIENTE varchar(24),
ID_SEXO int unsigned,
ID_DIRECCION_CLIENTE int unsigned,
EMAIL varchar(512),
FC_NACIMIENTO date,
ID_PROFESION int unsigned,
ID_COMPANYIA int unsigned,
FC_INSERT date,
FC_MODIFICACION date,
foreign key(ID_SEXO) references ODS_DM_SEXOS(ID_SEXO) on delete no action on update no action,
foreign key(ID_DIRECCION_CLIENTE) references ODS_HC_DIRECCIONES(ID_DIRECCION) on delete no action on update no action,
foreign key(ID_PROFESION) references ODS_DM_PROFESIONES(ID_PROFESION) on delete no action on update no action,
foreign key(ID_COMPANYIA) references ODS_DM_COMPANYIAS(ID_COMPANYIA) on delete no action on update no action) ;



create table if not exists ODS_DM_PRODUCTOS
(ID_PRODUCTO int unsigned auto_increment not null primary key,
DE_PRODUCTO varchar(512),
FC_INSERT date,
FC_MODIFICACION date);


create table if not exists ODS_DM_CANALES
(ID_CANAL int unsigned auto_increment not null primary key,
DE_CANAL varchar(512),
FC_INSERT date,
FC_MODIFICACION date);


create table if not exists ODS_DM_AGENTES
(ID_AGENTE int unsigned auto_increment not null primary key,
COD_AGENTE bigint,
FC_INSERT date,
FC_MODIFICACION date);



create table if not exists ODS_HC_SERVICIOS 
(ID_SERVICIO int not null primary key auto_increment,
ID_CLIENTE int,
ID_PRODUCTO int unsigned,
PUNTO_ACCESO double,
ID_CANAL int unsigned,
ID_AGENTE int unsigned,
DIA_INICIO date,
DIA_INSTALACION date,
DIA_FINALIZACION date,
FC_INSERT date,
FC_MODIFICACION date,
ID_DIRECCION_CLIENTE int unsigned,
foreign key(ID_CLIENTE) references ODS_HC_CLIENTES(ID_CLIENTE) on delete no action on update no action,
foreign key(ID_PRODUCTO) references ODS_DM_PRODUCTOS(ID_PRODUCTO) on delete no action on update no action,
foreign key(ID_CANAL) references ODS_DM_CANALES(ID_CANAL) on delete no action on update no action,
foreign key(ID_AGENTE) references ODS_DM_AGENTES(ID_AGENTE) on delete no action on update no action,
foreign key(ID_DIRECCION_CLIENTE) references ODS_HC_DIRECCIONES(ID_DIRECCION) on delete no action on update no action 
) ;



create table if not exists ODS_DM_DEPARTAMENTOS
(ID_DEPARTAMENTO int unsigned auto_increment not null primary key,
DE_DEPARTAMENTO varchar(512),
FC_INSERT date,
FC_MODIFICACION date);


create table if not exists ODS_HC_TELEFONOS
(ID_TELEFONO int unsigned auto_increment not null primary key,
DE_TELEFONO bigint,
FC_INSERT date,
FC_MODIFICACION date);


create table if not exists ODS_HC_TELEFONOS_PERSONAS
(ID int unsigned auto_increment not null primary key,
ID_CLIENTE int,
ID_TELEFONO int unsigned,
FC_INSERT date,
FC_MODIFICACION date,
foreign key(ID_CLIENTE) references ODS_HC_CLIENTES(ID_CLIENTE) on delete no action on update no action,
foreign key(ID_TELEFONO) references ODS_HC_TELEFONOS(ID_TELEFONO) on delete no action on update no action
);


create table if not exists ODS_HC_LLAMADAS 
(ID_LLAMADA int auto_increment not null primary key,
ID int,
ID_TELEFONO int unsigned,
DIA_INICIO date,
DIA_FINALIZACION date,
ID_DEPARTAMENTO int unsigned,
FLG_TRANSFER boolean,
AGENTE varchar(512),
FC_INSERT date,
FC_MODIFICACION date,
foreign key(ID_DEPARTAMENTO) references ODS_DM_DEPARTAMENTOS(ID_DEPARTAMENTO) on delete no action on update no action,
foreign key(ID_TELEFONO) references ODS_HC_TELEFONOS(ID_TELEFONO) on delete no action on update no action
) ;


create table if not exists ODS_DM_CICLO_FACTURACION
(ID_CICLO_FACTURACION int unsigned auto_increment not null primary key,
DE_CICLO_FACTURACION varchar(512),
FC_INSERT date,
FC_MODIFICACION date);


create table if not exists ODS_DM_METODO_FACTURACION
(ID_METODO_FACTURACION int unsigned auto_increment not null primary key,
DE_METODO_FACTURACION varchar(512),
FC_INSERT date,
FC_MODIFICACION date);	


create table if not exists ODS_HC_FACTURACION 
(BILL_REF_NO int not null primary key auto_increment,
ID_CLIENTE int,
DIA_INICIO date,
DIA_FINALIZACION date,
DIA_DECLARACION date,
DIA_PAGO date,
CANTIDAD float,
ID_METODO_FACTURACION int unsigned,
ID_CICLO_FACTURACION int unsigned,
FC_INSERT date,
FC_MODIFICACION date,
foreign key(ID_METODO_FACTURACION) references ODS_DM_METODO_FACTURACION(ID_METODO_FACTURACION) on delete no action on update no action,
foreign key(ID_CICLO_FACTURACION) references ODS_DM_CICLO_FACTURACION(ID_CICLO_FACTURACION) on delete no action on update no action,
foreign key(ID_CLIENTE) references ODS_HC_CLIENTES(ID_CLIENTE) on delete no action on update no action
) ;

create table if not exists ODS_HC_ENCARGOS(
NEWID int unsigned auto_increment not null primary key,
ID_SERVICIO int unsigned,
ORDERID int unsigned,
ID_PHASE int unsigned,
AGENTE  varchar(512),
DIA_COMIENZO date,
DIA_FINALIZACION date,
FC_INSERT date,
FC_MODIFICACION date,
foreign key(ID_PHASE) references ODS_DM_FASES(ID_PHASE) on delete no action on update no action
);

/*
Almacena si un encargo ha sido finalizado o tiene alguna fase pendiente
*/

create table if not exists ODS_HC_ENCARGOS_FINALIZADOS(
ID int unsigned not null,
FINALIZADO bool,
FC_INSERT date,
FC_MODIFICACION date,
foreign key(ID) references ODS_HC_ENCARGOS(NEWID) on delete no action on update no action
);


create table if not exists ODS_HC_ENCARGOS_SERVICIOS(
ID int unsigned auto_increment not null primary key,
ID_ENCARGO int unsigned,
ID_SERVICIO  int,
foreign key(ID_ENCARGO) references ODS_HC_ENCARGOS(NEWID) on delete no action on update no action,
foreign key(ID_SERVICIO) references ODS_HC_SERVICIOS(ID_SERVICIO) on delete no action on update no action
);



