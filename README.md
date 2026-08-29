# Windows Performance Toolkit

A PowerShell portfolio toolkit for startup diagnostics, system-upgrade readiness, Windows performance assessment, and operational verification.

## Two-dimensional metafield view

```text
                         OPERATIONAL LIFECYCLE
                 INVENTORY   DIAGNOSE   DECIDE   VERIFY
SYSTEM DOMAIN
Hardware            [X]         [ ]       [X]      [X]
Operating system    [X]         [X]       [X]      [X]
Startup             [X]         [X]       [X]      [X]
Performance         [X]         [X]       [X]      [X]
Upgrade readiness   [X]         [X]       [X]      [X]

METAFIELDS
Input     : Hardware, OS, startup, event, and resource information
Process   : Inventory, threshold analysis, diagnostic correlation
Decision  : Ready, warning, blocked, or further review
Output    : Readiness and diagnostic reports
Evidence  : Measured values and observed configuration
Risk      : Generic thresholds may not suit every device
Boundary  : Authorized Windows endpoint
```

## Included scripts

- `SystemUpgradeAudit.ps1`
- `SystemUpgradReadinessAuditScript.ps1`
- `VerifyStartupStatus.ps1`
- `Windows-11-Interception-Lag-Diagnostic.ps1`

## Safe usage

Use the scripts as diagnostic aids. Validate thresholds, avoid automatic process termination, and separate diagnosis from remediation.

## Documentation map

- [Two-dimensional architecture and metafields](docs/Architecture-2D-Metafields.md)
- [Detailed architecture](docs/Architecture.md)
- [Script catalog](docs/Script-Catalog.md)
- [Usage guidance](docs/Usage.md)
- [Testing and quality assurance](docs/Testing.md)
- [Business value](docs/Business-Value.md)
- [Pre-publication checklist](PRE-PUBLISH-CHECKLIST.md)

## Visual assets

- Editable Mermaid source: `assets/diagrams/architecture.mmd`
- Screenshot guidance: `assets/screenshots/README.md`
