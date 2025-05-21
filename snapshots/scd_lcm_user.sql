{% snapshot scd_lcm_user %}

{{
   config(
       target_schema='SNAP',
       unique_key = 'user_id',
       strategy='check',
       check_cols=['database_name','update_datetime','org_id','user_name','first_name','middle_name','last_name','email','is_deleted','years_experience','position_status_id','time_zone_id','sex','birth_datetime','address_id'],
       invalidate_hard_deletes=True
   )
}}

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
    
FROM {{ source('MYDB','LCM_USER') }}

{% endsnapshot %}
