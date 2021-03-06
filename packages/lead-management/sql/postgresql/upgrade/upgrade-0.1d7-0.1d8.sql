-- /packages/lead-management/sql/postgresql/upgrade/upgrade-0.1d7-0.1d8.sql

SELECT acs_log__debug ('/packages/lead-management/sql/postgresql/upgrade/upgrade-0.1d7-0.1d8.sql', '');

DROP FUNCTION lm_loan__new (integer, integer, varchar, int4, boolean);

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

