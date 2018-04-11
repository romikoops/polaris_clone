export function capitalize (str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

export function camelize (str) {
  return str.replace(/[_.-](\w|$)/g, (_, x) => x.toUpperCase())
}

export function humanizeSnakeCase (str) {
  return str.split('_').map(capitalize).join(' ')
}

export function capitalizeAndDashifyCamelCase (str) {
  return str.split(/(?=[A-Z])/).map(capitalize).join('-')
}
