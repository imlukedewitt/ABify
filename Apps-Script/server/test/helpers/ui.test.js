const UITest = (() => {
  function queue() {
    runInGas(true);
    printHeader('server/helpers/ui.js');

    describe('include()', () => {
      it('returns an html file as text', () => {
        const result = UI.include('client/templates/importer-sidebar.html');
        expect(typeof result).toEqual('string');
        expect(result.length).toBeGreaterThan(0);
        expect(result).toContain('<html>');
      });

      it('throws an error if file not found', () => {
        expect(() => UI.include('client/templates/missing.html')).toThrowError();
      });
    });

    describe('render()', () => {
      it('returns an html file as an HtmlOutput object', () => {
        const result = UI.render('client/templates/importer-sidebar.html');
        expect(result).toBeInstanceOf('HtmlOutput');
        expect(result).toRespondTo('getContent');
      });

      it('throws an error if file not found', () => {
        expect(() => UI.render('client/templates/missing.html')).toThrowError();
      });
    });
  }

  return { queue };
})();

if (typeof module !== "undefined") {
  UI = require('../../helpers/ui.js');
  module.exports = UITest;
}
