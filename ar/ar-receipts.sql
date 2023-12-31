/*
File Name: ar-receipts.sql
Version: Oracle Fusion Cloud
Author: Throwing Cheese
URL: https://github.com/throwing-cheese/oracle-fusion-cloud-sql-scripts

Queries:

-- TABLE DUMP
-- RECEIPT DETAILS
-- RECEIPT HISTORY
-- RECEIPT APPLICATIONS
-- RECEIPT APPLICATIONS - COUNT
-- COUNT BY CREATED BY
-- COUNT ON ACCOUNT BY CUSTOMER 1
-- COUNT ON ACCOUNT BY CUSTOMER 2
-- COUNT ON ACCOUNT BY CUSTOMER 3
-- SUMMARY BY CUSTOMER 1
-- SUMMARY BY CUSTOMER 2
-- SUMMARY BY CUSTOMER 3

*/

-- ##############################################################
-- TABLE DUMP
-- ##############################################################

select * from ar_cash_receipts_all acra where acra.receipt_number in ('123456')

-- ##############################################################
-- RECEIPT DETAILS
-- ##############################################################

		select acra.cash_receipt_id
			 , to_char(acra.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , to_char(acra.receipt_date, 'yyyy-mm-dd') receipt_date
			 , acra.receipt_number
			 , arm.name receipt_method
			 , acra.doc_sequence_value
			 , acra.customer_site_use_id
			 , hps.party_site_number
			 , fds.name doc_sequence
			 , acra.comments
			 , acra.amount
			 , haou.name org
			 , hca.account_number
			 , hca.account_name
			 , hca.cust_account_id
		  from ar_cash_receipts_all acra
	 left join hr_all_organization_units haou on acra.org_id = haou.organization_id
	 left join fnd_document_sequences fds on fds.doc_sequence_id = acra.doc_sequence_id
	 left join hz_cust_accounts hca on hca.cust_account_id = acra.pay_from_customer
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join hz_cust_site_uses_all hcsua on hcsua.site_use_id = acra.customer_site_use_id
	 left join hz_cust_acct_sites_all hcasa on hcasa.cust_acct_site_id = hcsua.cust_acct_site_id and hca.cust_account_id = hcasa.cust_account_id
	 left join hz_party_sites hps on hcasa.party_site_id = hps.party_site_id 
	 left join ar_receipt_methods arm on acra.receipt_method_id = arm.receipt_method_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- RECEIPT HISTORY
-- ##############################################################

/*
https://community.oracle.com/customerconnect/discussion/601846/query-to-find-amount-and-accounting-date-on-ar-receipt
*/

		SELECT receipt.amount
			 , receipt.cash_receipt_id
			 , receipt.doc_sequence_value
			 , receipt.receipt_date
			 , receipt.receipt_number
			 , receipt.TYPE AS receipt_type
			 , paymentschedules.amount_applied
			 , paymentschedules.amount_due_original
			 , paymentschedules.amount_on_account
			 , receipthistory.acctd_amount AS acctd_amount30
			 , receipthistory.acctd_factor_discount_amount AS acctdfactordiscountamount
			 , (receipthistory.acctd_amount + NVL (receipthistory.acctd_factor_discount_amount, 0)) AS receiptaccountedamount30
		  FROM ar_cash_receipts_all receipt
	 left join ar_payment_schedules_all paymentschedules on receipt.cash_receipt_id = paymentschedules.cash_receipt_id
		  join ar_cash_receipt_history_all receipthistory on receipt.cash_receipt_id = receipthistory.cash_receipt_id
		 where 1 = 1
		   and 1 = 1

-- ##############################################################
-- RECEIPT APPLICATIONS
-- ##############################################################
		
		select acra.receipt_number
			 , acra.status
			 , haou.name org
			 , hca.account_number
			 , hca.account_name
			 , araa.request_id
			 , araa.cash_receipt_id
			 , araa.receivable_application_id
			 , araa.payment_schedule_id
			 , araa.applied_customer_trx_id
			 , araa.applied_payment_schedule_id
			 , to_char(araa.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , araa.created_by
			 , to_char(araa.gl_date, 'yyyy-mm-dd') gl_date
			 , to_char(araa.gl_posted_date, 'yyyy-mm-dd') gl_posted_date
			 , araa.application_rule
			 , acra.amount
			 , araa.amount_applied
			 , acra.amount - sum (nvl (araa.amount_applied, 0)) unapplied_amount
			 , araa.line_applied
			 , araa.days_late
			 , araa.display
		  from ar_receivable_applications_all araa
	 left join ar_cash_receipts_all acra on araa.cash_receipt_id = acra.cash_receipt_id
	 left join hr_all_organization_units haou on acra.org_id = haou.organization_id
	 left join hz_cust_accounts hca on hca.cust_account_id = acra.pay_from_customer
		 where 1 = 1
		   and 1 = 1
	  group by acra.receipt_number
			 , acra.status
			 , haou.name
			 , hca.account_number
			 , hca.account_name
			 , araa.request_id
			 , araa.cash_receipt_id
			 , araa.receivable_application_id
			 , araa.payment_schedule_id
			 , araa.applied_customer_trx_id
			 , araa.applied_payment_schedule_id
			 , to_char(araa.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , araa.created_by
			 , to_char(araa.gl_date, 'yyyy-mm-dd')
			 , to_char(araa.gl_posted_date, 'yyyy-mm-dd')
			 , araa.application_rule
			 , acra.amount
			 , araa.amount_applied
			 , araa.line_applied
			 , araa.days_late
			 , araa.display

-- ##############################################################
-- RECEIPT APPLICATIONS
-- ##############################################################
		
		select acra.receipt_number
			 , acra.status
			 , hca.account_number
			 , hca.account_name
			 , idsa.total_amount_due
			 , idsa.number_delinquencies
			 , idsa.display_name
			 , araa.request_id
			 , araa.cash_receipt_id
			 , araa.receivable_application_id
			 , araa.payment_schedule_id
			 , araa.applied_customer_trx_id
			 , araa.applied_payment_schedule_id
			 , to_char(araa.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , araa.created_by
			 , acra.amount
			 , araa.amount_applied
			 , acra.amount - sum (nvl (araa.amount_applied, 0)) unapplied_amount
		  from ar_receivable_applications_all araa
		  join ar_cash_receipts_all acra on araa.cash_receipt_id = acra.cash_receipt_id
		  join hz_cust_accounts hca on hca.cust_account_id = acra.pay_from_customer
		  join ra_customer_trx_all rcta on rcta.customer_trx_id = araa.applied_customer_trx_id
		  join iex_delinq_summaries_all idsa on idsa.cust_account_id = hca.cust_account_id
		 where 1 = 1
		   and araa.display = 'Y'
		   and rcta.trx_number = '123456'
		   and 1 = 1
	  group by acra.receipt_number
			 , acra.status
			 , hca.account_number
			 , hca.account_name
			 , idsa.total_amount_due
			 , idsa.number_delinquencies
			 , idsa.display_name
			 , araa.request_id
			 , araa.cash_receipt_id
			 , araa.receivable_application_id
			 , araa.payment_schedule_id
			 , araa.applied_customer_trx_id
			 , araa.applied_payment_schedule_id
			 , to_char(araa.creation_date, 'yyyy-mm-dd hh24:mi:ss')
			 , araa.created_by
			 , acra.amount
			 , araa.amount_applied

-- ##############################################################
-- RECEIPT APPLICATIONS - COUNT
-- ##############################################################

		select hca.account_number
			 , count(*)
		  from ar_receivable_applications_all araa
	 left join ar_cash_receipts_all acra on araa.cash_receipt_id = acra.cash_receipt_id
	 left join hr_all_organization_units haou on acra.org_id = haou.organization_id
	 left join hz_cust_accounts hca on hca.cust_account_id = acra.pay_from_customer
		 where 1 = 1
		   and 1 = 1
	  group by hca.account_number

-- ##############################################################
-- COUNT BY CREATED BY
-- ##############################################################

		select acra.created_by
			 , min(to_char(acra.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(acra.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , count(*)
		  from ar_cash_receipts_all acra
	  group by acra.created_by

-- ##############################################################
-- COUNT ON ACCOUNT BY CUSTOMER 1
-- ##############################################################	

		select haou.name org
			 , hca.account_number
			 , hca.account_name
			 , hp.party_name
			 , hp.party_number
			 , hp.party_type
			 , min(to_char(araa.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(araa.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , min(acra.receipt_number) min_receipt
			 , max(acra.receipt_number) max_receipt
			 , sum(araa.amount_applied) sum_
			 , count(*) count_
		  from ar_receivable_applications_all araa
		  join ar_cash_receipts_all acra on araa.cash_receipt_id = acra.cash_receipt_id
		  join hr_all_organization_units haou on acra.org_id = haou.organization_id
		  join hz_cust_accounts hca on hca.cust_account_id = acra.pay_from_customer
		  join hz_parties hp on hp.party_id = hca.party_id
		 where 1 = 1
		   and araa.status = 'ACC'
		   and hca.account_number = '123'
		   and 1 = 1
	  group by haou.name
			 , '#' || hca.account_number
			 , hca.account_name
			 , hp.party_name
			 , '#' || hp.party_number
			 , hp.party_type

-- ##############################################################
-- COUNT ON ACCOUNT BY CUSTOMER 2
-- ##############################################################

		select haou.name org
			 , hca.account_number
			 , hca.account_name
			 , hp.party_name
			 , hp.party_number
			 , hp.party_type
			 , '####'
			 , tbl_summary.bill_cust_class
			 , tbl_summary.trx_source
			 , tbl_summary.trx_type
			 , tbl_summary.min_created summary_min_created
			 , tbl_summary.max_created summary_max_created
			 , tbl_summary.min_trx
			 , tbl_summary.max_trx
			 , tbl_summary.sum_outstanding
			 , tbl_summary.sum_adjustment
			 , tbl_summary.count_ trx_count
			 , min(to_char(araa.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(araa.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , min(acra.receipt_number) min_receipt
			 , max(acra.receipt_number) max_receipt
			 , sum(araa.amount_applied) sum_on_account_amt_applied
			 , count(*) on_account_count
		  from ar_receivable_applications_all araa
		  join ar_cash_receipts_all acra on araa.cash_receipt_id = acra.cash_receipt_id
		  join hr_all_organization_units haou on acra.org_id = haou.organization_id
		  join hz_cust_accounts hca on hca.cust_account_id = acra.pay_from_customer
		  join hz_parties hp on hp.party_id = hca.party_id
		  join (select account_id
					 , bill_cust_class
					 , trx_source
					 , trx_type
					 , min(creation_date) min_created
					 , max(creation_date) max_created
					 , min(trx_number) min_trx
					 , max(trx_number) max_trx
					 , sum(trx_value) sum_trx_value
					 , sum(amt_outstanding) sum_outstanding
					 , sum(adjustment_total) sum_adjustment
					 , count(*) count_
				  from (select hca.cust_account_id account_id
							 , hca.customer_class_code bill_cust_class
							 , rbsa.name trx_source
							 , rctta.name trx_type
							 , to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
							 , rcta.trx_number
							 , (select sum(extended_amount) from ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
							 , (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) amt_outstanding
							 , (select sum(line_adjusted) from ar_adjustments_all aaa where aaa.customer_trx_id = rcta.customer_trx_id) adjustment_total
						  from ra_customer_trx_all rcta
						  join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
						  join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
						  join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
						 where 1 = 1
						   -- and (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) <> 0
						   and 1 = 1)
			  group by account_id
					 , bill_cust_class
					 , trx_source
					 , trx_type) tbl_summary on tbl_summary.account_id = hca.cust_account_id
		 where 1 = 1
		   and araa.status = 'ACC'
		   and 1 = 1
	  group by haou.name
			 , hca.account_number
			 , hca.account_name
			 , hp.party_name
			 , hp.party_number
			 , hp.party_type
			 , '####'
			 , tbl_summary.bill_cust_class
			 , tbl_summary.trx_source
			 , tbl_summary.trx_type
			 , tbl_summary.min_created
			 , tbl_summary.max_created
			 , tbl_summary.min_trx
			 , tbl_summary.max_trx
			 , tbl_summary.sum_outstanding
			 , tbl_summary.sum_adjustment
			 , tbl_summary.count_ trx_count

-- ##############################################################
-- COUNT ON ACCOUNT BY CUSTOMER 3
-- ##############################################################

		select haou.name org
			 , hca.account_number
			 , hca.account_name
			 , hp.party_name
			 , tbl_summary.sum_outstanding
			 , tbl_summary.count_ trx_count
			 , sum(araa.amount_applied) sum_on_account_amt_applied
			 , count(*) on_account_count
		  from ar_receivable_applications_all araa
		  join ar_cash_receipts_all acra on araa.cash_receipt_id = acra.cash_receipt_id
		  join hr_all_organization_units haou on acra.org_id = haou.organization_id
		  join hz_cust_accounts hca on hca.cust_account_id = acra.pay_from_customer
		  join hz_parties hp on hp.party_id = hca.party_id
		  join (select account_id
					 , sum(trx_value) sum_trx_value
					 , sum(amt_outstanding) sum_outstanding
					 , count(*) count_
				  from (select rcta.bill_to_customer_id account_id
							 , (select sum(extended_amount) from ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
							 , (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) amt_outstanding
						  from ra_customer_trx_all rcta
						  join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id)
			  group by account_id) tbl_summary on tbl_summary.account_id = hca.cust_account_id
		 where 1 = 1
		   and araa.status = 'ACC'
		   and 1 = 1
	  group by haou.name
			 , hca.account_number
			 , hca.account_name
			 , hp.party_name
			 , tbl_summary.sum_outstanding
			 , tbl_summary.count_

-- ##############################################################
-- SUMMARY BY CUSTOMER 1
-- ##############################################################

		select hca.account_name acct_name
			 , hca.account_number
			 , hp.party_name
			 , hca.customer_class_code bill_cust_class
			 , rbsa.name trx_source
			 , rctta.name trx_type
			 , min(to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss')) min_created
			 , max(to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss')) max_created
			 , min(rcta.trx_number) min_trx
			 , min(rcta.trx_number) max_trx
			 , (select sum(extended_amount) from ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
			 , (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) amt_outstanding
			 , (select sum(line_adjusted) from ar_adjustments_all aaa where aaa.customer_trx_id = rcta.customer_trx_id) adjustment_total
			 , count(*)
		  from ra_customer_trx_all rcta
	 left join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
	 left join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		 where 1 = 1
		   and 1 = 1
	  group by hca.account_name
			 , hca.account_number
			 , hp.party_name
			 , hca.customer_class_code
			 , rbsa.name
			 , rctta.name

-- ##############################################################
-- SUMMARY BY CUSTOMER 2
-- ##############################################################

		select hca.account_name acct_name
			 , hca.account_number
			 , hp.party_name
			 , hca.customer_class_code bill_cust_class
			 , rbsa.name trx_source
			 , rctta.name trx_type
			 , to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
			 , rcta.trx_number
			 , (select sum(extended_amount) from ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
			 , (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) amt_outstanding
			 , (select sum(line_adjusted) from ar_adjustments_all aaa where aaa.customer_trx_id = rcta.customer_trx_id) adjustment_total
		  from ra_customer_trx_all rcta
	 left join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
	 left join hz_parties hp on hp.party_id = hca.party_id
	 left join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
	 left join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
		 where 1 = 1
		   and (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) <> 0
		   and 1 = 1

-- ##############################################################
-- SUMMARY BY CUSTOMER 3
-- ##############################################################

		select account_name
			 , account_number
			 , account_id
			 , party_name
			 , bill_cust_class
			 , trx_source
			 , trx_type
			 , min(creation_date) min_created
			 , max(creation_date) max_created
			 , min(trx_number) min_trx
			 , max(trx_number) max_trx
			 , sum(trx_value) sum_trx_value
			 , sum(amt_outstanding) sum_outstanding
			 , sum(adjustment_total) sum_adjustment
			 , count(*) count_
		  from (select hca.account_name
					 , hca.account_number
					 , hp.party_name
					 , hca.cust_account_id account_id
					 , hca.customer_class_code bill_cust_class
					 , rbsa.name trx_source
					 , rctta.name trx_type
					 , to_char(rcta.creation_date, 'yyyy-mm-dd hh24:mi:ss') creation_date
					 , rcta.trx_number
					 , (select sum(extended_amount) from ra_customer_trx_lines_all rctla where rcta.customer_trx_id = rctla.customer_trx_id) trx_value
					 , (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) amt_outstanding
					 , (select sum(line_adjusted) from ar_adjustments_all aaa where aaa.customer_trx_id = rcta.customer_trx_id) adjustment_total
				  from ra_customer_trx_all rcta
			 left join hz_cust_accounts hca on rcta.bill_to_customer_id = hca.cust_account_id
			 left join hz_parties hp on hp.party_id = hca.party_id
			 left join ra_batch_sources_all rbsa on rbsa.batch_source_seq_id = rcta.batch_source_seq_id
			 left join ra_cust_trx_types_all rctta on rctta.cust_trx_type_seq_id = rcta.cust_trx_type_seq_id 
				 where 1 = 1
				   and (select sum(amount_due_remaining) from ar_payment_schedules_all apsa where rcta.customer_trx_id = apsa.customer_trx_id) <> 0
				   and 1 = 1)
	  group by account_name
			 , account_number
			 , account_id
			 , party_name
			 , bill_cust_class
			 , trx_source
			 , trx_type
