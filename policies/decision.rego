package cloudguard

import rego.v1

blocking_violations := [violation |
  some violation in violations
  violation.enforcement == "blocking"
]

warning_violations := [violation |
  some violation in violations
  violation.enforcement == "warning"
]

decision := {
  "allow": count(blocking_violations) == 0,
  "summary": {
    "blocking": count(blocking_violations),
    "warnings": count(warning_violations),
    "total": count(violations)
  },
  "blocking_violations": sort(blocking_violations),
  "warnings": sort(warning_violations)
}
