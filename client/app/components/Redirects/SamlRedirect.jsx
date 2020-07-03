import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import queryString from 'query-string'
import { withRouter } from 'react-router-dom'
import { connect } from 'react-redux'
import { authenticationActions } from '../../actions'
import Loading from '../Loading/Loading'

class SamlRedirect extends Component {
  componentDidMount () {
    const { authenticationDispatch, location, failure } = this.props
    if (failure) {
      authenticationActions.goTo('/')
    }

    const newAuthHeaderAndUserId = queryString.parse(location.search)
    const { userId, organizationId } = newAuthHeaderAndUserId
    delete newAuthHeaderAndUserId.userId

    authenticationDispatch.postSamlActions({ headers: newAuthHeaderAndUserId, userId, organizationId })
  }

  render () {
    const { theme } = this.props

    return <Loading theme={theme} />
  }
}

function mapStateToProps (state) {
  const { app } = state
  const { tenant } = app

  return {
    tenant,
    theme: tenant.theme
  }
}
function mapDispatchToProps (dispatch) {
  return {
    authenticationDispatch: bindActionCreators(authenticationActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(SamlRedirect))
