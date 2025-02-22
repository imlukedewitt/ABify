if (typeof require !== "undefined") {
  MockData = require('../mock-data.js');
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

if (typeof module !== "undefined") {
  Spreadsheet = require('./spreadsheet-mock.js');
  module.exports = PropertiesServiceMock;
}