import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import NavDropdown from '../NavDropdown/NavDropdown'
import LoginRegistrationWrapper from '../LoginRegistrationWrapper/LoginRegistrationWrapper'
import styles from './Header.scss'
import { LoginPage } from '../../containers/LoginPage/LoginPage'
import { Modal } from '../Modal/Modal'
import {
  appActions,
  messagingActions,
  adminActions,
  authenticationActions,
  shipmentActions
} from '../../actions'
import FlashMessages from '../FlashMessages/FlashMessages'
import Alert from '../Alert/Alert'

class Header extends Component {
  constructor (props) {
    super(props)
    this.state = {
      showLogin: false,
      isTop: true,
      alertVisible: false,
      showTenants: false
    }
    this.goHome = this.goHome.bind(this)
    this.toggleShowLogin = this.toggleShowLogin.bind(this)
    this.toggleShowMessages = this.toggleShowMessages.bind(this)
    this.checkIsTop = this.checkIsTop.bind(this)
    this.hideAlert = this.hideAlert.bind(this)
  }

  componentWillMount () {
    if (this.props.loginAttempt && !this.state.showLogin) {
      this.setState({ showLogin: true })
    }
    if (this.props.loginAttempt && !this.state.alertVisible) {
      this.setState({ alertVisible: true })
    }
  }

  componentDidMount () {
    document.addEventListener('scroll', this.checkIsTop)
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.showRegistration) {
      this.setState({
        showLogin: true
      })
    }
    if (this.props.showRegistration && !nextProps.showRegistration) {
      this.setState({
        showLogin: false
      })
    }
    if (nextProps.loginAttempt && !this.state.alertVisible) {
      this.setState({ alertVisible: true })
    }
  }

  componentWillUnmount () {
    document.removeEventListener('scroll', this.checkIsTop)
  }

  checkIsTop () {
    const isTop = window.pageYOffset < 130
    if (isTop !== this.state.isTop) {
      this.setState({ isTop })
    }
  }

  goHome () {
    this.props.appDispatch.goTo('/')
  }

  hideAlert () {
    this.setState({ alertVisible: false })
  }

  toggleShowLogin () {
    const { showModal, authenticationDispatch, noRedirect } = this.props
    if (showModal) {
      authenticationDispatch.closeLogin()
    } else {
      authenticationDispatch.showLogin({ noRedirect })
    }
  }

  toggleShowMessages () {
    const { messageDispatch } = this.props
    messageDispatch.showMessageCenter()
  }

  render () {
    const {
      component,
      currentStage,
      error,
      invert,
      isLanding,
      req,
      scrollable,
      t,
      tenant,
      theme,
      user,
      authentication
    } = this.props
    const { isTop } = this.state
    const scope = tenant && tenant.id ? tenant.scope : {}
    const dropDownText = user && user.first_name ? `${user.first_name} ${user.last_name}` : ''
    const accountLinks = user && user.role && user.role.name.includes('admin')
      ? [
        {
          url: '/admin/dashboard',
          text: t('nav:account'),
          fontAwesomeIcon: 'fa-cog',
          key: 'settings'
        },
        {
          url: '/signout',
          text: t('nav:signOut'),
          fontAwesomeIcon: 'fa-sign-out',
          key: 'signOut'
        }
      ]
      : [
        {
          url: '/account',
          text: t('nav:account'),
          fontAwesomeIcon: 'fa-cog',
          key: 'settings'
        },
        {
          url: '/signout',
          text: t('nav:signOut'),
          fontAwesomeIcon: 'fa-sign-out',
          key: 'signOut'
        }
      ]

    let logoUrl = ''
    let logoStyle
    const logoDisplay = {
      display: `${isTop && invert ? 'none' : 'block'}`
    }

    if (theme && theme.logoWide) {
      logoUrl = theme.logoWide
      logoStyle = styles.wide_logo
    } else if (theme && theme.logoLarge) {
      logoUrl = theme.logoLarge
      logoStyle = styles.logo
    }

    const dropDown = (
      <NavDropdown
        dropDownText={dropDownText}
        linkOptions={accountLinks}
        invert={isTop && invert}
        user={user}
        isLanding={isLanding}
        toggleShowLogin={this.toggleShowLogin}
        loginText={scope.closed_registration ? t('common:logIn') : `${t('common:logIn')} / ${t('common:register')}`}
      />
    )
    const hasErrors = error && error[currentStage] && error[currentStage].length > 0

    const dropDowns = (
      <div className="layout-row layout-align-space-around-center">
        {dropDown}
      </div>
    )

    const loginComponent = (scope.closed_registration || !tenant.id) ? (
      <LoginPage
        theme={theme}
        req={req}
      />
    ) : (
      <LoginRegistrationWrapper
        LoginPageProps={{ theme, req }}
        RegistrationPageProps={{
          theme,
          tenant,
          req,
          user
        }}
        initialCompName={this.props.showRegistration ? 'RegistrationPage' : 'LoginPage'}
      />
    )

    const loginModal = (
      <Modal
        component={loginComponent}
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={this.toggleShowLogin}
      />
    )

    const alert = this.state.alertVisible ? (
      <Alert
        message={{ type: 'error', text: authentication.error.message }}
        onClose={this.hideAlert}
        timeout={50000}
        isLogin
      />
    ) : (
      ''
    )

    const headerClass =
      `${styles.header} layout-row flex-100 layout-wrap layout-align-center ` +
      `${invert ? styles.inverted : ''} ` +
      `${scrollable ? styles.scrollable : ''} ` +
      `${scrollable && !isTop ? styles.scrolled : ''}`

    return (
      <div className={headerClass} style={{ color: invert ? 'white' : 'black' }}>
        <div className="flex-100 layout-row" style={{ padding: '0 15px' }}>
          <div className="layout-row flex layout-align-start-center pointy">
            <img
              src={logoUrl}
              className={`${logoStyle}`}
              style={logoDisplay}
              alt=""
              onClick={this.goHome}
            />
          </div>
          {component}
          <div className="flex layout-row layout-align-end-center">
            {dropDowns}
            { this.props.showModal && loginModal }
          </div>
        </div>
        {alert}
        { hasErrors
          ? (
            <div className={`flex-none layout-row ${styles.error_messages}`}>
              <FlashMessages messages={error[currentStage]} />
            </div>
          ) : '' }
      </div>
    )
  }
}

Header.defaultProps = {
  tenant: null,
  theme: null,
  user: null,
  registering: false,
  noRedirect: false,
  isLanding: false,
  loggingIn: false,
  invert: false,
  loginAttempt: false,
  messages: null,
  showRegistration: false,
  req: null,
  scrollable: false,
  component: null,
  showModal: false,
  error: null,
  currentStage: 'stage1'
}

function mapStateToProps (state) {
  const {
    authentication, shipment, app, messaging, bookingData
  } = state
  const {
    user, loggedIn, loggingIn, registering, loginAttempt, showModal
  } = authentication
  const { unread, messages } = messaging
  const { currencies, tenant, tenants } = app
  const { error, currentStage } = bookingData

  return {
    user,
    tenant,
    loggedIn,
    loggingIn,
    registering,
    loginAttempt,
    shipment,
    currencies,
    tenants,
    unread,
    messages,
    showModal,
    error,
    currentStage,
    authentication
  }
}

function mapDispatchToProps (dispatch) {
  return {
    appDispatch: bindActionCreators(appActions, dispatch),
    authenticationDispatch: bindActionCreators(authenticationActions, dispatch),
    adminDispatch: bindActionCreators(adminActions, dispatch),
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch),
    messageDispatch: bindActionCreators(messagingActions, dispatch)
  }
}

export default withNamespaces(['nav', 'common'])(connect(mapStateToProps, mapDispatchToProps)(Header))
