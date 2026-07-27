-- Staging model for FCT_APPLICATION_RESPONSE
-- 1:1 with the source table, light cleanup only (renaming/casting).
-- TODO: replace select * with an explicit column list once youve confirmed
-- exact column names from your Snowflake table (run: DESCRIBE TABLE FCT_APPLICATION_RESPONSE;)

with source as (

    select * from {{ source("insurance_raw", "FCT_APPLICATION_RESPONSE") }}

)

select * from source
