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
	{label ""}
	{value "<h2>[_ lead-management.Lead_Profile]</h2>"}
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
	{label ""}
	{value "<h2>[_ lead-management.Loan_Profile]</h2>"}
    }
    {financed_amount:text(inform)
	{label "[_ lead-management.Financed_Amount]"}
    }
}


set category_ids [list]
foreach {category_id category_name} [lead_management::get_categories -package_id $package_id] {
    ad_form -extend -name lead -form [list \
					     [list "cat_${category_id}:text(select)" \
						  [list label "${category_name}"] \
						  [list options [lead_management::category_get_options -parent_id $category_id]] \
						  [list value   ""] \
						 ] \
					    ]
}

    
ad_form -extend -name lead -form {
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
	{label ""}
	{value "<h2>[_ lead-management.Contact_Info]</h2>"}
    }

    {inform4:text(inform)
	{label "<h4>[_ lead-management.Contact_Time]</h4>"}
    }
    {start_time:date,optional
        {label "[_ lead-management.Start_Time]"}
        {format {[lc_get formbuilder_time_format]}}
    }
    {end_time:date,optional
        {label "[_ lead-management.End_Time]"}
        {format {[lc_get formbuilder_time_format]}}
    }
    {email:email
	{label "[_ lead-management.Email]"}
    }
    {email2:email
	{label "[_ lead-management.Alternative_Email]"}
    }
    {phone1:text(text)
	{label "[_ lead-management.Phone1]"}
    }
    {phone_type1:text(select)
	{label "[_ lead-management.Phone_Type1]"}
	{options {{Home home} {Mobile mobile} {Work work}}}
    }
    {phone2:text(text)
	{label "[_ lead-management.Phone2]"}
    }
    {phone_type2:text(select)
	{label "[_ lead-management.Phone_Type2]"}
	{options {{Home home} {Mobile mobile} {Work work}}}
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
	{html {cols 50 rows 15}}
    }
} -validate {
    {email
        {[string equal "" [party::get_by_email -email $email]]}
        "[_ acs-subsite.Email_already_exists]"
    }
    
} -on_submit {

} -new_data {
    
    
    #add user
    db_transaction {
	# Pre-generate user_id for double-click protection
	set user_id [db_nextval acs_object_id_seq]
	
	for {set i 0} {$i < [expr [llength $name] -1]} {incr i} {
	    lappend first_names [lindex $name $i]
	}

	set last_name [lindex $name [expr [llength $name] - 1]]
	
	array set creation_info [auth::create_user \
                                     -user_id $user_id \
                                     -email $email \
                                     -first_names $first_names \
                                     -last_name $last_name \
                                    ]
	
        lead_management::lead::new \
	    -user_id $user_id \
	    -cpf $cpf \
	    -gender $gender \
	    -monthly_income $monthly_income \
	    -birth_date $birth_date \
	    -marital_status $marital_status \
	    -contact_time "$start_time - $end_time" \
	    -email $email2 \
	    -phone1 $phone1 \
	    -phone_type1 $phone_type1 \
	    -phone2 $phone2 \
	    -phone_type2 $phone_type2 \
	    -postal_code $postal_code \
	    -address $address \
	    -address2 $address2 \
	    -state $state \
	    -municipality $municipality \
	    -note $note

	lead_management::loan::new \
	    -lead_id $user_id \
	    -financed_amount $financed_amount \
	    -property_state $property_state \
	    -property_municipality $property_municipality \
	    -owner_p $owner_p
	    
	

	foreach {category_id category_name} [lead_management::get_categories -package_id $package_id] {
	    category::map_object -remove_old -object_id $user_id ""
	}
	foreach {category_id category_name} [lead_management::get_categories -package_id $package_id] {
	    ns_log Notice " TTT [set cat_${category_id}]"
	    set child_id  [set cat_${category_id}]
	    category::map_object -object_id $user_id $child_id
	    
	}
	
    } on_error {
	ad_return_complaint 1 "[_ lead-management.Error_add_lead] <pre>$errmsg</pre>"
	ad_script_abort
    }
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}

