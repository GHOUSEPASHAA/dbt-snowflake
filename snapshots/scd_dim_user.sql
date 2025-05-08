{% snapshot scd_dim_user %}

{{
   config(
       target_schema='SNAP',
       unique_key=['USER_IDENT','ADDRESS_IDENT'],
       strategy='timestamp',
       updated_at='update_datetime',
       invalidate_hard_deletes=True
   )
}}

select * FROM {{ source('MYDB', 'DIM_USER') }}

{% endsnapshot %}