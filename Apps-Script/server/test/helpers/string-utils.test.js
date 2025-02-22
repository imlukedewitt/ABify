const TestStringUtils = (() => {
  const blankValues = [null, '', ' ', [], '\n', '\t', '\r'];
  const nonBlankValues = ['a', 0, 1, {}, [1]];
  const trueValues = [true, 'true', 'TRUE', ' true ', 'TRUE ', ' true'];
  const falseValues = [false, 'false', 'FALSE', ' false ', 'FALSE ', ' false'];

  function test() {
    const tester = new UnitTestingApp();

    tester.runInGas(false);
    tester.printHeader('StringUtils');

    tester.describe('isBlank()', () => {
      tester.assert('it returns true for blank values', () => {
        return blankValues.every(StringUtils.isBlank);
      });

      tester.assert('it returns false for non-blank values', () => {
        return nonBlankValues.every(value => !StringUtils.isBlank(value));
      });
    });

    tester.describe('isPresent()', () => {
      tester.assert('it returns true for non-blank values', () => {
        return nonBlankValues.every(StringUtils.isPresent);
      });

      tester.assert('it returns false for blank values', () => {
        return blankValues.every(value => !StringUtils.isPresent(value));
      });
    });

    tester.describe('isTrue()', () => {
      tester.assert('it returns true for true values', () => {
        return trueValues.every(StringUtils.isTrue);
      });

      tester.assert('it returns false for false values', () => {
        return falseValues.every(value => !StringUtils.isTrue(value));
      });
    });

    tester.describe('isFalse()', () => {
      tester.assert('it returns true for false values', () => {
        return falseValues.every(StringUtils.isFalse);
      });

      tester.assert('it returns false for true values', () => {
        return trueValues.every(value => !StringUtils.isFalse(value));
      });
    });

    // testsForIsBoolean(tester);
    tester.describe('isBoolean()', () => {
      tester.assert('it returns true for true values', () => {
        return trueValues.every(StringUtils.isBoolean);
      });

      tester.assert('it returns true for false values', () => {
        return falseValues.every(StringUtils.isBoolean);
      });

      tester.assert('it returns false for blank values', () => {
        return blankValues.every(value => !StringUtils.isBoolean(value));
      });

      tester.assert('it returns false for non-boolean values', () => {
        return nonBlankValues.every(value => !StringUtils.isBoolean(value));
      });
    });

    // testsForGenerateString(tester);
    tester.describe('generateString()', () => {
      tester.assert('generateString returns an 8-char string by default', () => {
        return Array.from({ length: 100 }).every(() => {
          const str = StringUtils.generateString();
          return typeof str === 'string' && str.length === 8;
        });
      });

      tester.assert('generateString returns a string of the specified length', () => {
        return Array.from({ length: 100 }).every(() => {
          const str = StringUtils.generateString(16);
          return typeof str === 'string' && str.length === 16;
        });
      });
    });
  }

  return {
    test
  };
})();

if (typeof module !== "undefined") {
  UnitTestingApp = require('../unit-testing-app.js');
  MockData = require('../mock-data.js');
  StringUtils = require('../../helpers/string-utils.js');
  module.exports = TestStringUtils;
}
