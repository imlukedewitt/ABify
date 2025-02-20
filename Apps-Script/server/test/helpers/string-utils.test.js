const TestStringUtils = (() => {
  const tester = new UnitTestingApp();

  const blankValues = [null, '', ' ', [], '\n', '\t', '\r'];
  const nonBlankValues = ['a', 0, 1, {}, [1]];
  const trueValues = [true, 'true', 'TRUE', ' true ', 'TRUE ', ' true'];
  const falseValues = [false, 'false', 'FALSE', ' false ', 'FALSE ', ' false'];

  function test() {
    /* ====================
     *     LOCAL TESTS   
     * ==================== */
    tester.runInGas(false);
    tester.printHeader('StringUtils local tests');

    testsForIsBlank();
    testsForIsPresent();
    testsForIsTrue();
    testsForIsFalse();
    testsForIsBoolean();

    /* ====================
     *     ONLINE TESTS 
     * ==================== */
    tester.runInGas(true);
    tester.printHeader('StringUtils online tests');
  }

  function testsForIsBlank() {
    tester.assert(() => {
      return blankValues.every(StringUtils.isBlank);
    }, 'isBlank returns true for blank values');

    tester.assert(() => {
      return nonBlankValues.every(value => !StringUtils.isBlank(value));
    }, 'isBlank returns false for non-blank values');
  }

  function testsForIsPresent() {
    tester.assert(() => {
      return nonBlankValues.every(StringUtils.isPresent);
    }, 'isPresent returns true for non-blank values');

    tester.assert(() => {
      return blankValues.every(value => !StringUtils.isPresent(value));
    }, 'isPresent returns false for blank values');
  }

  function testsForIsTrue() {
    tester.assert(() => {
      return trueValues.every(StringUtils.isTrue);
    }, 'isTrue returns true for true values');

    tester.assert(() => {
      return falseValues.every(value => !StringUtils.isTrue(value));
    }, 'isTrue returns false for false values');
  }

  function testsForIsFalse() {
    tester.assert(() => {
      return falseValues.every(StringUtils.isFalse);
    }, 'isFalse returns true for false values');

    tester.assert(() => {
      return trueValues.every(value => !StringUtils.isFalse(value));
    }, 'isFalse returns false for true values');
  }

  function testsForIsBoolean() {
    tester.assert(() => {
      return trueValues.every(StringUtils.isBoolean);
    }, 'isBoolean returns true for true values');

    tester.assert(() => {
      return falseValues.every(StringUtils.isBoolean);
    }, 'isBoolean returns true for false values');

    tester.assert(() => {
      return blankValues.every(value => !StringUtils.isBoolean(value));
    }, 'isBoolean returns false for blank values');

    tester.assert(() => {
      return nonBlankValues.every(value => !StringUtils.isBoolean(value));
    }, 'isBoolean returns false for non-blank non-boolean values');
  }

  return {
    test
  };
})();

if (typeof module !== "undefined") {
  const UnitTestingApp = require('../unit-testing-app.js');
  const MockData = require('../mock-data.js');
  const StringUtils = require('../../helpers/string-utils.js');
  module.exports = TestStringUtils;
}
