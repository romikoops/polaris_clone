import '@babel/polyfill' // Required for polyfill fetch for IE11
import 'whatwg-fetch' // Required for polyfill fetch for IE11
import React from 'react'
import { render } from 'react-dom'
import GTM from 'react-tag-manager'
import * as Sentry from '@sentry/browser'
import { I18nextProvider } from 'react-i18next'
import { configureStore, history } from './store/configureStore'
import i18n from './i18next'
import Root from './containers/Root'
import getConfig from './constants/config.constants'
import './index.scss'

Sentry.init({
  debug: (process.env.NODE_ENV === 'development'),
  dsn: (process.env.NODE_ENV === 'development') ? '' : window.keel.sentryUrl,
  environment: window.keel.environment,
  release: process.env.RELEASE
})

const store = configureStore()

render(
  <I18nextProvider i18n={i18n}>
    <GTM
      gtm={{
        id: getConfig().gtmId
      }}
    >
      <Root store={store} history={history} />
    </GTM>
  </I18nextProvider>,
  document.getElementById('root')
)
