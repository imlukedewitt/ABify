const UI = (() => {
  function include(fileName) {
    return render(fileName).getContent();
  }

  function render(path) {
    return htmlBody = HtmlService.createTemplateFromFile(path).evaluate();
  }

  function renderModal(path, title) {
    let htmlOutput = render(path);
    SpreadsheetApp.getUi().showModalDialog(htmlOutput, title);
  }

  function renderSidebar(path, title) {
    let htmlOutput = render(path);
    htmlOutput.setTitle(title);
    SpreadsheetApp.getUi().showSidebar(htmlOutput);
  }

  function createMenu() {
    const ui = SpreadsheetApp.getUi();
    let menu = ui.createMenu('️🌀 ABify');
    menu.addItem('Importer...', 'UI.openImportSidebar')
      .addToUi();
  }

  function openImportSidebar() {
    renderSidebar('client/templates/importer-sidebar.html', 'Import Data');
  }

  function toast(message) {
    const ui = SpreadsheetApp.getUi();
    ui.alert(message);
  }

  return {
    include,
    render,
    renderModal,
    renderSidebar,
    createMenu,
    openImportSidebar,
    toast
  }
})();
