-- /packages/lead-management/sql/postgresql/upgrade/upgrade-0.1d-0.1d1.sql

SELECT acs_log__debug ('/packages/lead-management/sql/postgresql/upgrade/upgrade-0.1d-0.1d1.sql','');

ALTER TABLE lm_leads RENAME COLUMN montlhy_income to monthly_income;