function fn() {

  var env = karate.env || 'dev';
  karate.log('═══════════════════════════════════════════════');
  karate.log('Karate Environment:', env);
  karate.log('═══════════════════════════════════════════════');

  var config = {
    // FHIR Server Configuration
    fhirServerUrl: 'http://localhost:8000',

    // Authentication
    auth: {
      username: 'admin',
      password: 'password'
    },

    // Resource Paths
    paths: {
      commonData: 'classpath:common-data',
      measures: 'classpath:measures',
      expectedResults: 'classpath:expected-results'
    },

    // Default Measure Evaluation Parameters
    evaluationParams: {
      periodStart: '2024-01-01',
      periodEnd: '2024-12-31',
      reportType: 'summary'  // Population report
    },

    // Output Paths (for saving generated reports)
    outputPaths: {
      generatedReports: 'test-output/generated-reports',
      comparisonResults: 'test-output/comparison-results'
    },

    // Test Data
    testPatients: ['patient1', 'patient2'],

    // Timeout Settings (milliseconds)
    timeouts: {
      default: 30000,       // 30 seconds
      setup: 120000,        // 2 minutes
      evaluation: 60000     // 1 minute
    },

    // Comparison Configuration
    ignoreFields: [
      'id',
      'meta',
      'date',
      'text',
      'contained'
    ],

    // Feature Flags
    features: {
      saveGeneratedReports: true,
      saveComparisonResults: true,
      detailedLogging: true,
      parallelExecution: true
    },

    // Measure List (for bulk operations)
    measures: [
      'measure-01', 'measure-02', 'measure-03', 'measure-04',
      'measure-05', 'measure-06', 'measure-07', 'measure-08',
      'measure-09', 'measure-10', 'measure-11', 'measure-12',
      'measure-13', 'measure-14', 'measure-15', 'measure-16',
      'measure-17', 'measure-18', 'measure-19', 'measure-20'
    ]
  };

  // Environment-specific overrides
  if (env === 'dev') {
    config.fhirServerUrl = 'http://localhost:8000';
    config.features.detailedLogging = true;
  } else if (env === 'test') {
    config.fhirServerUrl = 'http://test-server:8000';
    config.features.detailedLogging = false;
  } else if (env === 'ci') {
    config.fhirServerUrl = 'http://ci-server:8000';
    config.features.detailedLogging = false;
    config.features.parallelExecution = true;
  }

  // Configure Karate HTTP client
  karate.configure('connectTimeout', config.timeouts.default);
  karate.configure('readTimeout', config.timeouts.default);
  karate.configure('ssl', true);
  karate.configure('logPrettyRequest', config.features.detailedLogging);
  karate.configure('logPrettyResponse', config.features.detailedLogging);

  // Log configuration
  karate.log('FHIR Server:', config.fhirServerUrl);
  karate.log('Report Type:', config.evaluationParams.reportType);
  karate.log('Test Patients:', config.testPatients);
  karate.log('Save Reports:', config.features.saveGeneratedReports);
  karate.log('═══════════════════════════════════════════════\n');

  return config;
}
