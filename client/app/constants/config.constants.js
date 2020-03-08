let config = {}

export default function getConfig () {
  const keel = window.keel || {}
  const environment = process.env.NODE_ENV === 'production' ? keel.environment : process.env.NODE_ENV

  const segmentKey = {
    development: '',
    test: '',
    review: '',
    production: 'BjuhWZe2ju14ux35VnoC8YsqWGtcgkjY'
  }

  if (!config.apiUrl) {
    config = {
      apiUrl: ((process.env.NODE_ENV !== 'production' && process.env.BASE_URL) || keel.apiUrl),
      segment: ((process.env.NODE_ENV !== 'production' && process.env.SEGMENT_KEY) || segmentKey[environment])
    }
  }

  return config
}
