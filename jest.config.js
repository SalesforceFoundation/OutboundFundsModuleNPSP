const { jestConfig } = require("@salesforce/sfdx-lwc-jest/config");

const setupFilesAfterEnv = jestConfig.setupFilesAfterEnv || [];
setupFilesAfterEnv.push("<rootDir>/jest.setup.js");

// Repo needs to have have 100% LWC Jest test code coverage across all measures.
const coverageThreshold = jestConfig.coverageThreshold || {};
/*
coverageThreshold.global = {
    branches: 100,
    functions: 100,
    lines: 100,
    statements: 0,
};
*/
// TODO: All LWC Jest tests require 100% code coverage that are not in the block list specified by this glob.  Remove components from the block list specified in this glob when code coverage is met.
coverageThreshold[
    "./force-app/main/default/lwc/!(gauExpenditureRow|lookup|manageExpenditures|manageExpendituresTableHeader)/**"
] = {
    branches: 100,
    functions: 100,
    lines: 100,
    statements: 0,
};

module.exports = {
    ...jestConfig,
    moduleNameMapper: {},
    testPathIgnorePatterns: ["force-app/main/default/lwc/__(tests|mocks)__/"],
    reporters: ["default"],
    setupFilesAfterEnv: setupFilesAfterEnv,
    coverageThreshold: coverageThreshold,
};
