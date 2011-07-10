-- /packages/lead-management/sql/postgresql/upgrade/upgrade-0.1d3-0.1d4.sql

SELECT acs_log__debug ('/packages/lead-management/sql/postgresql/upgrade/upgrade-0.1d3-0.1d4.sql', '');

CREATE OR REPLACE FUNCTION lm_lead_contact__new (integer, varchar, varchar, varchar, varchar, char, varchar, char, varchar, varchar, varchar, varchar, varchar, varchar)
RETURNS integer AS '
DECLARE
	new__lead_id		ALIAS FOR $1;
	new__contact_time	ALIAS FOR $2;
	new__postal_address	ALIAS FOR $3;
	new__postal_address2	ALIAS FOR $4;
	new__postal_code	ALIAS FOR $5;
	new__state_abbrev	ALIAS FOR $6;
	new__municipality	ALIAS FOR $7;
	new__country_code	ALIAS FOR $8;
	new__email2		ALIAS FOR $9;
	new__phone1		ALIAS FOR $10;
	new__phone_type1	ALIAS FOR $11;
	new__phone2		ALIAS FOR $12;
	new__phone_type2	ALIAS FOR $13;
	new__additional_text	ALIAS FOR $14;

BEGIN

	INSERT INTO lm_lead_contacts (lead_id, contact_time, postal_address, postal_address2, postal_code, state_abbrev, municipality, country_code, email2, phone1, phone_type1, phone2, phone_type2, additional_text) VALUES (new__lead_id, new__contact_time, new__postal_address, new__postal_address2, new__postal_code, new__state_abbrev, new__municipality, new__country_code, new__email2, new__phone1, new__phone_type1, new__phone2, new__phone_type2, new__additional_text);

	RETURN 0;
	
END;' language 'plpgsql';
