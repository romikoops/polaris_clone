import '@babel/polyfill'
import React from 'react'
import { render } from 'react-dom'
import { AppContainer } from 'react-hot-loader'
import { I18nextProvider } from 'react-i18next'
import * as Sentry from '@sentry/browser'
import i18n from './i18next'
import { configureStore, history } from './store/configureStore'
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
  <AppContainer>
    <Root store={store} history={history} />
  </AppContainer>,
  document.getElementById('root')
)

if (module.hot) {
  module.hot.accept('./containers/Root', () => {
    /* eslint-disable global-require */
    const newConfigureStore = require('./store/configureStore')
    const newStore = newConfigureStore.configureStore()
    const newHistory = newConfigureStore.history
    const NewRoot = require('./containers/Root').default
    /* eslint-enable global-require */
    render(
      <I18nextProvider i18n={i18n}>
        <AppContainer>
          <NewRoot store={newStore} history={newHistory} />
        </AppContainer>
      </I18nextProvider>
      ,
      document.getElementById('root')
    )
  })
}
