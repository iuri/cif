-- packages/ref-br-territories/sql/postgresql/ref-br-territories-create.sql
--
-- @author alessandro.landim@gmail.com
-- @creation-date 2001-08-27
-- @cvs-id $Id: ref-br-territories-create.sql,v 1.3 2003/07/18 00:25:33 donb Exp $

delete from  br_ibge_municipality;
\copy br_ibge_municipality from '[acs_root_dir]/packages/ref-br-ibge/sql/common/br-municipality.dat' using delimiters ',' with null as '';
