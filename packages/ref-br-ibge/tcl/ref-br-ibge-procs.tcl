ad_library {
    Data of IBGE
	
    @creation-date 2009-08-31
    @author Alessandro Landim alessandro.landim@gmail.com
}

namespace eval ref_br_ibge:: {}


ad_proc -public ref_br_ibge::get_municipality {} { 
	Get all data of ibge and put it in array
} {

	db_multirow get get_municipality {select ibge_code, name, state_code from br_ibge_municipality} {
		lappend ibge_data [list "$name - $state_code" $ibge_code]
	}
	return $ibge_data
}

ad_proc -public ref_br_ibge::get_name {
	{ibge_code}
} { 
	get name by ibge code
} {

	return [db_string get_name {select name || ' - ' || state_code from br_ibge_municipality where ibge_code = :ibge_code}]
}
ad_proc -public ref_br_ibge::get_state_code {
	{ibge_code}
} { 
	get name by ibge code
} {

	return [db_string get_state_code {select state_code from br_ibge_municipality where ibge_code = :ibge_code}]
}

ad_proc -public ref_br_ibge::get_list_from_state_code {
	{state_code}
} { 
} {

	db_multirow get get_municipality {select ibge_code, name, state_code from br_ibge_municipality where state_code = :state_code} {
		lappend ibge_data_municipality [list "$name" $ibge_code]
	}

	return $ibge_data_municipality
}

ad_proc -public ref_br_ibge::get {
    -ibge_code:required
    -array:required
} {
    This proc retrieves a video. 
} {
    upvar 1 $array row
    db_1row ibge_select {
	select ibge_code, name, state_code, lat, lng from br_ibge_municipality where ibge_code = :ibge_code
    } -column_array row
}


