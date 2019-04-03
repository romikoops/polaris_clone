function maxDimensionsKey (mots) {
  return mots.some(mot => mot !== 'air') || mots.length === 0 ? 'general' : 'air'
}

function calculateMaxVolume (maxDimensions) {
  const setVolume = maxDimensions.dimensionX * maxDimensions.dimensionY * maxDimensions.dimensionZ / 1000000
  const volume = setVolume > 0 ? setVolume : 1000
  
  return {
    ...maxDimensions,
    volume
  }
}
export default function calcMaxDimensionsToApply (availableMotsForRoute, maxDimensions) {
  return calculateMaxVolume(maxDimensions[maxDimensionsKey(availableMotsForRoute)])
}
