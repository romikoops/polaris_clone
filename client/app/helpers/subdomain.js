export function getSubdomain () {
  const { host } = window.location
  if (
    host.indexOf('.') < 0 ||
    host.split('.')[0] === 'www' ||
    host.split('.')[0] === 'react' ||
    host.split('.')[0] === 'dev' ||
    host.split('.')[0] === '192' ||
    host.includes('localhost')
  ) {
    return 'demo-sandbox'
  }
  return host.split('.')[0]
}

export default getSubdomain
