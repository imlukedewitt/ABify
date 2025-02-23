const StringUtilsTest = (() => {
  const blankValues = [null, '', ' ', [], '\n', '\t', '\r'];
  const nonBlankValues = ['a', 0, 1, {}, [1]];
  const trueValues = [true, 'true', 'TRUE', ' true ', 'TRUE ', ' true'];
  const falseValues = [false, 'false', 'FALSE', ' false ', 'FALSE ', ' false'];

  function run() {
    runInGas(false);
    printHeader('server/helpers/string-utils.js');

    describe('isBlank()', () => {
      it('returns true for blank values', () => {
        blankValues.forEach(value => {
          expect(StringUtils.isBlank(value)).toBeTruthy();
        });
      });

      it('returns false for non-blank values', () => {
        nonBlankValues.forEach(value => {
          expect(StringUtils.isBlank(value)).toBeFalsy();
        });
      });
    });

    describe('isPresent()', () => {
      it('returns true for non-blank values', () => {
        nonBlankValues.forEach(value => {
          expect(StringUtils.isPresent(value)).toBeTruthy();
        });
      });

      it('returns false for blank values', () => {
        blankValues.forEach(value => {
          expect(StringUtils.isPresent(value)).toBeFalsy();
        });
      });
    });

    describe('isTrue()', () => {
      it('returns true for true values', () => {
        trueValues.forEach(value => {
          expect(StringUtils.isTrue(value)).toBeTruthy();
        });
      });

      it('returns false for false values', () => {
        falseValues.forEach(value => {
          expect(StringUtils.isTrue(value)).toBeFalsy();
        });
      });
    });

    describe('isFalse()', () => {
      it('returns true for false values', () => {
        falseValues.forEach(value => {
          expect(StringUtils.isFalse(value)).toBeTruthy();
        });
      });

      it('returns false for true values', () => {
        trueValues.forEach(value => {
          expect(StringUtils.isFalse(value)).toBeFalsy();
        });
      });
    });

    describe('isBoolean()', () => {
      it('returns true for true values', () => {
        trueValues.forEach(value => {
          expect(StringUtils.isBoolean(value)).toBeTruthy();
        });
      });

      it('returns true for false values', () => {
        falseValues.forEach(value => {
          expect(StringUtils.isBoolean(value)).toBeTruthy();
        });
      });

      it('returns false for blank values', () => {
        blankValues.forEach(value => {
          expect(StringUtils.isBoolean(value)).toBeFalsy();
        });
      });

      it('returns false for non-boolean values', () => {
        nonBlankValues.forEach(value => {
          expect(StringUtils.isBoolean(value)).toBeFalsy();
        });
      });
    });

    describe('generateString()', () => {
      it('returns an 8-char string by default', () => {
        Array.from({ length: 100 }).forEach(() => {
          const str = StringUtils.generateString();
          expect(typeof str).toEqual('string');
          expect(str.length).toEqual(8);
        });
      });

      it('returns a string of the specified length', () => {
        Array.from({ length: 100 }).forEach(() => {
          const str = StringUtils.generateString(16);
          expect(typeof str).toEqual('string');
          expect(str.length).toEqual(16);
        });
      });
    });
  }

  return {
    run
  };
})();

if (typeof module !== "undefined") {
  UnitTestingApp = require('../unit-testing-app.js');
  MockData = require('../mock-data.js');
  StringUtils = require('../../helpers/string-utils.js');
  module.exports = StringUtilsTest;
}
