import '@babel/polyfill' // Required for polyfill fetch for IE11
import 'whatwg-fetch' // Required for polyfill fetch for IE11
import React from 'react'
import { render } from 'react-dom'
import * as Sentry from '@sentry/browser'
import { I18nextProvider } from 'react-i18next'
import { store, history } from './store/store'
import i18n from './i18next'
import Root from './containers/Root'
import getConfig from './constants/config.constants'
import './index.scss'

Sentry.init({
  debug: (process.env.NODE_ENV !== 'production'),
  dsn: 'https://3559b4ca079e44c687cd6f4c135426d0@sentry.itsmycargo.tech/3',
  sampleRate: process.env.NODE_ENV === 'production' ? 1 : 0,
  environment: window.keel.environment,
  release: window.keel.release || process.env.RELEASE,
  whitelistUrls: [window.location.origin]
})

render(
  <I18nextProvider i18n={i18n}>
    <Root store={store} history={history} />
  </I18nextProvider>,
  document.getElementById('root')
)
