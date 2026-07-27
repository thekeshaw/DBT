-- Staging model for DIM_INSURED_INFO
-- 1:1 with the source table, light cleanup only (renaming/casting).
-- TODO: replace select * with an explicit column list once youve confirmed
-- exact column names from your Snowflake table (run: DESCRIBE TABLE DIM_INSURED_INFO;)

with source as (

    select * from {{ source("insurance_raw", "DIM_INSURED_INFO") }}

)

select * from source
