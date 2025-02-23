const TestCredentials = (() => {
  function test() {
    const tester = new UnitTestingApp();

    tester.runInGas(false);
    tester.printHeader('Credentials');

    tester.do(() => {
      PropertiesService.getUserProperties().setProperty('credentials', JSON.stringify({
        '0987654321-abify debug credentials': {
          subdomain: 'subdomain',
          domain: 'domain.com',
          apiKey: '1234567890',
          spreadsheetID: '0987654321'
        }
      }));
    })

    tester.assert('it returns credentials by site name when spreadsheed ID is provided', () => {
      const result = Credentials.getCredentialsForSite('abify debug credentials', '0987654321');
      return typeof result === 'object' &&
        result.subdomain === 'subdomain' &&
        result.domain === 'domain.com' &&
        result.apiKey === '1234567890' &&
        result.spreadsheetID === '0987654321';
    });

    tester.assert('it returns null if no credentials are found', () =>
      Credentials.getCredentialsForSite('abify debug credentials', '1234567890') === null);

    tester.assert('it uses the current spreadsheet if an ID not provided', () => {
      const result = Credentials.getCredentialsForSite('abify debug credentials');
      return typeof result === 'object' &&
        result.subdomain === 'subdomain' &&
        result.domain === 'domain.com' &&
        result.apiKey === '1234567890' &&
        result.spreadsheetID === '0987654321';
    });

    tester.assert('it stores credentials', () => {
      Credentials.storeCredentials('example site', 'example', 'example.com', '1234');
      const result = Credentials.getCredentialsForSite('example site');
      return tester.areObjectsEqual(result, {
        subdomain: 'example',
        domain: 'example.com',
        apiKey: '1234',
        spreadsheetID: Spreadsheet.getID(),
        siteName: 'example site'
      });
    });

    tester.assert('it deletes credentials', () => {
      Credentials.storeCredentials('example site', 'example', 'example.com', '1234');
      Credentials.deleteCredentials('example site');
      return Credentials.getCredentialsForSite('example site') === null;
    });

    tester.assert('it returns the domain', () => {
      const result = Credentials.getDomain('abify debug credentials', '0987654321');
      return result === 'domain.com';
    });

    tester.assert('it lists sites', () => {
      const result = Credentials.listSites();
      return result.length === 1 && tester.areObjectsEqual(result[0], {
        subdomain: 'subdomain',
        domain: 'domain.com',
        apiKey: '1234567890',
        spreadsheetID: '0987654321',
        siteName: 'abify debug credentials'
      });
    });

    tester.assert('is return ABify base URL', () => {
      const result = Credentials.baseUrl.abify;
      return result === 'https://abify.onrender.com';
    });

    tester.assert('it returns ABify credentials', () => {
      Credentials.saveABifyCredentials('username', 'password');
      return tester.areObjectsEqual(
        Credentials.ABifyCredentials(),
        { username: 'username', password: 'password' }
      );
    });
  }

  return {
    test
  };
})();

if (typeof module !== "undefined") {
  UnitTestingApp = require('../unit-testing-app.js');
  Credentials = require('../../helpers/credentials.js');
  PropertiesService = require('../mocks/properties-service-mock.js');
  module.exports = TestCredentials;
}
