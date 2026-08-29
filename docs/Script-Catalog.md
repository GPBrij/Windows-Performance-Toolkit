# Script Catalog

## SystemUpgradeAudit.ps1

- Purpose: Captures hardware and operating-system information for upgrade planning.
- Input: Processor, memory, firmware, storage, and OS state.
- Output: Readiness inventory.
- Risk: Inventory may contain device identifiers and must remain private.

## SystemUpgradReadinessAuditScript.ps1

- Purpose: Evaluates selected upgrade-readiness conditions.
- Input: System inventory and configured requirements.
- Output: Readiness findings and exceptions.
- Risk: Requirements must be versioned and verified.

## VerifyStartupStatus.ps1

- Purpose: Reviews startup-related status after configuration changes.
- Input: Startup services, applications, and tasks.
- Output: Verification results.
- Risk: Expected startup state varies by device role.

## Windows-11-Interception-Lag-Diagnostic.ps1

- Purpose: Collects evidence relevant to Windows lag, startup interference, filters, and scheduled activity.
- Input: Tasks, services, filters, events, and platform state.
- Output: Diagnostic evidence.
- Risk: Findings require interpretation and may include false positives.
