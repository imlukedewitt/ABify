const TestSuite = (() => {
  function run() {
    runServerTests();
  }

  function runServerTests() {
    const test = new UnitTestingApp();
    test.enable();
    test.clearConsole();
    console.log('running server tests\n');

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
  TestStringUtils = require('./helpers/string-utils.test.js');
  TestUtils = require('./helpers/utils.test.js');
  TestSuite.run();
}
