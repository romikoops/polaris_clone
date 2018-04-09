import '@babel/polyfill'
import React from 'react'
import { render } from 'react-dom'
import { AppContainer } from 'react-hot-loader'
import { configureStore, history } from './store/configureStore'
import Root from './containers/Root'
import './index.scss'

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
      <AppContainer>
        <NewRoot store={newStore} history={newHistory} />
      </AppContainer>,
      document.getElementById('root')
    )
  })
}
