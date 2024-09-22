connection: "epidemic-dwh"
# persist_with: basic_datagroup # Persisting all explores across the epidemic-dwh with basic_datagroup

## Main explores
include: "/2_refinement_layer/explores/main/*"

## DRM
include: "/2_refinement_layer/explores/drm/*"

##Commercial
include: "/2_refinement_layer/explores/commercial/*"

## Sound
include: "/2_refinement_layer/explores/sound/*"

## Product
include: "/2_refinement_layer/explores/product/*"

## Tech & Tools
include: "/2_refinement_layer/explores/techtools/*"

## Features folder
include: "/3_features/search_sessions/search_session.explore"
include: "/3_features/okr/okr.lkml"
include: "/3_features/gcp_audit/**/bigquery_data_access.explore"
include: "/3_features/gcp_billing/gcp_billing.explore"
include: "/3_features/coupons/discounted_subs.explore"
include: "/3_features/events_per_platform/events_per_platform.explore.lkml"
include: "/3_features/snowplow_ownership/snowplow_ownership.explore.lkml"
include: "/3_features/bigquery_cost/*"

# Experimentation
include: "/3_features/experimentation/assignments_logged_out_subscription_dt.explore.lkml"
include: "/3_features/experimentation/assignments_logged_in.explore.lkml"
include: "/3_features/experimentation/assignments_logged_in_core.explore.lkml"

# Add derived tables
include: "/4_derived_tables/persistent_derived_tables/*"
include: "/4_derived_tables/derived_tables/*"

# Add data tests
include: "/6_data_tests/subscription_tests.lkml"
include: "/6_data_tests/fact_aprecords_amazon_music_track_revenue_tests.lkml"
include: "/6_data_tests/fact_aprecords_fuga_sales_summary_tests.lkml"
include: "/6_data_tests/fact_aprecords_kobalt_revenue_reports_tests.lkml"


# Add data groups
datagroup: basic_datagroup {
  label: "Basic data group"
  description: "Data group that refreshes on successful dbt runs in production, and caches for up to 24 hours. Production runs happen once on most days, and up to a few times on some days."
  sql_trigger:
    select max(latest_successful_execution.invocation_completed_at) as latest_successful_execution
    from `epidemic-dwh-prod.dwh_pii.dim_dbt_model_executions_latest`
    where latest_successful_execution.airflow_dag_id = 'dbt_daily_incremental'
      and environment='prod';;
  max_cache_age: "24 hours"
}

datagroup: refresh_on_first_daily_update {
  label: "Refresh on first daily update"
  description: "Data group that refreshes once a day on any update of the DWH tables and caches for 24 hours. This ensures we avoid excessive PDT rebuilds"
  sql_trigger: SELECT max(DATE(TIMESTAMP_MILLIS(last_modified_time))) FROM epidemic-dwh-prod.analytics.__TABLES__;;
  max_cache_age: "24 hours"
}

# Add access grants
access_grant: dev_access { # access grant for Looker developers
  user_attribute: dev_access
  allowed_values: ["y"]
}

access_grant: admin_access { # access grant for Looker admins
  user_attribute: admin_access
  allowed_values: ["y"]
}

access_grant: gcp_billing_access { # access grant for users that need to access GCP billing
  user_attribute: gcp_billing_access
  allowed_values: ["y"]
}

access_grant: accounting_access { # access grant for users that need to access accounting explores
  user_attribute: accounting_access
  allowed_values: ["y"]
}

access_grant: dsp_royalty_access { # access grant for users that need to access DSP royalty numbers
  user_attribute: dsp_royalty_access
  allowed_values: ["y"]
}

access_grant: artist_portal_access { # access grant for users that need to access artist compensation and royalty numbers
  user_attribute: artist_portal_access
  allowed_values: ["y"]
}

# Add named value formats
named_value_format: sek {
  value_format: "#,##0[$ kr]"
  strict_value_format: no
}

named_value_format: sek_decimals {
  value_format: "#,##0.00[$ kr]"
  strict_value_format: no
}
