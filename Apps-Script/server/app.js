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
  importer.sheet.writeImportResults(result.rows);
  return JSON.stringify(result);
}

// Allow calling functions from client side
// https://blog.ohheybrian.com/2022/06/adventures-in-building-an-interactive-apps-script-sidebar/
function exposeRun(namespace, method, argArray) {
  Logger.log(`exposeRun called with namespace: ${namespace}, method: ${method}, argArray: ${argArray}`);

  const classes = {
    'ABify': ABify,
    'Importer': Importer,
    'UI': UI
  };

  const target = namespace ? (classes[namespace] || this[namespace]) : this;
  if (!target) {
    throw new Error(`Invalid namespace: ${namespace}`);
  }

  const func = target[method];
  if (!func) {
    throw new Error(`Method ${method} not found in ${namespace || 'global scope'}`);
  }

  return argArray?.length ? func.apply(this, argArray) : func();
}
