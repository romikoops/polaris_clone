let config = {}

export default function getConfig () {
  const root = document.getElementById('root')
  const keel = window.keel || {}

  if (!config.api_url) {
    config = {
      api_url: (process.env.BASE_URL || keel.apiUrl || (root && root.getAttribute('data-api-url'))),
      tenant: (process.env.DEV_SUBDOMAIN || keel.tenantName || (root && root.getAttribute('data-tenant-subdomain')))
    }
  }

  return config
}
