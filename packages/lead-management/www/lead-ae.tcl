ad_page_contract {
    Add/Edit Leads

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-07-06
} {
    { action "add"}
    {return_url ""}
    {property_state ""}
    {state ""}
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set admin_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege "admin"]

set where_clause1 ""
if {[exists_and_not_null property_state]} {
    set where_clause1 "WHERE state_code = :property_state"
}

set where_clause2 ""
if {[exists_and_not_null state]} {
    set where_clause2 "WHERE state_code = :state"
}


set property_municipality_options [db_list_of_lists select_municipality "
    SELECT name, ibge_code FROM br_ibge_municipality $where_clause1 ORDER BY name
"]

set property_state_options [db_list_of_lists select_states { SELECT state_name, abbrev FROM br_states }]


set municipality_options [db_list_of_lists select_municipality "
    SELECT name, ibge_code FROM br_ibge_municipality $where_clause2 ORDER BY name
"]

set state_options [db_list_of_lists select_states { SELECT state_name, abbrev FROM br_states }]


ns_log Notice "$state_options"

ad_form -name lead -cancel_url $return_url -form {
    {lead_id:key}
    {inform1:text(inform)
	{label "<h2>[_ lead-management.Lead_Profile]</h2>"}
    }
    {name:text(text)
	{label "[_ lead-management.Name]"}
    }
    {cpf:text(text)
	{label "[_ lead-management.CPF]"}
    }
    {gender:text(select)
	{label "[_ lead-management.Gender]"}
	{options {{Male m} {Female f}}}
    }
    {monthly_income:text(text)
	{label "[_ lead-management.Monthly_Income]"}
    }
    {birth_date:date(date)
	{label "[_ lead-management.Birth_Date]"}
	{format "YYYY MM DD"}
        {after_html {
	    <input type="button" style="height:23px; width:23px; background: url('/resources/acs-templating/calendar.gif');" onclick ="return showCalendarWithDateWidget('birth_date', 'y-m-d');" > \[<b>[_ calendar.y-m-d]</b>\]
	}}
    } 
    {marital_status:text(select)
	{label "[_ lead-management.Marital_Status]"}
	{options {{Single s} {Married m}}}
    }
    {inform2:text(inform)
	{label "<h2>[_ lead-management.Loan_Profile]</h2>"}
    }
    {financed_amount:text(inform)
	{label "[_ lead-management.Financed_Amount]"}
    }
}


set category_ids [list]
foreach {category_id category_name} [lead_management::get_categories -package_id $package_id] {
    ad_form -extend -name lead -form [list \
					     [list "cat_${category_id}:integer(select)" \
						  [list label "${category_name}"] \
						  [list options [lead_management::category_get_options -parent_id $category_id]] \
						  [list value   ""] \
						 ] \
					    ]
}

    
ad_form -extend -name lead -form {
    {property_type:text(select)
	{label "[_ lead-management.Property_Type]"}
	{options {{rent 0} {own 1}}}
    }
    {property_state:text(select)
	{label "[_ lead-management.Property_State]"}
	{options {$property_state_options}}
	{html {onChange "document.lead.__refreshing_p.value='1';document.lead.submit()"}}
    }	
    {property_municipality:text(select)
	{label "[_ lead-management.Property_Municipality]"}
	{options {$property_municipality_options}}
    }	
    {owner_p:text(select)
	{label "[_ lead-management.Owner]"}
	{options {{Yes 1} {No 0}}}
    }
    {inform3:text(inform)
	{label "<h2>[_ lead-management.Contact_Info]</h2>"}
    }
    {contact_time:text(text)
	{label "[_ lead-management.Contact_Time]"}
    }
    {email:email
	{label "[_ lead-management.Email]"}
    }
    {email2:email
	{label "[_ lead-management.Alternative_Email]"}
    }
    {phone1:text(text)
	{label "[_ lead-management.Phone]"}
    }
    {phone_type1:text(text)
	{label "[_ lead-management.Phone]"}
    }
    {phone2:text(text)
	{label "[_ lead-management.Phone]"}
    }
    {phone_type2:text(text)
	{label "[_ lead-management.Phone]"}
    }
    {postal_code:text(text)
	{label "[_ lead-management.Postal_Code]"}
    }
    {address:text(text)
	{label "[_ lead-management.Address]"}
    }
    {address2:text(text)
	{label "[_ lead-management.Address]"}
    }
    {state:text(select)
	{label "[_ lead-management.State]"}
	{options {$state_options}}
	{html {onChange "document.lead.__refreshing_p.value='1';document.lead.submit()"}}
    }	 
    {municipality:text(select)
	{label "[_ lead-management.Municipality]"}
	{options {$municipality_options}}
    }	
    {note:text(textarea)
	{label "[_ lead-management.Note]"}
    }
} -on_submit {

} -new_data {





    foreach {category_id category_name} [lead_management::get_categories -package_id $package_id] {
	category::map_object -remove_old -object_id $lead_id ""
    }
    foreach {category_id category_name} [lead_management::get_categories -package_id $package_id] {
        ns_log Notice " TTT [set cat_${category_id}]"
	set child_id  [set cat_${category_id}]
	category::map_object -object_id $lead_id $child_id
	
    }
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}

