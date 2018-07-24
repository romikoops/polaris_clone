export function getSubdomain () {
  const { host } = window.location

  if (host.includes('localhost')) {
    // Specify subdomain in .node-env file, restart app after ENVs are updated
    return process.env.DEV_SUBDOMAIN
  }

  if (
    host.indexOf('.') < 0 ||
    host.split('.')[0] === 'www' ||
    host.split('.')[0] === 'react' ||
    host.split('.')[0] === 'dev' ||
    host.split('.')[0] === '192'
  ) {
    return 'greencarrier'
  }

  return host.split('.')[0]
}

export default getSubdomain
