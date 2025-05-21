
{{ config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = ['row_id', 'update_datetime','user_ident','stream_load_datetime','dbt_scd_id'],
        
        schema = 'raw'
    )}}


SELECT 
      
        
ROW_ID,
USER_IDENT,
USER_ID,
INFERRED_MEMBER,
ORG_IDENT,
ORG_ID,
USER_NAME,
FIRST_NAME,
MIDDLE_NAME,
LAST_NAME,
EMAIL,
IS_DELETED,
UPDATE_DATETIME,
UPDATE_USER_ID,
RECORD_CREATION_DATE,
RECORD_OBSOLETE_DATE,
DW_DATA_SOURCE_IDENT,
DW_LOAD_DATE,
CASE 
        WHEN dbt_valid_to IS NULL THEN 'Y' 
        ELSE 'N' 
    END AS is_current,
YEARS_EXPERIENCE,
POSITION_STATUS_ID,
TIME_ZONE_ID,
SEX,
BIRTH_DATETIME,
ADDRESS_IDENT,
CREATE_DATETIME,
DATABASE_NAME,
EXTERNAL_LOCATION,
STREAM_LOAD_DATETIME,
dbt_scd_id
    
FROM {{ ref('scd_dim_joined') }}