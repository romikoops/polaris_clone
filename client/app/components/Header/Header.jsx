import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { Redirect } from 'react-router'
import { connect } from 'react-redux'
import PropTypes from '../../prop-types'
import { NavDropdown } from '../NavDropdown/NavDropdown'
import styles from './Header.scss'
// import accountIcon from '../../assets/images/icons/person-dark.svg';
import defs from '../../styles/default_classes.scss'
import { LoginRegistrationWrapper } from '../LoginRegistrationWrapper/LoginRegistrationWrapper'
import { Modal } from '../Modal/Modal'

import { appActions, messagingActions } from '../../actions'
import { accountIconColor } from '../../helpers'

const iconColourer = accountIconColor
class Header extends Component {
  constructor (props) {
    super(props)
    this.state = {
      redirect: false,
      showLogin: false,
      isTop: true
    }
    this.goHome = this.goHome.bind(this)
    this.toggleShowLogin = this.toggleShowLogin.bind(this)
    this.toggleShowMessages = this.toggleShowMessages.bind(this)
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
    document.addEventListener('scroll', () => {
      const isTop = window.pageYOffset < 100
      if (isTop !== this.state.isTop) {
        this.setState({ isTop })
      }
    })
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

  goHome () {
    this.setState({ redirect: true })
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
      user, theme, tenant, invert, unread, req, landingPage
    } = this.props
    const dropDownText = user ? `${user.first_name} ${user.last_name}` : ''

    // const dropDownImage = accountIcon;
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

    const adjIcon = iconColourer(invert ? '#FFFFFF' : '#000000')
    if (this.state.redirect) {
      return <Redirect push to="/" />
    }
    const dropDown = (
      <NavDropdown
        dropDownText={dropDownText}
        dropDownImage={adjIcon}
        linkOptions={accountLinks}
        invert={invert}
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
    const textColour = invert ? 'white' : 'black'

    const dropDowns = (
      <div className="layout-row layout-align-space-around-center">
        {dropDown}
        {mail}
      </div>
    )

    const loginPrompt = (
      <a className={defs.pointy} style={{ color: textColour }} onClick={this.toggleShowLogin}>
        Log in
      </a>
    )
    const rightCorner = user && !user.guest ? dropDowns : loginPrompt
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
        width="40vw"
        verticalPadding="60px"
        horizontalPadding="0px"
        parentToggle={this.toggleShowLogin}
      />
    )
    const classProps = scrollable && !isTop
            ? `${styles.header_scrollable} 
        layout-row flex-100 layout-wrap layout-align-center`
            : `${styles.header}
        layout-row flex-100 layout-wrap layout-align-center`

        const sideNav = (
            <SideNav
                theme={theme}
                user={user}
            />);
        const dashboardMenu = (
            <FloatingMenu
                theme={theme}
                comp={sideNav}
            />);
        return (
            <div className={classProps} >
                <div className="flex layout-row layout-align-start">
                    { dashboard ? dashboardMenu : '' }
                </div>
                <div className="flex layout-row layout-align-start-center">
                    {this.props.menu}
                </div>
                <div className={`${defs.content_width} layout-row flex-none`}>
                    <div className={`${styles.infront} layout-row flex-50 layout-align-start-center`}>
                        <img
                            src={logoUrl}
                            className={logoStyle}
                            alt=""
                            onClick={this.goHome}
                        />
                    </div>
                    <div className="layout-row flex-50 layout-align-end-center">
                        {rightCorner}
                    </div>
                </div>
                <div className="flex layout-row layout-align-start-center">
                </div>
                { this.state.showLogin || this.props.loggingIn || this.props.registering ? loginModal : '' }

            </div>
        );
    }
}

Header.propTypes = {
  tenant: PropTypes.tenant,
  theme: PropTypes.theme,
  user: PropTypes.user,
  registering: PropTypes.bool,
  loggingIn: PropTypes.bool,
  menu: PropTypes.node,
  invert: PropTypes.bool,
  loginAttempt: PropTypes.bool,
  messageDispatch: PropTypes.shape({
    getUserConversations: PropTypes.func
  }).isRequired,
  messages: PropTypes.arrayOf(PropTypes.object),
  showRegistration: PropTypes.bool,
  unread: PropTypes.number,
  landingPage: PropTypes.bool,
  req: PropTypes.req
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
  landingPage: false,
  req: null,
  menu: null
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
