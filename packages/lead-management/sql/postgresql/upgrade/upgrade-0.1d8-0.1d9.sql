-- /packages/lead-management/sql/postgresql/upgrade/upgrade-0.1d8-0.1d9.sql

SELECT acs_log__debug ('/packages/lead-management/sql/postgresql/upgrade/upgrade-0.1d8-0.1d9.sql', '');

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
