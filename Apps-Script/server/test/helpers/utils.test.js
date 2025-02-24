const UtilsTest = (() => {
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

  function queue() {
    runInGas(false);
    tester.printHeader('server/helpers/utils.js');

    describe('convert2DArrayToObj()', () => {
      it('converts array to object correctly', () => {
        const result = Utils.convert2DArrayToObj(sampleArray);
        expect(result.length).toEqual(2);
        expect(result[0].name).toEqual('John');
        expect(result[1].city).toEqual('LA');
      });

      it('trims whitespace in headers', () => {
        const arrayWithSpaces = [
          [' name ', ' Age ', ' City '],
          ['John', 25, 'NY']
        ];
        const result = Utils.convert2DArrayToObj(arrayWithSpaces);
        expect(result[0].name).toEqual('John');
      });

      it('lowercases headers', () => {
        const arrayWithSpaces = [
          ['Name', 'Age', 'City'],
          ['John', 25, 'NY']
        ];
        const result = Utils.convert2DArrayToObj(arrayWithSpaces);
        expect(result[0]).toEqualObject({ name: 'John', age: 25, city: 'NY' });
      });
    });

    describe('convertObjTo2DArray()', () => {
      it('converts object to array with headers', () => {
        const result = Utils.convertObjTo2DArray(sampleObject);
        expect(result.length).toEqual(3);
        expect(result[0]).toContain('name');
        expect(result[1]).toContain('John');
      });

      it('respects includeHeaders parameter', () => {
        const result = Utils.convertObjTo2DArray(sampleObject, false);
        expect(result.length).toEqual(2);
        expect(result[0]).not.toContain('name');
      });
    });

    describe('trimObj()', () => {
      it('recursively removes empty values', () => {
        const result = Utils.trimObj(messyObject);
        expect(result).toEqualObject({
          name: 'John',
          nested: { value: 'test' }
        });
      });
    });

    describe('createLookupHash()', () => {
      it('creates single-item lookup', () => {
        const result = Utils.createLookupHash(arrayForLookup, 'id');
        expect(Object.keys(result).length).toEqual(3);
        expect(result[1].name).toEqual('John');
      });

      it('creates multi-item lookup', () => {
        const result = Utils.createLookupHash(arrayForLookup, 'name', false);
        expect(result['John'].length).toEqual(2);
        expect(result['Jane'].length).toEqual(1);
      });

      it('works with key function', () => {
        const result = Utils.createLookupHash(arrayForLookup, item => item.name + item.id);
        expect(result['John1'].name).toEqual('John');
        expect(result['Jane2'].name).toEqual('Jane');
      });
    });
  }

  return { queue };
})();

if (typeof module !== "undefined") {
  Utils = require('../../helpers/utils.js');
  module.exports = UtilsTest;
}
