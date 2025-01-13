function createCustomers() {
  test('luke', 'createCustomers');
}

function createSubscriptions() {
  test('luke', 'createSubscriptions');
}

function test(siteName, template) {
  let importer = new Importer({
    siteName: siteName,
    template: template
  })
  importer.sheet.filterActiveRows();
  importer.start();
  const result = importer.monitor();
  importer.sheet.writeImportResults(result.data);
  Logger.log('great job');
}
