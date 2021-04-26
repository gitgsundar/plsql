-- Grants Required
/*
grant administer resource manager to system;
grant select on dba_cdb_rsrc_plans to system;
grant select on dba_cdb_rsrc_plan_directives to system;
grant select on gv_$instance to system;
grant select on gv_$containers to system;
grant select on gv_$pdbs to system;
grant select on gv_$system_parameter to system;
grant select on gv_$rsrcpdbmetric to system;
grant select on gv_$rsrcpdbmetric_history to system;
grant select on dba_hist_rsrc_pdb_metric to system;
grant select on dba_hist_sysmetric_summary to system;

-- Config Table

drop table antm_config purge;

create table antm_config (
	program_name			varchar2(100),
	config_reference	varchar2(100),
	config_name				varchar2(100),
	config_value			varchar2(100),
	description				varchar2(100),
	comments					varchar2(250),
	created_date			date default sysdate,
	created_by				varchar2(30),
	updated_date			date default sysdate,
	updated_by				varchar2(30),
constraint 	antm_config_u1 primary key (program_name,config_reference,config_name))
tablespace users;

-- CDB Plan Name Values
insert into antm_config values ('ANTM_ADMIN_PKG.CREATE_RMPLAN_PRC','STANDARD','CDB_PLAN_NAME','ANTM_CDB_PLAN','Anthem Standard CDB Plan Name','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.CREATE_RMPLAN_PRC','STANDARD','CDB_AUTOTASK_DIRECTIVE','new_shares => 1, new_utilization_limit => 90, new_parallel_server_limit => 90','Anthem Standard CDB AutoTask Directives','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');

insert into antm_config values ('ANTM_ADMIN_PKG.CREATE_RMPLAN_PRC','PDB_PROFILE','PLATINUM','16','Anthem Standard PDB Profile PLATINUM with Shares 16','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.CREATE_RMPLAN_PRC','PDB_PROFILE','GOLD','8','Anthem Standard PDB Profile GOLD with Shares 8','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.CREATE_RMPLAN_PRC','PDB_PROFILE','SILVER','4','Anthem Standard PDB Profile SILVER with Shares 4','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.CREATE_RMPLAN_PRC','PDB_PROFILE','BRONZE','2','Anthem Standard PDB Profile BRONZE with Shares 2','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.CREATE_RMPLAN_PRC','PDB_PROFILE','DEFAULT','2','Anthem Standard PDB Profile DEFAULT with Shares 2','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');

-- Purge Log Table Values
insert into antm_config values ('ANTM_ADMIN_PKG.PURGE_LOG_PRC','STANDARD','PURGE_VOLUME_MONTHS',10,'Retention Number in Months','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');

-- Platinum Profile Memory and Session Values
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','PLATINUM','SHARED_POOL_SIZE','2048M','Platinum Profile Shared Pool Size','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','PLATINUM','DB_CACHE_SIZE','2048M','Platinum Profile DB Cache Size','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','PLATINUM','PGA_AGGREGATE_LIMIT','16G','Platinum Profile PGA Aggregate Limit','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','PLATINUM','PGA_AGGREGATE_TARGET','8G','Platinum Profile PGA Aggregate Target','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','PLATINUM','SESSIONS','2000','Platinum Profile Sessions Limit','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');

-- Gold Profile Memory and Session Values
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','GOLD','SHARED_POOL_SIZE','1024M','Gold Profile Shared Pool Size','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','GOLD','DB_CACHE_SIZE','1024M','Gold Profile DB Cache Size','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','GOLD','PGA_AGGREGATE_LIMIT','8G','Gold Profile PGA Aggregate Limit','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','GOLD','PGA_AGGREGATE_TARGET','4G','Gold Profile PGA Aggregate Target','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','GOLD','SESSIONS','1000','Platinum Gold Sessions Limit','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');

-- Silver Profile Memory and Session Values
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','SILVER','SHARED_POOL_SIZE','512M','Silver Profile Shared Pool Size','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','SILVER','DB_CACHE_SIZE','512M','Silver Profile DB Cache Size','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','SILVER','PGA_AGGREGATE_LIMIT','4G','Silver Profile PGA Aggregate Limit','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','SILVER','PGA_AGGREGATE_TARGET','2G','Silver Profile PGA Aggregate Target','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','SILVER','SESSIONS','500','Silver Profile Sessions Limit','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');

-- Bronze Profile Memory and Session Values
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','BRONZE','SHARED_POOL_SIZE','256M','Bronze Profile Shared Pool Size','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','BRONZE','DB_CACHE_SIZE','256M','Bronze Profile DB Cache Size','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','BRONZE','PGA_AGGREGATE_LIMIT','2G','Bronze Profile PGA Aggregate Limit','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','BRONZE','PGA_AGGREGATE_TARGET','1G','Bronze Profile PGA Aggregate Target','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');
insert into antm_config values ('ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC','BRONZE','SESSIONS','250','Bronze Profile Sessions Limit','',SYSDATE,'ANTHEMDBA',SYSDATE,'ANTHEMDBA');

commit;

-- Logging Table

drop table antm_log purge;

create table antm_log (
	log_id					number generated by default on null as identity,
	program_name		varchar2(100),
	log_severity		varchar2(15),
	log_date				date default sysdate,
	log_message			varchar2(1000),
	invoker_id			varchar2(30))
partition by range (log_date)
	interval(numtoyminterval(1,'month'))
(partition antm_log_seed values less than (to_date('01-01-2020','dd-mm-yyyy'))
)
tablespace users;
*/
-- Start of DDL Script for Package antm_ADMIN.antm_ADMIN_PKG

CREATE OR REPLACE PACKAGE antm_admin_pkg as
		procedure write_log_prc(lcall_program varchar2,lerror_severity varchar2,lmessage varchar2);
    procedure create_rmplan_prc;
    procedure activate_rmplan_prc;
    procedure delete_rmplan_prc(lcdbplan varchar2,lperf_profile varchar2);
		procedure modify_pdbplan_prc(lpdb_name varchar2,lperf_profile varchar2);
    procedure purge_log_prc;
    procedure view_rminfo_prc;
    procedure view_capacity_prc(ldays number);
    procedure report_minute_rminfo_prc;
    procedure report_hour_rminfo_prc(lpdb_name varchar2);
    procedure report_history_rminfo_prc(lpdb_name varchar2);
end antm_admin_pkg;
/

CREATE OR REPLACE PACKAGE BODY antm_admin_pkg as
/* 
		#########################################################################################################################
		# Program       : antm_admin_pkg
		# Programmer    : Anthem DBA Team
		# Date          : Mar 27th, 2020.
		# Revisions     : 09-25-2019   Wrote the code.
		#									03-13-2020	 Consolidated code in create_rmplan_info.
		#									03-20-2020	 Consolidated Log Table, included couple more attributes in Minute Reports.
		#									03-26-2020	 Included PDB Reports for Hourly and History.
		#                              Updated Default CDB Directive and Autotask Directive.
		#									03-27-2020	 Rewrote code to be data driven to create PDB Profiles to manage any future changes.
		#									04-14-2020	 Included Activate Procedure.
		#									05-05-2020	 Included Resource Capacity Procedure and added highlevel Resource report.
		#									05-14-2020	 Removed Instance Hard Coding for Utilization and Parallel Limit settings Calculations.
		#									05-17-2020	 Finalize View Capacity Procedure only to display Shared Pool Related Information.
		#									05-20-2020	 Finalize View Capacity Procedure only to display Buffer Cache Related Information.
		#									05-22-2020	 Identified code bug in Utilization Calculation.
		#
		# Dependencies  :
		#                 1. Table ANTM_CONFIG
		#                 2. Table ANTM_LOG
		#                 3. Grant SELECT on dba_cdb_rsrc_plan_directives, dba_cdb_rsrc_plans, gv_$instance to SYSTEM.  
		#                 4. Grant SELECT on gv_$containers, gv_$pdbs, gv_$system_parameter, gv_$rsrcpdbmetric to SYSTEM;
		#                 5. Grant SELECT on gv_$rsrcpdbmetric_history, dba_hist_rsrc_pdb_metric, dba_hist_sysmetric_summary to SYSTEM;
		#
		# Notes         : Script used to Standardize Resource Manager Profiles in 19c
		#										PROCEDURE write_log_prc(lcall_program varchar2,lerror_severity varchar2,lmessage varchar2)
		#    								PROCEDURE delete_rmplan_prc(lcdbplan varchar2,lperf_profile varchar2)
		#    								PROCEDURE create_rmplan_prc
		#    								PROCEDURE activate_rmplan_prc
		#										PROCEDURE modify_pdbplan_prc(lpdb_name varchar2,lperf_profile varchar2)
		#    								PROCEDURE purge_log_prc
		#    								PROCEDURE view_rminfo_prc
    #										PROCEDURE view_capacity_prc(ldays number)
		#    								PROCEDURE report_minute_rminfo_prc
		#    								PROCEDURE report_hour_rminfo_prc(lpdb_name varchar2)
		#    								PROCEDURE report_history_rminfo_prc(lpdb_name varchar2)
		# Usage         : To Create Anthem Standard CDB Resource Plan
		#										exec antm_admin_pkg.create_rmplan_prc;
		#    							To Activate CDB Resource Plan in the Container 
		#    								exec antm_admin_pkg.activate_rmplan_prc
		#    							To Delete PDB Resource Profiles 
		#    								exec antm_admin_pkg.delete_rmplan_prc(lcdbplan varchar2,lperf_profile varchar2)
		#    							To Modife PDB Resource Profiles 
		#										exec antm_admin_pkg.modify_pdbplan_prc(lpdb_name varchar2,lperf_profile varchar2)
		#    							To View Anthem Standard CDB Resource Profiles Values
		#    								exec antm_admin_pkg.view_rminfo_prc
		#    							To View Historical Capacity for Resources - Memory.
		#    								exec antm_admin_pkg.view_capacity_prc(,10)
		#    							To get Report of current PDB Resource Profile Usages across all PDB's 
		#    								exec antm_admin_pkg.report_minute_rminfo_prc
		#    							To get Hourly PDB Resource Profile Report for a specific PDB 
		#    								exec antm_admin_pkg.report_hour_rminfo_prc(lpdb_name varchar2)
		#    							To get Historical PDB Resource Profile Report for a specific PDB 
		#    								exec antm_admin_pkg.report_history_rminfo_prc(lpdb_name varchar2)
		#                 
		# IMPORTANT     : Copyright (c) 2020 by Anthem.
		#                 All Rights Reserved.
		######################################################################################################################### 
*/
		procedure write_log_prc(lcall_program varchar2,lerror_severity varchar2,lmessage varchar2) is
			PRAGMA	AUTONOMOUS_TRANSACTION;
			object_code	varchar2(10) 	:= 'ADMP1';
			object_name	varchar2(100)	:= 'ANTM_ADMIN_PKG.WRITE_LOG_PRC';
		begin
			insert into antm_log values(null,lcall_program||'->'||object_name,lerror_severity,sysdate,lmessage,(select sys_context('userenv','os_user') from dual));
			commit;
		end write_log_prc;

    procedure create_rmplan_prc as
 			lcdbplan				varchar2(20);
 			lconfig_value		varchar2(100);
    	lpcount					number;
    	ldcount					number;
    	lshares					number;
    	lutil_limit			number;
    	lparallel_limit	number;
    	lcpu						number;
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP2';
      object_name   	varchar2(100) := 'ANTM_ADMIN_PKG.CREATE_RMPLAN_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			select config_value into lcdbplan 
			from antm_config 
			where upper(config_name) ='CDB_PLAN_NAME'
			  and upper(program_name) = object_name;			

			select count(*) into lpcount from dba_cdb_rsrc_plans where upper(plan)=lcdbplan;
			select count(*) into ldcount from dba_cdb_rsrc_plan_directives where upper(plan)=lcdbplan;
			select sum(value) into lcpu from gv$system_parameter where name='cpu_count';
			
	 		lmessage := ' ......  Create Pending Area';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
	 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA(); END;';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA(); END;';
							
			if (lpcount > 0 OR ldcount > 0) then
				for i in (select config_name pdb_profile from antm_config where upper(config_reference) ='PDB_PROFILE' and upper(config_name) != 'DEFAULT' and upper(program_name) = object_name) loop
					delete_rmplan_prc(lcdbplan, i.pdb_profile);
				end loop;
				lmessage := ' ......  Delete Container Plan';
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				lmessage := 'BEGIN DBMS_RESOURCE_MANAGER.DELETE_CDB_PLAN(plan => '''|| lcdbplan ||'''); END;';
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.DELETE_CDB_PLAN(plan => '''|| lcdbplan ||'''); END;';		
			end if;	

	 		lmessage := ' ......  Create Container Plan';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
	 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN(plan => ''ANTM_CDB_PLAN'',comment => ''CDB resource plan for Anthem CDB''); END;';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN(plan => ''ANTM_CDB_PLAN'',comment => ''CDB resource plan for Anthem CDB''); END;';

			for i in (select config_name pdb_profile, to_number(config_value) shares, round(least(to_number(config_value),lcpu) * 100/lcpu) util_limit, round(least(to_number(config_value),lcpu) * 100/lcpu) parallel_limit
									from antm_config where upper(config_reference) ='PDB_PROFILE' and upper(program_name) = object_name) loop
		 		if i.pdb_profile != 'DEFAULT' then 
			 		lmessage := ' ......  Create Container '||i.pdb_profile||' Profile Directive';
					antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.CREATE_CDB_PROFILE_DIRECTIVE(plan => '''|| lcdbplan ||''', profile => '''||i.pdb_profile||''', shares => '||i.shares||', utilization_limit => '||i.util_limit||', parallel_server_limit => '||i.parallel_limit||'); END;';
					antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
					execute immediate ' BEGIN DBMS_RESOURCE_MANAGER.CREATE_CDB_PROFILE_DIRECTIVE(plan => '''|| lcdbplan ||''', profile => '''||i.pdb_profile||''', shares => '||i.shares||', utilization_limit => '||i.util_limit||', parallel_server_limit => '||i.parallel_limit||'); END;';
				else
			 		lmessage := ' ......  Update CDB '||i.pdb_profile||' Profile Directive';
					antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.UPDATE_CDB_DEFAULT_DIRECTIVE(plan => '''|| lcdbplan ||''', new_shares => '||i.shares||', new_utilization_limit => '||i.util_limit||', mew_parallel_server_limit => '||i.parallel_limit||'); END;';
					antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
					execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.UPDATE_CDB_DEFAULT_DIRECTIVE(plan => '''|| lcdbplan ||''', new_shares => '||i.shares||', new_utilization_limit => '||i.util_limit||', new_parallel_server_limit => '||i.parallel_limit||'); END;';

			 		lmessage := ' ......  Update CDB AutoTask Directive';
					antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
					select config_value into lconfig_value from antm_config where upper(config_name) ='CDB_AUTOTASK_DIRECTIVE' and upper(program_name) = object_name and upper(config_reference) = 'STANDARD';
			 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.UPDATE_CDB_AUTOTASK_DIRECTIVE(plan => '''|| lcdbplan ||''', '||lconfig_value||'); END;';
					antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
					execute immediate ' BEGIN DBMS_RESOURCE_MANAGER.UPDATE_CDB_AUTOTASK_DIRECTIVE(plan => '''|| lcdbplan ||''', '||lconfig_value||'); END;';			
				end if;
			end loop;

	 		lmessage := ' ......  Validate Pending Area';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
	 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA(); END;';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA(); END;';
	 		lmessage := ' ......  Submit Pending Area';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
	 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA(); END;';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA(); END;';
			purge_log_prc;
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antm_admin_pkg.write_log_prc('antm_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antm_admin_pkg.write_log_prc('antm_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				commit;					
    end create_rmplan_prc;   

    procedure activate_rmplan_prc as
 			lcdbplan				varchar2(20);
 			lsql						varchar(100);
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP3';
      object_name   	varchar2(100) := 'ANTM_ADMIN_PKG.ACTIVATE_RMPLAN_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			select config_value into lcdbplan 
			from antm_config 
			where upper(config_name) ='CDB_PLAN_NAME'
			  and upper(config_reference) = 'STANDARD';		

			lsql := 'alter system set resource_manager_plan=''FORCE:'|| lcdbplan ||''' scope=both sid=''*''';
      execute immediate lsql;
			lmessage := ' ......  Updated SPfile : '||lsql;
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			dbms_output.put_line(' ');
			lmessage := ' ......  DBA-INFO : Please make sure "db_files" parameter has optimal setting as per overall data volume expectations at CDB (try to be < 5000)';
			dbms_output.put_line(lmessage);
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'DBA-CRITICAL',lmessage);			
  		create_rmplan_prc;
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			lmessage := ' ......  DBA-INFO : Please verify Error Log table (antm_log) for more info.';
			dbms_output.put_line(lmessage);
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'DBA-CRITICAL',lmessage);	
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antm_admin_pkg.write_log_prc('antm_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antm_admin_pkg.write_log_prc('antm_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				commit;					
    end activate_rmplan_prc; 

    procedure delete_rmplan_prc(lcdbplan varchar2,lperf_profile varchar2) as
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP4';
      object_name   	varchar2(100) := 'ANTM_ADMIN_PKG.DELETE_RMPLAN_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			
	 		lmessage := ' ......  Delete Container '||lperf_profile||' Profile Directive ';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
	 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.DELETE_CDB_PROFILE_DIRECTIVE(plan => '''|| lcdbplan ||''', profile => ''' ||lperf_profile||'''); END; ';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.DELETE_CDB_PROFILE_DIRECTIVE(plan => '''|| lcdbplan ||''', profile => ''' ||lperf_profile||'''); END;';
			purge_log_prc;
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antm_admin_pkg.write_log_prc('antm_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antm_admin_pkg.write_log_prc('antm_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				commit;					
    end delete_rmplan_prc; 

    procedure modify_pdbplan_prc(lpdb_name varchar2,lperf_profile varchar2) as
    	cur							number;
    	lcount					number;
    	lsql						varchar2(500);
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP5';
      object_name   	varchar2(100) := 'ANTM_ADMIN_PKG.MODIFY_PDBPLAN_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

	 		lmessage := ' Modifying PDB Resource Plan for PDB : '||lpdb_name ;
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			select count(*) into lcount from antm_config where upper(config_reference)=upper(lperf_profile) and upper(program_name)=object_name;
			if lcount > 0 then 
				cur := dbms_sql.open_cursor;
				lsql := 'alter system set db_performance_profile='||lperf_profile;
				dbms_sql.parse(c => cur,
							 statement => lsql,
							 language_flag => dbms_sql.native,
							 edition => null,
							 container => lpdb_name);
				lcount := dbms_sql.execute(c => cur);
				dbms_sql.close_cursor(c => cur);
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lsql);

		 		lmessage := ' Reset PGA_AGGREGATE_LIMIT and PGA_AGGREGATE_TARGET to 0 in PDB : '||lpdb_name ;
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

				cur := dbms_sql.open_cursor;
				for j in (select 'pga_aggregate_limit' config_name from dual union select 'pga_aggregate_target' config_name from dual) loop
					lsql := 'alter system set '||j.config_name ||' = 0';
					dbms_sql.parse(c => cur,
										 statement => lsql,
										 language_flag => dbms_sql.native,
										 edition => null,
										 container => lpdb_name);
					lcount := dbms_sql.execute(c => cur);	
					antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lsql);
				end loop;
				dbms_sql.close_cursor(c => cur);

				cur := dbms_sql.open_cursor;
				for j in (select config_name, config_value from antm_config where upper(config_reference) = upper(lperf_profile)) loop
					lsql := 'alter system set '||j.config_name ||' = '||j.config_value;
					dbms_sql.parse(c => cur,
										 statement => lsql,
										 language_flag => dbms_sql.native,
										 edition => null,
										 container => lpdb_name);
					lcount := dbms_sql.execute(c => cur);	
					antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lsql);
				end loop;
				dbms_sql.close_cursor(c => cur);
			else
		 		lmessage := ' Profile '||lperf_profile|| ' NOT Found' ;
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);			
			end if;

			dbms_output.put_line(' ');
			lmessage := ' ......  DBA-INFO : Please verify Error Log table (antm_log) for more info.';
			dbms_output.put_line(lmessage);
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'DBA-CRITICAL',lmessage);	

			purge_log_prc;
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
 				if dbms_sql.is_open(cur) then
 					dbms_sql.close_cursor(cur);
 				end if;
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'FATAL',lsql);
        lmessage :=substr(sqlerrm,1,1000);
				antm_admin_pkg.write_log_prc('antm_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antm_admin_pkg.write_log_prc('antm_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				commit;					
    end modify_pdbplan_prc;

    procedure purge_log_prc as
   		ldate						date;
      lmonths         varchar2(30);
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP6';
      object_name   	varchar2(100) := 'ANTM_ADMIN_PKG.PURGE_LOG_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			select config_value into lmonths 
			from antm_config 
			where upper(config_name) ='PURGE_VOLUME_MONTHS'
			  and upper(program_name) = object_name;

			for i in (select partition_name, high_value from user_tab_partitions where table_name='ANTM_LOG' and partition_position > 1) loop
				execute immediate 'select '||i.high_value||' from dual' into ldate;
				if ldate < last_day(add_months(sysdate,-lmonths)+1) then
					execute immediate 'alter table antm_log drop partition '||i.partition_name||' update indexes';
				end if;
			end loop;
			  
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);					
				commit;
    end purge_log_prc;  

    procedure view_rminfo_prc as
    	lcdbplan				varchar2(20);
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP7';
      object_name   	varchar2(100) := 'ANTM_ADMIN_PKG.VIEW_RMINFO_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			
			select config_value into lcdbplan 
			from antm_config 
			where upper(config_name) ='CDB_PLAN_NAME' and
						config_reference = 'STANDARD';

			dbms_output.enable(buffer_size => null);
			dbms_output.put_line(' ');
			dbms_output.put_line('Resource Manager Settings Report');
			dbms_output.put_line('********************************');			
			for i in (select host_name, inst_id, instance_name from gv$instance order by 1) loop
					dbms_output.put_line('Host Name : '||i.host_name||' is running Instance : '||i.inst_id ||' -> ' ||i.instance_name);
			end loop;			

			dbms_output.put_line(' ');
			dbms_output.put_line('PDB Profile - Memory Settings Information ');
			dbms_output.put_line('***************************************** ');
			dbms_output.put_line('|---------|---------------|-------------|-------------|-----------|----------|----------------------|--------------------|');
			dbms_output.put_line('|Inst Id  | PDB Name      | PDB Profile | Shared Pool | DB Cache  | Sessions | PGA Aggregate Target | PGA Aggregate Limit|');
			dbms_output.put_line('|---------|---------------|-------------|-------------|-----------|----------|----------------------|--------------------|');
			
			for i in (select pdb.inst_id, pdb.name pdbname,
							       min (decode(upper(pm.name),'PGA_AGGREGATE_TARGET', pm.display_value, null)) as PGA_AGGREGATE_TARGET,
							       min (decode(upper(pm.name),'PGA_AGGREGATE_LIMIT', pm.display_value, null)) as  PGA_AGGREGATE_LIMIT,
							       min (decode(upper(pm.name),'SHARED_POOL_SIZE', pm.display_value, null)) as  SHARED_POOL_SIZE,
							       min (decode(upper(pm.name),'DB_CACHE_SIZE', pm.display_value, null)) as  DB_CACHE_SIZE,
							       min (decode(upper(pm.name),'SESSIONS', pm.display_value, null)) as  SESSIONS,
							       min (decode(upper(pm.name),'DB_PERFORMANCE_PROFILE', pm.display_value, null)) as  DB_PERFORMANCE_PROFILE
								from 	 gv$pdbs pdb, gv$system_parameter pm
								where  pdb.inst_id = pm.inst_id and
											 pdb.con_id  = pm.con_id and
											 upper(pm.name) IN ('PGA_AGGREGATE_TARGET',
											                  'PGA_AGGREGATE_LIMIT',
											                  'SHARED_POOL_SIZE',
											                  'DB_CACHE_SIZE',
											                  'SESSIONS',
											                   'DB_PERFORMANCE_PROFILE') and
											 pdb.con_id > 2
								group by pdb.inst_id, pdb.name) loop
				dbms_output.put_line(rpad('|    '||i.inst_id,9) ||' | '|| rpad(i.pdbname,13) ||' | '|| rpad(i.db_performance_profile,11) ||' | '|| rpad('    '||i.shared_pool_size,11) ||' | '|| rpad('  '||i.db_cache_size,9) ||' | '|| rpad('  '||i.sessions,8) ||' | '|| rpad('        '||i.pga_aggregate_target,20) ||' | '|| rpad('        '||i.pga_aggregate_limit,19)||'|');
			end loop;
			dbms_output.put_line('|---------|---------------|-------------|-------------|-----------|----------|----------------------|--------------------|');

			dbms_output.put_line(' ');
			dbms_output.put_line('CDB - Resource Plan Directives Information ');
			dbms_output.put_line('****************************************** ');
			dbms_output.put_line('|------------|---------|-------------|------------------|');
			dbms_output.put_line('|PDB Profile | Shares  | Util Limit  | Par Server Limit |');
			dbms_output.put_line('|------------|---------|-------------|------------------|');
			for i in (select distinct profile, shares, utilization_limit, parallel_server_limit from dba_cdb_rsrc_plan_directives where  plan = lcdbplan and	profile is not null order by 2) loop
					dbms_output.put_line('| '||rpad(i.profile,10)||' | '||rpad('    '||i.shares,7) ||' | '|| rpad('     '||i.utilization_limit,11) ||' | '|| rpad('       '||i.parallel_server_limit,17)||'|');
			end loop;
			dbms_output.put_line('|------------|---------|-------------|------------------|');

			dbms_output.put_line(' ');
			dbms_output.put_line('PDB Distribution Information ');
			dbms_output.put_line('**************************** ');
			dbms_output.put_line('|------------|-------|');
			dbms_output.put_line('|PDB Profile | Count |');
			dbms_output.put_line('|------------|-------|');
			for i in (select min (decode(upper(pm.name),'DB_PERFORMANCE_PROFILE', pm.display_value, null)) pdb_profile, count(*) pdbs 
								from gv$system_parameter pm
								where (decode(upper(pm.name),'DB_PERFORMANCE_PROFILE', pm.display_value, null)) is not null
								group by (decode(upper(pm.name),'DB_PERFORMANCE_PROFILE', pm.display_value, null))			
								order by 1) loop
					dbms_output.put_line('| '||rpad(i.pdb_profile,10)||' | '||rpad('  '||i.pdbs,5) ||' | ');
			end loop;
			dbms_output.put_line('|------------|-------|');

			dbms_output.put_line(' ');
			dbms_output.put_line('Current Resource Snapshot Based on 60-day History ');
			dbms_output.put_line('************************************************* ');
			dbms_output.put_line('|------------------|---------------|');
			dbms_output.put_line('|     Resources    |    Metrics    |');
			dbms_output.put_line('|------------------|---------------|');
			for i in (select 	min(avg_cpu_util) mincpu_util,	max(avg_cpu_util) maxcpu_util,
												min(cpu_used_time) mincpu_used,	max(cpu_used_time) maxcpu_used,
												min(cpu_wait_time) mincpu_wait,	max(cpu_wait_time) maxcpu_wait,
												min(sga_mbytes) minsga,	max(sga_mbytes) maxsga,
												min(avg_run_ses) minses_run, max(avg_run_ses) maxses_run,
												min(avg_wait_ses) minses_wait, max(avg_wait_ses) maxses_wait 
								from (select round(met.sga_bytes/1048576) sga_mbytes, round(met.avg_cpu_utilization,2) avg_cpu_util, round(met.cpu_consumed_time,2) cpu_used_time,
															round(met.cpu_wait_time,2) cpu_wait_time, round(met.avg_running_sessions,2) avg_run_ses, round(met.avg_waiting_sessions,2) avg_wait_ses
											from gv$pdbs pdb, dba_hist_rsrc_pdb_metric  met 
											where  	pdb.con_id = met.con_id and 
															pdb.inst_id = met.instance_number and
															sysdate - cast(begin_time as date) < 61)) loop
					dbms_output.put_line('| Min CPU Utilized |'||rpad('     '||i.mincpu_util,13) ||'  | ');
					dbms_output.put_line('| Max CPU Utilized |'||rpad('     '||i.maxcpu_util,13) ||'  | ');
					dbms_output.put_line('| Min CPU Used(ms) |'||rpad('     '||i.mincpu_used,13) ||'  | ');
					dbms_output.put_line('| Max CPU Used(ms) |'||rpad('     '||i.maxcpu_used,13) ||'  | ');
					dbms_output.put_line('| Min CPU Wait(ms) |'||rpad('     '||i.mincpu_wait,13) ||'  | ');
					dbms_output.put_line('| Max CPU Wait(ms) |'||rpad('     '||i.maxcpu_wait,13) ||'  | ');
					dbms_output.put_line('|     Min SGA      |'||rpad('     '||i.minsga,13) ||'  | ');
					dbms_output.put_line('|     Max SGA      |'||rpad('     '||i.maxsga,13) ||'  | ');
					dbms_output.put_line('|   Min Sessions   |'||rpad('     '||i.minses_run,13) ||'  | ');
					dbms_output.put_line('|   Max Sessions   |'||rpad('     '||i.maxses_run,13) ||'  | ');
					dbms_output.put_line('| Min Ses Wait(ms) |'||rpad('     '||i.minses_wait,13) ||'  | ');
					dbms_output.put_line('| Max Ses Wait(ms) |'||rpad('     '||i.maxses_wait,13) ||'  | ');
			end loop;
			dbms_output.put_line('|------------------|---------------|');
			purge_log_prc;
			
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);					
				commit;
    end view_rminfo_prc; 

    procedure view_capacity_prc(ldays number) as
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP8';
      object_name   	varchar2(100) := 'ANTM_ADMIN_PKG.VIEW_CAPACITY_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			
			dbms_output.put_line(' ');
			dbms_output.put_line('Memory Capacity Snapshot Based on ' ||ldays||' day History ');
			dbms_output.put_line(' ');
			dbms_output.put_line('Shared Pool Information');
			dbms_output.put_line('|-------------------------------------------|-----------------|');
			dbms_output.put_line('|      Shared Pool Stats                    |  Values in MB   |');
			dbms_output.put_line('|-------------------------------------------|-----------------|');
			for i in ( select sp_allocated, sp_consumed from 
									(select round(sum(VALUE)/1024/1024,0) sp_allocated from gv$system_parameter where upper(name) like 'SHARED_POOL_SIZE%' and con_id=0 ) a,
									(select round(sum(VALUE)/1024/1024,0) sp_consumed from gv$system_parameter where upper(name) like 'SHARED_POOL_SIZE%' and con_id > 2 ) b) loop
					dbms_output.put_line('| Shared Pool CDB level Allocation          |'||rpad('     '||i.sp_allocated,15) ||'  | ');
					dbms_output.put_line('| Shared Pool PDB level Aggregate           |'||rpad('     '||i.sp_consumed,15) ||'  | ');
					if ((i.sp_allocated / 2) > i.sp_consumed)  then
						dbms_output.put_line('| New PDBs / Profile Upgrades Allowed       |'||rpad('     '||((i.sp_allocated/2) - i.sp_consumed),15) ||'  | ');
					elsif (i.sp_consumed > i.sp_allocated) then
						dbms_output.put_line('| Alert! Exceeded Oracle Threshold          |'||rpad('     '||(i.sp_consumed - i.sp_allocated) ,15) ||'  | ');
					elsif ((i.sp_consumed > i.sp_allocated / 2) and (i.sp_consumed < i.sp_allocated)) then
						dbms_output.put_line('| Critical Alert! Exceeded Oracle Threshold |'||rpad('     '||(i.sp_consumed - (i.sp_allocated/2)) ,15) ||'  | ');
					end if;						
			end loop;
			dbms_output.put_line('|-------------------------------------------|-----------------|');
			lmessage := ' ......  DBA-INFO : Sum of SHARED_POOL_SIZE across all PDBs in a CDB must be less than or equal to 50% of the SHARED_POOL_SIZE at CDB Level.';
			dbms_output.put_line(lmessage);
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'DBA-CRITICAL',lmessage);	

			dbms_output.put_line(' ');
			dbms_output.put_line('Buffer Cache Information');
			dbms_output.put_line('|-------------------------------------------|-----------------|');
			dbms_output.put_line('|      Buffer Cache Stats                   |  Values in MB   |');
			dbms_output.put_line('|-------------------------------------------|-----------------|');
			for i in ( select bc_allocated, bc_consumed from 
									(select round(sum(VALUE)/1024/1024,0) bc_allocated from gv$system_parameter where upper(name) like 'DB_CACHE_SIZE%' and con_id=0 ) a,
									(select round(sum(VALUE)/1024/1024,0) bc_consumed from gv$system_parameter where upper(name) like 'DB_CACHE_SIZE%' and con_id > 2 ) b) loop
					dbms_output.put_line('| Buffer Cache CDB level Allocation         |'||rpad('     '||i.bc_allocated,15) ||'  | ');
					dbms_output.put_line('| Buffer Cache PDB level Aggregate          |'||rpad('     '||i.bc_consumed,15) ||'  | ');
					if ((i.bc_allocated / 2) > i.bc_consumed)  then
						dbms_output.put_line('| New PDBs / Profile Upgrades Allowed       |'||rpad('     '||((i.bc_allocated/2) - i.bc_consumed),15) ||'  | ');
					elsif (i.bc_consumed > i.bc_allocated) then
						dbms_output.put_line('| Alert! Exceeded Oracle Threshold          |'||rpad('     '||(i.bc_consumed - i.bc_allocated) ,15) ||'  | ');
					elsif ((i.bc_consumed > i.bc_allocated / 2) and (i.bc_consumed < i.bc_allocated)) then
						dbms_output.put_line('| Critical Alert! Exceeded Oracle Threshold |'||rpad('     '||(i.bc_consumed - (i.bc_allocated/2)) ,15) ||'  | ');
					end if;						
			end loop;
			dbms_output.put_line('|-------------------------------------------|-----------------|');
			lmessage := ' ......  DBA-INFO : Sum of DB_CACHE_SIZE across all PDBs in a CDB must be less than or equal to 50% of the DB_CACHE_SIZE at CDB Level.';
			dbms_output.put_line(lmessage);
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'DBA-CRITICAL',lmessage);	
			dbms_output.put_line(' ');
			dbms_output.put_line('Library Cache Hourly Hit Ratio');
			dbms_output.put_line('|-----------------------|----------|-----------|');
			dbms_output.put_line('| Date (dd-mon-yy:hh24) | Instance | Hit Raito |');
			dbms_output.put_line('|-----------------------|----------|-----------|');
			for i in ( select to_char(begin_time,'dd-mon-yy:hh24') begin_time, instance_number, round(avg(AVERAGE),2) hourly_avg
									from dba_hist_sysmetric_summary  
									where metric_id=2112  and
												sysdate - cast(begin_time as date) < ldays
									group by to_char(begin_time,'dd-mon-yy:hh24'), instance_number
									order by 1) loop
					dbms_output.put_line('|'||rpad('      '||i.begin_time,23) ||'|'
															||rpad('     '||i.instance_number,10) ||'|'||rpad('   '||i.hourly_avg,11) ||'|');
			end loop;
			dbms_output.put_line('|-----------------------|----------|-----------|');
			dbms_output.put_line(' ');
			dbms_output.put_line('Buffer Cache Hourly Hit Ratio');
			dbms_output.put_line('|-----------------------|----------|-----------|');
			dbms_output.put_line('| Date (dd-mon-yy:hh24) | Instance | Hit Raito |');
			dbms_output.put_line('|-----------------------|----------|-----------|');
			for i in ( select to_char(begin_time,'dd-mon-yy:hh24') begin_time, instance_number, round(avg(AVERAGE),2) hourly_avg
									from dba_hist_sysmetric_summary  
									where metric_id=2000  and
												sysdate - cast(begin_time as date) < ldays
									group by to_char(begin_time,'dd-mon-yy:hh24'), instance_number
									order by 1) loop
					dbms_output.put_line('|'||rpad('      '||i.begin_time,23) ||'|'
															||rpad('     '||i.instance_number,10) ||'|'||rpad('   '||i.hourly_avg,11) ||'|');
			end loop;
			dbms_output.put_line('|-----------------------|----------|-----------|');
			dbms_output.put_line(' ');
			lmessage := ' ......  DBA-INFO : Before onboarding PDBs, please review CDB Resource (CPU, DB_FILEs, Processes) Metrics in OEM/IT-Analytics, to make sure CDB Density is appropriate.';
			dbms_output.put_line(lmessage);
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'DBA-CRITICAL',lmessage);	

			purge_log_prc;
			
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);					
				commit;
    end view_capacity_prc; 

    procedure report_minute_rminfo_prc as
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP9';
      object_name   	varchar2(100) := 'ANTM_ADMIN_PKG.REPORT_MINUTE_RMINFO_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			dbms_output.enable(buffer_size => null);
			dbms_output.put_line(' ');
			dbms_output.put_line('Resource Manager Utilization Report');
			dbms_output.put_line('***********************************');			
			for i in (select host_name, inst_id, instance_name from gv$instance order by 1) loop
					dbms_output.put_line('Host Name : '||i.host_name||' is running Instance : '||i.inst_id ||' -> ' ||i.instance_name);
			end loop;			

			dbms_output.put_line(' ');
			dbms_output.put_line('CPU Consumption Time(ms) in terms of Utilization Information ');
			dbms_output.put_line('************************************************************ ');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|--------------|-------------------|---------------|------|');
			dbms_output.put_line('|Inst Id  | Begin Time            | End Time              | PDB Name      | CPU Util Limit | Avg CPU Util | CPU Consumed Time | CPU Wait Time | CPU# |');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|--------------|-------------------|---------------|------|');
			for i in (select pdb.inst_id, to_char(begin_time,'dd-mon-yyyy hh24:mi:ss') bt, to_char(end_time,'dd-mon-yyyy hh24:mi:ss') et, pdb.name, round(met.cpu_utilization_limit,2) cpu_util_lim, round(met.avg_cpu_utilization,2) avg_cpu_util, round(met.cpu_consumed_time,2) cpu_used_time, round(met.cpu_wait_time,2) cpu_wait_time, round(met.num_cpus,2) cpus
										from gv$pdbs pdb, gv$rsrcpdbmetric met where  pdb.con_id = met.con_id and pdb.inst_id = met.inst_id and pdb.con_id > 2 order by 1,2) loop
					dbms_output.put_line(rpad('|    '||i.inst_id,9)||' | '|| rpad(i.bt,21) ||' | '|| rpad(i.et,21) ||' | '|| rpad(i.name,13) ||' | '|| rpad('     '||i.cpu_util_lim,14) ||' | '|| rpad('     '||i.avg_cpu_util,13)||'|'|| rpad('        '||i.cpu_used_time,19)||'|'|| rpad('       '||i.cpu_wait_time,15)||'|'|| rpad('  '||i.cpus,6)||'|');
			end loop;
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|--------------|-------------------|---------------|------|');

			dbms_output.put_line(' ');
			dbms_output.put_line('Parallel Execution for PDBs Information ');
			dbms_output.put_line('*************************************** ');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|---------------------|----------------|----------------------|-----------------|');
			dbms_output.put_line('|Inst Id  | Begin Time            | End Time              | PDB Name      | Par Svrs Limit | Avg Active Par Svrs | Avg Q Par Svrs | Avg Active Par Stmts | Avg Q Par Stmts |');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|---------------------|----------------|----------------------|-----------------|');
			for i in (select pdb.inst_id, to_char(begin_time,'dd-mon-yyyy hh24:mi:ss') bt, to_char(end_time,'dd-mon-yyyy hh24:mi:ss') et, pdb.name, round(met.parallel_servers_limit,2) par_svr_lim, round(met.avg_active_parallel_servers,2) avg_par_svr, round(met.avg_queued_parallel_servers,2) avg_qpar_svr, round(met.avg_active_parallel_stmts,2) avg_apar_stmt, round(met.avg_queued_parallel_stmts,2) avg_qpar_stmt 
										from gv$pdbs pdb, gv$rsrcpdbmetric met where  pdb.con_id = met.con_id and pdb.inst_id = met.inst_id and pdb.con_id > 2 order by 1,2) loop
					dbms_output.put_line(rpad('|    '||i.inst_id,9)||' | '|| rpad(i.bt,21) ||' | '|| rpad(i.et,21) ||' | '||rpad(i.name,13) ||' | '|| rpad('     '||i.par_svr_lim,14) ||' | '|| rpad('         '||i.avg_par_svr,20)||'|'|| rpad('        '||i.avg_qpar_svr,16)||'|'|| rpad('            '||i.avg_apar_stmt,22)||'|'|| rpad('        '||i.avg_qpar_stmt,17)||'|');
			end loop;
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|---------------------|----------------|----------------------|-----------------|');

			dbms_output.put_line(' ');
			dbms_output.put_line('Sessions for PDBs Information ');
			dbms_output.put_line('***************************** ');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|------------------|------------------|');
			dbms_output.put_line('|Inst Id  | Begin Time            | End Time              | PDB Name      | Sessions Limit | Avg Running Sess | Avg Waiting Sess |');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|------------------|------------------|');
			for i in (select pdb.inst_id, to_char(begin_time,'dd-mon-yyyy hh24:mi:ss') bt, to_char(end_time,'dd-mon-yyyy hh24:mi:ss') et, pdb.name, round(met.running_sessions_limit,2) run_ses_lim, round(met.avg_running_sessions,2) avg_run_ses, round(met.avg_waiting_sessions,2) avg_wait_ses
										from gv$pdbs pdb, gv$rsrcpdbmetric met where  pdb.con_id = met.con_id and pdb.inst_id = met.inst_id and pdb.con_id > 2 order by 1,2) loop
					dbms_output.put_line(rpad('|    '||i.inst_id,9)||' | '|| rpad(i.bt,21) ||' | '|| rpad(i.et,21) ||' | '||rpad(i.name,13) ||' | '|| rpad('     '||i.run_ses_lim,14) ||' | '|| rpad('         '||i.avg_run_ses,17)||'|'|| rpad('         '||i.avg_wait_ses,18)||'|');
			end loop;
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|------------------|------------------|');

			dbms_output.put_line(' ');
			dbms_output.put_line('Memory Usage for PDBs Information ');
			dbms_output.put_line('********************************* ');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|------------|--------------------|---------------------|------------|');
			dbms_output.put_line('|Inst Id  | Begin Time            | End Time              | PDB Name      | SGA MBytes | Shared Pool MBytes | Buffer Cache MBytes | PGA MBytes |');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|------------|--------------------|---------------------|------------|');
			for i in (select pdb.inst_id, to_char(begin_time,'dd-mon-yyyy hh24:mi:ss') bt, to_char(end_time,'dd-mon-yyyy hh24:mi:ss') et, pdb.name, round(met.sga_bytes/1048576) sga_mbytes, round(met.shared_pool_bytes/1048576) shared_pool_mbytes, round(met.buffer_cache_bytes/1048576) buffer_cache_mbytes, round(met.pga_bytes/1048576) pga_mbytes 
										from gv$pdbs pdb, gv$rsrcpdbmetric met where  pdb.con_id = met.con_id and pdb.inst_id = met.inst_id and pdb.con_id > 2 order by 1,2) loop
					dbms_output.put_line(rpad('|    '||i.inst_id,9)||' | '|| rpad(i.bt,21) ||' | '|| rpad(i.et,21) ||' | '||rpad(i.name,13) ||' | '|| rpad('     '||i.sga_mbytes,10) ||' | '|| rpad('         '||i.shared_pool_mbytes,19)||'|'|| rpad('        '||i.buffer_cache_mbytes,21)||'|'|| rpad('      '||i.pga_mbytes,12)||'|');
			end loop;
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|------------|--------------------|---------------------|------------|');

			dbms_output.put_line(' ');
			dbms_output.put_line('IO Usage for PDBs Information ');
			dbms_output.put_line('***************************** ');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------|------------|-------------|----------------|-----------|');
			dbms_output.put_line('|Inst Id  | Begin Time            | End Time              | PDB Name      |   IOPs   |  IO MBPs   | IOPs Exempt | IO MBPs Exempt | Avg IO    |');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------|------------|-------------|----------------|-----------|');
			for i in (select pdb.inst_id, to_char(begin_time,'dd-mon-yyyy hh24:mi:ss') bt, to_char(end_time,'dd-mon-yyyy hh24:mi:ss') et, pdb.name, round(met.iops,2) iops, round(met.iombps,2) iombps, round(met.iops_throttle_exempt,2) iopse, round(met.iombps_throttle_exempt,2) iombpse, round(met.avg_io_throttle,2) avg_io 
										from gv$pdbs pdb, gv$rsrcpdbmetric met where  pdb.con_id = met.con_id and pdb.inst_id = met.inst_id and pdb.con_id > 2 order by 1,2) loop
					dbms_output.put_line(rpad('|    '||i.inst_id,9)||' | '|| rpad(i.bt,21) ||' | '|| rpad(i.et,21) ||' | '||rpad(i.name,13) ||' | '|| rpad('   '||i.iops,8) ||' | '|| rpad('     '||i.iombps,11)||'|'|| rpad('      '||i.iopse,13)||'|'|| rpad('      '||i.iombpse,16)||'|'|| rpad('     '||i.avg_io,11)||'|');
			end loop;
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------|------------|-------------|----------------|-----------|');
			purge_log_prc;
		  
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);					
				commit;
    end report_minute_rminfo_prc;

    procedure report_hour_rminfo_prc(lpdb_name varchar2) as
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP10';
      object_name   	varchar2(100) := 'ANTM_ADMIN_PKG.REPORT_HOUR_RMINFO_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			dbms_output.enable(buffer_size => null);
			dbms_output.put_line(' ');
			dbms_output.put_line('last Hour Sample of Resource Manager Utilization Report for PDB : '||lpdb_name);
			dbms_output.put_line('***************************************************************** ');			
			for i in (select host_name, inst_id, instance_name from gv$instance order by 1) loop
					dbms_output.put_line('Host Name : '||i.host_name||' is running Instance : '||i.inst_id ||' -> ' ||i.instance_name);
			end loop;			

			dbms_output.put_line(' ');
			dbms_output.put_line('CPU Consumption Time(ms) in terms of Utilization Information ');
			dbms_output.put_line('************************************************************ ');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|--------------|-------------------|---------------|------|');
			dbms_output.put_line('|Inst Id  | Begin Time            | End Time              | PDB Name      | CPU Util Limit | Avg CPU Util | CPU Consumed Time | CPU Wait Time | CPU# |');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|--------------|-------------------|---------------|------|');
			for i in (select pdb.inst_id, to_char(begin_time,'dd-mon-yyyy hh24:mi:ss') bt, to_char(end_time,'dd-mon-yyyy hh24:mi:ss') et, pdb.name, round(met.cpu_utilization_limit,2) cpu_util_lim, round(met.avg_cpu_utilization,2) avg_cpu_util, round(met.cpu_consumed_time,2) cpu_used_time, round(met.cpu_wait_time,2) cpu_wait_time, round(met.num_cpus,2) cpus
										from gv$pdbs pdb, gv$rsrcpdbmetric_history met where  pdb.con_id = met.con_id and pdb.inst_id = met.inst_id and pdb.name = upper(lpdb_name) order by 1,2) loop
					dbms_output.put_line(rpad('|    '||i.inst_id,9)||' | '|| rpad(i.bt,21) ||' | '|| rpad(i.et,21) ||' | '|| rpad(i.name,13) ||' | '|| rpad('     '||i.cpu_util_lim,14) ||' | '|| rpad('     '||i.avg_cpu_util,13)||'|'|| rpad('        '||i.cpu_used_time,19)||'|'|| rpad('       '||i.cpu_wait_time,15)||'|'|| rpad('  '||i.cpus,6)||'|');
			end loop;
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|--------------|-------------------|---------------|------|');

			dbms_output.put_line(' ');
			dbms_output.put_line('Parallel Execution for PDBs Information ');
			dbms_output.put_line('*************************************** ');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|---------------------|----------------|----------------------|-----------------|');
			dbms_output.put_line('|Inst Id  | Begin Time            | End Time              | PDB Name      | Par Svrs Limit | Avg Active Par Svrs | Avg Q Par Svrs | Avg Active Par Stmts | Avg Q Par Stmts |');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|---------------------|----------------|----------------------|-----------------|');
			for i in (select pdb.inst_id, to_char(begin_time,'dd-mon-yyyy hh24:mi:ss') bt, to_char(end_time,'dd-mon-yyyy hh24:mi:ss') et, pdb.name, round(met.parallel_servers_limit,2) par_svr_lim, round(met.avg_active_parallel_servers,2) avg_par_svr, round(met.avg_queued_parallel_servers,2) avg_qpar_svr, round(met.avg_active_parallel_stmts,2) avg_apar_stmt, round(met.avg_queued_parallel_stmts,2) avg_qpar_stmt 
										from gv$pdbs pdb, gv$rsrcpdbmetric_history met where  pdb.con_id = met.con_id and pdb.inst_id = met.inst_id and pdb.name = upper(lpdb_name) order by 1,2) loop
					dbms_output.put_line(rpad('|    '||i.inst_id,9)||' | '|| rpad(i.bt,21) ||' | '|| rpad(i.et,21) ||' | '||rpad(i.name,13) ||' | '|| rpad('     '||i.par_svr_lim,14) ||' | '|| rpad('         '||i.avg_par_svr,20)||'|'|| rpad('        '||i.avg_qpar_svr,16)||'|'|| rpad('            '||i.avg_apar_stmt,22)||'|'|| rpad('        '||i.avg_qpar_stmt,17)||'|');
			end loop;
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|---------------------|----------------|----------------------|-----------------|');

			dbms_output.put_line(' ');
			dbms_output.put_line('Sessions for PDBs Information ');
			dbms_output.put_line('***************************** ');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|------------------|------------------|');
			dbms_output.put_line('|Inst Id  | Begin Time            | End Time              | PDB Name      | Sessions Limit | Avg Running Sess | Avg Waiting Sess |');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|------------------|------------------|');
			for i in (select pdb.inst_id, to_char(begin_time,'dd-mon-yyyy hh24:mi:ss') bt, to_char(end_time,'dd-mon-yyyy hh24:mi:ss') et, pdb.name, round(met.running_sessions_limit,2) run_ses_lim, round(met.avg_running_sessions,2) avg_run_ses, round(met.avg_waiting_sessions,2) avg_wait_ses
										from gv$pdbs pdb, gv$rsrcpdbmetric_history met where  pdb.con_id = met.con_id and pdb.inst_id = met.inst_id and pdb.name = upper(lpdb_name) order by 1,2) loop
					dbms_output.put_line(rpad('|    '||i.inst_id,9)||' | '|| rpad(i.bt,21) ||' | '|| rpad(i.et,21) ||' | '||rpad(i.name,13) ||' | '|| rpad('     '||i.run_ses_lim,14) ||' | '|| rpad('         '||i.avg_run_ses,17)||'|'|| rpad('         '||i.avg_wait_ses,18)||'|');
			end loop;
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|----------------|------------------|------------------|');

			dbms_output.put_line(' ');
			dbms_output.put_line('Memory Usage for PDBs Information ');
			dbms_output.put_line('********************************* ');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|------------|--------------------|---------------------|------------|');
			dbms_output.put_line('|Inst Id  | Begin Time            | End Time              | PDB Name      | SGA MBytes | Shared Pool MBytes | Buffer Cache MBytes | PGA MBytes |');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|------------|--------------------|---------------------|------------|');
			for i in (select pdb.inst_id, to_char(begin_time,'dd-mon-yyyy hh24:mi:ss') bt, to_char(end_time,'dd-mon-yyyy hh24:mi:ss') et, pdb.name, round(met.sga_bytes/1048576) sga_mbytes, round(met.shared_pool_bytes/1048576) shared_pool_mbytes, round(met.buffer_cache_bytes/1048576) buffer_cache_mbytes, round(met.pga_bytes/1048576) pga_mbytes 
										from gv$pdbs pdb, gv$rsrcpdbmetric_history met where  pdb.con_id = met.con_id and pdb.inst_id = met.inst_id and pdb.name = upper(lpdb_name) order by 1,2) loop
					dbms_output.put_line(rpad('|    '||i.inst_id,9)||' | '|| rpad(i.bt,21) ||' | '|| rpad(i.et,21) ||' | '||rpad(i.name,13) ||' | '|| rpad('     '||i.sga_mbytes,10) ||' | '|| rpad('         '||i.shared_pool_mbytes,19)||'|'|| rpad('        '||i.buffer_cache_mbytes,21)||'|'|| rpad('      '||i.pga_mbytes,12)||'|');
			end loop;
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|------------|--------------------|---------------------|------------|');

			dbms_output.put_line(' ');
			dbms_output.put_line('IO Usage for PDBs Information ');
			dbms_output.put_line('***************************** ');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|-------------|------------|-------------|----------------|-----------|');
			dbms_output.put_line('|Inst Id  | Begin Time            | End Time              | PDB Name      |    IOPs     |  IO MBPs   | IOPs Exempt | IO MBPs Exempt | Avg IO    |');
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|-------------|------------|-------------|----------------|-----------|');
			for i in (select pdb.inst_id, to_char(begin_time,'dd-mon-yyyy hh24:mi:ss') bt, to_char(end_time,'dd-mon-yyyy hh24:mi:ss') et, pdb.name, round(met.iops,2) iops, round(met.iombps,2) iombps, round(met.iops_throttle_exempt,2) iopse, round(met.iombps_throttle_exempt,2) iombpse, round(met.avg_io_throttle,2) avg_io 
										from gv$pdbs pdb, gv$rsrcpdbmetric_history met where  pdb.con_id = met.con_id and pdb.inst_id = met.inst_id and pdb.name = upper(lpdb_name) order by 1,2) loop
					dbms_output.put_line(rpad('|    '||i.inst_id,9)||' | '|| rpad(i.bt,21) ||' | '|| rpad(i.et,21) ||' | '||rpad(i.name,13) ||' | '|| rpad('   '||i.iops,11) ||' | '|| rpad('   '||i.iombps,11)||'|'|| rpad('     '||i.iopse,13)||'|'|| rpad('      '||i.iombpse,16)||'|'|| rpad('   '||i.avg_io,11)||'|');
			end loop;
			dbms_output.put_line('|---------|-----------------------|-----------------------|---------------|-------------|------------|-------------|----------------|-----------|');
			purge_log_prc;
		  
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);					
				commit;
    end report_hour_rminfo_prc;

    procedure report_history_rminfo_prc(lpdb_name varchar2) as
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP11';
      object_name   	varchar2(100) := 'ANTM_ADMIN_PKG.REPORT_HISTORY_RMINFO_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			dbms_output.enable(buffer_size => null);
			dbms_output.put_line(' ');
			dbms_output.put_line('Historical AWR Resource Manager Utilization Report for PDB : '||lpdb_name);
			dbms_output.put_line('************************************************************ ');			
			for i in (select host_name, inst_id, instance_name from gv$instance order by 1) loop
					dbms_output.put_line('Host Name : '||i.host_name||' is running Instance : '||i.inst_id ||' -> ' ||i.instance_name);
			end loop;			

			dbms_output.put_line(' ');
			dbms_output.put_line('|---------|-----------------------|-----------------------|--------------|----------------|---------------|----------|---------------|------------------|----------------|-------------------|-----------------|------------|-----------|-----------|------------|');
			dbms_output.put_line('|Inst Id  | Begin Time            | End Time              | Avg CPU Util | CPU Time(ms)   | CPU Wait Time | Avg Sess | Avg Wait Sess | Avg Act Par Svrs | Avg Q Par Svrs | Avg Act Par Stmts | Avg Q Par Stmts | SGA MBytes | SP MBytes | BC MBytes | PGA MBytes |');
			dbms_output.put_line('|---------|-----------------------|-----------------------|--------------|----------------|---------------|----------|---------------|------------------|----------------|-------------------|-----------------|------------|-----------|-----------|------------|');
			for i in (select pdb.inst_id, to_char(begin_time,'dd-mon-yyyy hh24:mi:ss') bt, to_char(end_time,'dd-mon-yyyy hh24:mi:ss') et, round(met.avg_cpu_utilization,2) avg_cpu_util, round(met.cpu_consumed_time,2) cpu_used_time, round(met.cpu_wait_time,2) cpu_wait_time, 
						round(met.avg_running_sessions,2) avg_run_ses, round(met.avg_waiting_sessions,2) avg_wait_ses, round(met.avg_active_parallel_servers,2) avg_par_svr, round(met.avg_queued_parallel_servers,2) avg_qpar_svr,
						round(met.avg_active_parallel_stmts,2) avg_apar_stmt, round(met.avg_queued_parallel_stmts,2) avg_qpar_stmt,
						round(met.sga_bytes/1048576) sga_mbytes, round(met.shared_pool_bytes/1048576) shared_pool_mbytes, round(met.buffer_cache_bytes/1048576) buffer_cache_mbytes, round(met.pga_bytes/1048576) pga_mbytes
										from gv$pdbs pdb, dba_hist_rsrc_pdb_metric  met where  pdb.con_id = met.con_id and pdb.inst_id = met.instance_number and pdb.name = upper(lpdb_name) order by 1,2) loop
					dbms_output.put_line(rpad('|    '||i.inst_id,9)||' | '|| rpad(i.bt,21) ||' | '|| rpad(i.et,21) ||' | '|| rpad('      '||i.avg_cpu_util,13)||'|'|| rpad('     '||i.cpu_used_time,16)||'|'|| rpad('       '||i.cpu_wait_time,15)||'|'
					|| rpad('    '||i.avg_run_ses,10)||'|'|| rpad('       '||i.avg_wait_ses,15)||'|'|| rpad('         '||i.avg_par_svr,18)||'|'|| rpad('        '||i.avg_qpar_svr,16)||'|'
					|| rpad('        '||i.avg_apar_stmt,19)||'|'|| rpad('        '||i.avg_qpar_stmt,17)||'|'
					|| rpad('     '||i.sga_mbytes,11) ||' | '|| rpad('   '||i.shared_pool_mbytes,10)||'|'|| rpad('   '||i.buffer_cache_mbytes,11)||'|'|| rpad('      '||i.pga_mbytes,12)||'|');
			end loop;
			dbms_output.put_line('|---------|-----------------------|-----------------------|--------------|----------------|---------------|----------|---------------|------------------|----------------|-------------------|-----------------|------------|-----------|-----------|------------|');
			purge_log_prc;

			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antm_admin_pkg.write_log_prc('ANTM_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);					
				commit;
    end report_history_rminfo_prc;

end antm_admin_pkg;
/

-- End of DDL Script for Package antm_ADMIN.antm_ADMIN_PKG
