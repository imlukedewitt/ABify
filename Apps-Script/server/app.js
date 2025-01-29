// ABify
// by Luke

function onOpen() {
  UI.createMenu();
}

function startImporter(args) {
  Logger.log(`starting importer with args: ${JSON.stringify(args)}`);
  const importer = new Importer(args);
  importer.sheet.filterActiveRows();
  importer.start();
  const result = importer.monitor();
  importer.sheet.writeImportResults(result.data);
  return JSON.stringify(result);
}

// https://blog.ohheybrian.com/2022/06/adventures-in-building-an-interactive-apps-script-sidebar/
function exposeRun(namespace, method, argArray) {
  var func = (namespace ? this[namespace][method] : this[method]);
  if(argArray && argArray.length) {
    return func.apply(this, argArray)
  }
  else {
    return func();
  }
}
