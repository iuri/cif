<?xml version="1.0"?>
<queryset>

    <fullquery name="ref_br_territories::get_sdt_code.get_by_category_id">
        <querytext>
            select sdt_code
            from br_territories
			where category_id = :category_id
        </querytext>
    </fullquery>

	<fullquery name="ref_br_territories::get_sdt_code.get_by_community_id">
        <querytext>
            select sdt_code
            from br_territories
			where community_id = :community_id
        </querytext>
    </fullquery>
	<fullquery name="ref_br_territories::get_array_sdt_code.select_sdt_code">
        <querytext>
            select sdt_code, territory_name
            from br_territories
        </querytext>
    </fullquery>

    <fullquery name="ref_br_territories::get_array_territory_name.select_territory_name">
        <querytext>
            select sdt_code, territory_name
            from br_territories
        </querytext>
    </fullquery>

    <fullquery name="ref_br_territories::get.ibge_select">
        <querytext>
            select sdt_code, 
		   territory_
            from br_territories
        </querytext>
    </fullquery>



</queryset>



