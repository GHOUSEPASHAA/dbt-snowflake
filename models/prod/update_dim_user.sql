{{ config(
    materialized='incremental',
    unique_key='user_id'
) }}

WITH latest_snapshot AS (
    SELECT *
    FROM {{ ref('scd_lcm_user') }}
    WHERE dbt_valid_to IS NULL
),


existing_user_max_load AS (
    SELECT
        USER_ID,
        MAX(STREAM_LOAD_DATETIME) AS MAX_STREAM_LOAD_DATETIME
    FROM {{ this }}
    GROUP BY USER_ID
),

joined_existing AS (
    SELECT
        COALESCE(t.USER_IDENT, NULL) AS USER_IDENT,
        s.USER_ID,
        COALESCE(t.INFERRED_MEMBER, NULL) AS INFERRED_MEMBER,
        COALESCE(t.ORG_IDENT, NULL) AS ORG_IDENT,
        s.ORG_ID,
        s.USERNAME,
        s.FIRST_NAME,
        s.MIDDLE_NAME,
        s.LAST_NAME,
        s.EMAIL,
        COALESCE(CAST(s.IS_DELETED AS CHAR), t.IS_DELETED) AS IS_DELETED,
        s.UPDATE_DATETIME,
        s.UPDATE_USER_ID,
        COALESCE(t.RECORD_CREATION_DATE, CURRENT_TIMESTAMP()) AS RECORD_CREATION_DATE,
        NULL AS RECORD_OBSOLETE_DATE,
        COALESCE(t.DW_DATA_SOURCE_IDENT, NULL) AS DW_DATA_SOURCE_IDENT,
        CURRENT_TIMESTAMP() AS DW_LOAD_DATE,
        'Y' AS IS_CURRENT,
        s.YEARS_EXPERIENCE,
        s.POSITION_STATUS_ID,
        s.TIME_ZONE_ID,
        s.SEX,
        s.BIRTH_DATETIME,
        COALESCE(t.ADDRESS_IDENT, NULL) AS ADDRESS_IDENT,
        s.CREATE_DATETIME,
        s.DATABASE_NAME,
        s.EXTERNAL_LOCATION,
        s.STREAM_LOAD_DATETIME,
        m.MAX_STREAM_LOAD_DATETIME
    FROM latest_snapshot s
    LEFT JOIN {{ this }} t ON s.USER_ID = t.USER_ID
    LEFT JOIN existing_user_max_load m ON s.USER_ID = m.USER_ID
)

SELECT *
FROM joined_existing

{% if is_incremental() %}
WHERE joined_existing.MAX_STREAM_LOAD_DATETIME IS NULL
   OR joined_existing.STREAM_LOAD_DATETIME > joined_existing.MAX_STREAM_LOAD_DATETIME
{% endif %}
