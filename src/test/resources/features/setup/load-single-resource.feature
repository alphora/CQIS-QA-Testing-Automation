@ignore
Feature: Load Single Resource Helper

  Background:
    * url fhirServerUrl

    # Setup Basic Authentication
    * def Base64 = Java.type('java.util.Base64')
    * def authString = auth.username + ':' + auth.password
    * def encodedAuth = Base64.getEncoder().encodeToString(authString.getBytes())

    * configure headers = { 'Content-Type': 'application/fhir+json', 'Accept': 'application/fhir+json', 'Authorization': '#("Basic " + encodedAuth)' }

  Scenario: Load Resource
    * def resourceType = __arg.resourceType
    * def resourceId = __arg.resourceId
    * def resource = __arg.resource

    Given path resourceType, resourceId
    And request resource
    When method put
    And match responseStatus == '#? _ == 200 || _ == 201'
