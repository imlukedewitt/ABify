class Sheet {
  constructor(sheet = null) {
    if (sheet && typeof sheet.getSheetId === 'function') {
      // If sheet is a valid Google Sheets object
      this.sheet = sheet;
    } else if (sheet && sheet.spreadsheetId && sheet.sheetName) {
      // If sheet is an object containing spreadsheetId and sheetName
      const spreadsheet = SpreadsheetApp.openById(sheet.spreadsheetId);
      this.sheet = spreadsheet.getSheetByName(sheet.sheetName);
      if (!this.sheet) {
        throw new Error('Sheet not found!');
      }
    } else {
      // If no arguments are provided, use the active sheet
      this.sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    }
    this.sheetId = this.sheet.getSheetId();
    this.data = this.readData();
  }

  readData(range = null) {
    let sheetRange = range ? this.sheet.getRange(range) : this.sheet.getDataRange();
    let data = sheetRange.getDisplayValues();
    return Utils.convert2DArrayToObj(data);
  }

  writeData(data, range = null, writeHeaders = true, columnOrder = null) {
    let sheetData = Utils.convertObjTo2DArray(data, headers = writeHeaders);
    let sheetRange = range ? this.sheet.getRange(range) : this.sheet.getRange(1, 1, sheetData.length, sheetData[0].length);

    let allKeys = [];
    data.forEach(obj => {
      Object.keys(obj).forEach(key => {
        if (!allKeys.includes(key)) {
          allKeys.push(key);
        }
      });
    });

    if (allKeys.length === 0) {
      Logger.log('No data to write, done')
      return
    }

    // Sort the keys if a column order was provided
    if (columnOrder && Array.isArray(columnOrder)) {
      allKeys = columnOrder.filter(key => allKeys.includes(key));
      allKeys = allKeys.concat(allKeys.filter(key => !allKeys.includes(key)));
    }

    const outputBatchSize = 5000;
    let currentRow = sheetRange.getRow();
    let currentCol = sheetRange.getColumn();
    for (let i = 0; i < sheetData.length; i += outputBatchSize) {
      const outputData = [];
      const batch = sheetData.slice(i, i + outputBatchSize);
      batch.forEach(dataRow => {
        let outputRow = [];
        allKeys.forEach(column => {
          outputRow.push(dataRow[column] === undefined || dataRow[column] === null ? "" : dataRow[column]);
        });
        outputData.push(outputRow);
      });
      Logger.log(`Writing rows ${currentRow} - ${currentRow + outputData.length}`);
      this.sheet.getRange(currentRow, currentCol, outputData.length, outputData[0].length).setValues(outputData);
      currentRow += outputData.length;
    }
  }

  static getID() {
    return SpreadsheetApp.getActiveSpreadsheet().getActiveSheet().getSheetId();
  }
}