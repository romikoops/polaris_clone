function maxDimensionsKey (mots) {
  return mots.some(mot => mot !== 'air') || mots.length === 0 ? 'general' : 'air'
}

export default function calcMaxDimensionsToApply (availableMotsForRoute, maxDimensions) {
  return maxDimensions[maxDimensionsKey(availableMotsForRoute)]
}
