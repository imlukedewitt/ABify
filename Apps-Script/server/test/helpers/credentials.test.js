const TestCredentials = (() => {
  function test() {
    const tester = new UnitTestingApp();
    const mock = new MockData();

    /* ====================
     *     LOCAL TESTS   
     * ==================== */
    tester.runInGas(false);
    tester.printHeader('Credentials Local Tests');

    /* ====================
     *     ONLINE TESTS 
     * ==================== */
    tester.runInGas(true);
    tester.printHeader('Credentials Online Tests');

    testGetCredentialsForSite(tester);
  }

  function testGetCredentialsForSite(tester) {
    tester.assert(() => {
      const result = Credentials.getCredentialsForSite('abify debug credentials', '0987654321');
      return typeof result === 'object' &&
        result.subdomain === 'subdomain' &&
        result.domain === 'domain.com' &&
        result.apiKey === '1234567890' &&
        result.spreadsheetID === '0987654321';
    }, 'getCredentialsForSite returns correct credentials');
  }

  return {
    test
  };
})();

if (typeof module !== "undefined") {
  UnitTestingApp = require('../unit-testing-app.js');
  MockData = require('../mock-data.js');
  Credentials = require('../../helpers/credentials.js');
  module.exports = TestCredentials;
}
