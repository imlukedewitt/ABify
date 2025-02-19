function createCustomers() {
  test('luke', 'createCustomers');
}

function createSubscriptions() {
  test('luke', 'createSubscriptions');
}

function test(siteName, template) {
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

function checkStatus() {
  const id = '20250219054957-luke-64f31845';
  const abify = new ABify({
    creds: Credentials.getCredentialsForSite('luke')
  });
  const status = abify.status(id);
  Logger.log(`Status: ${status.status}, run time: ${status.run_time}`);
}