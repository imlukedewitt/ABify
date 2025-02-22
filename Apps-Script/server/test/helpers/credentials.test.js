const TestCredentials = (() => {
  function test() {
    const tester = new UnitTestingApp();

    tester.runInGas(false);
    tester.printHeader('Credentials');

    tester.describe('getCredentialsForSite()', () => {
      PropertiesService.getUserProperties().setProperty('credentials', JSON.stringify({
        '0987654321-abify debug credentials': {
          subdomain: 'subdomain',
          domain: 'domain.com',
          apiKey: '1234567890',
          spreadsheetID: '0987654321'
        }
      }));

      tester.assert('it works', true);

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
    })

    // tester.runInGas(true);
    // tester.printHeader('Credentials');
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
