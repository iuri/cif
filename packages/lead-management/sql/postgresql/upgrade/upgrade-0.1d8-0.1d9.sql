-- /packages/lead-management/sql/postgresql/upgrade/upgrade-0.1d9-0.1d10.sql

SELECT acs_log__debug ('/packages/lead-management/sql/postgresql/upgrade/upgrade-0.1d9-0.1d10.sql', '');



DROP FUNCTION lm_lead_contact__new (integer, integer, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar);


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
	new__email		ALIAS FOR $10;
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

	INSERT INTO lm_lead_contacts (contact_id, lead_id, contact_time, postal_address, postal_address2, postal_code, state_abbrev, municipality, country_code, email, phone1, phone_type1, phone2, phone_type2, additional_text) VALUES (v_contact_id, new__lead_id, new__contact_time, new__postal_address, new__postal_address2, new__postal_code, new__state_abbrev, new__municipality, new__country_code, new__email, new__phone1, new__phone_type1, new__phone2, new__phone_type2, new__additional_text);

	RETURN 0;
	
END;' language 'plpgsql';
