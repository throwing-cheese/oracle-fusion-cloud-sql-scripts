/*
File Name: sa-bi-catalog.sql

Queries:

-- REPORT DEFINITION
-- REPORT DEFINITION - COUNT BY REPORT TYPE
-- REPORT ACCESS INFO
-- REPORTS ACCESS - USER ASSIGNED COUNT BY REPORT

*/

-- https://community.oracle.com/customerconnect/discussion/563698/how-to-get-list-of-custom-bi-and-otbi-reports-in-fusion#latest

-- ##############################################################
-- REPORT DEFINITION
-- ##############################################################

		select gfrt.report_display_name
			 , gfrt.report_description
			 , gfrb.report_type_code
			 , to_char(gfrb.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , gfrb.created_by
			 , to_char(gfrb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , gfrb.last_updated_by
			 , gfrb.report_path
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 1) segment1
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 2) segment2
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 3) segment3
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 4) segment4
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 5) segment5
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 6) segment6
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 7) segment7
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 8) segment8
		  from gl_frc_reports_b gfrb
		  join gl_frc_reports_tl gfrt on gfrb.report_id = gfrt.report_id

-- ##############################################################
-- REPORT DEFINITION - COUNT BY REPORT TYPE
-- ##############################################################

		select gfrb.report_type_code
			 , min(gfrt.report_display_name) min_report_name
			 , max(gfrt.report_display_name) max_report_name
			 , min(to_char(gfrb.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_creation_date
			 , max(to_char(gfrb.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_creation_date
			 , min(gfrb.created_by) min_created_by
			 , max(gfrb.created_by) max_created_by
			 , count(*) report_count
		  from gl_frc_reports_b gfrb
		  join gl_frc_reports_tl gfrt on gfrb.report_id = gfrt.report_id
	  group by , gfrb.report_type_code

-- ##############################################################
-- REPORT ACCESS INFO
-- ##############################################################

		select gfrt.report_display_name
			 , gfrb.report_type_code
			 -- , decode(gfrb.report_type_code, 'BIP', 'BI Publisher', 'Analysis', 'OTBI', 'FR', 'Financial Reporting Studio', 'Dashboard', 'Dashboard') report_type
			 , gfrt.report_description
			 , to_char(gfrb.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , gfrb.created_by
			 , to_char(gfrb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , gfrb.last_updated_by
			 , gfrb.report_path
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 1) segment1
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 2) segment2
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 3) segment3
			 , gfuar.user_name user_name
			 , to_char(gfuar.creation_date, 'yyyy-mm-dd hh24:mi:ss') access_creation_date
			 , gfuar.created_by access_created_by
		  from gl_frc_reports_b gfrb
		  join gl_frc_reports_tl gfrt on gfrb.report_id = gfrt.report_id
		  join gl_frc_user_access_reports gfuar on gfrb.report_id = gfuar.report_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- REPORTS ACCESS - USER ASSIGNED COUNT BY REPORT
-- ##############################################################

		select gfrt.report_display_name
			 , gfrt.report_description
			 , gfrb.report_type_code
			 , to_char(gfrb.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , gfrb.created_by
			 , to_char(gfrb.last_update_date, 'yyyy-mm-dd hh24:mi:ss') last_update_date
			 , gfrb.last_updated_by
			 , gfrb.report_path
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 1) segment1
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 2) segment2
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 3) segment3
			 , count(gfuar.user_name) user_share_count
		  from gl_frc_reports_b gfrb
		  join gl_frc_reports_tl gfrt on gfrb.report_id = gfrt.report_id
		  join gl_frc_user_access_reports gfuar on gfrb.report_id = gfuar.report_id
	  group by gfrt.report_display_name
			 , gfrt.report_description
			 , gfrb.report_type_code
			 , to_char(gfrb.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , gfrb.created_by
			 , to_char(gfrb.last_update_date, 'yyyy-mm-dd hh24:mi:ss')
			 , gfrb.last_updated_by
			 , gfrb.report_path
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 1)
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 2)
			 , regexp_substr(gfrb.report_path, '[^/]+', 1, 3)
