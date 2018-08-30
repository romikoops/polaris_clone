import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'
import { moment } from '../../constants'
import { LandingTop } from '../../components/LandingTop/LandingTop'
import styles from './Landing.scss'
import { RoundButton } from '../../components/RoundButton/RoundButton'
import Loading from '../../components/Loading/Loading'
import { userActions, adminActions, authenticationActions } from '../../actions'
import { gradientTextGenerator } from '../../helpers'
import { Footer } from '../../components/Footer/Footer'

class Landing extends Component {
  constructor (props) {
    super(props)
    this.state = {
      showLogin: false
    }
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
        '/booking'
      )
    }
  }

  toggleShowLogin () {
    this.setState({
      showLogin: !this.state.showLogin
    })
  }

  render () {
    const {
      loggedIn, theme, user, tenant, userDispatch, authDispatch, adminDispatch, loggingIn
    } = this.props
    const textStyle1 =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const loadingScreen = this.props.loading || loggingIn ? <Loading theme={theme} /> : ''

    const minHeightForFooter = window.innerHeight - 350
    const footerStyle = { minHeight: `${minHeightForFooter}px`, position: 'relative', paddingBottom: '230px' }

    // debugger // eslint-disable-line
    return (
      <div className={`${styles.wrapper_landing} layout-row flex-100 layout-wrap`}>
        <div className=" layout-row flex-100 layout-wrap" style={footerStyle}>
          {loadingScreen}
          <LandingTop
            className="flex-100"
            user={user}
            theme={theme}
            goTo={userDispatch.goTo}
            toAdmin={adminDispatch.getDashboard}
            loggedIn={loggedIn}
            tenant={tenant}
            toggleShowLogin={() => this.toggleShowLogin()}
            authDispatch={authDispatch}
            bookNow={() => this.bookNow()}
          />
          <div className={`${styles.service_box} layout-row flex-100 layout-wrap`}>
            <div className={`${styles.service_label} layout-row layout-align-center-center flex-100`}>
              <h2 className="flex-none">
                {' '}
                {t('landing:title')}
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
                  <h3> {t('landing:instantIconText')} </h3>
                </div>
                <div
                  className={`flex-none layout-column layout-align-center-center ${styles.service}`}
                >
                  <i className="fa fa-edit" aria-hidden="true" style={textStyle1} />
                  <h3> {t('landing:quoteIconText')} </h3>
                </div>
                <div
                  className={`flex-none layout-column layout-align-center-center ${styles.service}`}
                >
                  <i className="fa fa-binoculars" aria-hidden="true" style={textStyle1} />
                  <h3> {t('landing:transparencyIconText')} </h3>
                </div>
                <div
                  className={`flex-none layout-column layout-align-center-center ${styles.service}`}
                >
                  <i className="fa fa-clock-o" aria-hidden="true" style={textStyle1} />
                  <h3>{t('landing:realTimeIconText')} </h3>
                </div>
              </div>
            </div>
          </div>
          {/* <BlogPostHighlights theme={theme} /> */}
          <div className={`${styles.btm_promo} flex-100 layout-row`}>
            <div className={`flex-50 ${styles.btm_promo_img}`} />
            <div className={`${styles.btm_promo_text} flex-50 layout-row layout-align-start-start`}>
              <div className="flex-90 layout-column layout-align-start-start height_100">
                <div className="flex-20 layout-column layout-align-center-start">
                  <h2> {t('landing:benefits')} </h2>
                </div>
                <div className="flex-65 layout-column layout-align-start-start">
                  <div className="flex layout-row layout-align-start-center">
                    <i className="fa fa-check" />
                    <p> {t('landing:placeBooking')} </p>
                  </div>
                  <div className="flex layout-row layout-align-start-center">
                    <i className="fa fa-check" />
                    <p> {t('landing:offersOverview')} </p>
                  </div>
                  <div className="flex layout-row layout-align-start-center">
                    <i className="fa fa-check" />
                    <p> {t('landing:reuseShipments')} </p>
                  </div>
                  <div className="flex layout-row layout-align-start-center">
                    <i className="fa fa-check" />
                    <p> {t('landing:viewDocuments')} </p>
                  </div>
                  <div className="flex layout-row layout-align-start-center">
                    <i className="fa fa-check" />
                    <p> {t('landing:showStats')} </p>
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
        <Footer theme={theme} tenant={tenant.data} />
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
  loggingIn: PropTypes.bool,
  // eslint-disable-next-line react/forbid-prop-types
  authDispatch: PropTypes.any.isRequired,
  t: PropTypes.func
}

Landing.defaultProps = {
  loggedIn: false,
  loggingIn: false,
  loading: false,
  theme: null,
  tenant: null,
  user: null,
  t: null
}

function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch),
    adminDispatch: bindActionCreators(adminActions, dispatch),
    authDispatch: bindActionCreators(authenticationActions, dispatch)
  }
}
function mapStateToProps (state) {
  const {
    users, authentication, tenant, admin
  } = state
  const {
    user, loggedIn, loggingIn, registering, showModal
  } = authentication
  const loading = authentication.loading || admin.loading

  return {
    user,
    users,
    tenant,
    loggedIn,
    loggingIn,
    registering,
    loading,
    showModal
  }
}

export default translate(['landing', 'common'])(withRouter(connect(mapStateToProps, mapDispatchToProps)(Landing)))
