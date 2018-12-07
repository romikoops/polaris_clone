export function capitalize (str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

export function capitalizeCities (str) {
  const splittedArr = str.split(' ')
  const string = splittedArr.map(a => a.charAt(0).toUpperCase() + a.slice(1).toLowerCase())

  return string.join(' ')
}

export function camelize (str) {
  return str.replace(/[_.-](\w|$)/g, (_, x) => x.toUpperCase())
}

export function humanizeSnakeCase (str) {
  return str.split('_').map(capitalize).join(' ')
}
export function camelizeSnakeCase (str) {
  const tmpStr =  str.split('_').map(capitalize).join('')
  return tmpStr.charAt(0).toLowerCase() + tmpStr.slice(1)
}

export function humanizeSnakeCaseUp (str) {
  return str.split('_').map(s => s.toUpperCase()).join(' ')
}

export function capitalizeAndDashifyCamelCase (str) {
  return str.split(/(?=[A-Z])/).map(capitalize).join('-')
}

export function renderHubType (mot) {
  switch (mot) {
    case 'air':
      return 'Airport'
    case 'ocean':
      return 'Port'
    case 'rail':
      return 'Railyard'
    case 'truck':
      return 'Depot'
    default:
      return ''
  }
}
