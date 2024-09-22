project_name: "epidemic-dwh"
new_lookml_runtime: yes

constant: TOLERANCE_RANGE {
  value: "0.01"
}

constant: EQUALS_YESTERDAY {
  value: "  = TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY), INTERVAL -1 DAY)"
  }
