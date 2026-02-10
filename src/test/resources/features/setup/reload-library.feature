Feature: Reload CQL Library

  Scenario: Reload Library from CQL Source File

    * url fhirServerUrl

    # Setup Basic Authentication
    * def Base64 = Java.type('java.util.Base64')
    * def authString = auth.username + ':' + auth.password
    * def encodedAuth = Base64.getEncoder().encodeToString(authString.getBytes())

    * configure headers = { 'Content-Type': 'application/fhir+json', 'Accept': 'application/fhir+json', 'Authorization': '#("Basic " + encodedAuth)' }

    * karate.log('\n╔════════════════════════════════════════════════════════╗')
    * karate.log('║          RELOADING CQL LIBRARY FROM SOURCE            ║')
    * karate.log('╚════════════════════════════════════════════════════════╝\n')

    # Read the CQL source file
    * karate.log('📚 Reading CQL source file...')
    * def cqlContent = karate.readAsString('classpath:cql/LibrarySimple.cql')

    # Encode CQL to base64
    * karate.log('🔐 Encoding CQL to base64...')
    * def encodedCql = Base64.getEncoder().encodeToString(cqlContent.getBytes())

    # Create Library resource with encoded CQL
    * def library =
      """
      {
        "resourceType": "Library",
        "id": "LibrarySimple",
        "url": "http://example.com/Library/LibrarySimple",
        "name": "LibrarySimple",
        "status": "active",
        "type": {
          "coding": [ {
            "system": "http://terminology.hl7.org/CodeSystem/library-type",
            "code": "logic-library"
          } ]
        },
        "content": [ {
          "contentType": "text/cql",
          "data": "#(encodedCql)"
        } ]
      }
      """

    # Upload library to FHIR server
    * karate.log('⬆️  Uploading library to FHIR server...')
    Given path 'Library', library.id
    And request library
    When method put
    And match responseStatus == '#? _ == 200 || _ == 201'

    * karate.log('✅ Library reloaded successfully!')
    * karate.log('\n╔════════════════════════════════════════════════════════╗')
    * karate.log('║          LIBRARY RELOAD COMPLETE                      ║')
    * karate.log('╚════════════════════════════════════════════════════════╝\n')
