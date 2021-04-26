-- Start of DDL Script for Package APDS_ADMIN.APDS_ADMIN_PKG

CREATE OR REPLACE PACKAGE apds_admin.apds_admin_pkg as
		procedure write_log_prc(lcall_program varchar2,lerror_severity varchar2,lmessage varchar2);
		function  manage_dblink_fun(ldatabase_name varchar2,lpassword varchar2,laction	varchar2) return number;
		procedure tablespace_prc(lhost_name varchar2,ldatabase_name varchar2,lversion varchar2,lenv_flag varchar2,lrun_flag char,lcomments varchar2);
		procedure archive_prc(lhost_name varchar2,ldatabase_name varchar2,lenv_flag varchar2,lrun_flag char,lcomments varchar2);
		procedure patch_prc(lhost_name varchar2,ldatabase_name varchar2,lversion varchar2,lenv_flag varchar2,lrun_flag char,lcomments varchar2);
		procedure sga_prc(lhost_name varchar2,ldatabase_name varchar2,lenv_flag varchar2,lrun_flag char,lcomments varchar2);
		procedure purge_prc;
    procedure job_control_prc(ljob_module varchar2,ljob_name varchar2,lstatus varchar2,lerror_cnt varchar2,ljob_type char,ljob_run_flag char,ljob_param varchar2,lcomments varchar2);
    procedure initialize_resource_prc(lconsumer_group varchar2);
		procedure capture_info_prc(lenv char,lrun_flag char);
		procedure update_inventory_prc;
/*  
    procedure   forecast_prc;
*/    
end apds_admin_pkg;
/

CREATE OR REPLACE PACKAGE BODY apds_admin.apds_admin_pkg as

		procedure write_log_prc(lcall_program varchar2,lerror_severity varchar2,lmessage varchar2) is
			PRAGMA	AUTONOMOUS_TRANSACTION;
			object_code	varchar2(10) 	:= 'ADMP1';
			object_name	varchar2(100)	:= 'APDS_ADMIN_PKG.WRITE_LOG_PRC';
		begin
			insert into apds_admin.apds_log values(null,lcall_program||'->'||object_name,lerror_severity,sysdate,lmessage);
			commit;
		end write_log_prc;

		function manage_dblink_fun(ldatabase_name varchar2,lpassword varchar2,laction	varchar2) return number as
		  lcnt        number;
		  lmessage 		varchar2(1000);
		  object_code	varchar2(10) 	:= 'ADMP2';
		  object_name varchar2(100) := 'APDS_ADMIN_PKG.MANAGE_DBLINK_FUN';
		begin
			lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			if laction='C' then			
			  select count(*) into lcnt from user_db_links
			  where upper(host) = upper(ldatabase_name) and
			    username='SYSTEM' and password is null and
			    upper(db_link)=upper('APDS_'||ldatabase_name);

			  if lcnt < 1 then
			    execute immediate 'create database link APDS_' || ldatabase_name || ' connect to system identified by "'|| lpassword|| '" using '''||ldatabase_name||'''';
					lmessage := ' ......  Created DB Link APDS_'||ldatabase_name ||' for : '|| ldatabase_name;
					apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				else 
					lmessage := ' ......  DB Link APDS_'||ldatabase_name ||' for '|| ldatabase_name||' already exists. Recreating it with right APDS Credentials';
					apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);        			        
			    execute immediate 'drop database link APDS_' || ldatabase_name;
			    execute immediate 'create database link APDS_' || ldatabase_name || ' connect to system identified by "'|| lpassword|| '" using '''||ldatabase_name||'''';
			  end if;
			elsif laction='D' then
				execute immediate 'alter session close database link APDS_'||ldatabase_name;
				lmessage := ' ......  Dropping DB Link APDS_'||ldatabase_name ||' for '|| ldatabase_name;
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);        			        
		    execute immediate 'drop database link APDS_' || ldatabase_name;
			else
				null;
       	-- for any more DB Link Manipulation Options
			end if;

			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			return 0;
		exception
		  when others then
					lmessage := ' ......  Dropping DB Link APDS_'||ldatabase_name ||' for '|| ldatabase_name;
					apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);        
		      execute immediate 'drop database link APDS_'||ldatabase_name;
		      lmessage:=substr(sqlerrm,1,1000);
					apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
					lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
					apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
		      return 1;
		end manage_dblink_fun;

    procedure tablespace_prc(lhost_name varchar2,ldatabase_name varchar2,lversion varchar2,lenv_flag varchar2,lrun_flag char,lcomments varchar2) is
			type				database_name_type   is table of APDS_CP_TABLESPACES.DATABASE_NAME%TYPE;
      type        tablespace_name_type is table of APDS_CP_TABLESPACES.TABLESPACE_NAME%TYPE;
      type        file_name_type       is table of APDS_CP_TABLESPACES.FILE_NAME%TYPE;
      type        alloted_space_type   is table of APDS_CP_TABLESPACES.ALLOTED_SPACE_GB%TYPE;
      type        used_space_type      is table of APDS_CP_TABLESPACES.USED_SPACE_GB%TYPE;
      type        free_space_type      is table of APDS_CP_TABLESPACES.FREE_SPACE_GB%TYPE;

			database_name				database_name_type;
      tablespace_name 		tablespace_name_type;
      file_name           file_name_type;
      alloted_space       alloted_space_type;
      used_space          used_space_type;
      free_space          free_space_type;

      type        cur_type is REF CURSOR;
      cur         cur_type;

--	10g/11g Query
      lsql11_1  varchar2(500 ) := 'select nvl(b.tablespace_name,nvl(a.tablespace_name,''UNKNOWN'')) tablespace_name, '||
               											' decode(nvl(b.file_id,nvl(a.file_id,-99)),-99,''UNKNOWN'',file_name) file_name, '||
               											' Gbytes_alloc alloted_Gbytes,	Gbytes_alloc-nvl(Gbytes_free,0) used_Gbytes, '||
               											' nvl(Gbytes_free,0) free_Gbytes from ( select sum(bytes)/1024/1024/1024 Gbytes_free, '||
               											' tablespace_name, file_id from sys.dba_free_space@apds_';
			lsql11_2  varchar2(500)  := '  group by tablespace_name,file_id ) a, ( select sum(bytes)/1024/1024/1024 Gbytes_alloc, '||
               											' tablespace_name,file_id,file_name from sys.dba_data_files@apds_';
      lsql11_3 	varchar2(500)  := ' group by tablespace_name,file_id, file_name ) b   where a.file_id = b.file_id ' ||
               											' UNION select ''REDOLOGS'', member, bytes/1024/1024/1024, bytes/1024/1024/1024, 0 from v$logfile@apds_';
      lsql11_4 	varchar2(100)  := ' lf, v$log@apds_';
      lsql11_5 	varchar2(500)  := ' l where lf.group# = l.group# UNION select ''TEMPFILE'',name,bytes/1024/1024/1024,bytes/1024/1024/1024,0 from v$tempfile@apds_';

--	12c Query
      lsql12_0  varchar2(100)  := ' f, v$containers@apds_';
      lsql12_1  varchar2(500)  := 'select a.name database_name, nvl(b.tablespace_name,nvl(a.tablespace_name,''UNKNOWN'')) tablespace_name,'||
               											' decode(nvl(b.file_id,nvl(a.file_id,-99)),-99,''UNKNOWN'',file_name) file_name, '||
               											' Gbytes_alloc alloted_Gbytes,	Gbytes_alloc-nvl(Gbytes_free,0) used_Gbytes, '||
               											' nvl(Gbytes_free,0) free_Gbytes from ( select /*+ NO_PARALLEL(f) NO_PARALLEL(c) */ c.name, tablespace_name, file_id, sum(bytes)/1024/1024/1024 Gbytes_free from sys.cdb_free_space@apds_';
			lsql12_2  varchar2(500)  := ' c where f.con_id = c.con_id	group by name, tablespace_name, file_id ) a, ( select /*+ NO_PARALLEL(f) NO_PARALLEL(c) */ c.name, tablespace_name,file_id,file_name, sum(bytes)/1024/1024/1024 Gbytes_alloc '||
               											' from sys.cdb_data_files@apds_';
      lsql12_3 	varchar2(500)  := ' c where f.con_id = c.con_id	group by name, tablespace_name,file_id, file_name ) b   where a.file_id = b.file_id ' ||
               											' UNION select c.name database_name,''REDOLOGS'', member, bytes/1024/1024/1024, bytes/1024/1024/1024, 0 from v$log@apds_';
      lsql12_4 	varchar2(100)  := ' l, v$logfile@apds_';
      lsql12_5 	varchar2(500)  := ' c where f.group# = l.group# and c.con_id < 2 UNION select c.name database_name, ''TEMPFILE'',f.name,bytes/1024/1024/1024,bytes/1024/1024/1024,0 from v$tempfile@apds_';
      lsql12_6  varchar2(100)  := ' c where f.con_id = c.con_id order by 1,2';

      lcnt        number;
      ljob_module	varchar2(30) 	:= 'CAPACITY_PLANNING_SYSTEM';
      ljob_name		varchar2(30)	:= 'CAPTURE_TABLESPACE_INFO';
      lmessage 		varchar2(1000);
      object_code	varchar2(10) 	:= 'ADMP3';
      object_name varchar2(100) := 'APDS_ADMIN_PKG.TABLESPACE_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'RUNNING',0,substr(lenv_flag,1,1),lrun_flag,'HOST_NAME='||lhost_name||'; DATABASE_NAME='||ldatabase_name||'; VERSION='||lversion||'; ENV_FLAG='||lenv_flag,lcomments);
			
/*
			dbms_output.put_line('12c Query');
			dbms_output.put_line('Sql string is :' || lsql12_1||ldatabase_name||lsql12_0||ldatabase_name||lsql12_2||ldatabase_name||lsql12_0||ldatabase_name||lsql12_3||ldatabase_name||lsql12_4||ldatabase_name||lsql12_0||ldatabase_name||lsql12_5||ldatabase_name||lsql12_0||ldatabase_name||lsql12_6);
			dbms_output.put_line('');
			dbms_output.put_line('11g Query');
			dbms_output.put_line('Sql string is :' || lsql11_1||ldatabase_name||lsql11_2||ldatabase_name||lsql11_3||ldatabase_name||lsql11_4||ldatabase_name||lsql11_5||ldatabase_name);
*/

			if substr(lversion,1,2) = '12' then
	      open cur for lsql12_1||ldatabase_name||lsql12_0||ldatabase_name||lsql12_2||ldatabase_name||lsql12_0||ldatabase_name||lsql12_3||ldatabase_name||lsql12_4||ldatabase_name||lsql12_0||ldatabase_name||lsql12_5||ldatabase_name||lsql12_0||ldatabase_name||lsql12_6;
	      fetch cur bulk collect into database_name,tablespace_name,file_name,alloted_space,used_space,free_space;
	      for j in 1..cur%rowcount loop
	         insert into apds_admin.apds_cp_tablespaces values (lhost_name,database_name(j),sysdate,tablespace_name(j),file_name(j), alloted_space(j),used_space(j),free_space(j),lenv_flag,'SOURCE-DB',SYSDATE,object_name,SYSDATE,object_name);
	      end loop;
        commit;
	      close cur;	
			else
	      open cur for lsql11_1||ldatabase_name||lsql11_2||ldatabase_name||lsql11_3||ldatabase_name||lsql11_4||ldatabase_name||lsql11_5||ldatabase_name;
	      fetch cur bulk collect into tablespace_name,file_name,alloted_space,used_space,free_space;
	      for j in 1..cur%rowcount loop
	         insert into apds_admin.apds_cp_tablespaces values (lhost_name,ldatabase_name,sysdate,tablespace_name(j),file_name(j), alloted_space(j),used_space(j),free_space(j),lenv_flag,'SOURCE-DB',SYSDATE,object_name,SYSDATE,object_name);
	      end loop;
	      commit;
	      close cur;					
			end if;

			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'COMPLETED',0,substr(lenv_flag,1,1),lrun_flag,'Completed Run for All Databases',lcomments);
    exception
      when others then
        lmessage :=substr('Issue with DB Link for : '||ldatabase_name||' '||sqlerrm,1,1000);
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' ......  Encountered Error while working Host with :'||lhost_name||' Database :'||ldatabase_name;
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);								
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);					
				job_control_prc(ljob_module,ljob_name,'ERRORED',1,substr(lenv_flag,1,1),lrun_flag,NULL,'Check APDS_ADMIN.APDS_LOG for more errors');
        commit;
    end tablespace_prc;

    procedure archive_prc(lhost_name varchar2,ldatabase_name varchar2,lenv_flag varchar2,lrun_flag char,lcomments varchar2) is
      type        archived_date_type      is table of APDS_CP_ARCHIVES.ARCHIVED_DATE%TYPE;
      type        log_switch_count_type   is table of APDS_CP_ARCHIVES.LOG_SWITCH_COUNT%TYPE;
      type        archive_space_type      is table of APDS_CP_ARCHIVES.ARCHIVE_SPACE_MB%TYPE;

      archived_date       archived_date_type;
      log_switch_count    log_switch_count_type;
      archive_space       archive_space_type;

      type        cur_type is REF CURSOR;
      cur         cur_type;

      lsql1 			varchar2(500) := ' select trunc(completion_time,''MI'') archived_date, count(*) log_switch_count, round(sum(blocks*block_size)/1024/1024) archive_space from v$archived_log@apds_';
      lsql2 			varchar2(500) := ' where dest_id=1 and completion_time > last_day(add_months(trunc(sysdate),-2))+1 and completion_time <= last_day(add_months(trunc(sysdate),-1))+1 group by trunc(completion_time,''MI'') order by 1';

      lcnt        number;
      ljob_module	varchar2(30) 	:= 'CAPACITY_PLANNING_SYSTEM';
      ljob_name		varchar2(30)	:= 'CAPTURE_ARCHIVE_INFO';
      lmessage 		varchar2(1000);
      object_code	varchar2(10) 	:= 'ADMP4';
      object_name varchar2(100) := 'APDS_ADMIN_PKG.ARCHIVE_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'RUNNING',0,substr(lenv_flag,1,1),lrun_flag,'HOST_NAME='||lhost_name||'; DATABASE_NAME='||ldatabase_name||'; ENV_FLAG='||lenv_flag,lcomments);
			    	
      open cur for lsql1||ldatabase_name||lsql2;
      fetch cur bulk collect into archived_date,log_switch_count,archive_space;
      for j in 1..cur%rowcount loop
				insert into apds_admin.apds_cp_archives_gt values (lhost_name,ldatabase_name,sysdate,archived_date(j),log_switch_count(j),archive_space(j),lenv_flag,'SOURCE-DB',SYSDATE,object_name,SYSDATE,object_name);
      end loop;
      commit;
      close cur;

      for j in (select * from apds_admin.apds_cp_archives_gt) loop
	      select count(1) into lcnt from apds_admin.apds_cp_archives
	      where host_name=lhost_name and database_name=ldatabase_name and archived_date=j.archived_date;
	      if lcnt=0 then
	          insert into apds_admin.apds_cp_archives values (lhost_name,ldatabase_name,sysdate,j.archived_date,j.log_switch_count,j.archive_space_mb,lenv_flag,'SOURCE-DB',SYSDATE,object_name,SYSDATE,object_name);
	      end if;
			end loop;
			commit;

			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'COMPLETED',0,substr(lenv_flag,1,1),lrun_flag,'Completed Run for All Databases',lcomments);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' ......  Encountered Error while working with Database : '||ldatabase_name;
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);								
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);					
				job_control_prc(ljob_module,ljob_name,'ERRORED',1,substr(lenv_flag,1,1),lrun_flag,NULL,'Check APDS_ADMIN.APDS_LOG for more errors');
        commit;
    end archive_prc;

		procedure patch_prc(lhost_name varchar2,ldatabase_name varchar2,lversion varchar2,lenv_flag varchar2,lrun_flag char,lcomments varchar2) is
			type				database_name_type			is table of APDS_CP_DBPATCHES.database_name%type;
			type        patch_id_type           is table of APDS_CP_DBPATCHES.patch_id%type;
			type        patch_uid_type          is table of APDS_CP_DBPATCHES.patch_uid%type;
			type        bundle_id_type      		is table of APDS_CP_DBPATCHES.bundle_id%type;
			type        bundle_series_type      is table of APDS_CP_DBPATCHES.bundle_series%type;
			type        description_type      	is table of APDS_CP_DBPATCHES.description%type;
			type        version_type      			is table of APDS_CP_DBPATCHES.version%type;
			type        action_time_type        is table of APDS_CP_DBPATCHES.action_time%type;
			type        action_type             is table of APDS_CP_DBPATCHES.action%type;
			type        status_type             is table of APDS_CP_DBPATCHES.status%type;

			database_name				database_name_type;
			patch_id            patch_id_type;
			patch_uid           patch_uid_type;
			bundle_id           bundle_id_type;
			bundle_series       bundle_series_type;
			description					description_type;
			version             version_type;
			action_time         action_time_type;
			action              action_type;
			status							status_type;
			comments						description_type;

			type        cur_type is REF CURSOR;
			cur         cur_type;
			
--	10g/11g Query
      lsql11_1  varchar2(500 ) := ' select action,action_time,version,comments from dba_registry_history@apds_';
      
--	12c Query
      lsql12_0  varchar2(100)  := ' p, v$containers@apds_';
      lsql12_1  varchar2(500)  := 'select c.name database_name, patch_id,patch_uid,bundle_id,bundle_series,description,version,status,action_time,action from cdb_registry_sqlpatch@apds_';
      lsql12_2  varchar2(100)  := ' c where p.con_id = c.con_id order by database_name, action_time';

      lcnt        number;
      ljob_module	varchar2(30) 	:= 'CAPACITY_PLANNING_SYSTEM';
      ljob_name		varchar2(30)	:= 'CAPTURE_PATCH_INFO';
      lmessage 		varchar2(1000);
      object_code	varchar2(10) 	:= 'ADMP5';
      object_name varchar2(100) := 'APDS_ADMIN_PKG.PATCH_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'RUNNING',0,substr(lenv_flag,1,1),lrun_flag,'HOST_NAME='||lhost_name||'; DATABASE_NAME='||ldatabase_name||'; VERSION='||lversion||'; ENV_FLAG='||lenv_flag,lcomments);

			if substr(lversion,1,2) = '12' then
	      open cur for lsql12_1||ldatabase_name||lsql12_0||ldatabase_name||lsql12_2;
	      fetch cur bulk collect into database_name,patch_id,patch_uid,bundle_id,bundle_series,description,version,status,action_time,action;
	      for j in 1..cur%rowcount loop
	      	insert into apds_admin.apds_cp_dbpatches_gt values 
	      	(lhost_name,database_name(j),sysdate,patch_id(j),patch_uid(j),bundle_id(j),bundle_series(j),description(j),version(j),status(j),action_time(j),action(j),lenv_flag,'SOURCE-DB',SYSDATE,object_name,SYSDATE,object_name);
	      end loop;	
        commit;
	      close cur;	
			else
	      open cur for lsql11_1||ldatabase_name||' order by action_time';
	      fetch cur bulk collect into action,action_time,version,comments;
	      for j in 1..cur%rowcount loop
	      	insert into apds_admin.apds_cp_dbpatches_gt values 
	      	(lhost_name,ldatabase_name,sysdate,null,null,null,null,comments(j),version(j),null,action_time(j),action(j),lenv_flag,'SOURCE-DB',SYSDATE,object_name,SYSDATE,object_name);	
	      end loop;	
        commit;
	      close cur;	
			end if;

      for j in (select * from apds_admin.apds_cp_dbpatches_gt order by database_name,action_time) loop  	
	        select count(1) into lcnt from apds_admin.apds_cp_dbpatches
	        where database_name=j.database_name and action_time=j.action_time;	      
	        if lcnt=0 then
	            insert into apds_admin.apds_cp_dbpatches values
	                (lhost_name,j.database_name,sysdate,j.patch_id,j.patch_uid,j.bundle_id,j.bundle_series,j.description,j.version,j.status,j.action_time,j.action,lenv_flag,'SOURCE-DB',SYSDATE,object_name,SYSDATE,object_name);
	        end if;	      
      end loop;
			commit;
			
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'COMPLETED',0,substr(lenv_flag,1,1),lrun_flag,'Completed Run for All Databases',lcomments);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' ......  Encountered Error while working with Database : '||ldatabase_name;
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);								
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);					
				job_control_prc(ljob_module,ljob_name,'ERRORED',1,substr(lenv_flag,1,1),lrun_flag,NULL,'Check APDS_ADMIN.APDS_LOG for more errors');
        commit;
		end patch_prc;

		procedure sga_prc(lhost_name varchar2,ldatabase_name varchar2,lenv_flag varchar2,lrun_flag char,lcomments varchar2) is
			type		instance_name_type				is table of APDS_CP_SGA.INSTANCE_NAME%TYPE;
			type    shared_pool_type          is table of APDS_CP_SGA.SHARED_POOL_MB%TYPE;
			type 		db_buffers_type						is table of APDS_CP_SGA.DB_BUFFERS_MB%TYPE;
			type 		log_buffers_type					is table of APDS_CP_SGA.LOG_BUFFERS_MB%TYPE;

      instance_name	  instance_name_type;
      shared_pool 	  shared_pool_type;
      db_buffers 	  	db_buffers_type;
      log_buffers    	log_buffers_type;

			lsql0		varchar2(100)  := ' s, gv$instance@apds_';
			lsql0_1 varchar2(100)  := ' i where s.inst_id = i.inst_id and ';
      lsql1  	varchar2(250)  := ' select distinct a.instance_name, a.shared_pool, b.db_buffers , c.log_buffers from '||
      													'  (select instance_name, round(sum(value)/1024/1024) shared_pool from gv$sga@apds_';
      lsql2   varchar2(250)	 :=	' name like ''%Size%'' group by instance_name) a, (select instance_name, round(value/1024/1024) db_buffers from gv$sga@apds_'; 
      lsql3 	varchar2(250)  := ' name like ''Database%'') b, (select instance_name, round(value/1024/1024) log_buffers from gv$sga@apds_';
      lsql4  	varchar2(250)  := ' name like ''Redo%'') c  where a.instance_name = b.instance_name and  b.instance_name = c.instance_name';

			type        cur_type is REF CURSOR;
			cur         cur_type;

      ljob_module			varchar2(30) 	:= 'CAPACITY_PLANNING_SYSTEM';
      ljob_name				varchar2(30)	:= 'CAPTURE_SGA_INFO';
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP6';
      object_name   	varchar2(100) := 'APDS_ADMIN_PKG.SGA_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'RUNNING',0,substr(lenv_flag,1,1),lrun_flag,'HOST_NAME='||lhost_name||'; DATABASE_NAME='||ldatabase_name||'; ENV_FLAG='||lenv_flag,lcomments);

--			dbms_output.put_line(lsql1||ldatabase_name||lsql0||ldatabase_name||lsql0_1||lsql2||ldatabase_name||lsql0||ldatabase_name||lsql0_1||lsql3||ldatabase_name||lsql0||ldatabase_name||lsql0_1||lsql4);

      open cur for lsql1||ldatabase_name||lsql0||ldatabase_name||lsql0_1||lsql2||ldatabase_name||lsql0||ldatabase_name||lsql0_1||lsql3||ldatabase_name||lsql0||ldatabase_name||lsql0_1||lsql4;
      fetch cur bulk collect into instance_name,shared_pool,db_buffers,log_buffers;
      for j in 1..cur%rowcount loop
      	insert into apds_admin.apds_cp_sga values 
      	(lhost_name,ldatabase_name,instance_name(j),sysdate,shared_pool(j),db_buffers(j),log_buffers(j),lenv_flag,'SOURCE-DB',SYSDATE,object_name,SYSDATE,object_name);
      end loop;	
      commit;
      close cur;	

			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'COMPLETED',0,substr(lenv_flag,1,1),lrun_flag,'Completed Run for All Databases',lcomments);
    exception
      when others then
	      lmessage :=substr(sqlerrm,1,1000);
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);					
				job_control_prc(ljob_module,ljob_name,'ERRORED',1,substr(lenv_flag,1,1),lrun_flag,NULL,'Check APDS_ADMIN.APDS_LOG for more errors');
        commit;
    end sga_prc;

    procedure purge_prc as
   		ldate						date;
      lvalue          varchar2(30);
      ljob_module			varchar2(30) 	:= 'CAPACITY_PLANNING_SYSTEM';
      ljob_name				varchar2(30)	:= 'PURGE_TABLE_INFO';
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP7';
      object_name   	varchar2(100) := 'APDS_ADMIN_PKG.PURGE_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'RUNNING',0,NULL,NULL,'APDS_ADMIN.APDS_LOG',NULL);
			    	
			select config_value into lvalue 
			from apds_admin.apds_config 
			where upper(config_name)='PURGE_VOLUME_MONTHS'
			  and upper(module_name)='CAPACITY_PLANNING_SYSTEM';

			for i in (select partition_name, high_value from user_tab_partitions where table_name='APDS_LOG' and partition_position > 1) loop
				execute immediate 'select '||i.high_value||' from dual' into ldate;
				if ldate < last_day(add_months(sysdate,-lvalue)+1) then
					execute immediate 'alter table apds_admin.apds_log drop partition '||i.partition_name||' update indexes';
				end if;
			end loop;
			  
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'COMPLETED',0,NULL,NULL,NULL,NULL);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);					
				job_control_prc(ljob_module,ljob_name,'ERRORED',1,NULL,NULL,NULL,'Check APDS_ADMIN.APDS_LOG for more errors');
				commit;
    end purge_prc;   

    procedure job_control_prc(ljob_module varchar2,ljob_name varchar2,lstatus varchar2,lerror_cnt varchar2,ljob_type char,ljob_run_flag char,ljob_param varchar2,lcomments varchar2) as
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP8';
      object_name   	varchar2(100) := 'APDS_ADMIN_PKG.JOB_CONTROL_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			    	
			if lstatus = 'RUNNING' then
				update apds_admin.apds_job_control
				set job_status      = lstatus,
						job_start_date 	= sysdate,
						job_end_date	 	= null,
						job_error_count = lerror_cnt,
						job_parameters 	= ljob_param,
						comments				=	lcomments
				where upper(job_module) 	= upper(ljob_module)
				  and upper(job_name) 		= upper(ljob_name)
				  and upper(job_type)   	= upper(nvl(ljob_type,'X'))
				  and upper(job_run_flag) = upper(nvl(ljob_run_flag,'X'));
			elsif lstatus in ('COMPLETED','ERRORED') then
				update apds_admin.apds_job_control
				set job_status      = lstatus,
						job_end_date	 	= sysdate,
						job_error_count = job_error_count + lerror_cnt,
						comments				= lcomments
				where upper(job_module) 	= upper(ljob_module)
				  and upper(job_name)   	= upper(ljob_name)
				  and upper(job_type)   	= upper(nvl(ljob_type,'X'))
				  and upper(job_run_flag) = upper(nvl(ljob_run_flag,'X'));				  			
			else
       	-- for any more Job Status Options
				null;			
			end if;
			commit;
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				commit;					
    end job_control_prc;   

    procedure initialize_resource_prc(lconsumer_group varchar2) as
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP9';
      object_name   	varchar2(100) := 'APDS_ADMIN_PKG.INITIALIZE_RESOURCE_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			
	 		lmessage := ' ......  Setting Resource Manager Consumer Group to  '||lconsumer_group;
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

			dbms_resource_manager.set_initial_consumer_group('APDS_ADMIN',lconsumer_group);
			commit;
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
    exception
      when others then
        lmessage :=substr(sqlerrm,1,1000);
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				commit;					
    end initialize_resource_prc;   

    procedure capture_info_prc(lenv char,lrun_flag char) is
			type		instance_name_type				is table of APDS_DB_INSTANCE.INSTANCE_NAME%TYPE;
			type		host_name_type						is table of APDS_DB_INSTANCE.HOST_NAME%TYPE;
			type    sga_type          				is table of APDS_DB_INSTANCE.SGA%TYPE;
			type 		cpu_type									is table of APDS_DB_INSTANCE.CPU_COUNT%TYPE;
			type 		archive_lag_type					is table of APDS_DB_INSTANCE.ARCHIVE_LAG%TYPE;

      instance_name	  instance_name_type;
      host_name				host_name_type;
      sga					 	  sga_type;
      cpu				 	  	cpu_type;
      archive_lag    	archive_lag_type;

			lsql0						varchar2(100)  := ' t, gv$instance@apds_';
			lsql0_1 				varchar2(100)  := ' i where t.inst_id = i.inst_id';
      lsql1  					varchar2(250)  := ' select distinct a.instance_name, a.host_name, sga, cpu, value from '||
      													'  (select instance_name, host_name, round(sum(value)/1024/1024/1024,1) sga from gv$sga@apds_';
      lsql2  				 	varchar2(250)	 :=	' group by instance_name, host_name ) a, (select instance_name, host_name, cpu_count_current cpu from gv$license@apds_'; 
      lsql3 					varchar2(250)  := ' ) b, (select instance_name, host_name, value from gv$parameter@apds_';
      lsql4  					varchar2(250)  := ' and name=''archive_lag_target'') c  where a.instance_name = b.instance_name and  b.instance_name = c.instance_name';

			type        		cur_type is REF CURSOR;
			cur         		cur_type;
			
			lenv_flag				varchar2(10);
      lhost_name 			varchar2(100);
      linstance_name	varchar2(15);
      ldatabase_role	varchar2(20);
      llog_mode   		varchar2(12);
      lcpu_count			number;
      lsga						number;
      larchive_lag		number;
      lcomments				varchar2(100);
      lversion    		varchar2(17);
			ldatabase_name	varchar2(30);
      lpassword     	varchar2(30);
      ldb_cnt					number := 0;
      ltotal_db				number;
      lrowcount				number := 0;
      lcnt          	number;
 			ldb_type_check	number := 0;
			ljob_error_cnt	number := 0;
      ljob_module			varchar2(30) 	:= 'CAPACITY_PLANNING_SYSTEM';
      ljob_name				varchar2(30)	:= 'CAPTURE_CAPACITY_INFO';
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP10';
      object_name   	varchar2(100) := 'APDS_ADMIN_PKG.CAPTURE_INFO_PRC';
    begin
			lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'RUNNING',0,lenv,lrun_flag,'ENV_FLAG='||lenv||'; RUN_FLAG='||lrun_flag,NULL);
			initialize_resource_prc('ELAPSED_TIME_LIMIT_GROUP');
			
			select decode(upper(lenv),'P','Prod','N','Non-Prod') into lenv_flag from dual;
	 		lmessage := ' ......  Capturing Capacity Information for Environments '||lenv_flag;
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);

      select translate(config_value,
                          '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                          '9876543210ZYXWVUTSRQPONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba')
      into lpassword from apds_admin.apds_config
      where upper(module_name)=upper('CAPACITY_PLANNING_SYSTEM') 
      and upper(config_name)=decode(upper(lenv),'P','PROD-SYSTEM-PASS','N','NON-PROD-SYSTEM-PASS');

--  		lpassword := 'Fam1ly#5';

			ldb_cnt := 0;
      select count(distinct multitenant_name) database_name
      into ltotal_db
      from apds_admin.apds_database
		  where upper(capture_flag) = 'Y' and 
		  			upper(env_flag) 		= upper(lenv_flag) and 
		  			database_name not like '-MGMT%';
      for i in (select distinct multitenant_name database_name from apds_admin.apds_database
		      			where upper(capture_flag) = 'Y' and upper(env_flag) = upper(lenv_flag) and database_name not like '-MGMT%' order by 1 ) loop
		      ldb_cnt := ldb_cnt + 1;
					lcomments := 'Processing Database '||ldb_cnt||' of '||ltotal_db;
          ldatabase_name := upper(i.database_name);
         
--					ldatabase_name := 'fs90dmo';
          begin
						lcnt:= manage_dblink_fun(ldatabase_name,lpassword,'C');
	          if lcnt = 0 then
								initialize_resource_prc('ELAPSED_TIME_LIMIT_GROUP');
								execute immediate 'select instance_name,lower(host_name),version from v$instance@apds_'||ldatabase_name into linstance_name,lhost_name,lversion;
								if upper(lrun_flag)='D' then
		            	tablespace_prc(lhost_name,ldatabase_name,lversion,lenv_flag,lrun_flag,lcomments);
									initialize_resource_prc('DEFAULT_CONSUMER_GROUP');
		            elsif upper(lrun_flag)='M' then 
									execute immediate 'select log_mode, database_role from v$database@apds_'||ldatabase_name into llog_mode, ldatabase_role;
									execute immediate 'select count(*) from gv$instance@apds_'||ldatabase_name into ldb_type_check;
									if ldb_type_check > 1 then
										open cur for lsql1||ldatabase_name||lsql0||ldatabase_name||lsql0_1||lsql2||ldatabase_name||lsql0||ldatabase_name||lsql0_1||lsql3||ldatabase_name||lsql0||ldatabase_name||lsql0_1||lsql4;
										fetch cur bulk collect into instance_name,host_name,sga,cpu,archive_lag;
										for j in 1..cur%rowcount loop
											insert into apds_admin.apds_db_instance_gt(database_name,host_name,instance_name,instance_type,sga,cpu_count,archive_lag) values(ldatabase_name,host_name(j),instance_name(j),'RAC-INSTANCE',sga(j),cpu(j),archive_lag(j));
										end loop;	
										commit;
										close cur;	
									else
										execute immediate 'select round(sum(value)/1024/1024/1024,1) sga from v$sga@apds_'||ldatabase_name into lsga;
										execute immediate 'select cpu_count_current from v$license@apds_'||ldatabase_name into lcpu_count;
										execute immediate 'select value from v$parameter@apds_'||ldatabase_name||' where name=''archive_lag_target''' into larchive_lag;
										insert into apds_admin.apds_db_instance_gt(database_name,host_name,instance_name,instance_type,sga,cpu_count,archive_lag) values(ldatabase_name,lhost_name,linstance_name,'SINGLE-INSTANCE',lsga,lcpu_count,larchive_lag);
										commit;
									end if;
									insert into apds_admin.apds_database_gt (database_name,instance_type,host_name,log_mode,version,database_role) values (i.database_name,decode(ldb_type_check,1,'SINGLE-INSTANCE','RAC-INSTANCE'),lhost_name,llog_mode,lversion,ldatabase_role);
									archive_prc(lhost_name,ldatabase_name,lenv_flag,lrun_flag,lcomments);
		            	patch_prc(lhost_name,ldatabase_name,lversion,lenv_flag,lrun_flag,lcomments);
		            	sga_prc(lhost_name,ldatabase_name,lenv_flag,lrun_flag,lcomments);
									initialize_resource_prc('DEFAULT_CONSUMER_GROUP');
		            else
		            	-- for any more Run Flag Options
		            	null;
		            end if;
		            commit;
								lcnt:= manage_dblink_fun(ldatabase_name,lpassword,'D');
	          else
							lmessage := ' ......  Error for Database '||ldatabase_name ||' accessing DB Link '|| ldatabase_name;
							apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
	          end if;
          exception
		       when others then
		       		ljob_error_cnt := ljob_error_cnt + 1;
		          lmessage:=substr('Issue with DB Link for : '||ldatabase_name||' '||sqlerrm,1,1000);
							apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
							lcnt:= manage_dblink_fun(ldatabase_name,lpassword,'D');
        	end;
			end loop;

			if upper(lrun_flag)='M' then 
		 		lmessage := ' ......  Updating CPU_COUNT, SGA, INSTANCE_TYPE, ARCHIVE_LAG Attributes in APDS_DB_INSTANCE Table. ';
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				for i in (select distinct database_name,host_name,instance_name,cpu_count,sga,instance_type,archive_lag from apds_admin.apds_db_instance_gt) loop
				begin
					update apds_admin.apds_db_instance t
					set instance_name			=	i.instance_name,
							host_name					=	i.host_name,
							cpu_count					=	i.cpu_count,
							sga								=	i.sga,
							instance_type			=	i.instance_type,
							archive_lag				=	i.archive_lag,
							last_updated_date	=	sysdate,
							last_updated_by		=	'APDS_ADMIN_PKG:ADMP10'
					where upper(t.database_name) = upper(i.database_name);
				exception
					when DUP_VAL_ON_INDEX then
						null;
				end;
				end loop;
				commit;

		 		lmessage := ' ......  Updating INSTANCE_TYPE, LOG_MODE, VERSION Attributes in APS_DATABASE Table. ';
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				for i in (select distinct database_name,host_name,instance_type,log_mode,version from apds_admin.apds_database_gt) loop
				begin
					update apds_admin.apds_database t
					set instance_type			=	i.instance_type,
							log_mode					=	i.log_mode,
							version						=	i.version,
							host_name					=	i.host_name,
							last_updated_date	=	sysdate,
							last_updated_by		=	'APDS_ADMIN_PKG:ADMP10'
					where upper(t.multitenant_name) = upper(i.database_name);
				exception
					when DUP_VAL_ON_INDEX then
						null;
				end;
				end loop;
				commit;
			end if;		
      purge_prc;
			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'COMPLETED',ljob_error_cnt,lenv,lrun_flag,NULL,NULL);
			initialize_resource_prc('DEFAULT_CONSUMER_GROUP');
    exception
       when others then
        lmessage:=substr(sqlerrm,1,1000);
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||' with Exception Errors  ----->';
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				job_control_prc(ljob_module,ljob_name,'ERRORED',ljob_error_cnt,lenv,lrun_flag,NULL,'Check APDS_ADMIN.APDS_LOG for more errors');
				commit;
    end capture_info_prc;

    procedure update_inventory_prc is
    	lcnt						number;
      lpassword     	varchar2(30);
    	lrowcount				number;
      ljob_module			varchar2(30) 	:= 'INVENTORY_UPDATE_SYSTEM';
      ljob_name				varchar2(30)	:= 'UPDATE_INVENTORY_INFO';
      lmessage      	varchar2(1000);
      object_code			varchar2(10) 	:= 'ADMP11';
      object_name   	varchar2(100) := 'APDS_ADMIN_PKG.UPDATE_INVENTORY_PRC';
    begin
	 		lmessage := ' <-----  Started Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'RUNNING',0,NULL,'M',NULL,NULL);

      select translate(config_value,
                          '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                          '9876543210ZYXWVUTSRQPONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba')
      into lpassword 
      from apds_admin.apds_config
      where upper(module_name)=upper('CAPACITY_PLANNING_SYSTEM') 
      and upper(config_name)='PROD-SYSTEM-PASS';
			
			for i in (select * from apds_admin.apds_config where upper(module_name)=upper('INVENTORY_UPDATE_SYSTEM')) loop
				if i.config_name in ('OMS','INFOHUB') then
					lcnt:= manage_dblink_fun(i.config_value,lpassword,'C');
          if lcnt = 0 then
						--	Update APDS_EXADATA_CELL_SERVER 
				    for i in (select distinct id cell_id, name, max(ecm_snapshot_id) snap_id from SYSMAN.EM_EXADATA_CELL_E@apds_oms group by id, name) loop
				        insert into apds_admin.apds_exadata_cell_server select id cell_id, name cell_server_name, cell_version, release_version, cpu_count,ip_address_1, cidr_prefix_size_1 ip_address1_cidr,
				            ip_address_2, cidr_prefix_size_2 ip_address2_cidr, ip_address_3, cidr_prefix_size_3 ip_address3_cidr,
				            ip_address_4, cidr_prefix_size_4 ip_address4_cidr, kernel_version, make_model, fc_mode, max_pd_iops, max_fd_iops, max_pd_mbps, max_fd_mbps,
										(case 
												when instr(name,'va33') > 0 then 2  
												when instr(name,'mom') > 0 then 3
												else 1
										end ),
				            'Y',decode(instr(name,'dx'),0,decode(instr(name,'fx'),0,decode(instr(name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod'),'GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
				        from SYSMAN.EM_EXADATA_CELL_E@apds_oms
				        where id=i.cell_id and name=i.name and ecm_snapshot_id=i.snap_id;
				    end loop;
						commit;
						
						merge into apds_admin.apds_exadata_cell_server t
							using apds_admin.apds_exadata_cell_server_gt i
							on (t.cell_id					 = i.cell_id and 
									t.cell_server_name = i.cell_server_name)
							when not matched then
								insert values(i.cell_id,i.cell_server_name,i.cell_server_version,i.release_version,i.cpu_count,i.ip_address1,i.ip_address1_cidr,i.ip_address2,i.ip_address2_cidr,i.ip_address3,i.ip_address3_cidr,
								i.ip_address4,i.ip_address4_cidr,i.kernel_version,i.make_model,i.fc_mode,i.max_pd_iops,i.max_fd_iops,i.max_pd_mbps,i.max_fd_mbps,i.deployment_id,i.active_flag,i.env_flag,i.record_src,i.created_date,
								i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_EXADATA_CELL_SERVER. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;
						
						--	Update APDS_EXADATA_CELLDISK 
						insert into apds_admin.apds_exadata_celldisk select distinct cell_id, cell_name cell_server_name, name cell_disk_name, device_name, device_partition,config_key, cd_size,
								(case 
										when instr(name,'va33') > 0 then 2  
										when instr(name,'mom') > 0 then 3
										else 1
								end ),
		            'Y',decode(instr(name,'dx'),0,decode(instr(name,'fx'),0,decode(instr(name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod'),'GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
        		from SYSMAN.EM_EXADATA_CELLDISK_E@apds_oms;
			      commit;

						merge into apds_admin.apds_exadata_celldisk t
							using apds_admin.apds_exadata_celldisk_gt i
							on (t.cell_id					 =	i.cell_id and 
									t.cell_server_name = i.cell_server_name and
							    t.cell_disk_name   = i.cell_disk_name and 
							    t.device_name			 = i.device_name)
							when not matched then
								insert values(i.cell_id,i.cell_server_name,i.config_key,i.cell_disk_name,i.device_name,i.device_partition,i.cd_size_gb,i.deployment_id,i.active_flag,i.env_flag,i.record_src,i.created_date,
								i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_EXADATA_CELLDISK. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;
						
						--	Update APDS_EXADATA_FCACHEDISK 
						for i in (select distinct cell_id, cell_name cell_disk_name, name fcache_name, config_key, effective_cache_size cache_size_gb	from sysman.em_exadata_fcache_e@apds_oms) loop
						begin
							insert into apds_admin.apds_exadata_fcachedisk values (i.cell_id, i.cell_disk_name, i.fcache_name,i.config_key, i.cache_size_gb,
											(case 
													when instr(i.cell_disk_name,'va33') > 0 then 2  
													when instr(i.cell_disk_name,'mom') > 0 then 3
													else 1
											end ),
					            'Y',decode(instr(i.cell_disk_name,'dx'),0,decode(instr(i.cell_disk_name,'fx'),0,decode(instr(i.cell_disk_name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod'),'GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN');
						exception
							when DUP_VAL_ON_INDEX then
								null;
						end;
						end loop;
			      commit;

						merge into apds_admin.apds_exadata_fcachedisk t
							using apds_admin.apds_exadata_fcachedisk_gt i
							on (t.cell_id					 = i.cell_id and 
									t.cell_disk_name = i.cell_disk_name and
							    t.fcache_name   	 = i.fcache_name)
							when not matched then
								insert values(i.cell_id,i.cell_disk_name,i.fcache_name,i.config_key,i.cache_size_gb,i.deployment_id,i.active_flag,i.env_flag,i.record_src,i.created_date,
								i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_EXADATA_FCACHEDISK. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;

						--	Update APDS_EXADATA_GRIDDISK 
						for i in (select distinct cell_id,cell_name cell_server_name,cell_disk cell_disk_name,name grid_disk_name,config_key,diskgroup disk_group,gd_size gd_size_mb,is_sparse from SYSMAN.EM_EXADATA_GRIDDISK_E@apds_oms) loop
						begin
							insert into apds_admin.apds_exadata_griddisk values (i.cell_id, i.cell_server_name, i.cell_disk_name, i.grid_disk_name,i.config_key, i.disk_group, i.gd_size_mb,i.is_sparse,
											(case 
													when instr(i.cell_server_name,'va33') > 0 then 2  
													when instr(i.cell_server_name,'mom') > 0 then 3
													else 1
											end ),
					            'Y',decode(instr(i.cell_server_name,'dx'),0,decode(instr(i.cell_server_name,'fx'),0,decode(instr(i.cell_server_name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod'),'GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN');
						exception
							when DUP_VAL_ON_INDEX then
								null;
						end;
						end loop;
						commit;

						merge into apds_admin.apds_exadata_griddisk t
							using apds_admin.apds_exadata_griddisk_gt i
							on (t.cell_id					 = i.cell_id and
									t.cell_server_name = i.cell_server_name and
							    t.cell_disk_name   = i.cell_disk_name   and
							    t.grid_disk_name   = i.grid_disk_name)
							when not matched then
								insert values(i.cell_id,i.cell_server_name,i.cell_disk_name,i.grid_disk_name,i.config_key,i.disk_group,i.gd_size_mb,i.is_sparse,i.deployment_id,i.active_flag,i.env_flag,i.record_src,i.created_date,
								i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_EXADATA_GRIDDISK. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;

						--	Update APDS_HOST 
						insert into apds_admin.apds_host_gt 
							select host_name, os_summary os, freq, domain, mem, disk,cpu_count,physical_cpu_count, logical_cpu_count,total_cpu_cores, ma, system_config, vendor_name, os_vendor, virtual,
									decode(dbm_member,1,'Y','N') exadata_flag, null, 
							    (case 
							          when instr(host_name,'va33') > 0 then 2  
							          when instr(host_name,'mom') > 0 then 3
							          when instr(host_name,'aws') > 0 then 4
							          else 1
							     end ) deployment_id, 
			     						'Y', decode(instr(host_name,'dx'),0,decode(instr(host_name,'fx'),0,decode(instr(host_name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod'),'GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
							from sysman.MGMT$OS_HW_SUMMARY@apds_oms;
			 
						update apds_admin.apds_host_gt
						set env_flag=decode(substr(host_name,5,1),'p','Prod','Non-Prod')
						where os like 'AIX%';

						update apds_admin.apds_host_gt
						set virtual = 'Oracle Virtual Machine'
						where host_name in (select host_name from sysman.EM_ALL_TARGETS@apds_oms
															where target_type='oracle_si_virtual_server');       

						-- Host Records in InfoHub not in Grid Control
			        
						insert into apds_admin.apds_host_gt 
						    select distinct server_nm, null, null, null, null, null,null,null, null,null, null, null, null, null, null,'N',null,
						            (case 
								          when instr(server_nm,'va33') > 0 then 2  
								          when instr(server_nm,'mom') > 0 then 3
								          when instr(server_nm,'aws') > 0 then 4
						                  else 1
						             end ) deployment_id, 
						                    'Y', decode(production_ind,'Y','Prod','Non-Prod') env_flag,'INFOHUB',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
						    from capacity_prod.all_databases@apds_infohub 
						    where upper(server_nm) not in (select upper(nvl(substr((host_name),1,instr((host_name),'.')-1),host_name)) from apds_admin.apds_host);
						commit;

						merge into apds_admin.apds_host t
							using apds_admin.apds_host_gt i
							on (t.host_name = i.host_name)
							when not matched then
								insert values(i.host_name,i.os,i.clock_freq_mhz,i.domain,i.memory_mb,i.local_disk_gb,i.cpu_count,i.physical_cpu_count,i.logical_cpu_count,i.total_cpu_cores,i.machine_architecture,i.system_config,i.vendor_name,i.os_vendor,i.virtual,i.exadata_flag,
								i.comments,i.deployment_id,i.active_flag,i.env_flag,i.record_src,i.created_date,i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_EXADATA_HOST. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;

						--	Update APDS_CLUSTER 
						insert into apds_admin.apds_cluster_gt 
							select distinct cm_target_name cluster_name, host_name,node_num node_number,software_version version,crs_home,null,
								    (case 
								          when instr(host_name,'va33') > 0 then 2  
								          when instr(host_name,'mom') > 0 then 3
								          when instr(host_name,'aws') > 0 then 4
								          else 1
								     end ) deployment_id,
			                'Y',decode(instr(host_name,'dx'),0,decode(instr(host_name,'fx'),0,decode(instr(host_name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod'),'GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
			      	from sysman.CM$MGMT_CLUSTER_CSS_NODES_ECM@apds_oms;
			        
			      update apds_admin.apds_cluster_gt
							set env_flag=decode(substr(host_name,5,1),'h','Non-Prod')
							where host_name like 'vaathm%';
						commit;

						merge into apds_admin.apds_cluster t
							using apds_admin.apds_cluster_gt i
							on (t.cluster_name = i.cluster_name and
							    t.host_name    = i.host_name)
							when not matched then
								insert values(i.cluster_name,i.host_name,i.node_number,i.version,i.crs_home,i.comments,i.deployment_id,i.active_flag,i.env_flag,i.record_src,i.created_date,
								i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_CLUSTER. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;

						--	Update APDS_ASM 
						insert into apds_admin.apds_asm_gt 
							select target_name asm_target_name, substr(target_name,1,5) asm_instance,  host_name,category_prop_1 version,decode(category_prop_3,'exadata','Y','N') exadata_flag,
			            'Y',decode(instr(host_name,'dx'),0,decode(instr(host_name,'fx'),0,decode(instr(host_name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod'),'GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
			      	from SYSMAN.EM_ALL_TARGETS@apds_oms where target_type='osm_instance';

						update apds_admin.apds_asm_gt
						set env_flag=decode(substr(host_name,5,1),'h','Non-Prod')
						where host_name like 'vaathm%';
						commit;

						merge into apds_admin.apds_asm t
							using apds_admin.apds_asm_gt i
							on (t.asm_target_name = i.asm_target_name)
							when not matched then
								insert values(i.asm_target_name,i.asm_instance,i.host_name,i.version,i.exadata_flag,i.active_flag,i.env_flag,i.record_src,i.created_date,i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_ASM. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;

						--	Update APDS_ASM_CLIENT 
						insert into apds_admin.apds_asm_client_gt 
							select distinct cm_target_name asm_target_name, db_name database_name, instance_name, diskgroup,
			            'Y',decode(instr(cm_target_name,'dx'),0,decode(instr(cm_target_name,'fx'),0,decode(instr(cm_target_name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod') env_flag,'GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
			        from sysman.CM$MGMT_ASM_CLIENT_ECM@apds_oms;
						commit;

						merge into apds_admin.apds_asm_client t
							using apds_admin.apds_asm_client_gt i
							on (t.asm_target_name = i.asm_target_name and 
									t.database_name   = i.database_name and
									t.diskgroup       = i.diskgroup)
							when not matched then
								insert values(i.asm_target_name,i.database_name,i.instance_name,i.diskgroup,i.active_flag,i.env_flag,i.record_src,i.created_date,i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_ASM_CLIENT. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;

						--	Update APDS_DATABASE 
						insert into apds_admin.apds_database_gt 
							select distinct t1.target_name database_name, 
				        decode(t1.target_type,'rac_database','RAC-DB','oracle_database',decode(t1.category_prop_5,'FullLLFile+CDB','CDB','DB'),'oracle_pdb','PDB') database_type,
				        decode(t1.category_prop_3,'RACINST','RAC-INSTANCE',decode(t1.target_type,'oracle_database','SINGLE-INSTANCE',upper(t1.target_type))) instance_type,null multitenant_name,null log_mode,
				        t1.category_prop_1 version,t1.host_name,'PRIMARY',null,null bcp_tier,null comments,
						    (case 
						          when instr(t1.host_name,'va33') > 0 then 2  
						          when instr(t1.host_name,'mom') > 0 then 3
						          when instr(t1.host_name,'aws') > 0 then 4
						          else 1
						     end ) deployment_id,
				        null, null,'Y',decode(instr(t1.host_name,'dx'),0,decode(instr(t1.host_name,'fx'),0,decode(instr(t1.host_name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod') env_flag,'Y','GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
			        from SYSMAN.EM_ALL_TARGETS@apds_oms t1
			        where t1.target_type in ('oracle_database','rac_database','oracle_pdb');
			 
						update apds_admin.apds_database_gt
						set env_flag=decode(substr(host_name,5,1),'p','Prod','Non-Prod')
						where host_name like 'vaa%';

						update apds_admin.apds_database_gt
						set env_flag=decode(substr(host_name,5,1),'p','Prod','Non-Prod')
						where host_name like 'va10%';

						update apds_admin.apds_database_gt
						set env_flag=decode(substr(host_name,5,1),'p','Prod','Non-Prod')
						where host_name like 'mom%';
						


				    for i in (select db_unique_name,stby_list,role from apds_admin.apds_database_gt, SYSMAN.MGMT$HA_DG_TARGET_SUMMARY@apds_oms where db_unique_name=database_name  and using_broker='YES') loop
			        update apds_admin.apds_database_gt
			            set database_role=i.role, dr_database_name=i.stby_list
			        where database_name=i.db_unique_name;
				    end loop;
						commit;

						-- Database Records in InfoHub not in Grid Control
			        
						insert into apds_admin.apds_database_gt 
							select database_nm database_name,'DB',null,null multitenant_name,null log_mode,null,server_nm host_name,'PRIMARY',null,null bcp_tier,null comments,
								(case 
								      when instr(server_nm,'va33') > 0 then 2  
								      when instr(server_nm,'mom') > 0 then 3
								      when instr(server_nm,'aws') > 0 then 4
								      else 1
								end) deployment_id,
								null, null,'Y', decode(production_ind,'Y','Prod','Non-Prod') env_flag, decode(production_ind,'Y','Y','N') capture_flag,'INFOHUB',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
							from capacity_prod.all_databases@apds_infohub 
							where upper(database_nm) not in (select upper(database_name) from apds_admin.apds_database_gt) 
              AND   upper(database_nm) not in (select upper((case when regexp_instr(database_name,'[_|.]') > 0 then substr(database_name,regexp_instr(database_name,'[_|.]')+1) 
                  																								else database_name 
            																								end )) database_name from apds_admin.apds_database);
						update apds_admin.apds_database_gt
						set bcp_tier = decode(env_flag,'Prod','TIER-2','Non-Prod','TIER-5')
						where bcp_tier is null;

						update apds_database
						set multitenant_name = (case when regexp_instr(database_name,'[_|.]') > 0 then substr(database_name,1,regexp_instr(database_name,'[_|.]')-1) 
                  											else database_name 
            												end);
						commit;

						merge into apds_admin.apds_database t
							using apds_admin.apds_database_gt i
							on (t.database_name = i.database_name)   
							when not matched then
								insert values(i.database_name,i.database_type,i.instance_type,i.multitenant_name,i.log_mode,i.version,i.host_name,i.database_role,i.dr_database_name,i.bcp_tier,i.comments,i.deployment_id,i.security_flag,i.audit_flag,
								i.active_flag,i.env_flag,i.capture_flag,i.record_src,i.created_date,i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_EXADATA_DATABASE. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;

						--	Update APDS_DB_INSTANCE 
						insert into apds_admin.apds_db_instance_gt 
							select distinct database_name,host_name,instance_name,null instance_type,null sga,null cpu_count,null archive_lag,null comments,
								 (case 
						        when instr(host_name,'va33') > 0 then 2  
						        when instr(host_name,'mom') > 0 then 3
						        when instr(host_name,'aws') > 0 then 4
						            else 1
						     end ) deployment_id,
								'Y',decode(instr(t1.host_name,'dx'),0,decode(instr(t1.host_name,'fx'),0,decode(instr(t1.host_name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod') env_flag,'GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
							from SYSMAN.MGMT$DB_DBNINSTANCEINFO_ALL@apds_oms t1
							where target_type in ('oracle_database') 
							order by instance_name;
						commit;

						-- Instance Records in InfoHub not in Grid Control

						insert into apds_admin.apds_db_instance_gt
						    SELECT database_nm database_name,server_nm host_name,instance_nm instance_name,null instance_type,null sga,null cpu_count,null archive_lag,null comments,
								    (case 
								          when instr(server_nm,'va33') > 0 then 2  
								          when instr(server_nm,'mom') > 0 then 3
								          when instr(server_nm,'aws') > 0 then 4
								          else 1
								     end ) deployment_id,
						        'Y', decode(production_ind,'Y','Prod','Non-Prod') env_flag,'INFOHUB',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
						        from capacity_prod.all_databases@apds_infohub 
						        where upper(database_nm) not in (select upper(database_name) from apds_admin.apds_db_instance)
						        AND   upper(database_nm) not in (select upper((case when regexp_instr(database_name,'[_|.]') > 0 then substr(database_name,regexp_instr(database_name,'[_|.]')+1) 
                  																								else database_name 
            																								end )) database_name from apds_admin.apds_database);
						commit;

						update apds_admin.apds_db_instance_gt
						set env_flag=decode(substr(host_name,5,1),'p','Prod','Non-Prod')
						where host_name in (select host_name from apds_admin.apds_host where os like 'AIX%');
						commit;

						merge into apds_admin.apds_db_instance t
							using apds_admin.apds_db_instance_gt i
							on (t.database_name = i.database_name and
								  t.host_name     = i.host_name and 
								  t.instance_name	= i.instance_name)
							when not matched then
								insert values(i.database_name,i.host_name,i.instance_name,i.instance_type,i.sga,i.cpu_count,i.archive_lag,i.comments,i.deployment_id,i.active_flag,i.env_flag,i.record_src,i.created_date,i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_DB_INSTANCE. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;

						--	Update APDS_LISTENER 
						insert into apds_admin.apds_listener_gt 
							select target_name listener_name, host_name, listener_port,listener_protocol,
			            (case 
					          when instr(host_name,'va33') > 0 then 2  
					          when instr(host_name,'mom') > 0 then 3
					          when instr(host_name,'aws') > 0 then 4
			                  else 1
			             end ) deployment_id, 
			             'Y', decode(instr(host_name,'dx'),0,decode(instr(host_name,'fx'),0,decode(instr(host_name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod') env_flag,'GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
					    from sysman.em_all_targets@apds_oms l, sysman.mgmt_listener_ports_ecm@apds_oms p 
					    where target_type='oracle_listener'
					    and l.host_name=p.machine_name;
						commit;

						merge into apds_admin.apds_listener t
							using apds_admin.apds_listener_gt i
							on (t.listener_name = i.listener_name and
								  t.host_name     = i.host_name and 
								  t.listener_port	= i.listener_port)
							when not matched then
								insert values(i.listener_name,i.host_name,i.listener_port,i.listener_protocol,i.deployment_id,i.active_flag,i.env_flag,i.record_src,i.created_date,i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_LISTENER. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;

						--	Update APDS_ORACLE_SOFTWARE_HOME 
						insert into apds_admin.apds_oracle_software_gt 
							select h.host_name, h.home_location software_home, nvl(h.oui_home_name,'NOT-DEFINED') home_name, h.home_pointer orainventory_loc, h.oh_owner home_owner,h.oh_group home_group,
							    p.patch_id, p.patch_upi,p.install_time patch_install_time, p.description patch_desc,
							    null, (case 
					          when instr(h.host_name,'va33') > 0 then 2  
					          when instr(h.host_name,'mom') > 0 then 3
					          when instr(h.host_name,'aws') > 0 then 4
			                  else 1
			             end ) deployment_id, 
							    'Y',decode(instr(h.host_name,'dx'),0,decode(instr(h.host_name,'fx'),0,decode(instr(h.host_name,'rx'),0,'Prod','Prod-RA'),'DR'),'Non-Prod') env_flag,'GRID-CONTROL',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
						  from SYSMAN.MGMT$OH_HOME_INFO@apds_oms h, SYSMAN.MGMT$OH_PATCH@apds_oms p
						  where h.host_name = p.host_name 
						 	 and h.home_location = p.home_location
						  order by h.host_name;
						commit;

						merge into apds_admin.apds_oracle_software t
							using apds_admin.apds_oracle_software_gt i
							on (t.host_name     = i.host_name and 
								  t.software_home	= i.software_home and
								  t.home_name			=	i.home_name and 
								  t.patch_id			=	i.patch_id)
							when not matched then
								insert values(i.host_name,i.software_home,i.home_name,i.orainventory_loc,i.home_owner,i.home_group,i.patch_id,i.patch_upi,i.patch_install_date,i.patch_desc,i.comments,i.deployment_id,i.active_flag,i.env_flag,i.record_src,i.created_date,i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_ORACLE_SOFTWARE_HOME. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;

						--	Update APDS_APPLICATION 
						insert into apds_admin.apds_application_gt 
							select distinct a.application_nm, a.application_desc,null,d.database_nm,null,'Y','INFOHUB',sysdate,'APDS_ADMIN',sysdate,'APDS_ADMIN'
							from wdbs.applications@apds_infohub a, wdbs.databases@apds_infohub d, (select distinct application_key, database_key 
					    																														 from wdbs.app_db_xref@apds_infohub
					    																														 where database_key in (select database_key from wdbs.databases@apds_infohub i, apds_admin.apds_database d
					        																																								where upper(d.database_name)=upper(i.database_nm))) akey
							where a.application_key = akey.application_key
							 and  akey.database_key = d.database_key
							 and  a.retired='N'
							order by database_nm;
						commit;

						merge into apds_admin.apds_application t
							using apds_admin.apds_application_gt i
							on (t.application_name = i.application_name and 
								  t.database_name		 = i.database_name)
							when not matched then
								insert values(i.application_name,i.application_desc,i.application_sme,i.database_name,i.comments,i.active_flag,i.record_src,i.created_date,i.created_by,i.last_updated_date,i.last_updated_by);
						lrowcount := sql%rowcount;	
				 		lmessage := ' ......  Update APDS_APPLICATION. Rows Merged : '||lrowcount;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
						commit;
          else
						lmessage := ' ......  Error for Database '||i.config_name ||' accessing DB Link '|| i.config_value;
						apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);          
        	end if;
				end if;
			end loop;

			lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
			apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
			job_control_prc(ljob_module,ljob_name,'COMPLETED',0,NULL,'M',NULL,NULL);
    exception
       when others then
        lmessage:=substr(sqlerrm,1,1000);
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'FATAL',lmessage);
				lmessage := ' <-----  Completed Program '||object_name ||'  ----->';
				apds_admin_pkg.write_log_prc('APDS_ADMIN_PKG:'||object_code,'INFORMATIONAL',lmessage);
				job_control_prc(ljob_module,ljob_name,'ERRORED',1,NULL,'M',NULL,'Check APDS_ADMIN.APDS_LOG for more errors');
				commit;
    end update_inventory_prc;		
    
end apds_admin_pkg;
/

-- End of DDL Script for Package APDS_ADMIN.APDS_ADMIN_PKG

