ad_page_contract {

    Kill (restart) the server.

    @author Peter Marklund (peter@collaboraid.biz)
    @creation-date 27:th of March 2003
    @cvs-id $Id: server-restart.tcl,v 1.4 2003/10/28 08:54:44 lars Exp $
}

set page_title "Restarting Server"

set context [list $page_title]


# We do this as a schedule proc, so the server will have time to serve the page

ad_schedule_proc -thread t -once t 2 ns_shutdown
