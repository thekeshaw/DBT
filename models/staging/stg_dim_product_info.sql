-- Staging model for DIM_PRODUCT_INFO
-- 1:1 with the source table, light cleanup only (renaming/casting).
-- TODO: replace select * with an explicit column list once youve confirmed
-- exact column names from your Snowflake table (run: DESCRIBE TABLE DIM_PRODUCT_INFO;)

with source as (

    select * from {{ source("insurance_raw", "DIM_PRODUCT_INFO") }}

)

select * from source
