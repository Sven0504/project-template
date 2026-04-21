id: governance-ci-fix-001

## Objective
Strengthen governance CI so it validates PR changes instead of relying on static repository content.

## Scope
- scripts/
- specs/
- docs/

## Non-Scope
- src/
- app/
- components/
- db/
- migrations/

## Acceptance
- [ ] Update scripts/ci-governance-check.sh to inspect PR diff
- [ ] Add a trace file documenting this governance fix
- [ ] No production paths are modified

## Constraints
- No production code changes
- Only allowed governance paths may be touched
- All changes must be traceable to this spec