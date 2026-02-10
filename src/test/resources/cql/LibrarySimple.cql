library LibrarySimple

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

parameter "Measurement Period" Interval<DateTime> default Interval[@2024-01-01T00:00:00, @2024-12-31T23:59:59]
// cql parameter that can pass in fhir id of an encounter
parameter practitionerParam String

context Patient

// boolean population results
// has matching encounter

define "Initial Population Boolean":
  exists "All Encounters"

define "Denominator Boolean":
    "Initial Population Boolean"

define "Denominator Exclusion Boolean":
  exists "Encounter Cancelled"

define "Denominator Exception Boolean":
  exists "Encounter InProgress"

define "Numerator Exclusion Boolean":
  exists "Encounter Arrived"

define "Numerator Boolean":
  exists "Encounters in Period"

define "Measure Population Exclusions Boolean":
    "Denominator Exclusion Boolean"

define "Measure Population Boolean":
    "Denominator Boolean"

// resource population results
// qty of matching encounters

define "Initial Population Resource":
    "All Encounters"

define "Denominator Resource":
    "Initial Population Resource"

define "Denominator Exclusion Resource":
    "Encounter Cancelled"

define "Denominator Exception Resource":
    "Encounter InProgress"

define "Numerator Exclusion Resource":
    "Encounter Arrived"

define "Numerator Resource":
    "Encounters in Period"

define "Measure Population Exclusions Resource":
    "Denominator Exclusion Resource"

define "Measure Population Resource":
    "Denominator Resource"

// for prospective gap calculations
define "date of compliance":
    "Measurement Period"

// cql to force results
define "always false":
    false

define "always true":
    true

define "list of boolean":
    {true, false, true}

define "list of dates":
  { @2024-01-01, @2024-01-02, @2024-01-03 }

define "list of string":
    {'test1', 'test2', 'test3'}

define "interval":
    Interval[@2024-01-01T00:00:00, @2024-12-31T23:59:59]

define "list of numbers":
    {31, 88, 11}

define "string":
    'string test'

define "date":
    @2026-01-01

define "datetime":
    @2026-12-30T23:59:59

define "NullExample":
         null

define "EmptyListExample":
  { }

define "number":
         31

define "decimal":
         31.31

define "test tuple":
         {
    number: "number",
    dates: "list of dates",
    birthYear: "string"
  }

define "test code":
    "SDE Sex"

// sde single value

// sde list of values

 define "SDE Encounters":
    "All Encounters"

// Continuous Variable
// number of hours for encounter

define function "MeasureObservation"(encounter Encounter):
    duration in minutes of encounter.period

// Cont Variable
// boolean basis age in years to end of measurementPeriod

define function "MeasureObservationBoolean"():
         AgeInYearsAt(end of "Measurement Period")
// component stratifier

define "Gender Stratification":
  Patient.gender.value

define "Age":
AgeInYearsAt(date from end of "Measurement Period")

define function "Age Stratifier Date"(stratificationDate Date):
//   CalculateAgeInYearsAt(Patient.birthDate.value, stratificationDate)
    102

define function "Gender String"(inputString String):
    Patient.gender.value

define function "Test String A"(inputString String):
    'Test Value A'

define "Gender Stratification String":
case
    when Patient.gender = 'male' then 'male'
    when Patient.gender = 'female' then 'female'
    when Patient.gender = 'other' then 'other'
    when Patient.gender = 'unknown' then 'unknown'
    else 'unknown'
  end

define "Gender Stratification Boolean":
    Patient.gender.value


define "SDE Sex":
 case
      when Patient.gender = 'male' then Code { code: 'M', system: 'http://hl7.org/fhir/v3/AdministrativeGender', display: 'Male' }
      when Patient.gender = 'female' then Code { code: 'F', system: 'http://hl7.org/fhir/v3/AdministrativeGender', display: 'Female' }
      else null
    end

define "SDE Sex Boolean":
  Patient.gender in { 'male', 'female', 'other', 'unknown' }


// boolean criteria stratifier

define "boolean strat not finished":
  exists "Encounter Not Finished"

// cql parameter boolean criteria stratifier

define "boolean strat has practitioner":
  exists "Matching General Practitioner"

// resource criteria stratifier

define "resource strat not finished":
    "Encounter Not Finished"

// main criteria logic

define "All Encounters":
     [Encounter] E

define "Encounters in Period":
     [Encounter] E
       where E.period during "Measurement Period" and E.status='finished'

define "Encounter Cancelled":
    [Encounter] E
       where E.status = 'cancelled'

define "Encounter Status":
    [Encounter] E
         return E.status

define "Encounter InProgress":
    [Encounter] E
       where E.status = 'in-progress'

define "Encounter Arrived":
    [Encounter] E
       where E.status = 'arrived'

define "Encounter Not Finished":
    [Encounter] E
        where E.status != 'finished'

define "Matching General Practitioner":
    [Patient] p
       where Last(Split(First(p.generalPractitioner.reference),'/')) = Last(Split(practitionerParam,'/'))



define "ip date":
    { @2024-01-01, @2024-01-05, @2024-01-02, @2024-01-03, @2024-01-04 }

define "den date":
    {  @2024-01-02, @2024-01-05, @2024-01-01 }

define "num date":
    { @2024-01-03, @2024-01-02 }

define "exc date":
    { @2024-01-04 }

define "Measure Population Exclusions date":
    { @2024-01-03 }

define "Measure Population date":
    { @2024-01-03 }

define "string ip":
    {'male', 'female', 'other'}

define "string den":
    {'male', 'female'}

define "string num":
    {'female'}

define "string exc":
    {'other'}

define "string Measure Population Exclusions":
    {'other'}

define "string Measure Population":
    {'male'}

define function "MeasureObservationDate"(observationDate Date):
  duration in days between observationDate and date from end of "Measurement Period"

define function "MeasureObservationString"(observationString String):
  case
    when observationString = 'male' then 100
    when observationString = 'female' then 90
    when observationString = 'other' then 80
    else 0
  end

define function "observation-den-match"(X String):
  if X = Patient.gender then 100 else 50

define function "observation-num-match"(X String):
  if X = Patient.gender then 90 else 40
