Feature: Measure 03 - Proportion with String Criteria

  Background:
    * def measureId = '3ProportionStringCriteria'

  Scenario: Evaluate and Validate Measure 03

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
    * def expectedReportRaw = read('classpath:expected-results/3ProportionStringCriteriaResponse.json')
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

    # Print stratifier results if present
    * def stratifiers = comparison.comparisonResult.stratifiers
    * def hasStratifiers = Object.keys(stratifiers).length > 0
    * def printStratifiers =
      """
      function() {
        if (!hasStratifiers) return;

        print('');
        print('STRATIFIERS:');
        var stratKeys = Object.keys(stratifiers);
        for (var i = 0; i < stratKeys.length; i++) {
          var stratCode = stratKeys[i];
          var strat = stratifiers[stratCode];
          print('  Stratifier: ' + stratCode);

          var stratumKeys = Object.keys(strat.stratum);
          for (var j = 0; j < stratumKeys.length; j++) {
            var stratumValue = stratumKeys[j];
            var stratum = strat.stratum[stratumValue];
            print('    [' + stratumValue + ']');

            var popKeys = Object.keys(stratum);
            for (var k = 0; k < popKeys.length; k++) {
              var popCode = popKeys[k];
              var pop = stratum[popCode];
              var icon = pop.match ? '✅' : '❌';
              var msg = '      ' + icon + ' ' + popCode + ': Expected=' + pop.expected + ', Actual=' + pop.actual;
              print(msg);
            }
          }
        }
      }
      """
    * eval printStratifiers()

    # Print overall result
    * print ''
    * def testResult = comparison.comparisonResult.passed ? '✅ PASSED - All assertions match!' : '❌ FAILED - Some assertions do not match'
    * print testResult
    * print ''

    # Step 5: Assert all populations match
    * assert comparison.comparisonResult.passed == true || comparison.comparisonResult.passed == 'true'
