import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import { moment } from '../../constants'
import LandingTop from '../../components/LandingTop/LandingTop'
import styles from './Landing.scss'
import { RoundButton } from '../../components/RoundButton/RoundButton'
import Loading from '../../components/Loading/Loading'
import { userActions, authenticationActions } from '../../actions'
import { gradientTextGenerator, isQuote, contentToHtml } from '../../helpers'
import withContent from '../../hocs/withContent'
import Footer from '../../components/Footer/Footer'

class Landing extends Component {
  constructor (props) {
    super(props)

    this.bookNow = this.bookNow.bind(this)
  }

  shouldComponentUpdate (nextProps) {
    const { loggingIn, registering, loading } = nextProps

    return loading || !(loggingIn || registering)
  }

  bookNow () {
    const {
      tenant, loggedIn, authDispatch, userDispatch, user
    } = this.props
    if (tenant.scope.closed_shop && (!user || user.guest || !loggedIn)) {
      authDispatch.showLogin()
    } else if (loggedIn) {
      userDispatch.goTo('/booking')
    } else {
      const unixTimeStamp = moment().unix().toString()
      const randNum = Math.floor(Math.random() * 100).toString()
      const randSuffix = unixTimeStamp + randNum
      const email = `guest${randSuffix}@${tenant.slug}.itsmycargo.shop`

      authDispatch.register(
        {
          email,
          password: 'guestpassword',
          password_confirmation: 'guestpassword',
          first_name: 'Guest',
          last_name: '',
          tenant_id: tenant.id,
          guest: true
        },
        '/booking'
      )
    }
  }

  render () {
    const {
      theme, user, tenant, content
    } = this.props
    const textStyle1 =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    const loadingScreen = this.props.loading ? <Loading theme={theme} /> : ''
    const defaultBulletContent = [
      (<div className="flex layout-row layout-align-start-center">
        <i className="fa fa-check" />
        <p> Place bookings from wherever, whenever </p>
      </div>),
      (<div className="flex layout-row layout-align-start-center">
        <i className="fa fa-check" />
        <p> Get an instant overview of available offers </p>
      </div>),
      (<div className="flex layout-row layout-align-start-center">
        <i className="fa fa-check" />
        <p> Reuse old shipments and store addresses </p>
      </div>),
      (<div className="flex layout-row layout-align-start-center">
        <i className="fa fa-check" />
        <p> View or download documents when you need them </p>
      </div>),
      (<div className="flex layout-row layout-align-start-center">
        <i className="fa fa-check" />
        <p> Pull statistics and reports on your logistics </p>
      </div>)
    ]

    const innerWrapperStyle = { position: 'relative' }
    const serviceContentToRender = content && content.services ? contentToHtml(content.services) : ['', '', '']
    const serviceTitlesToRender = content && content.serviceTitles ? contentToHtml(content.serviceTitles) : ([<h2 className="flex-none">
    Introducing Online Freight Booking Services
    </h2>])
    const bulletTitlesToRender = content && content.bulletTitles ? contentToHtml(content.bulletTitles) : ([<h2 className="flex-none">
    There are tons of benefits of managing your logistics online:
    </h2>])
    const bulletContentToRender = content && content.bullets ? contentToHtml(content.bullets) : defaultBulletContent
    const imageUrlRender = content && content.bulletImage ? `url(${content.bulletImage[0].image_url})` : false

    return (
      <div className={`${styles.wrapper_landing} layout-row flex-100 layout-wrap`}>
        <div className=" layout-row flex-100 layout-wrap" style={innerWrapperStyle}>
          {loadingScreen}
          <LandingTop
            className="flex-100"
            user={user}
            theme={theme}
            tenant={tenant}
            bookNow={this.bookNow}
          />
          {!isQuote(tenant) ? (
            <div className="layout-row flex-100 layout-wrap">
              <div className={`${styles.service_box} layout-row flex-100 layout-wrap`}>
                <div className={`${styles.service_label} layout-row layout-align-center-center flex-100 layout-wrap`}>
                  {serviceTitlesToRender}
                </div>
                <div className={`${styles.services_row} flex-100 layout-row layout-align-center`}>
                  <div
                    className="layout-row flex-100 flex-gt-sm-80 card layout-align-space-between-center"
                  >

                    <div
                      className={`flex-none layout-column layout-align-center-center ${styles.service}`}
                    >
                      <i className="fa fa-edit" aria-hidden="true" style={textStyle1} />
                      <h3> Real Time Quotes </h3>
                      <div
                        className={`flex-none layout-column layout-align-center-center ${styles.service_text}`}
                      >
                        {serviceContentToRender[0]}
                      </div>
                    </div>
                    <div
                      className={`flex-none layout-column layout-align-center-center ${styles.service}`}
                    >
                      <i className="fa fa-binoculars" aria-hidden="true" style={textStyle1} />
                      <h3> Full Transparency </h3>
                      <div
                        className={`flex-none layout-column layout-align-center-center ${styles.service_text}`}
                      >
                        {serviceContentToRender[1]}
                      </div>
                    </div>
                    <div
                      className={`flex-none layout-column layout-align-center-center ${styles.service}`}
                    >
                      <i className="fa fa-bolt" aria-hidden="true" style={textStyle1} />
                      <h3> Instant Booking </h3>
                      <div
                        className={`flex-none layout-column layout-align-center-center ${styles.service_text}`}
                      >
                        {serviceContentToRender[2]}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div className={`${styles.btm_promo} flex-100 layout-row`}>
                <div
                  className={`flex-45 btm_promo_img ${imageUrlRender ? '' : 'default'}`}
                  style={{ backgroundImage: imageUrlRender }}
                />
                <div className={`${styles.btm_promo_text} flex-55 layout-row layout-align-start-start`}>
                  <div className="flex-90 layout-column layout-align-start-start height_100">
                    <div className="flex-20 layout-column layout-align-center-start">
                      {bulletTitlesToRender}
                    </div>
                    <div className={`flex-65 layout-column layout-align-start-start ${styles.promo_bullets}`}>
                      {bulletContentToRender}
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
                        handleNext={this.bookNow}
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ) : ''}
        </div>
        <Footer theme={theme} tenant={tenant} bookNow={this.bookNow} />
      </div>
    )
  }
}

Landing.defaultProps = {
  loggedIn: false,
  loggingIn: false,
  loading: false,
  theme: null,
  tenant: null,
  user: null
}

function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch),
    authDispatch: bindActionCreators(authenticationActions, dispatch)
  }
}
function mapStateToProps (state) {
  const {
    users, authentication, admin, app
  } = state
  const { tenant } = app
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

export default withContent(withRouter(connect(mapStateToProps, mapDispatchToProps)(Landing)), 'Landing')
