#/packages/lead-management/tcl/lead-mangement-procs.tcl
ad_library {
    TCL Library for Lead Manamegement Package

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-07-03
}


namespace eval lead_management {}
namespace eval lead  {}





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

