{% snapshot scd_dwh_dim_org %}
{{ config(
    target_schema='SNAP',
    unique_key='row_numm',
    strategy='timestamp',
    updated_at='stream_load_datetime',
    invalidate_hard_deletes=True
) }}

SELECT * FROM {{ ref('dwh_dim_org1') }}

{% endsnapshot %}
