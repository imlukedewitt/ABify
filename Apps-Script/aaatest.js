function test() {
  let importer = new Importer({
    siteName: 'luke',
    template: 'createCustomers'
  })
  importer.start();
  const result = importer.monitor();
  Logger.log('great job');
}
