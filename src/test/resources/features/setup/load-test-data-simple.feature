Feature: Load Test Data Once - Simple

  Scenario: Load Library, Measures, and Common Data

    * url fhirServerUrl

    # Setup Basic Authentication
    * def Base64 = Java.type('java.util.Base64')
    * def authString = auth.username + ':' + auth.password
    * def encodedAuth = Base64.getEncoder().encodeToString(authString.getBytes())

    * configure headers = { 'Content-Type': 'application/fhir+json', 'Accept': 'application/fhir+json', 'Authorization': '#("Basic " + encodedAuth)' }

    * karate.log('\n╔════════════════════════════════════════════════════════╗')
    * karate.log('║          LOADING TEST DATA - ONE TIME SETUP           ║')
    * karate.log('╚════════════════════════════════════════════════════════╝\n')

    # Load CQL Library
    * karate.log('📚 Loading CQL Library...')
    * def library = read('classpath:common-data/library/LibrarySimple.json')

    Given path 'Library', library.id
    And request library
    When method put
    And match responseStatus == '#? _ == 200 || _ == 201'
    * karate.log('✅ Library loaded:', library.id)

    # Load Measures
    * karate.log('📊 Loading Measures...')

    # Define all measure files to load (add more filenames here as needed)
    * def measureFiles = ['1ProportionDateCompStratSDEMulti.json','2ProportionBooleanComponentStratSDEMulti.json','3ProportionStringCriteria.json','4ProportionResourceNoStart.json','5RatioBooleanMultiComponent.json','6RatioDateBasisComponent.json']

    # Load each measure
    * def loadMeasure =
      """
      function(fileName) {
        var measure = karate.read('classpath:measures/' + fileName);
        karate.log('  Loading measure:', measure.id);

        var response = karate.call(false, 'classpath:features/setup/load-single-resource.feature', {
          resourceType: 'Measure',
          resourceId: measure.id,
          resource: measure
        });

        karate.log('  ✅ Measure loaded:', measure.id);
        return response;
      }
      """

    * eval for (var i = 0; i < measureFiles.length; i++) loadMeasure(measureFiles[i])
    * karate.log('✅ All measures loaded')

    # Load Organizations
    * karate.log('🏢 Loading Organizations...')
    * def org1 = read('classpath:common-data/organizations/practice-group-utah.json')
    Given path 'Organization', org1.id
    And request org1
    When method put
    And match responseStatus == '#? _ == 200 || _ == 201'
    * karate.log('✅ Organization loaded')

    # Load Practitioners
    * karate.log('👨‍⚕️ Loading Practitioners...')
    * def practitioner1 = read('classpath:common-data/practitioners/practitioner1.json')
    Given path 'Practitioner', practitioner1.id
    And request practitioner1
    When method put
    And match responseStatus == '#? _ == 200 || _ == 201'
    * karate.log('✅ Practitioner loaded')

    # Load Patients
    * karate.log('👥 Loading Patients...')
    * def patient1 = read('classpath:common-data/patients/patient1.json')
    * def patient2 = read('classpath:common-data/patients/patient2.json')

    Given path 'Patient', patient1.id
    And request patient1
    When method put
    And match responseStatus == '#? _ == 200 || _ == 201'

    Given path 'Patient', patient2.id
    And request patient2
    When method put
    And match responseStatus == '#? _ == 200 || _ == 201'
    * karate.log('✅ Patients loaded')

    # Load Encounters
    * karate.log('🏥 Loading Encounters...')
    * def encounter1 = read('classpath:common-data/encounters/Encounter1P1F.json')
    * def encounter2 = read('classpath:common-data/encounters/Encounter2P2IP.json')
    * def encounter3 = read('classpath:common-data/encounters/Encounter3P2IP.json')
    * def encounter4 = read('classpath:common-data/encounters/Encounter4P1C.json')

    Given path 'Encounter', encounter1.id
    And request encounter1
    When method put
    And match responseStatus == '#? _ == 200 || _ == 201'

    Given path 'Encounter', encounter2.id
    And request encounter2
    When method put
    And match responseStatus == '#? _ == 200 || _ == 201'

    Given path 'Encounter', encounter3.id
    And request encounter3
    When method put
    And match responseStatus == '#? _ == 200 || _ == 201'

    Given path 'Encounter', encounter4.id
    And request encounter4
    When method put
    And match responseStatus == '#? _ == 200 || _ == 201'
    * karate.log('✅ Encounters loaded')

    * karate.log('\n╔════════════════════════════════════════════════════════╗')
    * karate.log('║           TEST DATA LOADED SUCCESSFULLY               ║')
    * karate.log('╚════════════════════════════════════════════════════════╝\n')
