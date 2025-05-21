{% snapshot scd_dim_joined %}

{{
   config(
       target_schema='SNAP',
       unique_key = ['row_id','user_ident','database_name','update_datetime'],
       strategy='check',
       check_cols=['user_ident','database_name','update_datetime','org_id','org_ident','user_name','first_name','middle_name','last_name','email','is_deleted','is_current','years_experience','position_status_id','time_zone_id','sex','birth_datetime','address_ident'],
       invalidate_hard_deletes=True
   )
}}

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
-- CASE 
--         WHEN dbt_valid_to IS NULL THEN 'Y' 
--         ELSE 'N' 
--     END AS 
is_current,
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
    
FROM {{ ref('dim_joined') }}

{% endsnapshot %}
