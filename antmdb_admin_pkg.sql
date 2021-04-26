-- Logging Table

/*
grant administer resource manager to system;
grant select on dba_cdb_rsrc_plans to system;
grant select on dba_cdb_rsrc_plan_directives to system;
grant select on gv_$parameter to system;

drop table antmdb_log purge;

create table antmdb_log (
	log_id					number generated by default on null as identity,
	program_name		varchar2(100),
	log_severity		varchar2(15),
	log_date				date default sysdate,
	log_message			varchar2(1000))
partition by range (log_date)
	interval(numtoyminterval(1,'month'))
(partition apds_log_seed values less than (to_date('01-01-2019','dd-mm-yyyy'))
)
tablespace users;


*/

-- Start of DDL Script for Package antmdb_ADMIN.antmdb_ADMIN_PKG

CREATE OR REPLACE PACKAGE antmdb_admin_pkg as
		procedure write_log_prc(lcall_program varchar2,lerror_severity varchar2,lmessage varchar2);
    procedure delete_rm_plan_prc(lprofile varchar2);
    procedure create_rm_plan_prc(lprofile varchar2,lshares number,lutil_limit number,lparallel_limit number);
    procedure main_prc;
end antmdb_admin_pkg;
/

CREATE OR REPLACE PACKAGE BODY antmdb_admin_pkg as

		procedure write_log_prc(lcall_program varchar2,lerror_severity varchar2,lmessage varchar2) is
			PRAGMA	AUTONOMOUS_TRANSACTION;
			object_code	varchar2(10) 	:= 'ADMP1';
			object_name	varchar2(100)	:= 'ANTMDB_ADMIN_PKG.WRITE_LOG_PRC';
		begin
			insert into antmdb_log values(null,lcall_program||'->'||object_name,lerror_severity,sysdate,lmessage);
			commit;
		end write_log_prc;

    procedure delete_rm_plan_prc(lprofile varchar2) as
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP2';
      object_name   	varchar2(100) := 'ANTMDB_ADMIN_PKG.DELETE_RM_PLAN_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			
	 		lmessage := ' ......  Delete Container '||lprofile||' Profile Directive ';
			antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
	 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.DELETE_CDB_PROFILE_DIRECTIVE(plan => ''ANTMDB_CDB_PLAN'',profile => '''||lprofile||'''); END; ';
			antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			dbms_output.put_line('BEGIN DBMS_RESOURCE_MANAGER.DELETE_CDB_PROFILE_DIRECTIVE(plan => ''ANTMDB_CDB_PLAN'',profile => '''||lprofile||'''); END;');
			execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.DELETE_CDB_PROFILE_DIRECTIVE(plan => ''ANTMDB_CDB_PLAN'',profile => '''||lprofile||'''); END;';

			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				commit;					
    end delete_rm_plan_prc; 

    procedure create_rm_plan_prc(lprofile varchar2,lshares number,lutil_limit number,lparallel_limit number) as
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP3';
      object_name   	varchar2(100) := 'ANTMDB_ADMIN_PKG.CREATE_RM_PLAN_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			
	 		lmessage := ' ......  Create Container '||lprofile||' Profile Directive';
			antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
	 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.CREATE_CDB_PROFILE_DIRECTIVE(plan => ''ANTMDB_CDB_PLAN'',profile => '''||lprofile||''', SHARES => '||lshares||', utilization_limit => '||lutil_limit||', parallel_server_limit => '||lparallel_limit||'); END;';
			antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						
			dbms_output.put_line('BEGIN DBMS_RESOURCE_MANAGER.CREATE_CDB_PROFILE_DIRECTIVE(plan => ''ANTMDB_CDB_PLAN'',profile => '''||lprofile||''', SHARES => '||lshares||', utilization_limit => '||lutil_limit||', parallel_server_limit => '||lparallel_limit||'); END;');
			execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.CREATE_CDB_PROFILE_DIRECTIVE(plan => ''ANTMDB_CDB_PLAN'',profile => '''||lprofile||''', SHARES => '||lshares||', utilization_limit => '||lutil_limit||', parallel_server_limit => '||lparallel_limit||'); END;';

			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				commit;					
    end create_rm_plan_prc;   

    procedure main_prc as
    	lpcount					number;
    	ldcount					number;
    	lshares					number;
    	lutil_limit			number;
    	lparallel_limit	number;
    	lcpu						number;
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP4';
      object_name   	varchar2(100) := 'ANTMDB_ADMIN_PKG.MAIN_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			select count(*) into lpcount from dba_cdb_rsrc_plans where upper(plan)='ANTMDB_CDB_PLAN';
			select count(*) into ldcount from dba_cdb_rsrc_plan_directives where upper(plan)='ANTMDB_CDB_PLAN';
			select sum(value) into lcpu from gv$parameter where name='cpu_count';
			
			if (lpcount > 0 OR ldcount > 0) then
		 		lmessage := ' ......  Create Pending Area';
				antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
		 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA(); END;';
				antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA(); END;';
				for i in (select 'PLATINUM' pdb_profile from dual union select 'GOLD' pdb_profile from dual union select 'SILVER' pdb_profile from dual union select 'BRONZE' pdb_profile from dual) loop
					delete_rm_plan_prc(i.pdb_profile);
				end loop;
		 		lmessage := ' ......  Delete Container Plan';
				antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
		 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.DELETE_CDB_PLAN(plan => ''ANTMDB_CDB_PLAN''); END;';
				antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.DELETE_CDB_PLAN(plan => ''ANTMDB_CDB_PLAN''); END;';
			end if;	

	 		lmessage := ' ......  Create Container Plan';
			antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
	 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN(plan => ''ANTMDB_CDB_PLAN'',comment => ''CDB resource plan for Anthem CDB''); END;';
			antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.CREATE_CDB_PLAN(plan => ''ANTMDB_CDB_PLAN'',comment => ''CDB resource plan for Anthem CDB''); END;';

			for i in (select 'PLATINUM' pdb_profile,16 shares, least(round(3200/lcpu),lcpu) util_limit, least(round(3200/lcpu),lcpu) parallel_limit from dual union 
								select 'GOLD'   	pdb_profile, 8 shares, least(round(1600/lcpu),lcpu) util_limit, least(round(1600/lcpu),lcpu) parallel_limit from dual union 
							  select 'SILVER' 	pdb_profile, 4 shares, least(round(800/lcpu),lcpu)  util_limit, least(round(800/lcpu),lcpu)  parallel_limit from dual union 
							  select 'BRONZE' 	pdb_profile, 2 shares, least(round(400/lcpu),lcpu)  util_limit, least(round(400/lcpu),lcpu)  parallel_limit from dual) loop
				create_rm_plan_prc(i.pdb_profile,i.shares,i.util_limit,i.parallel_limit);
			end loop;
	 		lmessage := ' ......  Validate Pending Area';
			antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
	 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA(); END;';
			antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA(); END;';
	 		lmessage := ' ......  Submit Pending Area';
			antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
	 		lmessage := ' BEGIN DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA(); END;';
			antmdb_admin_pkg.write_log_prc('ANTMDB_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			execute immediate 'BEGIN DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA(); END;';

			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				antmdb_admin_pkg.write_log_prc('antmdb_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				commit;					
    end main_prc;   

end antmdb_admin_pkg;
/

-- End of DDL Script for Package antmdb_ADMIN.antmdb_ADMIN_PKG
