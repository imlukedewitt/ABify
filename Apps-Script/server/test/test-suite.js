const TestSuite = {
  run() {
    const test = new UnitTestingApp();
    test.enable();
    test.clearConsole();
    
    TestStringUtils.test();
  }
};

if (typeof module !== "undefined") {
  UnitTestingApp = require('./unit-testing-app.js');
  TestStringUtils = require('./helpers/string-utils.test.js');
  TestSuite.run();
}
