import '@babel/polyfill'
import React from 'react'
import { render } from 'react-dom'
import * as Sentry from '@sentry/browser'
import { I18nextProvider } from 'react-i18next'
import { configureStore, history } from './store/configureStore'
import i18n from './i18next'
import Root from './containers/Root'
import './index.scss'

Sentry.init({
  debug: (process.env.NODE_ENV === 'development'),
  dsn: (process.env.NODE_ENV === 'development') ? '' : window.keel.sentryUrl,
  environment: window.keel.environment,
  release: process.env.RELEASE
})

const store = configureStore()

render(
  <I18nextProvider i18n={i18n} >
    <Root store={store} history={history} />
  </I18nextProvider>,
  document.getElementById('root')
)
