Feature: Measure 12 - Ratio Continuous Variable Resource No Stratifiers

  Background:
    * def measureId = '12RatioCVResourceNoStrat'

  Scenario: Evaluate and Validate Measure 12

    # Step 1: Evaluate measure (calls common function)
    * def result = call read('classpath:features/common/evaluate-measure.feature') { measureId: '#(measureId)' }
    * def actualReport = result.measureReport
    * karate.log('actualReport:', actualReport)
    * karate.log('actualReport type:', typeof actualReport)

    # Save actual report to file for review
    * def actualReportFile = 'test-output/actual-reports/' + measureId + '-actual.json'
    * karate.write(actualReport, actualReportFile)
    * karate.log('💾 Actual report saved to:', actualReportFile)

    # Step 2: Load expected report
    * def expectedReportRaw = read('classpath:expected-results/12RatioCVResourceNoStratResponse.json')
    * karate.log('expectedReportRaw:', expectedReportRaw)

    # Extract MeasureReport from Parameters/Bundle structure if needed
    * def expectedReport = expectedReportRaw.resourceType == 'Parameters' ? expectedReportRaw.parameter[0].resource.entry[0].resource : expectedReportRaw
    * karate.log('Extracted expectedReport:', expectedReport)

    # Verify reports have groups
    * match actualReport.group == '#present'
    * match expectedReport.group == '#present'

    # Step 3: Compare reports (calls common function)
    * karate.set('actualForComparison', actualReport)
    * karate.set('expectedForComparison', expectedReport)
    * def comparison = karate.call('classpath:features/common/compare-reports.feature', { actual: karate.get('actualForComparison'), expected: karate.get('expectedForComparison'), measureId: measureId })

    # Step 4: Print test summary for terminal visibility
    * print ''
    * print '╔══════════════════════════════════════════════════════════╗'
    * print '║  TEST RESULT: ' + measureId
    * print '╚══════════════════════════════════════════════════════════╝'

    # Print actual populations with IDs from actual report
    * print ''
    * print 'MAIN POPULATIONS (from actual report):'
    * eval var pops = actualReport.group[0].population; for (var i = 0; i < pops.length; i++) { var pop = pops[i]; var id = pop.id; var code = pop.code.coding[0].code; var count = pop.count; var display = id === code ? id : id + ' (' + code + ')'; print('  ' + display + ': ' + count); }

    # Print comparison results
    * def populations = comparison.comparisonResult.populations
    * print ''
    * print 'COMPARISON RESULTS:'
    * eval var popKeys = Object.keys(populations); for (var i = 0; i < popKeys.length; i++) { var key = popKeys[i]; var pop = populations[key]; var icon = pop.match ? '✅' : '❌'; var msg = '  ' + icon + ' ' + key + ': Expected=' + pop.expected + ', Actual=' + pop.actual; karate.log(msg); print(msg); }

    # Print overall result
    * print ''
    * def testResult = comparison.comparisonResult.passed ? '✅ PASSED - All assertions match!' : '❌ FAILED - Some assertions do not match'
    * print testResult
    * print ''

    # Step 5: Assert all populations match
    * assert comparison.comparisonResult.passed == true || comparison.comparisonResult.passed == 'true'
