const TestUtils = (() => {
  const sampleArray = [
    ['Name', 'Age', 'City'],
    ['John', 25, 'NY'],
    ['Jane', 30, 'LA']
  ];

  const sampleObject = [
    { name: 'John', age: 25, city: 'NY' },
    { name: 'Jane', age: 30, city: 'LA' }
  ];

  const messyObject = {
    name: 'John',
    empty: '',
    nullValue: null,
    emptyArray: [],
    emptyObject: {},
    nested: {
      value: 'test',
      empty: '',
      nullValue: null
    }
  };

  const arrayForLookup = [
    { id: 1, name: 'John' },
    { id: 2, name: 'Jane' },
    { id: 3, name: 'John' }
  ];

  function test() {
    const tester = new UnitTestingApp();

    tester.runInGas(false);
    tester.printHeader('Utils');

    tester.describe('convert2DArrayToObj()', () => {
      tester.assert('converts array to object correctly', () => {
        const result = Utils.convert2DArrayToObj(sampleArray);
        return result.length === 2 &&
          result[0].name === 'John' &&
          result[1].city === 'LA';
      });

      tester.assert('handles whitespace in headers', () => {
        const arrayWithSpaces = [
          [' Name ', ' Age ', ' City '],
          ['John', 25, 'NY']
        ];
        const result = Utils.convert2DArrayToObj(arrayWithSpaces);
        return result[0].name === 'John';
      });
    });

    tester.describe('convertObjTo2DArray()', () => {
      tester.assert('converts object to array with headers', () => {
        const result = Utils.convertObjTo2DArray(sampleObject);
        return result.length === 3 &&
          result[0].includes('name') &&
          result[1].includes('John');
      });

      tester.assert('respects includeHeaders parameter', () => {
        const result = Utils.convertObjTo2DArray(sampleObject, false);
        return result.length === 2 &&
          !result[0].includes('name');
      });
    });

    tester.describe('trimObj()', () => {
      tester.assert('removes empty values and maintains structure', () => {
        const result = Utils.trimObj(messyObject);
        return !result.hasOwnProperty('empty') &&
          !result.hasOwnProperty('nullValue') &&
          !result.hasOwnProperty('emptyArray') &&
          !result.hasOwnProperty('emptyObject') &&
          !result.nested.hasOwnProperty('empty') &&
          !result.nested.hasOwnProperty('nullValue');
      });
    });

    tester.describe('createLookupHash()', () => {
      tester.assert('creates single-item lookup', () => {
        const result = Utils.createLookupHash(arrayForLookup, 'id');
        return Object.keys(result).length === 3 &&
          result[1].name === 'John';
      });

      tester.assert('creates multi-item lookup', () => {
        const result = Utils.createLookupHash(arrayForLookup, 'name', false);
        return result['John'].length === 2 &&
          result['Jane'].length === 1;
      });

      tester.assert('works with key function', () => {
        const result = Utils.createLookupHash(arrayForLookup, item => item.name + item.id);
        return result['John1'].name === 'John' &&
          result['Jane2'].name === 'Jane';
      });
    });
  }

  return {
    test
  };
})();

if (typeof module !== "undefined") {
  UnitTestingApp = require('../unit-testing-app.js');
  Utils = require('../../helpers/utils.js');
  module.exports = TestUtils;
}
