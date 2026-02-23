# CQL Source Files

This directory contains the CQL (Clinical Quality Language) source files for your measures.

## Workflow

### 1. Edit CQL Logic

Edit the CQL file directly:
```bash
# Open in your editor
code src/test/resources/cql/LibrarySimple.cql
```

The CQL file contains all your measure logic - population definitions, stratifiers, etc.

### 2. Reload Library to FHIR Server

After editing the CQL, reload just the library (no need to reload all data):

```bash
mvn test -Dtest=ReloadLibraryTest
```

This will:
- Read the CQL source file
- Base64 encode it
- Update the Library resource on the FHIR server
- **No need to reload measures, patients, encounters, etc.**

### 3. Run Your Measure Tests

After reloading the library, run your measure tests:

```bash
mvn test -Dtest=AllMeasuresTestRun
```

## Benefits

- **Edit CQL in plain text** - no need to manually base64 encode/decode
- **Quick iteration** - reload just the library, not all test data
- **Version control friendly** - CQL files are readable in git diffs
- **References maintained** - Measures automatically use the updated library

## Files

- `LibrarySimple.cql` - Your CQL logic source file
- The library JSON (`common-data/library/LibrarySimple.json`) is still used for initial setup
- This workflow is for **development** when you're iterating on CQL logic
