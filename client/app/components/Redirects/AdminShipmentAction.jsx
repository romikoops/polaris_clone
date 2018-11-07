import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { withRouter } from 'react-router-dom'
import { connect } from 'react-redux'
import { LoginPage } from '../../containers/LoginPage/LoginPage'
import { Modal } from '../../components/Modal/Modal'
import { adminActions, authenticationActions } from '../../actions'
import PropTypes from '../../prop-types'

class AdminShipmentAction extends Component {
  constructor (props) {
    super(props)
    this.handleAction = this.handleAction.bind(this)
    this.toggleShowLogin = this.toggleShowLogin.bind(this)
  }
  componentDidMount () {
    const { user, loggedIn, adminDispatch } = this.props
    if (!user || !loggedIn || user.guest) {
      this.toggleShowLogin()
    } else if (user && user.role && user.role.name === 'shipper') {
      adminDispatch.goTo('/')
    } else {
      this.handleAction()
    }
  }
  componentDidUpdate () {
    const { user, loggedIn } = this.props
    if (user && loggedIn && user.role && user.role.name === 'admin') {
      this.handleAction()
    }
  }
  handleAction () {
    const { match, address, adminDispatch } = this.props
    const { uuid } = match.params
    const query = new window.URLSearchParams(address.search)
    const action = query.get('action')
    if (action === 'edit') {
      adminDispatch.getShipment(uuid, true)
    } else {
      adminDispatch.confirmShipment(uuid, action, true)
    }
  }
  toggleShowLogin () {
    const { showModal, authenticationDispatch } = this.props
    if (showModal) {
      authenticationDispatch.closeLogin()
    } else {
      authenticationDispatch.showLogin({ noRedirect: true })
    }
  }
  render () {
    const { theme, loading } = this.props
    const loginModal = (
      <Modal
        component={<LoginPage theme={theme} />}
        parentToggle={this.toggleShowLogin}
      />
    )

    return <div className="layout-fill">{this.props.showModal && !loading ? loginModal : ''}</div>
  }
}

AdminShipmentAction.propTypes = {
  theme: PropTypes.theme,
  loading: PropTypes.bool,
  user: PropTypes.user.isRequired,
  loggedIn: PropTypes.bool,
  showModal: PropTypes.bool,
  adminDispatch: PropTypes.shape({
    goTo: PropTypes.func,
    confirmShipment: PropTypes.func,
    getShipment: PropTypes.func
  }).isRequired,
  authenticationDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  match: PropTypes.match.isRequired,
  address: PropTypes.address.isRequired
}

AdminShipmentAction.defaultProps = {
  theme: null,
  loading: false,
  showModal: false,
  loggedIn: false
}

function mapStateToProps (state) {
  const { authentication, tenant } = state
  const { user, loggedIn, showModal } = authentication
  return {
    user,
    tenant,
    theme: tenant.data.theme,
    loggedIn,
    showModal
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    authenticationDispatch: bindActionCreators(authenticationActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(AdminShipmentAction))
