<?xml version="1.0"?>

<queryset>
  <rdbms><type>postgresql</type><version>8.4</version></rdbms>

  <fullquery name="after_mount.select_object_id">
    <querytext>
      SELECT object_id FROM acs_objects 
      WHERE object_type = 'apm_package' AND package_id = :package_id
    </querytext>
  </fullquery>
</queryset>
