{% snapshot scd_dim_org_type %}

{{
   config(
       target_schema='SNAP',
       unique_key=['org_type_id', 'database_name'],
       strategy='timestamp',
       updated_at='stream_load_datetime',
       invalidate_hard_deletes=True
   )
}}

select *
from {{ source('MYDB', 'DIM_ORG_TYPE') }}

{% endsnapshot %}
