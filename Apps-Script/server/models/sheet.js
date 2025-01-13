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
    data = Utils.convert2DArrayToObj(data);
    data.forEach((row, idx) => {
      if (idx > 0) row.index = idx + 1;
    });
    return data;
  }

  readHeaders() {
    return this.sheet.getRange(1, 1, 1, this.sheet.getLastColumn()).getDisplayValues()[0].map(header => String(header).trim().toLowerCase());
  }

  // function to remove rows from data if row.success is true, partial, or "display only". Also remove blank rows
  filterActiveRows() {
    this.data = this.data.filter(row => {
      let successValue = String(row.success).trim().toLowerCase();
      let displayOnlyRegex = /^\(?display(\s|-)only/i;
      let blankRow = Object.values(row).every(value => StringUtils.isBlank(value));
      return !(successValue === 'true' || successValue === 'partial' || displayOnlyRegex.test(successValue) || blankRow);
    });
  }

  writeImportResults(data) {
    let headers = this.readHeaders();
    let resultsColumns = new Set(["success", "request"]);
    data.forEach(row => {
      row.requests.forEach(request => { resultsColumns.add(`Response (${request.step})`); });
      row.errors.forEach(error => { resultsColumns.add(`Response (${error.step})`); });
    });
    // todo: ensure results columns exist and are in the correct order
    // for now we will just assume its fine

    let resultsRange = `A1:${String.fromCharCode(65 + resultsColumns.size - 1)}${this.sheet.getLastRow()}`;
    let resultsData = this.readData(resultsRange);
    let minIdx = null;
    let maxIdx = null;
    data.forEach(row => {
      const idx = parseInt(row.index) - 1;
      let currentRow = resultsData[idx];
      currentRow.success = row.status === 'complete';
      currentRow.request = JSON.stringify(row.requests);
      row.responses.forEach(response => {
        currentRow[`response (${response.step})`] = response.text;
      });
      row.errors.forEach(error => {
        currentRow[`response (${error.step})`] = error.text;
      });
      minIdx = minIdx === null ? idx : Math.min(minIdx, idx);
      maxIdx = maxIdx === null ? idx : Math.max(maxIdx, idx);
    });

    let range = `A${minIdx + 2}:${String.fromCharCode(65 + resultsColumns.size - 1)}${maxIdx + 2}`;
    let dataToWrite = resultsData.slice(minIdx, maxIdx + 1);
    dataToWrite = dataToWrite.map(row => {
      let newRow = {};
      resultsColumns.forEach(col => {
        col = col.toLowerCase();
        newRow[col] = row[col];
      });
      return newRow;
    });

    this.writeData(dataToWrite, range, false);
  }

  writeData(data, range = null, writeHeaders = true, columnOrder = null) {
    let sheetData = Utils.convertObjTo2DArray(data, writeHeaders);
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
          let colIdx = allKeys.indexOf(column);
          outputRow.push(dataRow[colIdx] === undefined || dataRow[colIdx] === null ? "" : dataRow[colIdx]);
        });
        outputData.push(outputRow);
      });
      Logger.log(`Writing rows ${currentRow} - ${currentRow + outputData.length - 1}`);
      this.sheet.getRange(currentRow, currentCol, outputData.length, outputData[0].length).setValues(outputData);
      currentRow += outputData.length;
    }
  }

  static getID() {
    return SpreadsheetApp.getActiveSpreadsheet().getActiveSheet().getSheetId();
  }
}