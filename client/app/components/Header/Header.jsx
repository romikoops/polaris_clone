import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../prop-types'
import { NavDropdown } from '../NavDropdown/NavDropdown'
import styles from './Header.scss'
import defs from '../../styles/default_classes.scss'
import { LoginRegistrationWrapper } from '../LoginRegistrationWrapper/LoginRegistrationWrapper'
import { Modal } from '../Modal/Modal'
import { appActions, messagingActions } from '../../actions'

class Header extends Component {
  constructor (props) {
    super(props)
    this.state = {
      showLogin: false,
      isTop: true
    }
    this.goHome = this.goHome.bind(this)
    this.toggleShowLogin = this.toggleShowLogin.bind(this)
    this.toggleShowMessages = this.toggleShowMessages.bind(this)
    this.checkIsTop = this.checkIsTop.bind(this)
  }
  componentWillMount () {
    if (this.props.loginAttempt && !this.state.showLogin) {
      this.setState({ showLogin: true })
    }
  }
  componentDidMount () {
    const { messageDispatch, messages } = this.props
    if (!messages) {
      messageDispatch.getUserConversations()
    }
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
  }
  componentWillUnmount () {
    document.removeEventListener('scroll', this.checkIsTop)
  }
  checkIsTop () {
    const isTop = window.pageYOffset < 10
    if (isTop !== this.state.isTop) {
      this.setState({ isTop })
    }
  }
  goHome () {
    this.props.appDispatch.goTo('/')
  }
  toggleShowLogin () {
    this.setState({
      showLogin: !this.state.showLogin
    })
  }
  toggleShowMessages () {
    const { messageDispatch } = this.props
    messageDispatch.showMessageCenter()
  }
  render () {
    const {
      user, theme, tenant, invert, unread, req, scrollable, noMessages
    } = this.props
    const { isTop } = this.state
    const dropDownText = user && user.first_name ? `${user.first_name} ${user.last_name}` : ''

    const accountLinks = [
      {
        url: '/account',
        text: 'Account',
        fontAwesomeIcon: 'fa-cog',
        key: 'settings'
      },
      {
        url: '/signout',
        text: 'Sign out',
        fontAwesomeIcon: 'fa-sign-out',
        key: 'signOut'
      }
    ]

    const dropDown = (
      <NavDropdown
        dropDownText={dropDownText}
        linkOptions={accountLinks}
        invert={isTop && invert}
      />
    )

    const alertStyle = unread > 0 ? styles.unread : styles.all_read
    const mail = (
      <div
        className={`flex-none layout-row layout-align-center-center ${styles.mail_box}`}
        onClick={this.toggleShowMessages}
      >
        <span className={`${alertStyle} flex-none`}>{unread}</span>
        <i className="fa fa-envelope-o" />
      </div>
    )

    let logoUrl = ''
    let logoStyle
    if (theme && theme.logoWide) {
      logoUrl = theme.logoWide
      logoStyle = styles.wide_logo
    } else if (theme && theme.logoLarge) {
      logoUrl = theme.logoLarge
      logoStyle = styles.logo
    }
    const textColor = isTop && invert ? 'white' : 'black'
    const dropDowns = (
      <div className="layout-row layout-align-space-around-center">
        {dropDown}
        {!noMessages ? mail : ''}
      </div>
    )

    const loginPrompt = (
      <a className={defs.pointy} style={{ color: textColor }} onClick={this.toggleShowLogin}>
        Login/Register
      </a>
    )
    const rightCorner = user && user.first_name && !user.guest ? dropDowns : loginPrompt
    const loginModal = (
      <Modal
        component={
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
        }
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={this.toggleShowLogin}
      />
    )
    const headerClass =
      `${styles.header} layout-row flex-100 layout-wrap layout-align-center ` +
      `${invert ? styles.inverted : ''} ` +
      `${scrollable ? styles.scrollable : ''} ` +
      `${scrollable && !isTop ? styles.scrolled : ''}`

    return (
      <div
        className={headerClass}
        style={{ color: invert ? 'white' : 'black' }}
      >
        <div className="flex-100 layout-row" style={{ padding: '0 15px' }}>
          <div className="layout-row flex layout-align-start-center">
            <img
              src={logoUrl}
              className={logoStyle}
              alt=""
              onClick={this.goHome}
            />
          </div>
          <div className="flex layout-row layout-align-end-center">
            {rightCorner}
            { this.state.showLogin || this.props.loggingIn || this.props.registering ? loginModal : '' }
          </div>
        </div>
      </div>
    )
  }
}

Header.propTypes = {
  tenant: PropTypes.tenant,
  theme: PropTypes.theme,
  user: PropTypes.user,
  registering: PropTypes.bool,
  loggingIn: PropTypes.bool,
  invert: PropTypes.bool,
  loginAttempt: PropTypes.bool,
  messageDispatch: PropTypes.shape({
    getUserConversations: PropTypes.func
  }).isRequired,
  messages: PropTypes.arrayOf(PropTypes.object),
  showRegistration: PropTypes.bool,
  unread: PropTypes.number,
  req: PropTypes.req,
  scrollable: PropTypes.bool,
  appDispatch: PropTypes.func.isRequired,
  noMessages: PropTypes.bool
}

Header.defaultProps = {
  tenant: null,
  theme: null,
  user: null,
  registering: false,
  loggingIn: false,
  invert: false,
  loginAttempt: false,
  messages: null,
  showRegistration: false,
  unread: 0,
  req: null,
  scrollable: false,
  noMessages: false
}

function mapStateToProps (state) {
  const {
    authentication, tenant, shipment, app, messaging
  } = state
  const {
    user, loggedIn, loggingIn, registering, loginAttempt
  } = authentication
  const { unread, messages } = messaging
  const { currencies } = app
  return {
    user,
    tenant,
    loggedIn,
    loggingIn,
    registering,
    loginAttempt,
    shipment,
    currencies,
    unread,
    messages
  }
}
function mapDispatchToProps (dispatch) {
  return {
    appDispatch: bindActionCreators(appActions, dispatch),
    messageDispatch: bindActionCreators(messagingActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Header)
