ad_page_contract {
    Add/Edit Leads

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-07-06
} {
    { action "add"}
    {return_url ""}
}

set package_id [ad_conn package_id]
set user_id [ad_conn user_id]

set admin_p [permission::permission_p -party_id $user_id -object_id $package_id -privilege "admin"]

set municipality_options ""
set state_options [db_list_of_lists select_states { SELECT abbrev, state_name FROM br_states }]

ad_form -name lead-ae -cancel_url $return_url -form {
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
    ad_form -extend -name lead-ae -form [list \
					     [list "cat_${category_id}:integer(select)" \
						  [list label "${category_name}"] \
						  [list options [lead_management::category_get_options -parent_id $category_id]] \
						  [list value   ""] \
						 ] \
					    ]
}

    
ad_form -extend -name lead-ae -form {
    {property_type:text(select)
	{label "[_ lead-management.Property_Type]"}
	{options {{rent 0} {own 1}}}
    }
    {property_municipality:text(select)
	{label "[_ lead-management.Property_Municipality]"}
	{options $municipality_options}
    }	
    {property_state:text(select)
	{label "[_ lead-management.Property_State]"}
	{options $state_options}
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
    {municipality:text(select)
	{label "[_ lead-management.Municipality]"}
	{options $municipality_options}
    }	
    {state:text(select)
	{label "[_ lead-management.State]"}
	{options $state_options}
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

