const CredentialsTest = (() => {
  function queue() {
    runInGas(false);
    printHeader('server/helpers/credentials.js');

    describe('getCredentialsForSite()', () => {
      PropertiesService.getUserProperties().setProperty('credentials', JSON.stringify({
        '0987654321-abify debug credentials': {
          subdomain: 'subdomain',
          domain: 'domain.com',
          apiKey: '1234567890',
          spreadsheetID: '0987654321'
        }
      }));

      it('returns credentials when spreadsheet ID is provided', () => {
        const result = Credentials.getCredentialsForSite('abify debug credentials', '0987654321');
        expect(result).toEqualObject({
          subdomain: 'subdomain',
          domain: 'domain.com',
          apiKey: '1234567890',
          spreadsheetID: '0987654321'
        });
      });

      it('returns null if no credentials are found', () => {
        expect(Credentials.getCredentialsForSite('abify debug credentials', '1234567890')).toBeNull();
      });

      it('uses the current spreadsheet if an ID not provided', () => {
        const result = Credentials.getCredentialsForSite('abify debug credentials');
        expect(result).toEqualObject({
          subdomain: 'subdomain',
          domain: 'domain.com',
          apiKey: '1234567890',
          spreadsheetID: '0987654321'
        });
      });
    });

    describe('storeCredentials()', () => {
      it('stores credentials correctly', () => {
        Credentials.storeCredentials('example site', 'example', 'example.com', '1234');
        const result = Credentials.getCredentialsForSite('example site');
        expect(result).toEqualObject({
          subdomain: 'example',
          domain: 'example.com',
          apiKey: '1234',
          spreadsheetID: Spreadsheet.getID(),
          siteName: 'example site'
        });
      });
    });

    describe('deleteCredentials()', () => {
      it('deletes credentials correctly', () => {
        Credentials.deleteCredentials('example site');
        expect(Credentials.getCredentialsForSite('example site')).toBeNull();
      });
    });

    describe('utility methods', () => {
      it('returns the domain', () => {
        expect(Credentials.getDomain('abify debug credentials', '0987654321')).toEqual('domain.com');
      });

      it('lists sites', () => {
        const result = Credentials.listSites();
        expect(result.length).toEqual(1);
        expect(result[0]).toEqualObject({
          subdomain: 'subdomain',
          domain: 'domain.com',
          apiKey: '1234567890',
          spreadsheetID: '0987654321',
          siteName: 'abify debug credentials'
        });
      });

      it('returns ABify base URL', () => {
        expect(Credentials.baseUrl.abify).toEqual('https://abify.onrender.com');
      });

      it('handles ABify credentials', () => {
        Credentials.saveABifyCredentials('username', 'password');
        expect(Credentials.ABifyCredentials()).toEqualObject({
          username: 'username',
          password: 'password'
        });
      });
    });
  }

  return { queue };
})();

if (typeof module !== "undefined") {
  Credentials = require('../../helpers/credentials.js');
  PropertiesService = require('../mocks/properties-service-mock.js');
  module.exports = CredentialsTest;
}
