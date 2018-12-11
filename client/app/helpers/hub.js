function splitName (fullName) {
  const fullNameArr = fullName.split(' ')
  const hubType = fullNameArr.pop()
  const name = fullNameArr.join(' ')

  return {
    hubType,
    name
  }
}

export function getHubType (hub) {
  let hubType = ''
  switch (hub.hub_type) {
    case 'ocean':
      hubType = 'Port'
      break
    case 'air':
      hubType = 'Airport'
      break
    case 'rail':
      hubType = 'Railyard'
      break
    case 'truck':
      hubType = 'Depot'
      break
    default:
      break
  }

  return hubType
}

export default splitName
