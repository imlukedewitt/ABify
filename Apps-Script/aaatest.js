function test() {
  let importer = new Importer({
    siteName: 'luke',
    template: 'createCustomers'
  })
  importer.sheet.filterActiveRows();
  importer.start();
  const result = importer.monitor();
  importer.sheet.writeImportResults(result.data);
  Logger.log('great job');
}
