package com.measure.test;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Test Runner for All Measures
 */
public class ProportionMeasuresTest {

    @Test
    void runMeasures() {
        Results results = Runner.path("classpath:features/measures")
                .outputCucumberJson(true)
                .karateEnv("dev")
                .parallel(1);

        printTestSummary(results);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    private void printTestSummary(Results results) {
        System.out.println("\n╔══════════════════════════════════════════════════════════╗");
        System.out.println("║              MEASURE TEST EXECUTION SUMMARY              ║");
        System.out.println("╚══════════════════════════════════════════════════════════╝\n");

        results.getScenarioResults().forEach(scenario -> {
            String measureName = extractMeasureName(scenario.getScenario().getFeature().getName());
            String status = scenario.isFailed() ? "❌ FAILED" : "✅ PASSED";
            String scenarioName = scenario.getScenario().getName();

            System.out.printf("  %s - %s: %s%n", status, measureName, scenarioName);

            if (scenario.isFailed()) {
                System.out.println("    Error: " + scenario.getErrorMessage());
            }
        });

        System.out.println("\n═══════════════════════════════════════════════════════════");
        System.out.printf("  Total: %d | Passed: %d | Failed: %d | Time: %.2fs%n",
                results.getFeaturesTotal(),
                results.getFeaturesPassed(),
                results.getFeaturesFailed(),
                results.getTimeTakenMillis() / 1000.0);
        System.out.println("═══════════════════════════════════════════════════════════\n");
    }

    private String extractMeasureName(String featureName) {
        // Extract measure name from feature name
        // e.g., "Measure 01 - Proportion Date with Stratifiers" -> "Measure 01"
        if (featureName.contains("-")) {
            return featureName.substring(0, featureName.indexOf("-")).trim();
        }
        return featureName;
    }
}
