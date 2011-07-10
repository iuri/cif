ad_page_contract {
    Main page of lead-management system
    List of Leads

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-07-06
}


set return_url [ad_conn url]


set actions {"#lead-management.Add_Lead#" "lead-ae?return_url=/lead-management" "#lead-management.Add_a_new_lead#"}
template::list::create \
    -name leads \
    -multirow leads \
    -key lead_id \
    -actions $actions \
    -elements {
	name {
	    label "#lead-management.Name#"
	}
	email {
	    label "#lead-management.Email"
	}
    }


db_multirow -extend {} leads select_leads {
    SELECT u.first_names || ' ' || u.last_name as name, email FROM cc_users u, lm_leads lm WHERE lm.user_id = u.user_id
}

