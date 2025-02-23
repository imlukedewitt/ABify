if (typeof require !== "undefined") {
  Tester = require('../lib/gaspec/tester.js');
  UtilsTest = require('./helpers/utils.test.js');
  StringUtilsTest = require('./helpers/string-utils.test.js');
  CredentialsTest = require('./helpers/credentials.test.js');
}

const TestRunner = (() => {
  return {
    start() {
      const tester = Tester.setup();

      UtilsTest.queue();
      StringUtilsTest.queue();
      CredentialsTest.queue();

      tester.run();
    }
  }
})();

if (typeof module !== "undefined") TestRunner.start();
