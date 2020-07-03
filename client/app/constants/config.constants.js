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

  const zendeskKey = {
    development: '627ad638-a13b-4f53-bb1d-ca7a7e36f3f1',
    test: '627ad638-a13b-4f53-bb1d-ca7a7e36f3f1',
    review: '627ad638-a13b-4f53-bb1d-ca7a7e36f3f1',
    production: '627ad638-a13b-4f53-bb1d-ca7a7e36f3f1'
  }


  if (!config.apiUrl) {
    config = {
      apiUrl: ((process.env.NODE_ENV !== 'production' && process.env.BASE_URL) || keel.apiUrl),
      segment: ((process.env.NODE_ENV !== 'production' && process.env.SEGMENT_KEY) || segmentKey[environment]),
      zendesk: ((process.env.NODE_ENV !== 'production' && process.env.ZENDESK_KEY) || zendeskKey[environment]),
      oauthClientId: ((process.env.NODE_ENV !== 'production' && process.env.OAUTH_CLIENT_ID) || keel.oauthClientId),
      oauthClientSecret: ((process.env.NODE_ENV !== 'production' && process.env.OAUTH_CLIENT_SECRET) || keel.oauthClientSecret)
    }
  }

  return config
}
