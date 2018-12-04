import React from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { adminActions } from '../actions'
import PrivateRoute from './PrivateRoute'

function NonAdminPrivateRoute ({
  user, adminDispatch, ...rest
}) {
  const isAdmin = user && user.role && (user.role.name === 'admin' || user.role.name === 'super_admin')

  if (isAdmin) {
    adminDispatch.getDashboard(true)

    return ''
  }

  return <PrivateRoute {...rest} user={user} />
}

function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default connect(null, mapDispatchToProps)(NonAdminPrivateRoute)
