// ABify
// by Luke

function onOpen() {
  UI.createMenu();
}

const startImporter = (args) => {
  Logger.log(`starting importer with args: ${JSON.stringify(args)}`);
  const importer = new Importer(args);
  importer.sheet.filterActiveRows();
  importer.start();
  const result = importer.monitor();
  importer.sheet.writeImportResults(result.data);
  return JSON.stringify(result);
}