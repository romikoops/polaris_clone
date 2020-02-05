import React from 'react'
import { Route, Redirect } from 'react-router-dom'
import PropTypes from 'prop-types'
import { cookieKey } from '../../helpers'

export const PrivateRoute = ({ component: Component, ...rest }) => (
  <Route
    {...rest}
    render={props =>
      (window.localStorage.getItem(cookieKey()) ? (
        <Component {...props} />
      ) : (
        // eslint-disable-next-line react/prop-types
        <Redirect to={{ pathname: '/login', state: { from: props.location } }} />
      ))
    }
  />
)

PrivateRoute.propTypes = {
  component: PropTypes.node.isRequired
}

export default PrivateRoute
