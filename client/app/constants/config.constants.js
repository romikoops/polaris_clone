let config = {}

export default function getConfig () {
  const googleTagManagerId = {
    development: '',
    test: '',
    review: 'GTM-P29HCHV',
    production: 'GTM-KTST893'
  }

  const sentryUrl = {
    development: '',
    test: '',
    review: 'https://8bc4a8e340e84e9b86a1e374815b4117@sentry.itsmycargo.tech/5',
    production: 'https://16d43a033af648da8b2f2933f6e62717@sentry.itsmycargo.tech/3'
  }

  const keel = window.keel || {}
  if (!config.api_url) {
    config = {
      api_url: ((process.env.NODE_ENV !== 'production' && process.env.BASE_URL) || keel.apiUrl),
      gtmId: ((process.env.NODE_ENV !== 'production' && process.env.GTM_ID) || googleTagManagerId[keel.environment]),
      sentryUrl: ((process.env.NODE_ENV !== 'production' && process.env.SENTRY_URL) || sentryUrl[keel.environment])
    }
  }

  return config
}
