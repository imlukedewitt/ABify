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

    /* ====================
     *     LOCAL TESTS   
     * ==================== */
    tester.runInGas(false);
    tester.printHeader('Utils Local Tests');

    testsForConvert2DArrayToObj(tester);
    testsForConvertObjTo2DArray(tester);
    testsForTrimObj(tester);
    testsForCreateLookupHash(tester);

    /* ====================
     *     ONLINE TESTS 
     * ==================== */
    tester.runInGas(true);
    // tester.printHeader('Utils Online Tests');
    // Online tests go here
  }

  function testsForConvert2DArrayToObj(tester) {
    tester.assert(() => {
      const result = Utils.convert2DArrayToObj(sampleArray);
      return result.length === 2 &&
        result[0].name === 'John' &&
        result[1].city === 'LA';
    }, 'convert2DArrayToObj converts array to object correctly');

    tester.assert(() => {
      const arrayWithSpaces = [
        [' Name ', ' Age ', ' City '],
        ['John', 25, 'NY']
      ];
      const result = Utils.convert2DArrayToObj(arrayWithSpaces);
      return result[0].name === 'John';
    }, 'convert2DArrayToObj handles whitespace in headers');
  }

  function testsForConvertObjTo2DArray(tester) {
    tester.assert(() => {
      const result = Utils.convertObjTo2DArray(sampleObject);
      return result.length === 3 &&
        result[0].includes('name') &&
        result[1].includes('John');
    }, 'convertObjTo2DArray converts object to array with headers');

    tester.assert(() => {
      const result = Utils.convertObjTo2DArray(sampleObject, false);
      return result.length === 2 &&
        !result[0].includes('name');
    }, 'convertObjTo2DArray respects includeHeaders parameter');
  }

  function testsForTrimObj(tester) {
    tester.assert(() => {
      const result = Utils.trimObj(messyObject);
      return !result.hasOwnProperty('empty') &&
        !result.hasOwnProperty('nullValue') &&
        !result.hasOwnProperty('emptyArray') &&
        !result.hasOwnProperty('emptyObject') &&
        !result.nested.hasOwnProperty('empty') &&
        !result.nested.hasOwnProperty('nullValue');
    }, 'trimObj removes empty values and maintains structure');
  }

  function testsForCreateLookupHash(tester) {
    tester.assert(() => {
      const result = Utils.createLookupHash(arrayForLookup, 'id');
      return Object.keys(result).length === 3 &&
        result[1].name === 'John';
    }, 'createLookupHash creates single-item lookup');

    tester.assert(() => {
      const result = Utils.createLookupHash(arrayForLookup, 'name', false);
      return result['John'].length === 2 &&
        result['Jane'].length === 1;
    }, 'createLookupHash creates multi-item lookup');

    tester.assert(() => {
      const result = Utils.createLookupHash(arrayForLookup, item => item.name + item.id);
      return result['John1'].name === 'John' &&
        result['Jane2'].name === 'Jane';
    }, 'createLookupHash works with key function');
  }

  return {
    test
  };
})();

if (typeof module !== "undefined") {
  const UnitTestingApp = require('../unit-testing-app.js');
  const Utils = require('../../helpers/utils.js');
  module.exports = TestUtils;
}
