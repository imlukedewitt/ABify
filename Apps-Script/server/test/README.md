
# UnitTestingApp for Google Apps Script
<!-- makrdown link to https://github.com/WildH0g/UnitTestingApp/tree/master -->

## About
> [UnitTestingApp Github Repo](https://github.com/WildH0g/UnitTestingApp/tree/master)

Lightweight unit testing framework for Google Apps Script (GAS) that allows you to run tests locally and in the GAS environment.

## Running Tests

### Locally

Use Node to run tests locally.

```bash
node server/run-tests.js
```

### In GAS

Navigate to the file 'server/test'

## Template

This is a blank template for an individual test file. These are called by `server/test/test-suite.js`.

```js
const TestClassName = (() => {
  const tester = new UnitTestingApp();

  function test() {
    /* ====================
     *     LOCAL TESTS   
     * ==================== */
    tester.runInGas(false);
    tester.printHeader('ClassName Local Tests');

    // Local tests go here

    /* ====================
     *     ONLINE TESTS 
     * ==================== */
    tester.runInGas(true);
    tester.printHeader('ClassName Online Tests');

    // Online tests go here
  }

  return {
    test
  };
})();

if (typeof module !== "undefined") {
  const UnitTestingApp = require('../unit-testing-app.js');
  const MockData = require('../mock-data.js');
  const ClassName = require('../../helpers/string-utils.js');
  module.exports = TestClassName;
}

```