-- Force all init models to run before this one
{{
    config(
        materialized='table'
    )
}}


WITH 
_1 AS (SELECT * FROM {{ ref('init_customers') }})


     

SELECT 'all tables created' AS status
