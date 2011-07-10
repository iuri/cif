-- /packages/lead-management/sql/postgresql/lead-management-create.sql
-- Create the necessary datamodel and ACS relations for lead-management package
-- @author  Iuri Sampaio (iuri.sampaio@iurix.com)
-- @creation-date 2011-07-03

-- References: 
-- packages/acs-kernel/sql/postgresql/community-core-create.sql
-- packages/acs-kernel/sql/postgresql/acs-objects-create.sql		

------------------------------- 
-- Create datamodel for Leads 
------------------------------- 
CREATE TABLE lm_leads (
	lead_id		integer not null
			CONSTRAINT lm_leads_lead_id_fk
			REFERENCES acs_objects (object_id)
			CONSTRAINT lm_leads_lead_id_pk primary key,
	user_id		integer not null
			CONSTRAINT lm_leads_user_id_fk
			REFERENCES users (user_id),
	cpf		varchar(20)
			CONSTRAINT lm_leads_cpf_nn
			not null
			CONSTRAINT lm_leads_cpf_un
			unique,
	gender		char,
	monthly_income	varchar(50),
	birth_date	timestamp,
	marital_status	varchar(20)	
);

CREATE INDEX lm_leads_cpf_ix ON lm_leads(cpf);

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE 
BEGIN
	PERFORM acs_object_type__create_type (
		''lm_lead'',		-- object_type
		''Lead'',		-- pretty_name
		''Leads'',		-- pretty_plural
		''acs_object'', 	-- supertype
		''lm_leads'',		-- table_name
		''lead_id'',		-- id_column
		''lead-management'',	-- package_name
		''f'',			-- abstract_p
		null,			-- type_extension_table
		null			-- name_method
	);

	RETURN 0;

END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();



SELECT define_function_args ('lm_lead__new', 'lead_id, user_id, gender, cpf, montlhy_income, birth_date, marital_status');

CREATE OR REPLACE FUNCTION lm_lead__new (integer, integer, varchar, char, varchar, timestamp, varchar)
RETURNS integer AS '
DECLARE
	new__lead_id		ALIAS FOR $1;
	new__user_id		ALIAS FOR $2;
	new__cpf		ALIAS FOR $3;
	new__gender		ALIAS FOR $4;
	new__monthly_income	ALIAS FOR $5;
	new__birth_date		ALIAS FOR $6;
	new__marital_status	ALIAS FOR $7;

	v_lead_id		lm_leads.lead_id%TYPE;

BEGIN
	v_lead_id := acs_object__new (
		  new__lead_id,		-- object_id
		  ''lm_lead'', 		-- object_type
		  now(),		-- creation_date
		  0,			-- creation_user
		  null,			-- creation_ip
		  null,			-- context_id
		  ''t'',		-- security_inherit_p
		  null,			-- title
		  null			-- package_id 
	);

	INSERT INTO lm_leads (lead_id, user_id, cpf, gender, monthly_income, birth_date, marital_status)
	VALUES	(v_lead_id, new__user_id, new__cpf, new__gender, new__monthly_income, new__birth_date, new__marital_status);

	RETURN v_lead_id;
	
END;' language 'plpgsql';


SELECT define_function_args ('lm_lead__delete', 'lead_id');

CREATE OR REPLACE FUNCTION lm_lead__delete (integer)
RETURNS integer AS '
DECLARE
	p_lead_id	ALIAS FOR $1;
		
BEGIN
	
	PERFORM lm_loan__delete (null, p_lead_id);

	PERFORM lm_lead_contact__delete (null, p_lead_id);
	
	PERFORM acs_object__delete (p_lead_id);
	
	DELETE FROM lm_leads WHERE lead_id = p_lead_id;

	RETURN 0;

END;' language 'plpgsql';



------------------------------- 
-- Datamodel for Loans
------------------------------- 
CREATE TABLE lm_loans (
	loan_id			integer not null
				CONSTRAINT lm_loans_loan_id_fk
				REFERENCES acs_objects (object_id) 
				constraint lm_loans_loan_id_pk primary key,
	lead_id			integer not null
				CONSTRAINT lm_loans_lead_id_fk
				REFERENCES lm_leads (lead_id),
	financed_amount		varchar(100),			
	property_state		varchar(2)
				CONSTRAINT lm_loans_property_state_fk
				REFERENCES br_states (abbrev),
	property_municipality	int4 
				CONSTRAINT lm_loans_property_municipality_fk
				REFERENCES br_ibge_municipality (ibge_code),
	owner_p			boolean default 'f'
);

-- Create object_type for loan
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE 
BEGIN
	PERFORM acs_object_type__create_type (
		''lm_loan'',		-- object_type
		''Loan'',		-- pretty_name
		''Loans'',		-- pretty_plural
		''acs_object'', 	-- supertype
		''lm_loans'',		-- table_name
		''loan_id'',		-- id_column
		null,			-- package_name
		''f'',			-- abstract_p
		null,			-- type_extension_table
		null			-- name_method
	);

	RETURN 0;

END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();


-- Create plsql functions for loans
SELECT define_function_args ('lm_loan__new', 'loan_id, lead_id, financed_amount, property_state, poroperty_municipality, owner_p;f');
				
CREATE OR REPLACE FUNCTION lm_loan__new (integer, integer, varchar, varchar, int4, boolean)
RETURNS integer AS '
DECLARE
	new__loan_id			ALIAS FOR $1;	-- default null
	new__lead_id			ALIAS FOR $2;
	new__financed_amount		ALIAS FOR $3;
	new__property_state		ALIAS FOR $4;
	new__property_municipality	ALIAS FOR $5;
	new__owner_p			ALIAS FOR $6;

	v_loan_id			lm_loans.loan_id%TYPE;
BEGIN
	
	v_loan_id := acs_object__new (
		new__loan_id,		-- object_id
		''lm_loan'', 		-- object_type
		now(),			-- creation_date
		0,			-- creation_user
		null,			-- creation_ip
		new__lead_id,		-- context_id
		''t'',			-- security_inherit_p
		null,			-- title
		null			-- package_id 
	);		

	INSERT INTO lm_loans (loan_id, lead_id, financed_amount, property_state, property_municipality, owner_p) 
	VALUES (v_loan_id, new__lead_id, new__financed_amount, new__property_state, new__property_municipality, new__owner_p);

	RETURN v_loan_id;

END;' language 'plpgsql';


SELECT define_function_args ('lm_loan__delete', 'loan_id, lead_id');

CREATE OR REPLACE FUNCTION lm_loan__delete (integer, integer)
RETURNS integer AS '
DECLARE
	p_loan_id	ALIAS FOR $1;
	p_lead_id	ALIAS FOR $2;

	row		record;

BEGIN

	IF p_loan_id IS NOT NULL THEN
	   PERFORM acs_object__delete (p_loan_id);

	   DELETE FROM lm_loans WHERE loan_id = p_loan_id;

	   RETURN 0;
	END IF;
	
	FOR row IN 
	    SELECT object_id FROM acs_objects WHERE context_id = p_lead_id
	LOOP
	   PERFORM acs_object__delete (row.object_id);
	   
	   DELETE FROM lm_loans WHERE loan_id = row.object_id;
		
	END LOOP;
	
	RETURN 0;
END;' language 'plpgsql';




------------------------------- 
-- Datamodel for Lead's contact info
------------------------------- 
CREATE TABLE lm_lead_contacts (
	contact_id	 	integer not null
				CONSTRAINT lm_lead_contacts_contact_id_pk primary key,
	lead_id			integer not null
				CONSTRAINT lm_lead_contacts_lead_id_fk
				REFERENCES lm_leads (lead_id),
	contact_time		varchar(200),
	postal_address		varchar(1000),
	postal_address2		varchar(1000),
	postal_code		varchar(50),
	state_abbrev		varchar(2)
				CONSTRAINT lm_lead_contacts_state_abbrev_fk
				REFERENCES br_states (abbrev),
	municipality		varchar(100),
	country_code    	varchar(2)
                        	CONSTRAINT lm_lead_contacts_country_code_fk
                        	REFERENCES countries (iso)
                        	not null,
	email			varchar(50),
	phone1			varchar(20),
	phone_type1		varchar(20),
	phone2			varchar(20),
	phone_type2		varchar(20),
	additional_text 	varchar(200)
);	

CREATE INDEX lm_lead_contacts_country_code_ix ON lm_lead_contacts(country_code);
CREATE INDEX lm_lead_contacts_state_abbrev_ix ON lm_lead_contacts(state_abbrev);
CREATE INDEX lm_lead_contacts_municipality_ix ON lm_lead_contacts(municipality);
CREATE INDEX lm_lead_contacts_lead_id_ix ON lm_lead_contacts(lead_id);

SELECT define_function_args ('lm_lead_contact__new', 'contact_id, lead_id, contact_time, postal_address, postal_address2, postal_code, state_abbrev, municipality, country_code, email, phone1, phone_type1, phone2, phone_type2, additional_text');

CREATE OR REPLACE FUNCTION lm_lead_contact__new (integer, integer, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar)
RETURNS integer AS '
DECLARE
	new__contact_id		ALIAS FOR $1;
	new__lead_id		ALIAS FOR $2;
	new__contact_time	ALIAS FOR $3;
	new__postal_address	ALIAS FOR $4;
	new__postal_address2	ALIAS FOR $5;
	new__postal_code	ALIAS FOR $6;
	new__state_abbrev	ALIAS FOR $7;
	new__municipality	ALIAS FOR $8;
	new__country_code	ALIAS FOR $9;
	new__email2		ALIAS FOR $10;
	new__phone1		ALIAS FOR $11;
	new__phone_type1	ALIAS FOR $12;
	new__phone2		ALIAS FOR $13;
	new__phone_type2	ALIAS FOR $14;
	new__additional_text	ALIAS FOR $15;

	v_contact_id		lm_lead_contacts.contact_id%TYPE;
BEGIN

	IF new__contact_id IS NULL THEN
	   SELECT nextval(''t_acs_object_id_seq'') INTO v_contact_id;
	ELSE 
	   v_contact_id := new__contact_id;
	END IF;

	INSERT INTO lm_lead_contacts (contact_id, lead_id, contact_time, postal_address, postal_address2, postal_code, state_abbrev, municipality, country_code, email2, phone1, phone_type1, phone2, phone_type2, additional_text) VALUES (v_contact_id, new__lead_id, new__contact_time, new__postal_address, new__postal_address2, new__postal_code, new__state_abbrev, new__municipality, new__country_code, new__email2, new__phone1, new__phone_type1, new__phone2, new__phone_type2, new__additional_text);

	RETURN 0;
	
END;' language 'plpgsql';


SELECT define_function_args ('lm_lead_contact__delete', 'contact_id, lead_id');

CREATE OR REPLACE FUNCTION lm_lead_contact__delete (integer, integer)
RETURNS integer AS '
DECLARE
	p_contact_id	integer;	-- default null
	p_lead_id	integer;	-- default null
BEGIN
	IF p_contact_id IS NULL THEN
	   DELETE FROM lm_lead_contacts WHERE contact_id = p_lead_id;

	   RETURN 0;
	END IF;

	DELETE FROM lm_lead_contacts WHERE contact_id = p_contact_id;

	RETURN 0;

END;' language 'plpgsql';
	
