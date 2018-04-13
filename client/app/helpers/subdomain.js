export function getSubdomain () {
  const { host } = window.location
  if (host.indexOf('.') < 0) {
    return 'easyshipping'
  }
  if (
    host.split('.')[0] === 'www' ||
    host.split('.')[0] === 'react' ||
    host.split('.')[0] === 'dev' ||
    host.split('.')[0] === '192' ||
    host.includes('localhost')
  ) {
    return 'easyshipping'
  }
  return host.split('.')[0]
}

export default getSubdomain
