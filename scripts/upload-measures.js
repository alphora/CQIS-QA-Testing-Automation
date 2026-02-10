#!/usr/bin/env node

const axios = require('axios');
const fs = require('fs');
const path = require('path');

// Configuration
const FHIR_SERVER = process.env.FHIR_SERVER || 'http://localhost:8000';
const AUTH = {
  username: 'admin',
  password: 'password'
};
const MEASURES_DIR = path.join(__dirname, '..', 'src', 'test', 'resources', 'measures');

// All measure files to upload
const MEASURE_FILES = [
  '1ProportionDateCompStratSDEMulti.json',
  '2ProportionBooleanComponentStratSDEMulti.json',
  '3ProportionStringCriteria.json',
  '4ProportionResourceNoStart.json',
  '5RatioBooleanMultiComponent.json',
  '6RatioDateBasisComponent.json'
];

async function uploadMeasure(measureFile) {
  const filePath = path.join(MEASURES_DIR, measureFile);

  console.log(`\n📤 Uploading ${measureFile}...`);

  try {
    // Read the measure file
    const measureData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    const measureId = measureData.id;

    console.log(`   Measure ID: ${measureId}`);
    console.log(`   URL: ${FHIR_SERVER}/Measure/${measureId}`);

    // Upload using PUT to create/update the measure with specific ID
    const response = await axios.put(
      `${FHIR_SERVER}/Measure/${measureId}`,
      measureData,
      {
        headers: {
          'Content-Type': 'application/fhir+json',
          'Accept': 'application/fhir+json'
        },
        auth: AUTH,
        timeout: 30000
      }
    );

    console.log(`   ✅ Status: ${response.status} ${response.statusText}`);
    return { success: true, file: measureFile, id: measureId };

  } catch (error) {
    console.log(`   ❌ Failed: ${error.message}`);
    if (error.response) {
      console.log(`   Status: ${error.response.status}`);
      console.log(`   Error: ${JSON.stringify(error.response.data, null, 2)}`);
    }
    return { success: false, file: measureFile, error: error.message };
  }
}

async function uploadAllMeasures() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  Uploading Measures to FHIR Server');
  console.log('═══════════════════════════════════════════════════════════');
  console.log(`\nFHIR Server: ${FHIR_SERVER}`);
  console.log(`Measures Directory: ${MEASURES_DIR}`);
  console.log(`Files to upload: ${MEASURE_FILES.length}\n`);

  const results = [];

  for (const measureFile of MEASURE_FILES) {
    const result = await uploadMeasure(measureFile);
    results.push(result);
  }

  console.log('\n═══════════════════════════════════════════════════════════');
  console.log('  Upload Summary');
  console.log('═══════════════════════════════════════════════════════════\n');

  const successful = results.filter(r => r.success);
  const failed = results.filter(r => !r.success);

  console.log(`✅ Successful: ${successful.length}`);
  successful.forEach(r => console.log(`   • ${r.file} (ID: ${r.id})`));

  if (failed.length > 0) {
    console.log(`\n❌ Failed: ${failed.length}`);
    failed.forEach(r => console.log(`   • ${r.file}: ${r.error}`));
  }

  console.log('\n═══════════════════════════════════════════════════════════\n');

  if (failed.length > 0) {
    process.exit(1);
  }
}

uploadAllMeasures();
