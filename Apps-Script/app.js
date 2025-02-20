// This isn't really the main app file.
// See client/ and server/ for the actual code
//
// The Apps Script web editor files are sorted alphabetically.
// This file is displayed by default when the web UI is opened.
// For convenience, this file contains a debugging functions
// to be run from the web UI

function gasTests() {
  Logger.log('running gas tests');
  TestSuite.run();
}

function debugCreateCustomers() {
  debugImport('luke', 'createCustomers');
}

function debugCreateSubscriptions() {
  debugImport('luke', 'createSubscriptions');
}

function debugImport(siteName, template) {
  const importer = new Importer({
    siteName: siteName,
    template: template
  })
  importer.sheet.filterActiveRows();
  importer.start();
  const result = importer.monitor();
  importer.sheet.writeImportResults(result.rows);
  Logger.log('great job');
}

function debugImportStatus() {
  const id = '';
  const abify = new ABify({
    creds: Credentials.getCredentialsForSite('luke')
  });
  const status = abify.status(id);
  Logger.log(`Status: ${status.status}, run time: ${status.run_time}`);
}
