{{ config(materialized='table') }}

-- Staging raw data from the source table 'MYDB.STAGING.TIMESERIES'
with raw_data as (
    select 
        PERSON_KEY,
        PLAYERID,
        ACCT,
        DURATION,
        EVENT_TIMESTAMP,
        FIRSTNAME,
        LASTNAME,
        ENTITY,
        ACTION,
        DETAILS,
        PROPERTY,
        THEO_WIN,
        CASINO_WIN,
        TRANSACTION_AMOUNT,
        PARSE_JSON(ADDITIONAL_INFO) as ADDITIONAL_INFO_JSON,
        CLUB_LEVEL,
        POINTS_EARNED,
        HYBRID,
        PLAYER_VALUE,
        RUNNING_REDEMPTIONS,
        RUNNING_PLAYER_VALUE,
        RUNNING_PLAYER_VALUE_EARNED,
        REINVESTMENT,
        RUNNING_POINTS_EARNED,
        ADT_90,
        ADT_118,
        ADT_365,
        PLAYER_VALUE_90,
        PLAYER_VALUE_118,
        PLAYER_VALUE_365
    from MYDB.STAGING.TIMESERIES
)

-- Select raw data for staging without transformations
select * from raw_data
