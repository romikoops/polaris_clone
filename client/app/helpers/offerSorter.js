import { get } from 'lodash'

const propertyLookup = {
  total: 'quote.total.value',
  duration: 'meta.transit_time',
  carrier: 'meta.carrier',
  service_level: 'meta.service_level'
}

function getProperty (key, type) {
  const fallback = type === 'primary' ? 'total' : 'duration'

  return get(propertyLookup, [key], propertyLookup[fallback])
}
function getValue (item, scope, type) {
  const key = get(scope, ['sorting', 'offers', type])
  const property = getProperty(key, type)
  if (key === 'total') {
    return parseFloat(get(item, property) || 0)
  }

  return get(item, property) || 0
}

export default function offerSorter (offers, scope) {
  return offers.sort((a, b) => {
    const aPrimary = getValue(a, scope, 'primary')
    const bPrimary = getValue(b, scope, 'primary')
    const aSecondary = getValue(a, scope, 'secondary')
    const bSecondary = getValue(b, scope, 'secondary')

    return aPrimary - bPrimary || aSecondary - bSecondary
  })
}
