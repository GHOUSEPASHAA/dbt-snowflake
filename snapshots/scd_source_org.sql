{% snapshot scd_source_org %}

{{
   config(
       target_schema='SNAP',
       unique_key='org_id',
       strategy='timestamp',
       updated_at='update_datetime',
       invalidate_hard_deletes=True
   )
}}

select * FROM {{ source('MYDB', 'SOURCE_ORG') }}

{% endsnapshot %}