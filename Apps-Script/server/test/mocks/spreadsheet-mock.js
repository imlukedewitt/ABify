const SpreadsheetMock = (() => {
  const CURRENT_SPREADSHEET_ID = '0987654321';
  const getID = () => CURRENT_SPREADSHEET_ID;

  return {
    getID
  };
})();

if (typeof module !== "undefined") module.exports = SpreadsheetMock;