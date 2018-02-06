export function capitalize (str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

export function camelize (str) {
  return str.replace(/[_.-](\w|$)/g, (_, x) => x.toUpperCase())
}
