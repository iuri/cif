ad_page_contract {
    Main page of lead-management system
    List of Leads

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-07-06
} {
    {orderby "name,asc"}
    page:optional
}


set return_url [ad_conn url]

set lead_state_options ""

set actions {"#lead-management.Add_Lead#" "lead-ae?return_url=/lead-management" "#lead-management.Add_a_new_lead#"}

set bulk_actions [list]

template::list::create \
    -name leads \
    -multirow leads \
    -key lead_id \
    -actions $actions \
    -row_pretty_plural "leads" \
    -page_size 10 \
    -page_flush_p t \
    -page_query_name leads_pagination \
    -bulk_actions $bulk_actions \
    -elements {
	name {
	    label "[_ lead-management.Name]"
	    display_template {
		<a href="@leads.lead_ae_url@">@leads.name;noquote@</a>
	    }
	}
	email {
	    label "[_ lead-management.Email]"
	}
    } -orderby {
	name {
	    label "[_ lead-management.Name]"
	    orderby "lower(u.first_names || ' ' || u.last_name)"
	}
	email {
	    label "[_ lead-management.Email]"
	    orderby "u.email"
	}
    } -orderby_name orderby

	


db_multirow -extend {lead_ae_url} leads select_leads {} {
    
    set lead_ae_url [export_vars -base lead-ae {lead_id return_url}]
}

