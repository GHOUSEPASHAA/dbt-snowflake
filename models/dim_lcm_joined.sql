{{ config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = ['USER_ID','is_current'],
        
        schema = 'raw'
    )}}

SELECT 
    
    

USER_ID,


ORG_ID,
USER_NAME,
FIRST_NAME,
MIDDLE_NAME,
LAST_NAME,
EMAIL,
IS_DELETED,
UPDATE_DATETIME,
UPDATE_USER_ID,

CASE 
        WHEN dbt_valid_to IS NULL THEN 'Y' 
        ELSE 'N' 
    END AS 
is_current,
YEARS_EXPERIENCE,
POSITION_STATUS_ID,
TIME_ZONE_ID,
SEX,
BIRTH_DATETIME,
ADDRESS_ID,
CREATE_DATETIME,
DATABASE_NAME,
EXTERNAL_LOCATION,
STREAM_LOAD_DATETIME,
    
FROM {{ref('scd_lcm_user')}}


