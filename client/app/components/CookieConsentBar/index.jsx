import React from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { authenticationActions } from '../../actions'
import PropTypes from '../../prop-types'
import styles from './CookieConsentBar.scss'
import { moment } from '../../constants'
import { ROW, trim, COLUMN } from '../../classNames'
import setCookie from './_modules/setCookie'
import getCookie from './_modules/getCookie'

const sampleData = {
  title: 'This site use cookies',
  description: trim(`
  We and our advertising partners                    
  use these cookies to deliver advertisements, 
  to make them more relevant and meaningful
  to visitors to our website, and to track
  the efficiency of our advertising campaigns, 
  both on our services and on other websites.
  `),
  modalTitle: 'Cookie declaration',
  modalDescription: trim(`
  We use cookies to personalize content and ads, 
  to provide social media features and to analyze 
  our traffic. 
  `),
  modalMandatory: trim(`
  These cookies are necessary for the Website to function and cannot be turned off in our systems. They are usually only set in response to actions made by you which amount to a request for information or services, such as logging in or filling in forms on our Website.
  `),
  modalMarketing: trim(`
  These cookies enable us to provide enhanced functionality and personalization for our website. They may be set by us or by third party providers whose services we have added to our pages.
  `),
  modalTracking: trim(`
  These cookies may be set through our site by our advertising partners. They may be used by those companies to build a profile of your interests and show you relevant adverts on other websites.
  `)
}

const MODAL = `${styles.modal} ${COLUMN(100)}`
const MODAL_TITLE = `${COLUMN(50)} ${styles.modal_title}`
const MODAL_DESCRIPTION = `${COLUMN(50)} ${
  styles.modal_description
}`
const MODAL_SECTION_TEXT = `${ROW(80)} ${styles.modal_section_text}`
const MODAL_SECTION_TITLE = `${COLUMN(10)} ${
  styles.modal_section_title
}`
const MODAL_SECTION_BUTTON = `${ROW(35)} ${
  styles.modal_section_button
}`
const SHOW_DETAILS_BOX = `${ROW(35)} ${styles.show_details}`
const LEARN_MORE = `${ROW(20)} ${styles.show_details}`
const BOX_LEFT = `${ROW(65)} ${styles.box_left}`
const BOX_RIGHT = `${ROW(35)} layout-row`
const BOX_RIGHT_INNER = `${ROW(100)} layout-align-center ${styles.padding_top}`
const TOGGLE = `${styles.mandatory} fa fa-3x fa-toggle-on`

function getToggleStyle (flag) {
  const base = 'fa fa-3x'
  const active = flag
    ? styles.active
    : styles.inactive
  const on = flag
    ? 'fa-toggle-on'
    : 'fa-toggle-off'

  return `${base} ${active} ${on}`
}

function handleAccept (user, tenant, loggedIn, authDispatch) {
  if (loggedIn) {
    authDispatch.updateUser(user, { cookies: true })
  } else {
    const unixTimeStamp = moment()
      .unix()
      .toString()
    const randNum = Math.floor(Math.random() * 100).toString()
    const randSuffix = unixTimeStamp + randNum
    const email = `guest${randSuffix}@${tenant.subdomain}.com`

    authDispatch.register({
      email,
      password: 'guestpassword',
      password_confirmation: 'guestpassword',
      first_name: 'Guest',
      last_name: '',
      tenant_id: tenant.id,
      guest: true,
      cookies: true
    })
  }
}

class CookieConsentBar extends React.PureComponent {
  static getDerivedStateFromProps (props, state) {
    if (props.height === state.lastHeight) {
      return null
    }

    return { bottom: CookieConsentBar.updatedBottom(props), lastHeight: props.height }
  }

  static updatedBottom (props) {
    const scrollLimit = document.documentElement.scrollHeight - document.documentElement.clientHeight

    if (window.scrollY < scrollLimit - props.height) {
      return 0
    }

    return Math.max(0, props.height - (scrollLimit - window.scrollY))
  }

  constructor (props) {
    super(props)
    const accepted = getCookie('consent_mandatory') === '1'
    this.state = {
      accepted,
      showModal: false,
      bottom: CookieConsentBar.updatedBottom(props),
      trackingSelected: true,
      marketingSelected: true
    }
    this.toggleModal = this.toggleModal.bind(this)
    this.toggleMarketing = this.toggleMarketing.bind(this)
    this.toggleTracking = this.toggleTracking.bind(this)
    this.cookieBarLimit = this.cookieBarLimit.bind(this)
    this.accept = this.accept.bind(this)
  }

  componentDidMount () {
    window.addEventListener('scroll', () => { this.setState({ bottom: CookieConsentBar.updatedBottom(this.props) }) })
  }

  cookieBarLimit () {
    const scrollLimit =
      document.documentElement.scrollHeight -
      document.documentElement.clientHeight

    if (window.scrollY < scrollLimit - this.props.height) {
      this.setState({ bottom: 0 })
    } else {
      this.setState({ bottom: Math.max(0, this.props.height - (scrollLimit - window.scrollY)) })
    }
  }

  toggleModal () {
    this.setState(prevState => ({ showModal: !prevState.showModal }))
  }

  toggleTracking () {
    this.setState(prevState => ({
      trackingSelected: !prevState.trackingSelected
    }))
  }

  toggleMarketing () {
    this.setState(prevState => ({
      marketingSelected: !prevState.marketingSelected
    }))
  }

  accept () {
    setCookie('consent_mandatory', '1')
    setCookie(
      'consent_marketing',
      this.state.marketingSelected ? '1' : '0'
    )
    setCookie(
      'consent_tracking',
      this.state.trackingSelected ? '1' : '0'
    )
    this.setState({ accepted: true })
  }

  render () {
    const {
      t,
      user,
      fixedHeight,
      tenant,
      loggedIn,
      authDispatch
    } = this.props

    const {
      bottom,
      accepted,
      showModal,
      trackingSelected,
      marketingSelected
    } = this.state

    if (accepted || !tenant) return ''
    const containerStyle = {
      background: 'white',
      bottom: (fixedHeight || 0) + bottom
    }
    const clickAccept = () => {
      this.accept()

      return handleAccept(user, tenant, loggedIn, authDispatch)
    }

    const modal = (
      <React.Fragment>
        <div
          onClick={this.toggleModal}
          className={styles.modal_background}
        />
        <div className={MODAL}>
          <div className={COLUMN(20)}>
            <div className={COLUMN(100)}>
              <div className={MODAL_TITLE}>
                {sampleData.modalTitle}
              </div>
              <div className={MODAL_DESCRIPTION}>
                {sampleData.modalDescription}
              </div>
            </div>
          </div>

          <div className={styles.modal_separator} />

          <div className={MODAL_SECTION_TITLE}>Mandatory</div>
          <div className={COLUMN(20)}>
            <div className={ROW(100)}>
              <div className={MODAL_SECTION_TEXT}>
                {sampleData.modalMandatory}
              </div>
              <div className={MODAL_SECTION_BUTTON}>
                <i
                  className={TOGGLE}
                />
              </div>
            </div>
          </div>

          <div className={MODAL_SECTION_TITLE}>{t('common:marketing')}</div>
          <div className={COLUMN(20)}>
            <div className={ROW(100)}>
              <div className={MODAL_SECTION_TEXT}>
                {sampleData.modalMarketing}
              </div>
              <div className={MODAL_SECTION_BUTTON}>
                <i
                  onClick={this.toggleMarketing}
                  className={getToggleStyle(marketingSelected)}
                />
              </div>
            </div>
          </div>

          <div className={MODAL_SECTION_TITLE}>{t('common:tracking')}</div>
          <div className={COLUMN(20)}>
            <div className={ROW(100)}>
              <div className={MODAL_SECTION_TEXT}>
                {sampleData.modalTracking}
              </div>
              <div className={MODAL_SECTION_BUTTON}>
                <i
                  onClick={this.toggleTracking}
                  className={getToggleStyle(trackingSelected)}
                />
              </div>
            </div>
          </div>

          <div className={styles.modal_separator} />

          <div className={COLUMN(20)}>
            <div className={ROW(100)}>
              <div className={ROW(60)} />
              <div className={LEARN_MORE}>
                <a
                  href="https://www.itsmycargo.com/en/privacy"
                  target="_blank"
                >
                  {t('common:learnMore')}
                </a>
              </div>
              <div className={ROW(20)}>
                <button
                  className={styles.accept_all}
                  type="button"
                  onClick={clickAccept}
                >
                  <i className="fa fa-check" />
                  {t('common:accept')}
                </button>
              </div>
            </div>
          </div>
        </div>
      </React.Fragment>
    )
    const showDetails = (
      <div className={SHOW_DETAILS_BOX}>
        <a href="#" onClick={this.toggleModal}>
          {t('bookconf:showDetails')}
        </a>
      </div>
    )
    const acceptAll = (
      <div className={ROW(60)}>
        <button
          className={styles.accept_all}
          type="button"
          onClick={clickAccept}
        >
          <i className="fa fa-check" />
          {t('common:acceptAll')}
        </button>
      </div>
    )

    return (
      <React.Fragment>
        {showModal && modal}
        <div className={styles.cookie_flex} style={containerStyle}>
          <div className={BOX_LEFT}>
            <div>
              <div className={styles.title}>
                {sampleData.title}
              </div>
              <div className={styles.description}>
                {sampleData.description}
              </div>
            </div>
          </div>
          <div className={BOX_RIGHT}>
            <div className={BOX_RIGHT_INNER}>
              {showDetails}
              {acceptAll}
            </div>
          </div>
        </div>
      </React.Fragment>
    )
  }
}

CookieConsentBar.propTypes = {
  user: PropTypes.user,
  t: PropTypes.func.isRequired,
  loggedIn: PropTypes.bool,
  authDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  tenant: PropTypes.tenant
}

CookieConsentBar.defaultProps = {
  tenant: null,
  user: null,
  loggedIn: false
}

function mapStateToProps (state) {
  return {
    height: 0,
    fixedHeight: 0,
    ...state.cookie
  }
}

function mapDispatchToProps (dispatch) {
  return {
    authDispatch: bindActionCreators(
      authenticationActions,
      dispatch
    )
  }
}

export default withNamespaces(['common', 'bookconf'])(connect(
  mapStateToProps,
  mapDispatchToProps
)(CookieConsentBar))
