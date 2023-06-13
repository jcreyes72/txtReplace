create or replace FUNCTION CODE OBJ
(       manuUserName     IN VARCHAR2,
        jobid            IN VARCHAR2)
RETURN INTEGER IS return_code INTEGER;
   /*********************************************************************
    *    name:  CODE OBJ
    * created:  06/13/2023 by Plantensive
    *   DESCR:  DESC
    *           
    * ---------------
    * - INPUT PARAMS
    * ---------------
    * None
    *
    * GRANTS: N/A
    *
    *        Use Case:  USE CASE
    *  Technical Spec:  TBD    
    *--------------------------------------------------------------------
    * REVISION HISTORY
    *--------------------------------------------------------------------
    * Date            Who            Description
    *--------------------------------------------------------------------
    * 06/13/2023      JCR/PG         Initial Creation
    **********************************************************************
    * Confidential Information under Section 2.7 of Partner General Terms 
    * and Conditions ("PGTC") Exclusively for use by Blue Yonder's Cloud 
    * Support team as necessary to perform support obligations as 
    * contemplated in Section 5.2 of PGTC Subject to the Defend Trade 
    * Secrets Act of 2016 (18 U.S.C. §§ 1831-1836)
    *
    * We also are within our rights to ask for the names, emails and roles 
    * of the individuals who are receiving the information.
    *
    * Prepared by Plantensive Solutions Group
    **********************************************************************/

    ------------------------------------
    -- Variable Declarations
    ------------------------------------
        vn_error_code           NUMBER            := SQLCODE;
        vc_error_msg            VARCHAR2(300)     := SQLERRM;
        vc_proc_name            VARCHAR2(30)      := 'CODE OBJ';
        vc_proc_step            VARCHAR2(300)     := vc_proc_name;
        vn_exptn_num            INTEGER           := EXP NUM;  --exception number        	
    ------------------------------------
    -- Cursor Declarations
    ------------------------------------
        -- None
    ------------------------------------
    -- Exception Declarations
    ------------------------------------
        fatal_error            EXCEPTION;

BEGIN
    -------------------------------------------------------------------------
    -- Main Logic
    -------------------------------------------------------------------------

    EXECUTE IMMEDIATE 'ALTER SESSION SET nls_timestamp_format=''YYYY-MM-DD HH24:MI:SS.FF6''';

    return_code := 0;

    CORE_UTILITIES.Log_Info(vc_proc_name,systimestamp,'INFO',return_code,'--- PROGRAM BEGIN ---');

    -------------------------------------------------------------------------
    BEGIN
    vc_proc_step := 'Clear INTERR_IPG TABLE';
    -------------------------------------------------------------------------

        CORE_UTILITIES.Log_Info(vc_proc_name,systimestamp,'INFO',return_code,vc_proc_step);

        DELETE FROM igpmgr.interr_IPG TABLE 
        WHERE
            integration_jobid = vc_proc_name;
        
        CORE_UTILITIES.Log_Info(vc_proc_name,systimestamp,'INFO',return_code,'Rows deleted from INTERR_IPG TABLE: '||SQL%ROWCOUNT);
        COMMIT;

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        vn_error_code := SQLCODE;
        vc_error_msg  := SQLERRM;
        return_code   := 1; --set to failure
        RAISE fatal_error;
    END;  

    -------------------------------------------------------------------------
    BEGIN
    vc_proc_step := 'Clear UDT_USER_EXCEPTION';
    -------------------------------------------------------------------------
    
        CORE_UTILITIES.Log_Info(vc_proc_name,systimestamp,'INFO',return_code,vc_proc_step);

        DELETE FROM scpomgr.udt_user_exception 
        WHERE
            except_jobid = vc_proc_name;
        
        CORE_UTILITIES.Log_Info(vc_proc_name,systimestamp,'INFO',return_code,'Rows deleted from UDT_USER_EXCEPTION: '||SQL%ROWCOUNT);
        COMMIT;

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        vn_error_code := SQLCODE;
        vc_error_msg  := SQLERRM;
        return_code   := 1; --set to failure
        RAISE fatal_error;
    END;  

    -------------------------------------------------------------------------
    BEGIN
    vc_proc_step := 'INSERT EXCEPTIONS INTO UDT_USER_EXCEPTION';
    -------------------------------------------------------------------------
        CORE_UTILITIES.Log_Info(vc_proc_name,systimestamp,'INFO',return_code,vc_proc_step);

        Insert into scpomgr.udt_user_exception
        (
            Except_Date            
            ,Table_Name            
            ,Record_ID            
            ,except_jobid            
            ,Exception           
            ,Descr            
            ,IGP_Err_Str 
            ,DMDUNIT
            ,LOC
        )
        SELECT
            sysdate as Except_Date            
            ,'IPG TABLE' as Table_Name            
            ,except_seq.nextval as Record_ID            
            ,integration_jobid as except_jobid            
            ,vn_exptn_num as Exception            
            ,'ERROR WITH: (DMDUNIT, LOC): ('||nvl(DMDUNIT,'null')||','
                                            ||nvl(LOC,'null')||')'
                                             AS Descr                     
            ,error_str as IGP_Err_Str  
            ,DMDUNIT as DMDUNIT
            ,LOC as LOC
        FROM igpmgr.interr_IPG TABLE
            WHERE integration_jobid = vc_proc_name;

        CORE_UTILITIES.Log_Info(vc_proc_name,systimestamp,'INFO',return_code,'Rows inserted to UDT_USER_EXCEPTION table for IPG TABLE: '||SQL%ROWCOUNT);

        COMMIT;

    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        vn_error_code := SQLCODE;
        vc_error_msg  := SQLERRM;
        return_code   := 1; --set to failure
        RAISE fatal_error;
    END;
    ----------------------------
    -- END
    ----------------------------

    CORE_UTILITIES.Log_Info(vc_proc_name,systimestamp,'INFO',return_code,'--- PROGRAM END ---');
    EXTRACT_SQL_LOG(vc_proc_name); --EXTRACT SQL_LOG TO FILE

    RETURN return_code;

----------------------------
-- EXCEPTIONS
----------------------------

EXCEPTION
	WHEN fatal_error THEN
        CORE_UTILITIES.Log_Error(vc_proc_name,systimestamp,'ERROR',return_code,vn_error_code,
        DBMS_UTILITY.format_error_backtrace,DBMS_UTILITY.format_error_stack);
        EXTRACT_SQL_LOG(vc_proc_name); --EXTRACT SQL_LOG TO FILE
        RETURN return_code;
    WHEN OTHERS THEN
        CORE_UTILITIES.Log_Error(vc_proc_name,systimestamp,'ERROR',return_code,vn_error_code,
        DBMS_UTILITY.format_error_backtrace,DBMS_UTILITY.format_error_stack);
        EXTRACT_SQL_LOG(vc_proc_name); --EXTRACT SQL_LOG TO FILE
        RETURN return_code;
END CODE OBJ;