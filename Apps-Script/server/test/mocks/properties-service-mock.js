if (typeof require !== "undefined") {
  MockData = require('../../lib/mock-data.js');
  Spreadsheet = require('./spreadsheet-mock.js');
}

const PropertiesServiceMock = (() => {
  const mock = new MockData();
  const getUserProperties = () => {
    return {
      getProperty: (key) => mock.getData(key),
      setProperty: (key, value) => mock.addData(key, value)
    };
  }

  return {
    getUserProperties
  }
})();

if (typeof module !== "undefined") module.exports = PropertiesServiceMock;