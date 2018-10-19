import React from 'react'
import PropTypes from 'prop-types'
import { Route, Redirect } from 'react-router-dom'

const isSuperAdmin = user => (user && user.role && user.role.name === 'super_admin')

export default function SuperAdminPrivateRoute ({
  component: Component, user, loggedIn, ...rest
}) {
  return (
    <Route
      {...rest}
      render={({ location, ...props }) =>
        (isSuperAdmin(user) ? (
          <Component location={location} {...props} />
        ) : (
          <Redirect to={{ pathname: '/', state: { from: location } }} />
        ))
      }
    />
  )
}

SuperAdminPrivateRoute.propTypes = {
  component: PropTypes.func.isRequired,
  loggedIn: PropTypes.bool,
  // eslint-disable-next-line react/forbid-prop-types
  user: PropTypes.any
}

SuperAdminPrivateRoute.defaultProps = {
  loggedIn: false,
  user: null
}
