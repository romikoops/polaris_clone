import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import PropTypes from '../../prop-types'
import { moment } from '../../constants'
import { LandingTop } from '../../components/LandingTop/LandingTop'
import { ActiveRoutes } from '../../components/ActiveRoutes/ActiveRoutes'
import { BlogPostHighlights } from '../../components/BlogPostHighlights/BlogPostHighlights'
import styles from './Landing.scss'
// import defaults from '../../styles/default_classes.scss';
import { RoundButton } from '../../components/RoundButton/RoundButton'
import Loading from '../../components/Loading/Loading'
import { userActions, adminActions, authenticationActions } from '../../actions'
import { LoginRegistrationWrapper } from '../../components/LoginRegistrationWrapper/LoginRegistrationWrapper'
import { Modal } from '../../components/Modal/Modal'
import { gradientTextGenerator } from '../../helpers'

class Landing extends Component {
  constructor (props) {
    super(props)
    this.state = {
      showCarousel: false,
      showLogin: false
    }
    this.showCarousel = this.showCarousel.bind(this)
    this.toggleShowLogin = this.toggleShowLogin.bind(this)
  }
  componentDidMount () {
    this.showCarousel()
  }
  shouldComponentUpdate (nextProps) {
    const { loggingIn, registering, loading } = nextProps
    return loading || !(loggingIn || registering)
  }
  bookNow () {
    const {
      tenant, loggedIn, authDispatch, userDispatch
    } = this.props

    if (loggedIn) {
      userDispatch.goTo('/booking')
    } else {
      const unixTimeStamp = moment().unix().toString()
      const randNum = Math.floor(Math.random() * 100).toString()
      const randSuffix = unixTimeStamp + randNum
      const email = `guest${randSuffix}@${tenant.data.subdomain}.com`

      authDispatch.register(
        {
          email,
          password: 'guestpassword',
          password_confirmation: 'guestpassword',
          first_name: 'Guest',
          last_name: '',
          tenant_id: tenant.data.id,
          guest: true
        },
        true
      )
    }
  }

  showCarousel () {
    this.setState({ showCarousel: true })
  }

  toggleShowLogin () {
    this.setState({
      showLogin: !this.state.showLogin
    })
  }

  render () {
    const {
      loggedIn, theme, user, tenant, userDispatch, authDispatch, adminDispatch
    } = this.props
    const { showCarousel } = this.state
    const textStyle1 =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const textStyle2 =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.secondary, theme.colors.primary)
        : { color: 'black' }
    const loadingScreen = this.props.loading ? <Loading theme={theme} /> : ''
    const loginModal = (
      <Modal
        component={
          <LoginRegistrationWrapper
            LoginPageProps={{ theme }}
            RegistrationPageProps={{ theme, tenant }}
            initialCompName="RegistrationPage"
          />
        }
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={this.toggleShowLogin}
      />
    )
    return (
      <div className={`${styles.wrapper_landing} layout-row flex-100 layout-wrap`}>
        {loadingScreen}
        {this.state.showLogin ? loginModal : ''}
        <LandingTop
          className="flex-100"
          user={user}
          theme={theme}
          goTo={userDispatch.goTo}
          toAdmin={adminDispatch.getDashboard}
          loggedIn={loggedIn}
          tenant={tenant}
          authDispatch={authDispatch}
          bookNow={() => this.bookNow()}
        />
        <div className={`${styles.service_box} layout-row flex-100 layout-wrap`}>
          <div className={`${styles.service_label} layout-row layout-align-center-center flex-100`}>
            <h2 className="flex-none">
              {' '}
              Introducing Online Freight Booking Services {this.props.loggedIn}
            </h2>
          </div>
          <div className={`${styles.services_row} flex-100 layout-row layout-align-center`}>
            <div
              className="layout-row flex-100 flex-gt-sm-80 card layout-align-space-between-center"
            >
              <div
                className={`flex-none layout-column layout-align-center-center ${styles.service}`}
              >
                <i className="fa fa-bolt" aria-hidden="true" style={textStyle1} />
                <h3> Instant Booking </h3>
              </div>
              <div
                className={`flex-none layout-column layout-align-center-center ${styles.service}`}
              >
                <i className="fa fa-edit" aria-hidden="true" style={textStyle2} />
                <h3> Real Time Quotes </h3>
              </div>
              <div
                className={`flex-none layout-column layout-align-center-center ${styles.service}`}
              >
                <i className="fa fa-binoculars" aria-hidden="true" style={textStyle1} />
                <h3> Full Transparency </h3>
              </div>
              <div
                className={`flex-none layout-column layout-align-center-center ${styles.service}`}
              >
                <i className="fa fa-clock-o" aria-hidden="true" style={textStyle2} />
                <h3>Updates in Real Time </h3>
              </div>
            </div>
          </div>
        </div>
        {showCarousel ? <ActiveRoutes className={styles.mc} theme={theme} /> : ''}
        <BlogPostHighlights theme={theme} />
        <div className={`${styles.btm_promo} flex-100 layout-row`}>
          <div className={`flex-50 ${styles.btm_promo_img}`} />
          <div className={`${styles.btm_promo_text} flex-50 layout-row layout-align-start-start`}>
            <div className="flex-90 layout-column layout-align-start-start height_100">
              <div className="flex-20 layout-column layout-align-center-start">
                <h2> There are tons of benefits of managing your logistics online: </h2>
              </div>
              <div className="flex-65 layout-column layout-align-start-start">
                <div className="flex layout-row layout-align-start-center">
                  <i className="fa fa-check" />
                  <p> Place bookings from wherever, whenever </p>
                </div>
                <div className="flex layout-row layout-align-start-center">
                  <i className="fa fa-check" />
                  <p> Get an instant overview of available offers </p>
                </div>
                <div className="flex layout-row layout-align-start-center">
                  <i className="fa fa-check" />
                  <p> Reuse old shipments and store addresses </p>
                </div>
                <div className="flex layout-row layout-align-start-center">
                  <i className="fa fa-check" />
                  <p> View or download documents when you need them </p>
                </div>
                <div className="flex layout-row layout-align-start-center">
                  <i className="fa fa-check" />
                  <p> Pull statistics and reports on your logistics </p>
                </div>
              </div>
              <div className={
                `${styles.btm_promo_btn_wrapper} flex-15 ` +
                'layout-row layout-align-start-left'
              }
              >
                <RoundButton
                  text="Book Now"
                  theme={theme}
                  active
                  handleNext={() => this.bookNow()}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

Landing.propTypes = {
  tenant: PropTypes.tenant,
  theme: PropTypes.theme,
  user: PropTypes.user,
  loggedIn: PropTypes.bool,
  loading: PropTypes.bool,
  userDispatch: PropTypes.shape({
    goTo: PropTypes.func
  }).isRequired,
  adminDispatch: PropTypes.shape({
    getDashboard: PropTypes.func
  }).isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  authDispatch: PropTypes.any.isRequired
}

Landing.defaultProps = {
  loggedIn: false,
  loading: false,
  theme: null,
  tenant: null,
  user: null
}

function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch),
    adminDispatch: bindActionCreators(adminActions, dispatch),
    authDispatch: bindActionCreators(authenticationActions, dispatch)
  }
}
function mapStateToProps (state) {
  const { users, authentication, tenant } = state
  const {
    user, loggedIn, loggingIn, registering, loading
  } = authentication
  return {
    user,
    users,
    tenant,
    loggedIn,
    loggingIn,
    registering,
    loading
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Landing))
