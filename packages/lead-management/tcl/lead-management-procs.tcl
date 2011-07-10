#/packages/lead-management/tcl/lead-mangement-procs.tcl
ad_library {
    TCL Library for Lead Manamegement Package

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-07-03
}


namespace eval lead_management {}
namespace eval lead_management::lead  {}
namespace eval lead_management::loan {}

ad_proc -public lead_management::loan::new {
    -lead_id:required
    -financed_amount
    -property_state
    -property_municipality
    -owner_p
} { 

    Adds new loan associated with lead_id

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-07-07

} {

    return [db_exec_plsql insert_loan {
	SELECT lm_loan__new (
			     null,
			     :lead_id,
			     :financed_amount,
			     :property_state,
			     :property_municipality,
			     :owner_p
			     );
    }]
}

ad_proc -public lead_management::lead::new {
    -user_id:required
    -cpf
    -gender
    -monthly_income
    -birth_date
    -marital_status 
    -contact_time
    -email
    -phone1
    -phone_type1
    -phone2
    -phone_type2
    -postal_code
    -address
    -address2
    -state
    -municipality
    -country
    -note
} { 
    Adds new lead and contact info

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-07-07

} {

    set lead_id [db_exec_plsql insert_lead {
	SELECT lm_lead__new (
			     null,
			     :user_id,
			     :cpf,
			     :gender,
			     :monthly_income,
			     :birth_date,
			     :marital_status 
			     );
    }]

    db_exec_plsql insert_contact_info {
	SELECT lm_lead_contact__new (
				     null,
				     :lead_id,
				     :contact_time,
				     :address,
				     :address2,
				     :postal_code,
				     :state,
				     :municipality,
				     :country,
				     :email,
				     :phone1,
				     :phone_type1,
				     :phone2,
				     :phone_type2,
				     :note
				     );
    }

    return $lead_id
}
    

ad_proc -public lead_management::get_categories {
    {-package_id ""}
} {
   Returns categories 
} {
    #ns_log Notice "Running videos::category_types"

    set locale [ad_conn locale]
    #ns_log Notice "LOCAL $locale"
    set category_trees [category_tree::get_mapped_trees $package_id]
    #ns_log Notice "TREES: $category_trees"


    if {[exists_and_not_null category_trees]} {
	
	set tree_id [lindex [lindex $category_trees 0] 0]
	#ns_log Notice "TREEID: $tree_id"
	set cat_ids [category_tree::get_categories -tree_id $tree_id]
	#ns_log Notice "cat $cat_ids"
	set categories [list]
	foreach cat_id $cat_ids {
	    set cat_name [category::get_name $cat_id]
	        lappend categories $cat_id
	        lappend categories $cat_name
	}
	
	return $categories
    }

    return
}




ad_proc lead_management::category_get_options {
    {-parent_id:required}
} {
    @return Returns the category types for this instance as an
    array-list of { parent_id1 heading1 parent_id2 heading2 ... }
} {

#    ns_log Notice "Running videos::category_get_options $parent_id"

    set children_ids [category::get_children -category_id $parent_id]
    
#    ns_log Notice "CC $children_ids"

    set children [list]
    foreach child_id $children_ids {
	set child_name [category::get_name $child_id]
	#ns_log Notice "CHILDNAME: $child_name"
	set temp "$child_name $child_id"
	lappend children $temp
    }

#    ns_log Notice  "CHILDREN $children"
    return $children
}   

