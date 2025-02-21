const TestSuite = (() => {
  function run() {
    runServerTests();
  }

  function runServerTests() {
    const test = new UnitTestingApp();
    test.enable();
    test.clearConsole();

    TestCredentials.test();
    TestStringUtils.test();
    TestUtils.test();
  }

  return {
    run,
    runServerTests
  };
})();

if (typeof module !== "undefined") {
  UnitTestingApp = require('./unit-testing-app.js');
  TestCredentials = require('./helpers/credentials.test.js');
  TestStringUtils = require('./helpers/string-utils.test.js');
  TestUtils = require('./helpers/utils.test.js');
  TestSuite.run();
}
