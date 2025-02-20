const TestStringUtils = {
  test() {
    const test = new UnitTestingApp();
    console.log(test.isEnabled);
    test.enable();

    // LOCAL TESTS
    test.runInGas(false);
    test.printHeader('StringUtils local tests');
    test.assert(() => 2 + 2 === 4, '2 + 2 should equal 4');

    // ONLINE TESTS
    test.runInGas(true);
    test.printHeader('StringUtils online tests');
    test.assert(() => 3 + 3 === 6, '3 + 3 should equal 6');
  }
};

if (typeof module !== "undefined") {
  const UnitTestingApp = require('../unit-testing-app.js');
  const MockData = require('../mock-data.js');
  const StringUtils = require('../../helpers/string-utils.js');
  module.exports = TestStringUtils;
}
