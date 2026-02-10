package com.measure.test;

import com.intuit.karate.junit5.Karate;

/**
 * One-time test data setup runner
 */
public class DataSetupTest {

    @Karate.Test
    Karate setupTestData() {
        return Karate.run("classpath:features/setup/load-test-data-simple.feature");
    }
}
