let config = {}

export default function getConfig () {
  const keel = window.keel || {}
  if (!config.api_url) {
    config = {
      api_url: ((process.env.NODE_ENV !== 'production' && process.env.BASE_URL) || keel.apiUrl),
      gtmId: ((process.env.NODE_ENV !== 'production' && process.env.GTM_ID) || keel.gtmId),
    }
  }

  return config
}
