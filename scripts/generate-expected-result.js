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
const OUTPUT_DIR = path.join(__dirname, '..', 'src', 'test', 'resources', 'expected-results');

const MEASURE_ID = '1ProportionDateCompStratSDEMulti';

const EVALUATION_PARAMS = {
  resourceType: "Parameters",
  parameter: [
    { name: "periodStart", valueString: "2024-01-01" },
    { name: "periodEnd", valueString: "2024-12-31" },
    { name: "measureId", valueString: MEASURE_ID }
  ]
};

async function generateExpectedResult() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  Generating Expected MeasureReport for measure-01');
  console.log('═══════════════════════════════════════════════════════════\n');
  console.log(`FHIR Server: ${FHIR_SERVER}`);
  console.log(`Measure ID: ${MEASURE_ID}`);
  console.log(`Output Directory: ${OUTPUT_DIR}\n`);

  // Create output directory
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  try {
    process.stdout.write(`📊 Evaluating ${MEASURE_ID}... `);

    console.log('\n📤 Request Details:');
    console.log('URL:', `${FHIR_SERVER}/Measure/$evaluate-measures`);
    console.log('Parameters:', JSON.stringify(EVALUATION_PARAMS, null, 2));

    // Call $evaluate-measures
    const response = await axios.post(
      `${FHIR_SERVER}/Measure/$evaluate-measures`,
      EVALUATION_PARAMS,
      {
        headers: {
          'Content-Type': 'application/fhir+json',
          'Accept': 'application/fhir+json'
        },
        auth: AUTH,
        timeout: 60000
      }
    );


    // Extract MeasureReport from the response
    let measureReport;
    if (response.data.resourceType === 'Parameters') {
      // Extract from Parameters response
      const bundle = response.data.parameter[0].resource;
      measureReport = bundle.entry[0].resource;
    } else if (response.data.resourceType === 'MeasureReport') {
      measureReport = response.data;
    } else {
      throw new Error('Unexpected response format');
    }

    // Save report
    fs.writeFileSync(outputPath, JSON.stringify(measureReport, null, 2));

    console.log('✅');
    console.log(`\n✅ Expected result saved to: ${outputPath}`);

    // Show population counts
    if (measureReport.group && measureReport.group[0]) {
      console.log('\n📊 Population Counts:');
      const group = measureReport.group[0];
      if (group.population) {
        group.population.forEach(pop => {
          const code = pop.id || pop.code.coding[0].code;
          const count = pop.count;
          console.log(`   • ${code}: ${count}`);
        });
      }
    }

    console.log('\n═══════════════════════════════════════════════════════════');
    console.log('✅ Expected result generated successfully!');
    console.log('═══════════════════════════════════════════════════════════\n');

  } catch (error) {
    console.log('❌');
    console.error('\n❌ Error:', error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data, null, 2));
    }
    process.exit(1);
  }
}

generateExpectedResult();
