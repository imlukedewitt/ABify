const ResultsHandler = (() => {
  function getLastCompletedRowIdx(data) {
    if (data.length === 0) { return -1; }
    let lastCompletedRowIdx = -1;
    let highestIndex = -1;

    for (let i = 0; i < data.length; i++) {
      if (data[i].status === 'complete' || data[i].status === 'error') {
        if (data[i].index > highestIndex) {
          highestIndex = data[i].index;
          lastCompletedRowIdx = i + 1;
        }
      }
    }

    return lastCompletedRowIdx;
  }

  return {
    getLastCompletedRowIdx
  }
})();