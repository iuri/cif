-- packages/ref-br-territories/sql/postgresql/ref-br-territories-create.sql
--
-- @author alessandro.landim@gmail.com
-- @creation-date 2001-08-27
-- @cvs-id $Id: ref-br-territories-create.sql,v 1.3 2003/07/18 00:25:33 donb Exp $

create table br_ibge_municipality (
    ibge_code        int4
                    constraint br_ibge_municipality_ibge_code_pk primary key,
    name  	    varchar,
    state_code      char(2),
    lat		    varchar,
    lng		    varchar,
    territory_sdt_code	integer
);


-- add this table into the reference repository
select acs_reference__new (
    'BR_IBGE',
    null,
    'Internal',
    '',
    now()
);
