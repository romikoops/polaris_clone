import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { withRouter } from 'react-router-dom'
import { connect } from 'react-redux'
import { LoginPage } from '../../containers/LoginPage/LoginPage'
import { Modal } from '../../components/Modal/Modal'
import { adminActions } from '../../actions'
import PropTypes from '../../prop-types'

class AdminShipmentAction extends Component {
  constructor (props) {
    super(props)
    this.state = {
      showLogin: false
    }
    this.handleAction = this.handleAction.bind(this)
    this.toggleShowLogin = this.toggleShowLogin.bind(this)
  }
  componentDidMount () {
    const { user, loggedIn, adminDispatch } = this.props
    if (!user || !loggedIn || user.guest) {
      this.toggleShowLogin()
    } else if (user && user.role.name === 'shipper') {
      adminDispatch.goTo('/')
    } else {
      this.handleAction()
    }
  }
  componentDidUpdate () {
    const { user, loggedIn } = this.props
    if (user && loggedIn && user.role.name === 'admin') {
      this.handleAction()
    }
  }
  handleAction () {
    const { match, location, adminDispatch } = this.props
    const { uuid } = match.params
    const query = new window.URLSearchParams(location.search)
    const action = query.get('action')
    if (action === 'edit') {
      adminDispatch.getShipment(uuid, true)
    } else {
      adminDispatch.confirmShipment(uuid, action, true)
    }
  }
  toggleShowLogin () {
    this.setState({
      showLogin: !this.state.showLogin
    })
  }
  render () {
    const { theme, loading } = this.props
    const loginModal = (
      <Modal
        component={<LoginPage theme={theme} noRedirect />}
        parentToggle={this.toggleShowLogin}
      />
    )
    return <div className="layout-fill">{this.state.showLogin && !loading ? loginModal : ''}</div>
  }
}

AdminShipmentAction.propTypes = {
  theme: PropTypes.theme,
  loading: PropTypes.bool,
  user: PropTypes.user.isRequired,
  loggedIn: PropTypes.bool,
  adminDispatch: PropTypes.shape({
    goTo: PropTypes.func,
    confirmShipment: PropTypes.func,
    getShipment: PropTypes.func
  }).isRequired,
  match: PropTypes.match.isRequired,
  location: PropTypes.location.isRequired
}

AdminShipmentAction.defaultProps = {
  theme: null,
  loading: false,
  loggedIn: false
}

function mapStateToProps (state) {
  const { authentication, tenant } = state
  const { user, loggedIn } = authentication
  return {
    user,
    tenant,
    theme: tenant.data.theme,
    loggedIn
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(AdminShipmentAction))
