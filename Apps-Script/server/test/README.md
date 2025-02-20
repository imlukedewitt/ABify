
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
const TestClassName = {
  test() {
    const test = new UnitTestingApp();
    test.enable();

    /* ====================
     *     LOCAL TESTS   
     * ==================== */
    test.runInGas(false);
    test.printHeader('ClassName Local Tests');

    /* ====================
     *     ONLINE TESTS 
     * ==================== */
    test.runInGas(true);
    test.printHeader('ClassName Online Tests');
  }
};

if (typeof module !== "undefined") {
  const UnitTestingApp = require('../unit-testing-app.js');
  const MockData = require('../mock-data.js');
  const ClassName = require('../../models/class-name.js');
  module.exports = TestStringUtils;
}
```