---
name: update-documentation
description: "Audit and update all project documentation to match the currently implemented codebase. Use when the user wants to update documentation, sync docs, refresh documentation, update docs, fix outdated docs, align documentation, or bring docs up to date. Triggers on: update documentation, sync docs, refresh docs, update docs, outdated documentation, align docs, documentation update."
---

# Update Documentation

Systematically audit and update all project documentation files to accurately reflect the currently implemented system.

## Instructions

1. **Read the current codebase** to understand what is actually implemented:
   - Read `lib/types.ts` for current type definitions
   - Read `lib/db/schema.ts` for the actual database schema
   - Read `lib/validations.ts` for current validation rules
   - Read `server.ts` for server startup behavior
   - Scan `lib/services/*.ts` and `lib/adapters/*.ts` for business logic and data access patterns
   - Scan `lib/actions/*.ts` for server action signatures
   - Scan `app/` directory for page routes and API routes
   - Read `lib/auth.ts` for authentication mechanisms
   - Read `lib/scoring.ts` for scoring logic
   - Check `components/providers.tsx` for WebSocket/real-time behavior
   - Read `lib/import/athlete-spreadsheet.ts` for import capabilities
   - Check for i18n support (look for translation files or dictionaries)

2. **Read each documentation file** and compare against the codebase:

   - `README.md` — Project overview, setup instructions, feature summary
   - `docs/prd.md` — Product requirements, user stories, data model, page inventory
   - `ui.html` — UI mockups and design tokens (update field labels, remove non-existent fields)
   - `srs.md` — Software requirements specification, entity definitions, API contracts

3. **Fix inaccuracies** — For each doc, correct:
   - **Removed fields**: e.g., `birthDate` and `photo` on Athlete were removed — delete from all entity tables
   - **Wrong enum values**: e.g., Judge role should be `volume_of_game` / `effectiveness` / `finishing`, not `game_volume` / `objectivity` / `finishing`
   - **Missing features**: e.g., audit log with SHA-256 hash chain, XLSX/CSV athlete import, i18n (English/Chinese/Portuguese), data export, score count display
   - **Wrong field names or types**: Cross-reference with `lib/types.ts` and `lib/db/schema.ts`
   - **Outdated architecture descriptions**: e.g., the adapter → service → action layering pattern
   - **Missing pages or routes**: e.g., admin test mode, language toggle, export functionality
   - **Stale scoring descriptions**: e.g., weighted score SQL, per-round submission, bonus field
   - **Wrong scoring criteria names**: The code uses "Volume of Game", "Effectiveness", "Finishing" — ensure docs match

4. **Preserve existing structure and style** — Don't rewrite docs from scratch. Make targeted edits to fix inaccuracies while keeping the original document's voice, format, and organization.

5. **Update data model tables** to match `lib/types.ts` and `lib/db/schema.ts` exactly. Every field name, type, and enum value must be verified.

6. **Add missing sections** if a significant implemented feature has no documentation at all (e.g., audit log, export, i18n). Keep additions concise.

7. **After updating**, run a final verification pass:
   ```bash
   # Verify docs don't reference removed files or fields
   grep -rn "birthDate\|photo\|game_volume\|objectivity" README.md docs/prd.md ui.html srs.md
   # Verify type references match lib/types.ts
   grep -rn "volume_of_game\|effectiveness\|finishing" README.md docs/prd.md ui.html srs.md
   ```

## Relevant Files

### Source of truth (read these to understand what's implemented)
- `lib/types.ts` — All type definitions
- `lib/db/schema.ts` — Database schema and indexes
- `lib/validations.ts` — Validation schemas
- `lib/auth.ts` — Authentication (admin password + judge PIN)
- `lib/scoring.ts` — Scoring SQL and logic
- `server.ts` — Server startup
- `lib/actions/*.ts` — Server action signatures
- `lib/services/*.ts` — Business logic
- `lib/adapters/*.ts` — Data access layer
- `lib/import/athlete-spreadsheet.ts` — Import logic
- `components/providers.tsx` — WebSocket provider
- `app/` — All routes and pages

### Documentation files to update
- `README.md` — Project overview
- `docs/prd.md` — Product requirements document
- `ui.html` — UI mockups
- `srs.md` — Software requirements specification

## Plan Format

When planning the documentation update, create a structured diff list:

```md
# Documentation Update Plan

## Files to Update
- `README.md` — <summary of changes>
- `docs/prd.md` — <summary of changes>
- `ui.html` — <summary of changes>
- `srs.md` — <summary of changes>

## Changes per File

### README.md
- [ ] <specific change>
- [ ] <specific change>

### docs/prd.md
- [ ] <specific change>

### ui.html
- [ ] <specific change>

### srs.md
- [ ] <specific change>

## Validation
- [ ] No references to removed fields (birthDate, photo on Athlete)
- [ ] Judge role enum matches code (volume_of_game, effectiveness, finishing)
- [ ] Data model tables match lib/types.ts exactly
- [ ] All implemented features are documented
```
