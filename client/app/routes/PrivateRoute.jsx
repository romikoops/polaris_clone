import React from 'react'
import PropTypes from 'prop-types'
import { Route, Redirect } from 'react-router-dom'

export default function PrivateRoute ({
  component: Component, user, loggedIn, theme, ...rest
}) {
  return (
    <Route
      {...rest}
      render={({ location, ...props }) =>
        (user && loggedIn ? (
          <Component theme={theme} location={location} {...props} />
        ) : (
          <Redirect to={{ pathname: '/', state: { from: location } }} />
        ))
      }
    />
  )
}

PrivateRoute.propTypes = {
  component: PropTypes.func.isRequired,
  loggedIn: PropTypes.bool,
  // eslint-disable-next-line react/forbid-prop-types
  user: PropTypes.any,
  // eslint-disable-next-line react/forbid-prop-types
  theme: PropTypes.object
}

PrivateRoute.defaultProps = {
  loggedIn: false,
  user: null,
  theme: null
}
