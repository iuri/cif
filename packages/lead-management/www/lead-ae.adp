<master>
<if @action@ eq add>
  <property name="title">#lead-management.Add_Lead#</property>
  <property name="context">#lead-management.Add_Lead#</property>
  <h1>#lead-management.Add_Lead#</h1>
</if>
<if @action@ eq edit>
  <property name="title">#lead-management.Edit_Lead#</property>
  <property name="context">#lead-management.Edit_Lead#</property>
  <h1>#lead-management.Edit_Lead#</h1>
</if>

<property name="focus">lead-ae.name</property>

 
<formtemplate id="lead"></formtemplate>