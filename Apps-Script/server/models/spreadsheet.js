class Spreadsheet {
  constructor(id = null) {
    this.spreadsheet = id ? SpreadsheetApp.openById(id) : SpreadsheetApp.getActiveSpreadsheet();
    this.spreadsheetID = this.spreadsheet.getId();
  }

  createSheet(name, data = null, columnOrder = null) {
    let newName = getAvailableSheetName(name);
    let newSheet = new Sheet(this.spreadsheet.insertSheet(newName));
    if (data) {
      newSheet.writeData(data, null, true, columnOrder);
    }
  }

  getAvailableSheetName(name) {
    let newName = name;
    if (this.spreadsheet.getSheetByName(name) != null) {
      let i = 0;
      do {
        i++;
        newName = `${name} (${i})`;
      } while (this.spreadsheet.getSheetByName(newName) != null);
    }

    return newName;
  }

  static getID() {
    return SpreadsheetApp.getActiveSpreadsheet().getId();
  }
}