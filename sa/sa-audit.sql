/*
File Name: ap-audit.sql
*/

/*
FND_AUDIT_ATTRIBUTES
This table will store the attributes enabled for Auditing.
*/

		select *
		  from fnd_audit_attributes
		 where table_name = 'AP_INVOICES_ALL'

		select *
		  from fnd_audit_attributes
		 where table_name like 'AP_INVOICE%'

		select table_name
			 , enabled_flag
			 , created_by
			 , min(to_char(creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , min(view_attribute) min_view_attribute
			 , max(view_attribute) max_view_attribute
			 , min(column_name) min_column_name
			 , max(column_name) max_column_name
			 , count(*)
		  from fnd_audit_attributes
	  group by table_name
			 , enabled_flag
			 , created_by
