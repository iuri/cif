-- /packages/lead-management/sql/postgresql/lead-management-drop.sql
-- Remove lead-management datamodel and ACS relations for lead-management package
-- @author  Iuri Sampaio (iuri.sampaio@iurix.com)
-- @creation-date 2011-07-03

------------------------
-- Remove Loans
------------------------

-- SELECT get_func_drop_command ('lm_loan__delete');
DROP FUNCTION lm_loan__delete (integer, integer);


-- SELECT get_func_drop_command ('lm_loan__new');
DROP FUNCTION lm_loan__new (integer, integer, varchar, int4, boolean);

SELECT acs_object_type__drop_type ('lm_loan','t');

DROP TABLE lm_loans;

------------------------
-- Remove Lead Contact Info
------------------------
-- SELECT get_func_drop_command ('lm_lead_contact__delete');
DROP FUNCTION lm_lead_contact__delete (integer, integer);


-- SELECT get_func_drop_command ('lm_lead_contact__new');
DROP FUNCTION lm_lead_contact__new (integer, integer, varchar, varchar, varchar, varchar, char, varchar, char, varchar, varchar, varchar, varchar, varchar);


DROP INDEX lm_lead_contacts_country_code_ix;
DROP INDEX lm_lead_contacts_state_abbrev_ix;
DROP INDEX lm_lead_contacts_municipality_ix;
DROP INDEX lm_lead_contacts_lead_id_ix;

DROP TABLE lm_lead_contacts


------------------------
-- Remove Leads 
------------------------
-- SELECT get_func_drop_command('lm_lead__delete');
DROP FUNCTION lm_lead__delete (integer);

-- SELECT get_func_drop_command('lm_lead__new');
DROP FUNCTION lm_lead__new (integer, integer, varchar, char, varchar, timestamp, varchar);


SELECT acs_object_type__drop_type ('lm_lead','t');

DROP INDEX lm_leads_cpf_ix;

DROP TABLE lm_leads;
