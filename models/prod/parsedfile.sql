{{ config(materialized='table') }}

with raw_data as (
    select 
        *
    from {{ref('unparsedfile')}}
),

parsed_data as (
    select 
        PERSON_KEY,
        
        
        
        ADDITIONAL_INFO_JSON:"Beverage Description"::STRING as BEVERAGE_DESCRIPTION,
        ADDITIONAL_INFO_JSON:"Beverage Name"::STRING as BEVERAGE_NAME,
        ADDITIONAL_INFO_JSON:"Beverage Type"::STRING as BEVERAGE_TYPE,
        ADDITIONAL_INFO_JSON:"CASH_ROOM_REVENUE"::NUMBER as CASH_ROOM_REVENUE,
        ADDITIONAL_INFO_JSON:"COMP_ROOM_REVENUE"::NUMBER as COMP_ROOM_REVENUE,
        ADDITIONAL_INFO_JSON:"Club Level Name"::STRING as CLUB_LEVEL_NAME,
        ADDITIONAL_INFO_JSON:"Description"::STRING as DESCRIPTION,
        ADDITIONAL_INFO_JSON:"Guest Duration"::NUMBER as GUEST_DURATION,
        ADDITIONAL_INFO_JSON:"MEMBERSHIP_LEVEL"::STRING as MEMBERSHIP_LEVEL,
        ADDITIONAL_INFO_JSON:"Netprice"::NUMBER as NETPRICE,
        ADDITIONAL_INFO_JSON:"ORDERID"::STRING as ORDERID,
        ADDITIONAL_INFO_JSON:"Price"::NUMBER as PRICE,
        ADDITIONAL_INFO_JSON:"REVENUE"::NUMBER as REVENUE,
        ADDITIONAL_INFO_JSON:"Short Description"::STRING as SHORT_DESCRIPTION,
        ADDITIONAL_INFO_JSON:"TERMINAL_NAME"::STRING as TERMINAL_NAME,
        ADDITIONAL_INFO_JSON:"TRANSACTION_DATA_ID"::NUMBER as TRANSACTION_DATA_ID,
        ADDITIONAL_INFO_JSON:"amount"::NUMBER as AMOUNT,
        ADDITIONAL_INFO_JSON:"auth_amount"::NUMBER as AUTH_AMOUNT,
        ADDITIONAL_INFO_JSON:"bank"::STRING as BANK,
        ADDITIONAL_INFO_JSON:"bet"::NUMBER as BET,
        ADDITIONAL_INFO_JSON:"cashbuyin"::NUMBER as CASHBUYIN,
        ADDITIONAL_INFO_JSON:"casino_name"::STRING as CASINO_NAME,
        ADDITIONAL_INFO_JSON:"casino_win"::NUMBER as CASINO_WIN,
        ADDITIONAL_INFO_JSON:"casinowin"::NUMBER as CASINOWIN,
        ADDITIONAL_INFO_JSON:"chipbuyin"::NUMBER as CHIPBUYIN,
        ADDITIONAL_INFO_JSON:"club_level"::STRING as CLUB_LEVEL,
        ADDITIONAL_INFO_JSON:"creditbuyin"::NUMBER as CREDITBUYIN,
        ADDITIONAL_INFO_JSON:"game_displayname"::STRING as GAME_DISPLAYNAME,
        ADDITIONAL_INFO_JSON:"game_end"::TIMESTAMP as GAME_END,
        ADDITIONAL_INFO_JSON:"game_points_earned"::NUMBER as GAME_POINTS_EARNED,
        ADDITIONAL_INFO_JSON:"game_start"::TIMESTAMP as GAME_START,
        ADDITIONAL_INFO_JSON:"game_title"::STRING as GAME_TITLE,
        ADDITIONAL_INFO_JSON:"hold_pct"::NUMBER as HOLD_PCT,
        ADDITIONAL_INFO_JSON:"items"::ARRAY as ITEMS_ARRAY,
        ADDITIONAL_INFO_JSON:"locncode"::STRING as LOCNCODE,
        ADDITIONAL_INFO_JSON:"model"::STRING as MODEL,
        ADDITIONAL_INFO_JSON:"outlet"::STRING as OUTLET,
        ADDITIONAL_INFO_JSON:"paid_out"::NUMBER as PAID_OUT,
        ADDITIONAL_INFO_JSON:"paidout"::NUMBER as PAIDOUT,
        ADDITIONAL_INFO_JSON:"plays"::NUMBER as PLAYS,
        ADDITIONAL_INFO_JSON:"prizecode"::STRING as PRIZECODE,
        ADDITIONAL_INFO_JSON:"prizename"::STRING as PRIZENAME,
        ADDITIONAL_INFO_JSON:"promobuyin"::NUMBER as PROMOBUYIN,
        ADDITIONAL_INFO_JSON:"rating_period_minutes"::NUMBER as RATING_PERIOD_MINUTES,
        ADDITIONAL_INFO_JSON:"redeem_trancode"::STRING as REDEEM_TRANCO,
        ADDITIONAL_INFO_JSON:"room"::STRING as ROOM,
        ADDITIONAL_INFO_JSON:"room_cat_descr"::STRING as ROOM_CAT_DESCR,
        ADDITIONAL_INFO_JSON:"room_category"::STRING as ROOM_CATEGORY,
        ADDITIONAL_INFO_JSON:"room_class"::STRING as ROOM_CLASS,
        ADDITIONAL_INFO_JSON:"rtptheo"::NUMBER as RTPTHEO,
        ADDITIONAL_INFO_JSON:"serialnumber"::STRING as SERIALNUMBER,
        ADDITIONAL_INFO_JSON:"settle_trancode"::STRING as SETTLE_TRANCO,
        ADDITIONAL_INFO_JSON:"sitecode"::STRING as SITECODE,
        ADDITIONAL_INFO_JSON:"sitename"::STRING as SITENAME,
        ADDITIONAL_INFO_JSON:"theorwin"::NUMBER as THEORWIN,
        ADDITIONAL_INFO_JSON:"total_amount"::NUMBER as TOTAL_AMOUNT,
        ADDITIONAL_INFO_JSON:"tournamentid"::STRING as TOURNAMENTID,
        
        
    from raw_data
)

select * from parsed_data