#!/usr/bin/env python3
"""Evaluate a Terraform plan with OPA and create JSON, HTML, and console reports."""

from __future__ import annotations

import argparse
import html
import json
import subprocess
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("plan", type=Path, help="Terraform plan JSON input")
    parser.add_argument("--policies", type=Path, default=Path("policies"))
    parser.add_argument("--output-dir", type=Path, default=Path("reports"))
    parser.add_argument("--opa", default="opa", help="OPA executable")
    return parser.parse_args()


def evaluate(opa: str, policies: Path, plan: Path) -> dict:
    command = [
        opa,
        "eval",
        "--format=json",
        "--data",
        str(policies),
        "--input",
        str(plan),
        "data.cloudguard.decision",
    ]
    completed = subprocess.run(command, capture_output=True, text=True, check=False)
    if completed.returncode != 0:
        message = completed.stderr.strip() or completed.stdout.strip()
        raise RuntimeError(f"OPA evaluation failed: {message}")

    payload = json.loads(completed.stdout)
    try:
        return payload["result"][0]["expressions"][0]["value"]
    except (KeyError, IndexError, TypeError) as exc:
        raise RuntimeError("OPA returned no CloudGuard decision") from exc


def render_html(decision: dict) -> str:
    allowed = bool(decision.get("allow"))
    status = "PASS" if allowed else "FAIL"
    status_class = "pass" if allowed else "fail"
    violations = decision.get("blocking_violations", []) + decision.get("warnings", [])

    rows = []
    for item in violations:
        rows.append(
            "<tr>"
            f"<td>{html.escape(str(item.get('policy_id', '')))}</td>"
            f"<td>{html.escape(str(item.get('category', '')))}</td>"
            f"<td>{html.escape(str(item.get('severity', '')))}</td>"
            f"<td>{html.escape(str(item.get('enforcement', '')))}</td>"
            f"<td>{html.escape(str(item.get('resource', '')))}</td>"
            f"<td>{html.escape(str(item.get('message', '')))}</td>"
            f"<td>{html.escape(str(item.get('remediation', '')))}</td>"
            "</tr>"
        )

    if not rows:
        rows.append('<tr><td colspan="7">No policy violations detected.</td></tr>')

    summary = decision.get("summary", {})
    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>CloudGuard Policy Report</title>
  <style>
    body {{ font-family: system-ui, sans-serif; margin: 2rem; color: #172033; }}
    .status {{ font-size: 1.4rem; font-weight: 750; }}
    .pass {{ color: #176b3a; }} .fail {{ color: #a32121; }}
    table {{ border-collapse: collapse; width: 100%; margin-top: 1.5rem; }}
    th, td {{ border: 1px solid #d9d9d9; padding: .65rem; text-align: left; vertical-align: top; }}
    th {{ background: #1e3a5f; color: white; }}
    tr:nth-child(even) {{ background: #f5f8fb; }}
  </style>
</head>
<body>
  <h1>CloudGuard Policy Report</h1>
  <p class="status {status_class}">{status}</p>
  <p>Blocking: {summary.get('blocking', 0)} &nbsp; Warnings: {summary.get('warnings', 0)} &nbsp; Total: {summary.get('total', 0)}</p>
  <table>
    <thead><tr><th>Policy</th><th>Category</th><th>Severity</th><th>Mode</th><th>Resource</th><th>Violation</th><th>Remediation</th></tr></thead>
    <tbody>{''.join(rows)}</tbody>
  </table>
</body>
</html>
"""


def print_summary(decision: dict) -> None:
    status = "PASS" if decision.get("allow") else "FAIL"
    summary = decision.get("summary", {})
    print(f"CloudGuard decision: {status}")
    print(
        "Blocking: {blocking} | Warnings: {warnings} | Total: {total}".format(
            blocking=summary.get("blocking", 0),
            warnings=summary.get("warnings", 0),
            total=summary.get("total", 0),
        )
    )
    for item in decision.get("blocking_violations", []) + decision.get("warnings", []):
        print(
            f"[{item.get('enforcement', '').upper()}] {item.get('policy_id')}: "
            f"{item.get('resource')} - {item.get('message')}"
        )


def main() -> int:
    args = parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    try:
        decision = evaluate(args.opa, args.policies, args.plan)
    except (OSError, RuntimeError, json.JSONDecodeError) as exc:
        print(str(exc), file=sys.stderr)
        return 1

    (args.output_dir / "policy-report.json").write_text(
        json.dumps(decision, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    (args.output_dir / "policy-report.html").write_text(
        render_html(decision), encoding="utf-8"
    )
    print_summary(decision)
    return 0 if decision.get("allow") else 2


if __name__ == "__main__":
    raise SystemExit(main())
