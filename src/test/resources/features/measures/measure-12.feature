Feature: Measure 12 - Ratio CV Resource No Stratifiers

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
    * def expectedReport = read('classpath:expected-results/12RatioCVResourceNoStratResponse.json')
    * karate.log('expectedReport:', expectedReport)

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

    # Print all population results dynamically
    * def populations = comparison.comparisonResult.populations
    * print ''
    * print 'POPULATIONS:'
    * def printPopulations =
      """
      function() {
        var popKeys = Object.keys(populations);
        for (var i = 0; i < popKeys.length; i++) {
          var key = popKeys[i];
          var pop = populations[key];
          var icon = pop.match ? '✅' : '❌';
          var msg = '  ' + icon + ' ' + key + ': Expected=' + pop.expected + ', Actual=' + pop.actual;
          karate.log(msg);
          print(msg);
        }
      }
      """
    * eval printPopulations()

    # Print overall result
    * print ''
    * def testResult = comparison.comparisonResult.passed ? '✅ PASSED - All assertions match!' : '❌ FAILED - Some assertions do not match'
    * print testResult
    * print ''

    # Step 5: Assert all populations match
    * assert comparison.comparisonResult.passed == true || comparison.comparisonResult.passed == 'true'
