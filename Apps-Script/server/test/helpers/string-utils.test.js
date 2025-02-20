const TestStringUtils = (() => {
  const blankValues = [null, '', ' ', [], '\n', '\t', '\r'];
  const nonBlankValues = ['a', 0, 1, {}, [1]];
  const trueValues = [true, 'true', 'TRUE', ' true ', 'TRUE ', ' true'];
  const falseValues = [false, 'false', 'FALSE', ' false ', 'FALSE ', ' false'];
  
  function test() {
    const tester = new UnitTestingApp();

    /* ====================
     *     LOCAL TESTS   
     * ==================== */
    tester.runInGas(false);
    tester.printHeader('StringUtils Local Tests');

    testsForIsBlank(tester);
    testsForIsPresent(tester);
    testsForIsTrue(tester);
    testsForIsFalse(tester);
    testsForIsBoolean(tester);
    testsForGenerateString(tester);

    /* ====================
     *     ONLINE TESTS 
     * ==================== */
    tester.runInGas(true);

    // Online tests go here
  }

  function testsForIsBlank(tester) {
    tester.assert(() => {
      return blankValues.every(StringUtils.isBlank);
    }, 'isBlank returns true for blank values');

    tester.assert(() => {
      return nonBlankValues.every(value => !StringUtils.isBlank(value));
    }, 'isBlank returns false for non-blank values');
  }

  function testsForIsPresent(tester) {
    tester.assert(() => {
      return nonBlankValues.every(StringUtils.isPresent);
    }, 'isPresent returns true for non-blank values');

    tester.assert(() => {
      return blankValues.every(value => !StringUtils.isPresent(value));
    }, 'isPresent returns false for blank values');
  }

  function testsForIsTrue(tester) {
    tester.assert(() => {
      return trueValues.every(StringUtils.isTrue);
    }, 'isTrue returns true for true values');

    tester.assert(() => {
      return falseValues.every(value => !StringUtils.isTrue(value));
    }, 'isTrue returns false for false values');
  }

  function testsForIsFalse(tester) {
    tester.assert(() => {
      return falseValues.every(StringUtils.isFalse);
    }, 'isFalse returns true for false values');

    tester.assert(() => {
      return trueValues.every(value => !StringUtils.isFalse(value));
    }, 'isFalse returns false for true values');
  }

  function testsForIsBoolean(tester) {
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
    }, 'isBoolean returns false for non-boolean values');
  }

  function testsForGenerateString(tester) {
    tester.assert(() => {
      return Array.from({ length: 100 }).every(() => {
        const str = StringUtils.generateString();
        return typeof str === 'string' && str.length === 8;
      });
    }, 'generateString returns an 8-char string by default');

    tester.assert(() => {
      return Array.from({ length: 100 }).every(() => {
        const str = StringUtils.generateString(16);
        return typeof str === 'string' && str.length === 16;
      });
    }, 'generateString returns a string of the specified length');
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
