const Credentials = (() => {
  function getCredentials() {
    let creds = PropertiesService.getUserProperties().getProperty('credentials');
    return creds ? JSON.parse(creds) : {};
  }

  function getCredentialsForSite(siteName, spreadsheetID = null) {
    if (!spreadsheetID) { spreadsheetID = Spreadsheet.getID(); }
    let creds = getCredentials();
    return creds[`${spreadsheetID}-${siteName}`] || null;
  }

  function listSites(spreadsheetID = null) {
    if (!spreadsheetID) { spreadsheetID = Spreadsheet.getID(); }
    let creds = getCredentials();
    return Object.keys(creds)
      .filter(key => key.includes(spreadsheetID))
      .map(key => {
        let siteName = key.split('-')[1];
        return { ...creds[key], siteName };
      });
  }

  function storeCredentials(siteName, subdomain, domain, apiKey, spreadsheetID = null) {
    let creds = getCredentials();
    if (!spreadsheetID) { spreadsheetID = Spreadsheet.getID(); }
    creds[`${spreadsheetID}-${siteName}`] = { siteName, subdomain, domain, apiKey, spreadsheetID };
    saveCredsToProperties(creds);
  }

  function deleteCredentials(siteName, spreadsheetID = null) {
    if (!spreadsheetID) { spreadsheetID = Spreadsheet.getID(); }
    let creds = getCredentials();
    delete creds[`${spreadsheetID}-${siteName}`];
    saveCredsToProperties(creds);
  }

  function getDomain(siteName, spreadsheetID = null) {
    if (!spreadsheetID) { spreadsheetID = Spreadsheet.getID(); }
    let creds = getCredentials();
    return creds[`${spreadsheetID}-${siteName}`].domain;
  }

  function saveCredsToProperties(creds) {
    PropertiesService.getUserProperties().setProperty('credentials', JSON.stringify(creds));
  }

  function ABifyCredentials() {
    let creds = getCredentials();
    return creds['ABify'];
  }

  function saveABifyCredentials(username, password) {
    let creds = getCredentials();
    creds['ABify'] = { username, password };
    saveCredsToProperties(creds);
  }

  function RedisCredentials() {
    let creds = getCredentials();
    return creds['Redis'];
  }

  function saveRedisCredentials(username, password) {
    let creds = getCredentials();
    creds['Redis'] = { username, password };
    saveCredsToProperties(creds);
  }

  const baseUrl = {
    abify: 'https://abify.onrender.com',
  }

  return {
    getCredentialsForSite,
    storeCredentials,
    deleteCredentials,
    getDomain,
    listSites,
    ABifyCredentials,
    saveABifyCredentials,
    RedisCredentials,
    saveRedisCredentials,
    baseUrl
  }
})();

if (typeof module !== 'undefined') module.exports = Credentials;