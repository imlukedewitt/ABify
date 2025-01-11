class ABify {
  constructor(args) {
    this.baseUrl = 'https://abify.onrender.com/';
    this.creds = args.creds;
  }

  start(data, template) {
    const response = this.sendRequest('start', 'post', data, null, template);
    const responseText = response.getContentText();
    return JSON.parse(responseText);
  }

  status(id) {
    const response = this.sendRequest('status', 'get', null, { id: id });
    const responseText = response.getContentText();
    return JSON.parse(responseText);
  }

  monitor(id) {
    while (1) {
      Logger.log('Checking status');
      const status = this.status(id);
      console.log(`Status: ${status.status}, run time: ${status.run_time}`);
      if (status.status === 'complete') {
        return status;
      }
    }
  }

  static wakeUp() {
    const creds = Credentials.ABifyCredentials();
    const basicAuth = `${creds.username}:${creds.password}`;
    const response = UrlFetchApp.fetch(this.baseUrl, {
      'method': 'get',
      'muteHttpExceptions': true,
      'headers': { 'Authorization': 'Basic ' + Utilities.base64Encode(basicAuth) }
    });
    const responseText = response.getContentText();
    return responseText;
  }

  sendRequest(endpoint, method, payload, params, template = null) {
    let url = this.baseUrl + endpoint;
    if (params) {
      const queryString = Object.keys(params)
        .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
        .join('&');
      url += '?' + queryString;
    }
    const ABifyCreds = Credentials.ABifyCredentials();
    const basicAuth = `${ABifyCreds.username}:${ABifyCreds.password}`;
    const headers = {
      "Authorization": "Basic " + Utilities.base64Encode(basicAuth),
      'Content-Type': "application/json",
      'SUBDOMAIN': this.creds.subdomain,
      'DOMAIN': this.creds.domain,
      'APIKEY': this.creds.apiKey,
      'TEMPLATE': template || ''
    };

    const options = {
      'method': method,
      'contentType': 'application/json',
      'muteHttpExceptions': true,
      'headers': headers
    };

    if (payload) {
      options['payload'] = JSON.stringify(payload);
    }

    return UrlFetchApp.fetch(url, options);
  }
};