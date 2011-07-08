# /packages/lead-management/tcl/apm-callback-procs.tcl
ad_library {
    Lead Management System Install Library
    @author Iuri Sampaio
    @creation-date 2011-07-05
}


namespace eval lead_management {}
namespace eval lead_management::install {}
namespace eval lead_management::apm {}

ad_proc -private lead_management::apm::after_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    
    Upgrading callback to run after upgrading pkg

    @author Iuri Sampaio
    @creation-date 2011-07-05
} {
    apm_upgrade_logic \
	-from_version_name $from_version_name \
	-to_version_name $to_version_name \
	-spec  {
	    0.1d 0.1d1 {
	    }
	}
}


ad_proc -private lead_management::install::after_mount {
    {-package_id ""}
    {-node_id ""}
} {
    A callback install that adds standard tree, categories, sub-categories and map them to lead-management pkg

    @author Iuri Sampaio
    @creation-date 2011-07-05
} {

    #create category tree
    set tree_id [category_tree::add -name "Lead Management"]
    
    set parent_id [category::add -tree_id $tree_id -parent_id [db_null] -name "Type of Property" -description "Types of Property"]
    category::add -tree_id $tree_id -parent_id $parent_id -name "Residencial Usado" -description "Residencial Usado"
    
    db_1row select_object_id {
      SELECT object_id FROM acs_objects 
      WHERE object_type = 'apm_package' AND package_id = :package_id

    }

    category_tree::map -tree_id $tree_id -object_id $object_id
}