# CQIS QA Testing Automation

A comprehensive testing framework for FHIR Clinical Quality Language (CQL) measures using Karate and Java.

## Overview

This framework provides automated testing capabilities for CQL-based clinical quality measures. It evaluates measure reports against expected results and validates population counts, stratifiers, and supplemental data elements.

## Features

- **Automated Measure Evaluation**: Execute CQL measures against FHIR test data
- **Result Validation**: Compare actual measure reports with expected results
- **Test Data Management**: Load and manage test patients, encounters, and clinical data
- **Library Management**: Hot-reload CQL libraries during development
- **Detailed Reporting**: Generate comprehensive HTML test reports

## Project Structure

```
measure-tests/
├── src/test/
│   ├── java/com/measure/test/     # Test runners
│   │   ├── DataSetupTest.java     # One-time data setup
│   │   ├── ReloadLibraryTest.java # Library reload utility
│   │   └── ProportionMeasuresTest.java # Measure execution
│   └── resources/
│       ├── features/
│       │   ├── setup/             # Data loading features
│       │   ├── measures/          # Measure test scenarios
│       │   └── common/            # Reusable feature components
│       ├── measures/              # Measure definitions (JSON)
│       ├── cql/                   # CQL source files
│       ├── common-data/           # Test data (patients, encounters, etc.)
│       ├── expected-results/      # Expected measure reports
│       └── karate-config.js       # Test configuration
├── target/
│   ├── karate-reports/            # Generated test reports
│   └── test-output/actual-reports/ # Actual measure reports
└── pom.xml
```

## Prerequisites

- Java 17 or higher
- Maven 3.6 or higher
- FHIR Server (configured in karate-config.js)

## Configuration

Edit `src/test/resources/karate-config.js` to configure:
- FHIR server URL
- Authentication credentials
- Test environment settings

## Usage

### 1. Load Test Data (One-Time Setup)

```bash
mvn test -Dtest=DataSetupTest
```

This loads:
- CQL Library
- Measure definitions
- Test organizations, practitioners, patients, and encounters

### 2. Reload CQL Library (After CQL Changes)

```bash
mvn test -Dtest=ReloadLibraryTest
```

Reloads the CQL library from `src/test/resources/cql/LibrarySimple.cql`

### 3. Run All Measures

```bash
mvn test -Dtest=ProportionMeasuresTest
```

### 4. Run Specific Measures

```bash
mvn test -Dtest=ProportionMeasuresTest -Dkarate.options="classpath:features/measures/measure-01.feature classpath:features/measures/measure-03.feature"
```

## Test Measures

| Measure | Type | Description |
|---------|------|-------------|
| measure-01 | Proportion | Date-based with stratifiers and SDE |
| measure-02 | Proportion | Boolean component with stratifiers and SDE |
| measure-03 | Proportion | String criteria-based populations |
| measure-04 | Proportion | Resource-based without start date |

## Test Reports

After running tests, view the detailed HTML report:
```
target/karate-reports/karate-summary.html
```

Actual measure reports are saved to:
```
target/test-output/actual-reports/
```

## Development Workflow

1. **Edit CQL**: Modify `src/test/resources/cql/LibrarySimple.cql`
2. **Reload**: Run `ReloadLibraryTest` to update the library on the FHIR server
3. **Test**: Run measure tests to validate changes
4. **Compare**: Review actual vs expected results in reports

## Adding New Measures

1. Add measure JSON to `src/test/resources/measures/`
2. Add expected results to `src/test/resources/expected-results/`
3. Create feature file in `src/test/resources/features/measures/`
4. Update measure file list in `load-test-data-simple.feature`

## Troubleshooting

### Tests Failing with "mismatched input"
Check that multi-line arrays in feature files are on a single line.

### Connection Refused
Verify FHIR server is running and accessible at the configured URL.

### Library Not Found
Run `DataSetupTest` or `ReloadLibraryTest` to load/reload the library.

## Technologies

- **Karate**: API testing framework
- **JUnit 5**: Test execution
- **Maven**: Build and dependency management
- **FHIR**: Healthcare interoperability standard
- **CQL**: Clinical Quality Language

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]

## Contact

[Add contact information here]
