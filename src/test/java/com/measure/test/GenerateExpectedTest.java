package com.measure.test;

import com.intuit.karate.junit5.Karate;

/**
 * Generate expected MeasureReports
 */
public class GenerateExpectedTest {

    @Karate.Test
    Karate generateExpected() {
        return Karate.run("classpath:features/util/generate-expected.feature");
    }
}
