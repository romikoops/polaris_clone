import React, { Component } from 'react'
import { Redirect } from 'react-router'
import { connect } from 'react-redux'
import PropTypes from '../../prop-types'
import { authenticationActions } from '../../actions'

class SignOut extends Component {
  componentDidMount () {
    const { dispatch } = this.props
    dispatch(authenticationActions.logout())
  }

  render () {
    return <Redirect to="/" />
  }
}

function mapStateToProps (state) {
  const { loggingIn } = state.authentication
  return {
    loggingIn
  }
}

SignOut.propTypes = {
  dispatch: PropTypes.func.isRequired
}

const connectedSignOut = connect(mapStateToProps)(SignOut)
export { connectedSignOut as SignOut }

export default connectedSignOut
