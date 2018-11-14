import React, { Component } from 'react'
import { withRouter } from 'react-router-dom'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { appActions } from '../../actions'
import { moment } from '../../constants'
import getApiHost from '../constants/api.constants'
import { authHeader } from '../../helpers'

const { localStorage, fetch } = window

class CacheClearer extends Component {
  static checkState () {
    const resetTime = localStorage.getItem('lastReset')
    const requestOptions = {
      method: 'GET',
      headers: authHeader()
    }
    return fetch(`${getApiHost()}/messaging/get`, requestOptions).then((data) => {
      if (data.reset && moment(data.reset.time).isAfter(moment(resetTime))) {
        localStorage.removeItem('state')
        localStorage.removeItem('user')
        localStorage.removeItem('authHeader')
        localStorage.setItem('lastReset', moment().format('x'))
      }
    })
  }
  constructor (props) {
    super(props)
    this.state = {}
  }
  componentDidMount () {
    this.startCheck()
  }
  componentWillUnmount () {
    this.cancelCheck()
  }
  startCheck () {
    const interval = setInterval(() => {
      CacheClearer.checkState()
    }, 3600)
    this.setState({ interval })
  }
  cancelCheck () {
    clearInterval(this.state.interval)
  }

  render () {
    return <div className="flex-none layout-row layout-wrap layout-align-center-center" />
  }
}

function mapStateToProps (state) {
  const {
    users, authentication, app, bookingData, admin
  } = state
  const { tenant } = app

  return {
    users,
    authentication,
    tenant,
    bookingData,
    admin
  }
}
function mapDispatchToProps (dispatch) {
  return {
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(CacheClearer))
