#/packages/lead-management/tcl/lead-mangement-procs.tcl
ad_library {
    TCL Library for Lead Manamegement Package

    @author Iuri Sampaio (iuri.sampaio@iurix.com)
    @creation-date 2011-07-03
}


namespace eval lead_management {}
namespace eval lead  {}

ad_proc -public lead_management::lead::new {}