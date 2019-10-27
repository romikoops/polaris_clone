let config = {}

export default function getConfig () {
  const googleTagManagerId = {
    development: 'GTM-P29HCHV',
    test: '',
    review: 'GTM-P29HCHV',
    production: 'GTM-KTST893'
  }

  const sentryUrl = {
    development: '',
    test: '',
    review: 'https://3559b4ca079e44c687cd6f4c135426d0@sentry.itsmycargo.tech/3',
    production: 'https://3559b4ca079e44c687cd6f4c135426d0@sentry.itsmycargo.tech/3'
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
