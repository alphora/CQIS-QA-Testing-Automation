Feature: Generate Expected MeasureReport

  Scenario: Generate Expected Result for Measure 01

    * def measureId = '1ProportionDateCompStratSDEMulti'

    # Evaluate measure
    * def result = call read('classpath:features/common/evaluate-measure.feature') { measureId: '#(measureId)' }
    * def measureReport = result.measureReport

    # Save as expected result
    * karate.write(measureReport, 'src/test/resources/expected-results/measure-01-expected.json')

    * karate.log('✅ Expected result saved for measure-01')
    * karate.log('📊 MeasureReport ID:', measureReport.id)
