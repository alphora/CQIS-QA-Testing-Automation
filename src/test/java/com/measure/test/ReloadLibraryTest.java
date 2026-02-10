package com.measure.test;

import com.intuit.karate.junit5.Karate;

/**
 * Test runner to reload CQL library from source file
 * Run this after editing src/test/resources/cql/LibrarySimple.cql
 */
public class ReloadLibraryTest {

    @Karate.Test
    Karate reloadLibrary() {
        return Karate.run("classpath:features/setup/reload-library.feature");
    }
}
