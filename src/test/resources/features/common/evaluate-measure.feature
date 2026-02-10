@ignore
Feature: Common Measure Evaluation Function

  Background:
    * url fhirServerUrl
    * configure headers = { 'Content-Type': 'application/fhir+json', 'Accept': 'application/fhir+json' }
    * def Base64 = Java.type('java.util.Base64')
    * def credentials = auth.username + ':' + auth.password
    * def encodedCredentials = Base64.getEncoder().encodeToString(credentials.getBytes())
    * header Authorization = 'Basic ' + encodedCredentials

  Scenario: Evaluate Measure
    * def measureId = __arg.measureId
    * def evaluationRequest =
      """
      {
        "resourceType": "Parameters",
        "parameter": [
          {
            "name": "periodStart",
            "valueString": "#(evaluationParams.periodStart)"
          },
          {
            "name": "periodEnd",
            "valueString": "#(evaluationParams.periodEnd)"
          },
          {
            "name": "measureId",
            "valueString": "#(measureId)"
          }
        ]
      }
      """

    Given path 'Measure', '$evaluate-measures'
    And request evaluationRequest
    When method post
    Then status 200

    * def bundle = response.parameter[0].resource
    * def measureReport = bundle.entry[0].resource
