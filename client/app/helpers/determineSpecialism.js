function determineSpecialism (motScope) {
  const results = {}
  Object.keys(motScope).forEach((mot) => {
    results[mot] = Object.values(motScope[mot]).reduce((acc, val) => acc + val)
  })
  if (results.truck === 2 && results.air === 0 && results.ocean === 0 && results.rail === 0) {
    return 'truck'
  } else if (results.truck === 0 &&
     results.air === 2 &&
     results.ocean === 0 &&
     results.rail === 0) {
    return 'air'
  } else if (results.truck === 0 &&
    results.air === 0 &&
    results.ocean === 2 &&
    results.rail === 0) {
    return 'ocean'
  } if (results.truck === 0 &&
    results.air === 0 &&
    results.ocean === 0 &&
    results.rail === 2) {
    return 'rail'
  }
  return 'none'
}
export default determineSpecialism
