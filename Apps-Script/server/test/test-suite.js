const TestSuite = {
  run() {
    const test = new UnitTestingApp();
    test.enable();
    test.clearConsole();
    
    // Add all test runs here
    TestStringUtils.test();
  }
};

if (typeof module !== "undefined") {
  module.exports = TestSuite;
}
