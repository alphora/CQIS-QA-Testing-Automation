@ignore
Feature: Compare MeasureReports

  Scenario: Compare Population Counts

    * karate.log('__arg:', __arg)
    * def actual = __arg.actual
    * karate.log('actual type:', typeof actual)
    * karate.log('actual has group?:', actual.group != null)
    * def expected = __arg.expected
    * def measureId = __arg.measureId

    * def actualGroup = actual.group[0]
    * def expectedGroup = expected.group[0]

    * karate.log('\n╔══════════════════════════════════════════════════╗')
    * karate.log('║  Comparing Populations for', measureId)
    * karate.log('╚══════════════════════════════════════════════════╝\n')

    # Extract populations
    * def actualPops = actualGroup.population
    * def expectedPops = expectedGroup.population

    # Simple comparison using Karate match
    * def allMatch = true
    * def comparisonResults = {}

    # Compare each expected population with actual
    * def comparePopulations =
      """
      function() {
        for (var i = 0; i < expectedPops.length; i++) {
          var exp = expectedPops[i];
          var popId = exp.id;
          var popCode = exp.code.coding[0].code;
          var expCount = exp.count;

          var act = actualPops.find(function(p) {
            return p.id === popId;
          });
          var actCount = act ? act.count : 0;

          var match = actCount === expCount;

          comparisonResults[popId] = {
            actual: actCount,
            expected: expCount,
            match: match
          };

          if (match) {
            karate.log('  ✅ ' + popId + ': ' + actCount);
          } else {
            karate.log('  ❌ ' + popId + ': Expected ' + expCount + ', Got ' + actCount);
            allMatch = false;
          }
        }
        return allMatch;
      }
      """

    * def allMatch = comparePopulations()

    * karate.log('\n' + (allMatch ? '✅ All populations match!' : '❌ Some populations do not match'))

    # Compare measure score if present
    * def measureScoreMatch = true
    * def actualMeasureScore = actualGroup.measureScore ? actualGroup.measureScore.value : null
    * def expectedMeasureScore = expectedGroup.measureScore ? expectedGroup.measureScore.value : null

    * def compareMeasureScore =
      """
      function() {
        if (expectedMeasureScore === null && actualMeasureScore === null) {
          karate.log('  ℹ️  No measure score to compare');
          return true;
        }

        if (expectedMeasureScore === null || actualMeasureScore === null) {
          karate.log('  ❌ Measure score missing in one report');
          return false;
        }

        // Compare with small tolerance for floating point precision
        var tolerance = 0.0001;
        var diff = Math.abs(actualMeasureScore - expectedMeasureScore);
        var match = diff < tolerance;

        if (match) {
          karate.log('  ℹ️  Measure Score: ' + actualMeasureScore.toFixed(4) + ' (matches expected)');
        } else {
          karate.log('  ⚠️  Measure Score: Expected ' + expectedMeasureScore.toFixed(4) + ', Got ' + actualMeasureScore.toFixed(4) + ' (informational only)');
        }
        return match;
      }
      """

    * def measureScoreMatch = compareMeasureScore()

    # Compare stratifiers if present
    * def stratifierResults = {}
    * def stratifiersMatch = true

    * def actualStratifiers = actualGroup.stratifier || []
    * def expectedStratifiers = expectedGroup.stratifier || []

    * if (expectedStratifiers.length > 0) karate.log('\n📊 Comparing Stratifiers...')

    * def compareStratifiers =
      """
      function() {
        if (expectedStratifiers.length === 0) return true;

        var allStratMatch = true;
        var stratResults = {};

        for (var i = 0; i < expectedStratifiers.length; i++) {
          var expStrat = expectedStratifiers[i];
          var actStrat = actualStratifiers[i];

          if (!actStrat) {
            karate.log('  ❌ Stratifier ' + i + ' missing in actual report');
            allStratMatch = false;
            continue;
          }

          var stratCode = 'stratifier-' + i;
          try {
            if (expStrat.code && expStrat.code.length > 0 && expStrat.code[0].coding && expStrat.code[0].coding.length > 0) {
              stratCode = expStrat.code[0].coding[0].code;
            }
          } catch (e) {
            // Use default stratifier name
          }
          stratResults[stratCode] = { stratum: {} };

          var expStratum = expStrat.stratum || [];
          var actStratum = actStrat.stratum || [];

          for (var j = 0; j < expStratum.length; j++) {
            var expStrum = expStratum[j];
            var actStrum = actStratum[j];

            if (!actStrum) {
              karate.log('  ❌ Stratum ' + j + ' missing');
              allStratMatch = false;
              continue;
            }

            var stratValue = expStrum.value ? expStrum.value.text : 'Stratum-' + j;
            stratResults[stratCode].stratum[stratValue] = {};

            var expPops = expStrum.population || [];
            var actPops = actStrum.population || [];

            for (var k = 0; k < expPops.length; k++) {
              var expPop = expPops[k];
              var popId = expPop.id;
              var popCode = expPop.code.coding[0].code;
              var expCount = expPop.count;

              var actPop = actPops.find(function(p) {
                return p.id === popId;
              });
              var actCount = actPop ? actPop.count : 0;

              var match = actCount === expCount;

              stratResults[stratCode].stratum[stratValue][popId] = {
                expected: expCount,
                actual: actCount,
                match: match
              };

              if (match) {
                karate.log('  ✅ [' + stratValue + '] ' + popId + ': ' + actCount);
              } else {
                karate.log('  ❌ [' + stratValue + '] ' + popId + ': Expected ' + expCount + ', Got ' + actCount);
                allStratMatch = false;
              }
            }
          }
        }

        stratifierResults = stratResults;
        return allStratMatch;
      }
      """

    * def stratifiersMatch = compareStratifiers()

    * karate.log('\n' + (allMatch && stratifiersMatch ? '✅ All populations and stratifiers match!' : '❌ Some comparisons failed'))
    * karate.log('══════════════════════════════════════════════════\n')

    # Return comparison result (measure score is informational only, doesn't affect pass/fail)
    * def overallMatch = allMatch && stratifiersMatch
    * def measureScoreResult = { expected: '#(expectedMeasureScore)', actual: '#(actualMeasureScore)', match: '#(measureScoreMatch)' }
    * def comparisonResult = { populations: '#(comparisonResults)', stratifiers: '#(stratifierResults)', measureScore: '#(measureScoreResult)', allMatch: '#(overallMatch)', passed: '#(overallMatch)' }
