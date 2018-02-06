export function getSubdomain () {
  const { host } = window.location
  if (host.indexOf('.') < 0) {
    return 'greencarrier'
  }
  if (
    host.split('.')[0] === 'www' ||
    host.split('.')[0] === 'react' ||
    host.includes('localhost')
  ) {
    return 'demo'
  }
  return host.split('.')[0]
}

export default getSubdomain
