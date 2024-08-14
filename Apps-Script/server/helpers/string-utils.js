StringUtils = (() => {
  function isBlank(thing) {
    return thing === null || String(thing).trim() === '';
  }

  function isPresent(thing) {
    return !isBlank(thing);
  }

  function isTrue(thing) {
    return thing === true || String(thing).trim().toLowerCase() === 'true';
  }

  function isFalse(thing) {
    return thing === false || String(thing).trim().toLowerCase() === 'false';
  }

  function isBoolean(thing) {
    return isTrue(thing) || isFalse(thing);
  }

  function generateString(length = 8) {
    let result = '';
    for (let i = 0; i < length; i++) {
      result += Math.floor(Math.random() * 16).toString(16);
    }
    return result;
  }

  return {
    isBlank,
    isPresent,
    isTrue,
    isFalse,
    isBoolean,
    generateString
  }
})();