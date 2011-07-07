-- packages/ref-br-states/sql/postgresql/ref-br-states-create.sql
--
-- @author iuri@iurix.com
-- @creation-date 2011-07-04

create table br_states (
    abbrev          char(2)
                    constraint br_states_abbrev_pk primary key,
    state_name      varchar(100)
	            constraint br_states_state_name_nn not null
                    constraint br_states_state_name_uq unique
);

comment on table br_states is '
This is the BR states table.
';

comment on column br_states.abbrev is '
This is the 2 letter abbreviation for states.
';

-- add this table into the reference repository
select acs_reference__new (
    'BR_STATES',
    null,
    'Internal',
    '',
    now()
);