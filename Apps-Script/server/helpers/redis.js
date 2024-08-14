const Redis = (() => {
  const BASE_URL = 'https://abify-redis-etgmlif55a-uc.a.run.app';

  function sendRequest(endpoint, method, payload, params) {
    let url = BASE_URL + endpoint;
    if (params) {
      const queryString = Object.keys(params)
        .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
        .join('&');
      url += '?' + queryString;
    }

    const ABifyCreds = Credentials.RedisCredentials();
    const basicAuth = `${ABifyCreds.username}:${ABifyCreds.password}`;
    const headers = {
      "Authorization": "Basic " + Utilities.base64Encode(basicAuth),      'Content-Type': "application/json"
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

  function set(key, data) {
    const response = sendRequest('/set', 'post', {key: key, value: data});
    const code = response.getResponseCode();
    return code < 400 ? true : `${code} ${response.getContentText()}`.trim();
  }

  function get(key) {
    const response = sendRequest('/get', 'get', null, {key: key});
    const code = response.getResponseCode();
    const responseText = response.getContentText();
    return code < 400 ? JSON.parse(responseText) : `${code} ${responseText}`.trim();
  }

  function wakeUp() {
    const response = sendRequest('', 'get');
    const code = response.getResponseCode();
    const responseText = response.getContentText();
    return code < 400 ? responseText : `${code} ${responseText}`.trim();
  }

  return {
    set,
    get,
    wakeUp
  }
})()