import PropTypes from 'prop-types'
import React from 'react'
import { Provider } from 'react-redux'
import { Route } from 'react-router-dom'
import { ConnectedRouter } from 'react-router-redux'

import App from '../containers/App/App'
import DevTools from './DevTools'

export default function Root ({ store, history }) {
  const devtools = process.env.NODE_ENV === 'development' ? (<DevTools />) : null
  return (
    <Provider store={store}>
      <div>
        <ConnectedRouter history={history}>
          <Route path="/" component={App} />
        </ConnectedRouter>
        { devtools }
      </div>
    </Provider>
  )
}

Root.propTypes = {
  store: PropTypes.object.isRequired,
  history: PropTypes.object.isRequired
}
