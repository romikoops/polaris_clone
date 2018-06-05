import React from 'react'
import { Provider } from 'react-redux'
import { Route } from 'react-router-dom'
import { ConnectedRouter } from 'react-router-redux'
import PropTypes from '../prop-types'

import App from '../containers/App/App'
import DevTools from './DevTools'

export default function Root ({ store, history }) {
  const devtools = process.env.NODE_ENV === 'development' ? <DevTools /> : null
  return (
    <Provider store={store}>
      <div>
        <ConnectedRouter history={history}>
          <Route path="/" component={App} />
        </ConnectedRouter>
        {devtools}
      </div>
    </Provider>
  )
}

Root.propTypes = {
  store: PropTypes.shape({
    subscribe: PropTypes.func.isRequired,
    dispatch: PropTypes.func.isRequired,
    getState: PropTypes.func.isRequired
  }).isRequired,
  history: PropTypes.history.isRequired
}
