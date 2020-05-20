function determineSpecialism (motScope) {
  const results = {}
  Object.keys(motScope).forEach((mot) => {
    results[mot] = Object.values(motScope[mot]).reduce((acc, val) => acc + val)
  })

  if (results.truck === (1 || 2) && results.air === 0 && results.ocean === 0 && results.rail === 0) {
    return 'truck'
  } if (results.truck === 0 &&
    results.air === (1 || 2) &&
    results.ocean === 0 &&
    results.rail === 0) {
    return 'air'
  } if (results.truck === 0 &&
    results.air === 0 &&
    results.ocean === (1 || 2) &&
    results.rail === 0) {
    return 'ocean'
  } if (results.truck === 0 &&
    results.air === 0 &&
    results.ocean === 0 &&
    results.rail === (1 || 2)) {
    return 'rail'
  }

  return 'none'
}
export default determineSpecialism
