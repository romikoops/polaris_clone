import React from 'react'
import PropTypes from 'prop-types'
import { Route, Redirect } from 'react-router-dom'

const isAdmin = user => (user && user.role_id === 1) || (user && user.role_id === 3)

export default function AdminPrivateRoute ({
  component: Component, user, loggedIn, ...rest
}) {
  return (
    <Route
      {...rest}
      render={({ location, ...props }) =>
        (isAdmin(user) && loggedIn ? (
          <Component location={location} {...props} />
        ) : (
          <Redirect to={{ pathname: '/', state: { from: location } }} />
        ))
      }
    />
  )
}

AdminPrivateRoute.propTypes = {
  component: PropTypes.node.isRequired,
  loggedIn: PropTypes.bool,
  // eslint-disable-next-line react/forbid-prop-types
  user: PropTypes.any
}

AdminPrivateRoute.defaultProps = {
  loggedIn: false,
  user: null
}
