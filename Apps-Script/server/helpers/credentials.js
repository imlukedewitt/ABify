const Credentials = (() => {
  function getCredentials() {
    let creds = PropertiesService.getUserProperties().getProperty('credentials');
    return creds ? JSON.parse(creds) : {};
  }

  function getCredentialsForSite(siteName, spreadsheetID = null) {
    if (!spreadsheetID) { spreadsheetID = Spreadsheet.getID(); }
    let creds = getCredentials();
    return creds[`${spreadsheetID}-${siteName}`];
  }

  function listSites(spreadsheetID = null) {
    if (!spreadsheetID) { spreadsheetID = Spreadsheet.getID(); }
    let creds = getCredentials();
    return Object.keys(creds)
      .filter(cred => cred.spreadsheetID === spreadsheetID)
      .map(cred => { cred.siteName, cred.subdomain, cred.domain })
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

  function RedisCredentials() {
    let creds = getCredentials();
    return creds['Redis'];
  }

  function saveRedisCredentials(username, password) {
    let creds = getCredentials();
    creds['Redis'] = { username, password };
    saveCredsToProperties(creds);
  }

  return {
    getCredentialsForSite,
    storeCredentials,
    deleteCredentials,
    getDomain,
    listSites,
    ABifyCredentials,
    RedisCredentials
  }
})();