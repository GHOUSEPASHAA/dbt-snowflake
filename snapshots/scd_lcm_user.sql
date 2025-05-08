{% snapshot scd_lcm_user %}

{{
   config(
       target_schema='SNAP',
       unique_key='USER_ID',
       strategy='timestamp',
       updated_at='stream_load_datetime',
       invalidate_hard_deletes=True
   )
}}

select * FROM {{ source('MYDB', 'LCM_USER') }}

{% endsnapshot %}