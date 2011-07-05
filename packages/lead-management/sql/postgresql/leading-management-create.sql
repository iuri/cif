-- /packages/lead-management/sql/postgresql/lead-management-create.sql
-- Create the necessary datamodel and ACS relations for lead-management package
-- @author  Iuri Sampaio (iuri.sampaio@iurix.com)
-- @creation-date 2011-07-03

-- References: 
-- packages/acs-kernel/sql/postgresql/community-core-create.sql
-- packages/acs-kernel/sql/postgresql/acs-objects-create.sql		

-- Datamodel for Property Types
CREATE TABLE cif_property_types (
	type_id		integer not null
			constraint property_types_type_id_pk primary key,
	type		varchar(100)
);


SELECT define_function_args ('cif_property_type__new', 'type');

CREATE OR REPLACE FUNCTION cif_property_type__new (varchar)
RETURNS integer AS '
DECLARE 
	p_type	ALIAS FOR $1;

BEGIN 
	INSERT INTO cif_property_types (type) VALUES (p_type);

	RETURN 0;
END;' language 'plpgsql';


SELECT define_function_args ('cif_property_type__delete', 'type');

CREATE OR REPLACE FUNCTION cif_property_type__delete (varchar)
RETURNS integer AS '
DECLARE 
	p_type	ALIAS FOR $1;
BEGIN
	DELETE FROM cif_property_types WHERE type = p_type;	
	
	RETURN 0;	
END;' language 'plpgsql';


-- Datamodel for Loans
CREATE TABLE cif_loans (
	loan_id			integer not null
				CONSTRAINT cif_loans_loan_id_fk foreign key (loan_id)
				REFERENCES acs_objects (object_id) 
				constraint cif_loans_loan_id_pk primary key,
	lead_id			integer not null
				CONSTRAINT cif_loans_lead_id_fk foreign key (lead_id)
				REFERENCES cif_leads (lead_id),
	property_type_id	integer
				CONSTRAINT cif_loans_property_type_id_fk foreign key (property_type_id)
				REFERENCES cif_property_types (type_id),
	property_state		varchar(2)
				CONSTRAINT cif_loans_property_state_fk foreign key (property_state)
				REFERENCES br_states (abbrev),
	property_municipality	int4 
				CONSTRAINT cif_loans_property_municipality_fk
				REFERENCES br_ibge_municipality (ibge_code),
	owner_p			boolean default 'f'
);

-- Create object_type for loan
CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE 
BEGIN
	PERFORM acs_object_type__create_type (
		''cif_loan'',		-- object_type
		''Loan'',		-- pretty_name
		''Loans'',		-- pretty_plural
		''acs_object'', 	-- supertype
		''cif_loans'',		-- table_name
		''loan_id'',		-- id_column
		''leading-management,	-- package_name
		''f'',			-- abstract_p
		null,			-- type_extension_table
		null			-- name_method
	);

	RETURN 0;

END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();


-- Create plsql functions for loans
SELECT define_function_args ('cif_loan__new', 'loan_id, lead_id, property_type_id, property_state, poroperty_municipality, owner_p;f');
				
CREATE OR REPLACE FUNCTION cif_loan__new (integer, integer, integer, varchar, int4, boolean)
RETURNS integer AS '
DECLARE
	new__loan_id			ALIAS FOR $1;	-- default null
	new__lead_id			ALIAS FOR $2;
	new__property_type_id		ALIAS FOR $3;
	new__property_state		ALIAS FOR $4;
	new__property_municipality	ALIAS FOR $5;
	new__owner_p			ALIAS FOR $6;

	v_loan_id			cif_loans.loan_id%TYPE;
BEGIN
	
	v_loan_id := acs_object__new (
		new__loan_id,		-- object_id
		''cif_loan'', 		-- object_type
		now(),			-- creation_date
		0,			-- creation_user
		null,			-- creation_ip
		new__lead_id,		-- context_id
		''t'',			-- security_inherit_p
		null,			-- title
		null			-- package_id 
	);		

	INSERT INTO cif_loans (loan_id, lead_id, property_type_id, property_state, property_municipality, owner_p) 
	VALUES (v_loan_id, new__lead_id, new__property_type_id, new__property_state, new__property_municipality, new__owner_p);

	RETURN 0;

END;' language 'plpgsql';

SELECT define_function_args ('cif_loan__delete', 'loan_id, lead_id');

CREATE OR REPLACE FUNCTION cif_loan__delete (integer, integer)
RETURNS integer AS '
DECLARE
	p_loan_id	ALIAS FOR $1;
	p_lead_id	ALIAS FOR $2;

	row		record;

BEGIN

	IF p_loan_id IS NOT NULL THEN
	   PERFORM acs_object__delete (p_loan_id);

	   DELETE FROM cif_loans WHERE loan_id = p_loan_id;

	   RETURN 0;
	END IF;
	
	FOR row IN 
	    SELECT object_id FROM acs_objects WHERE context_id = p_lead_id
	LOOP
	   PERFORM acs_object__delete (row.object_id);
	   
	   DELETE FROM cif_loans WHERE loan_id = row.object_id;
		
	END LOOP;
	
	RETURN 0;
END;' language 'plpgsql';




-- Datamodel for Lead's contact info
CREATE TABLE cif_lead_contacts (
	contact_id	 	integer not null
				CONSTRAINT cif_lead_contacts_contact_id_pk primary key,
	lead_id			integer not null
				CONSTRAINT cif_lead_contacts_lead_id_fk foreing key (lead_id)
				REFERENCES cif_leads (lead_id),
	contact_time		varchar(200),
	postal_address		varchar(1000),
	number			varchar(10),
	postal_code		varchar(50),
	state_abbrev		char(2)
				CONSTRAINT cif_lead_contacts_state_abbrev_fk foreing key (state_abbrev)
				REFERENCES br_states (abbrev),
	municipality		varchar(100) 
				CONSTRAINT cif_lead_contacts_municipality_fk foreing key (municipality)
				REFERENCES br_ibge_municipality (name),
	country_code    	char(2)
                        	CONSTRAINT cif_lead_contacts_country_code_fk
                        	REFERENCES countries (iso)
                        	not null,
	phone1			varchar(20),
	phone_type1		varchar(20),
	phone2			varchar(20),
	phone_type2		varchar(20),
	additional_text 	varchar(200)
);	

CREATE INDEX cif_lead_contacts_country_code_ix ON cif_lead_contacts_country(country_code);
CREATE INDEX cif_lead_contacts_state_abbrev_ix ON cif_lead_contacts_state(state_abbrev);
CREATE INDEX cif_lead_contacts_municipality_ix ON cif_lead_contacts_municipality(municipality);
CREATE INDEX cif_lead_contacts_lead_id_ix ON cif_lead_contacts(lead_id);

SELECT define_function_args ('cif_lead_contact__new', 'contact_id, lead_id, contact_time, postal_address, number, postal_code, state_abbrev, municipality, country_code, phone1, phone_type1, phone2, phone_type2, additional_text');

CREATE OR REPLACE FUNCTION cif_lead_contact__new (integer, integer, varchar, varchar, varchar, varchar, char, varchar, char, varchar, varchar, varchar, varchar, varchar)
RETURNS integer AS '
DECLARE
	new__contact_id		ALIAS FOR $1;
	new__lead_id		ALIAS FOR $2;
	new__contact_time	ALIAS FOR $3;
	new__postal_address	ALIAS FOR $4;
	new__number		ALIAS FOR $5;
	new__postal_code	ALIAS FOR $6;
	new__state_abbrev	ALIAS FOR $7;
	new__municipality	ALIAS FOR $8;
	new__country_code	ALIAS FOR $9;
	new__phone1		ALIAS FOR $10;
	new__phone_type1	ALIAS FOR $11;
	new__phone2		ALIAS FOR $12;
	new__phone_type2	ALIAS FOR $13;
	new__additional_text	ALIAS FOR $14;

BEGIN

	INSERTO INTO cif_lead_contacts (contact_id, lead_id, contact_time, postal_address, number, postal_code, state_abbrev, municipality, country_code, phone1, phone_type1, phone2, phone_type2, additional_text) VALUES (new__contact_id, new__lead_id, new__contact_time, new__postal_address, new__number, new__postal_code, new__state_abbrev, new__municipality, new__country_code, new__phone1, new__phone_type1, new__phone2, new__phone_type2, new__additional_text);

	RETURN 0;
	
END;' language 'plpgsql';

SELECT define_function_args ('cif_lead_contact__delete', 'contact_id, lead_id');

CREATE OR REPLACE FUNCTION cif_lead_contact__delete (integer, integer)
RETURNS integer AS '
DECLARE
	p_contact_id	integer;	-- default null
	p_lead_id	integer;	-- default null
BEGIN
	IF p_contact_id IS NULL THEN
		DELETE FROM cif_lead_contacts WHERE contact_id = p_lead_id;
]
		RETURN 0;
	END IF;

	DELETE FROM cif_lead_contacts WHERE contact_id = p_contact_id;

	RETURN 0;

END;' language 'plpgsql';
	
 
-- Datamodel for Leads 
CREATE TABLE cif_leads (
	lead_id		integer not null
			CONSTRAINT cif_leads_lead_id_fk foreign key (lead_id)
			REFERENCES acs_objects (object_id)
			CONSTRAINT cif_leads_lead_id_pk primary key,
	user_id		integer not null
			CONSTRAINT cif_leads_user_id_fk foreing key (user_id)
			REFERENCES users (user_id),
	cpf		varchar(20)
			CONSTRAINT cif_leads_cpf_nn
			not null
			CONSTRAINT cif_leads_cpf_un
			unique,
	gender		char,
	montlhy_income	varchar(50),
	birth_date	timestamp,
	marital_status	varchar(20)	
);

CREATE INDEX cif_leads_cpf_ix ON cif_leads(cpf);

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
DECLARE 
BEGIN
	PERFORM acs_object_type__create_type (
		''lead'',		-- object_type
		''Lead'',		-- pretty_name
		''Leads'',		-- pretty_plural
		''acs_object'', 	-- supertype
		''cif_leads'',		-- table_name
		''lead_id'',		-- id_column
		''leading-management,	-- package_name
		''f'',			-- abstract_p
		null,			-- type_extension_table
		null			-- name_method
	);

	RETURN 0;

END;' language 'plpgsql';

SELECT inline_0 ();
DROP FUNCTION inline_0 ();



SELECT define_function_args ('cif_lead__new', 'lead_id, user_id, gender, cpf, montlhy_income, birth_date, marital_status');

CREATE OR REPLACE FUNCTION cif_lead__new (integer, integer, varchar, char, varchar, timestamp, varchar)
RETURNS integer AS '
DECLARE
	new__lead_id		ALIAS FOR $1;
	new__user_id		ALIAS FOR $2;
	new__cpf		ALIAS FOR $3;
	new__gender		ALIAS FOR $4;
	new__monthly_income	ALIAS FOR $5;
	new__birth_date		ALIAS FOR $6;
	new__marital_status	ALIAS FOR $7;

	v_lead_id		cif_leads.lead_id%TYPE;

BEGIN

	v_lead_id := acs_object__new (
		new__lead_id,		-- object_id
		''cif_lead'', 		-- object_type
		now(),			-- creation_date
		0,			-- creation_user
		null,			-- creation_ip
		null,			-- context_id
		''t'',			-- security_inherit_p
		null,			-- title
		null			-- package_id 
	);

	INSERT INTO cif_leads (lead_id, user_id, cpf, gender, monthly_income, birth_date, marital_status)
	VALUES	(v_lead_id, new__user_id, new__cpf, new__gender, new__monthly_income, new__birth_date, new__marital_status);

	RETURN 0;
	
END;' language 'plpgsql';


SELECT define_function_args ('cif_lead__delete', 'lead_id');

CREATE OR REPLACE FUNCTION cif_lead__delete (integer)
RETURNS integer AS '
DECLARE
	p_lead_id	ALIAS FOR $1;
		
BEGIN
	
	PERFORM cif_loan__delete (null, p_lead_id);

	PERFORM cif_lead_contact__delete (null, p_lead_id);
	
	PERFORM acs_object__delete (p_lead_id);

	DELETE FROM cif_leads WHERE lead_id = p_lead_id;

	RETURN 0;

END;' language 'plpgsql';

