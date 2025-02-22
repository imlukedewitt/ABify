const TestSuite = (() => {
  function run() {
    runServerTests();
  }

  function runServerTests() {
    const test = new UnitTestingApp();
    test.enable();
    test.clearConsole();

    test.addNewTest('areObjectsEqual', areObjectsEqual)

    TestCredentials.test();
    TestStringUtils.test();
    TestUtils.test();
  }

  function areObjectsEqual(obj1, obj2) {
    if (typeof obj1 !== 'object' || typeof obj2 !== 'object') {
      throw new Error('Both arguments must be objects');
    }
    
    const keys1 = Object.keys(obj1);
    const keys2 = Object.keys(obj2);

    if (keys1.length !== keys2.length) return false;
    for (let key of keys1) { if (obj1[key] !== obj2[key]) return false; }
    for (let key of keys2) { if (obj1[key] !== obj2[key]) return false; }
    return true;
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
