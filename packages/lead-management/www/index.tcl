ad_page_contract {
    Main page of lead-management system
    List of Leads

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-07-06
}


set return_url [ad_conn url]
set lead_ae_url [export_vars -base "lead-ae" {return_url}]