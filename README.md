# Insurance Underwriting dbt Project

Built around your existing Snowflake tables:

```
DIM_PRODUCT_INFO        DIM_PHYSICAL_ATTRIBUTES   DIM_EMPLOYMENT_INFO
DIM_INSURED_INFO        DIM_INSURANCE_HISTORY     DIM_FAMILY_HISTORY
DIM_MEDICAL_HISTORY     FCT_MEDICAL_KEYWORDS      FCT_APPLICATION_RESPONSE
```

This looks like a classic underwriting/risk star schema: `FCT_APPLICATION_RESPONSE`
is your main fact table (one row per application, ending in an underwriting
response/outcome), `FCT_MEDICAL_KEYWORDS` is a secondary fact table, and the
7 `DIM_*` tables describe the insured person and the product.

---

## The one thing to understand first: nothing gets "uploaded" to Snowflake

Your tables already live in Snowflake — dbt doesn't move them or replace them.
A dbt project is just **a folder of text files** (SQL + YAML) that live on your
computer (or in dbt Cloud's web IDE). When you run `dbt run`, dbt:

1. Reads your `.sql` files
2. Compiles them into real `CREATE TABLE/VIEW ... AS SELECT ...` statements
3. Connects to Snowflake (using credentials in `profiles.yml`) and runs them there

So "uploading the yml file" isn't really a step — you save the file locally,
and the *next command you run* (`dbt run`, `dbt test`, etc.) is what talks to
Snowflake.

---

## Project structure

```
insurance_dbt/
├── dbt_project.yml              ← project config (already set up for you)
├── packages.yml                 ← adds dbt-utils package
├── models/
│   ├── staging/
│   │   ├── _insurance_sources.yml   ← declares your 9 existing tables as sources
│   │   ├── stg_dim_product_info.sql
│   │   ├── stg_dim_physical_attributes.sql
│   │   ├── stg_dim_employment_info.sql
│   │   ├── stg_dim_insured_info.sql
│   │   ├── stg_dim_insurance_history.sql
│   │   ├── stg_dim_family_history.sql
│   │   ├── stg_dim_medical_history.sql
│   │   ├── stg_fct_medical_keywords.sql
│   │   └── stg_fct_application_response.sql
│   └── marts/
│       ├── _marts.yml               ← descriptions + tests for the marts
│       ├── dim_insured_360.sql      ← one row per insured person, all attributes joined
│       └── fct_applications.sql     ← one row per application, enriched + tested
```

**Staging layer** = one model per source table, 1:1, light cleanup only.
**Marts layer** = the two joined, business-ready models people/BI tools actually query.

---

## Setup steps

### 1. Install dbt for Snowflake
```bash
pip install dbt-snowflake
```

### 2. Create `profiles.yml` (this is the file that actually connects to Snowflake)
This file does **not** live inside the project folder — it lives at
`~/.dbt/profiles.yml` on your machine (create the `.dbt` folder if it doesn't exist).

```yaml
insurance_underwriting:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: your_account_id      # e.g. abc12345.us-east-1
      user: your_username
      password: your_password       # or use key-pair / SSO — see dbt docs
      role: your_role
      database: YOUR_DATABASE
      warehouse: YOUR_WAREHOUSE
      schema: dbt_dev                # dbt writes its output models here
      threads: 4
```

### 3. Point sources.yml at your real tables
Open `models/staging/_insurance_sources.yml` and replace:
```yaml
database: YOUR_DATABASE
schema: YOUR_SCHEMA
```
with wherever your 9 tables actually live today (run `SHOW TABLES;` in
Snowflake if you're not sure).

### 4. Confirm real column names
The staging models currently use `select *` as a placeholder. Run this in
Snowflake for each table:
```sql
DESCRIBE TABLE DIM_INSURED_INFO;
```
Then (optional but good practice) replace `select *` in each staging model
with an explicit column list — this makes breaking changes visible immediately
instead of silently.

### 5. Install packages, then run
```bash
dbt deps        # installs dbt-utils from packages.yml
dbt debug       # confirms the Snowflake connection works
dbt run         # builds staging views + mart tables in Snowflake
dbt test        # runs the not_null / unique / relationships tests
dbt docs generate && dbt docs serve   # browsable docs + lineage graph
```

---

## What you get after `dbt run`

In Snowflake, under your configured schema:
- `staging` schema: 9 views, one per source table
- `marts` schema: 2 tables — `dim_insured_360` and `fct_applications`

`fct_applications` is now a single, tested, query-ready table with the
response outcome, product info, and medical keyword count all in one place —
instead of joining 9 tables by hand every time someone needs this data.

## Natural next steps
- Add more generic tests (`accepted_values` on categorical columns once you
  know the real value ranges)
- Add a snapshot on `DIM_INSURED_INFO` if attributes change over time and you
  need history (SCD Type 2)
- Schedule `dbt run` + `dbt test` on a cadence (dbt Cloud job, or Airflow)
