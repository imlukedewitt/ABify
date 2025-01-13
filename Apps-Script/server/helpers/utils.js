// helper functions for working with objects
const Utils = (() => {
  // convert 2D array to object (for reading data from a sheet)
  function convert2DArrayToObj(array) {
    let headers = array[0].map(header => header.toLowerCase().trim());
    return array.slice(1).map(row => {
      let obj = {};
      row.forEach((item, i) => {
        obj[headers[i]] = item;
      });
      return obj;
    });
  }

  // convert object to 2D array (for writing data to a sheet)
  function convertObjTo2DArray(objects, includeHeaders = true) {
    if (objects.length === 0) return [];
    const headers = Object.keys(objects[0]);
    const data = objects.map(obj => headers.map(header => obj[header]));
    return includeHeaders ? [headers, ...data] : data;
  }

  // recursively remove empty strings, null, empty arrays, and empty objects
  function trimObj(obj) {
    return Object.entries(obj).reduce((newObj, [key, value]) => {
      const cleanedValue = (typeof value === 'object' && value !== null && !Array.isArray(value)) ? trimPayload(value) : value;

      if (cleanedValue !== null && cleanedValue !== '' && (!Array.isArray(cleanedValue) || cleanedValue.length > 0) && (typeof cleanedValue !== 'object' || Object.keys(cleanedValue).length > 0)) {
        newObj[key] = cleanedValue;
      }

      return newObj;
    }, {});
  }

  // create a lookup hash from an array of objects
  function createLookupHash(array, keyOrFn, single = true) {
    return array.reduce((obj, item) => {
      const identifier = typeof keyOrFn === 'function' ? keyOrFn(item) : item[keyOrFn];
      
      if (single) {
        obj[identifier] = item;
      } else {
        if (!obj[identifier]) obj[identifier] = [];
        obj[identifier].push(item);
      }
      return obj;
    }, {});
  }

  return {
    convert2DArrayToObj,
    convertObjTo2DArray,
    trimObj,
    createLookupHash
  }
})();