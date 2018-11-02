import React from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { authenticationActions } from '../../actions'
import PropTypes from '../../prop-types'
import styles from './CookieConsentBar.scss'
import ConsentButton from './ConsentButton'
import { Modal } from '../Modal/Modal'
import { moment } from '../../constants'

function handleAccept (user, tenant, loggedIn, authDispatch) {
  if (loggedIn) {
    authDispatch.updateUser(user, { cookies: true })
  } else {
    const unixTimeStamp = moment().unix().toString()
    const randNum = Math.floor(Math.random() * 100).toString()
    const randSuffix = unixTimeStamp + randNum
    const email = `guest${randSuffix}@${tenant.data.subdomain}.com`

    authDispatch.register({
      email,
      password: 'guestpassword',
      password_confirmation: 'guestpassword',
      first_name: 'Guest',
      last_name: '',
      tenant_id: tenant.data.id,
      guest: true,
      cookies: true
    })
  }
}

class CookieConsentBar extends React.PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      showModal: false
    }
    this.toggleShowModal = this.toggleShowModal.bind(this)
    this.handleDecline = this.handleDecline.bind(this)
  }
  handleDecline () {
    this.setState({ showModal: true })
  }

  toggleShowModal () {
    this.setState(prevState => ({ showModal: !prevState.showModal }))
  }

  render () {
    const {
      user,
      theme,
      tenant,
      loggedIn,
      authDispatch,
      t
    } = this.props

    const modal = (
      <Modal
        component={
          <div className={styles.cookie_modal} >
            <p>{t('common:cookieHead')} <br /><br />
              {t('common:cookieTail')}</p>
            <ConsentButton
              theme={theme}
              handleNext={() => handleAccept(user, tenant, loggedIn, authDispatch)}
              text={t('common:ok')}
              active
            />
            <ConsentButton
              theme={theme}
              handleNext={() => { window.open('https://www.itsmycargo.com/') }}
              text={t('common:cookiesPolicy')}
              active
            />
          </div>
        }
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={this.toggleShowModal}
      />
    )

    if (!tenant) return ''

    const cookieBackground = theme && theme.colors ? theme.colors.secondary : '#aaa'

    return (
      <div
        className={`${styles.cookie_flex} ${user && user.optin_status && user.optin_status.cookies ? styles.hidden : ''}`}
        style={{ background: cookieBackground, filter: 'grayscale(60%)' }}
      >
        { this.state.showModal && modal}
        <p className={styles.cookie_text}>
          {t('common:useCookies')} <a href="https://www.itsmycargo.com/en/privacy" target="_blank"> {t('common:learnMore')}</a>
        </p>

        <ConsentButton
          theme={theme}
          handleNext={() => handleAccept(user, tenant, loggedIn, authDispatch)}
          text={t('common:accept')}
          active
        />
        <ConsentButton
          theme={theme}
          handleNext={this.handleDecline}
          text={t('common:decline')}
          active
        />
      </div>
    )
  }
}

CookieConsentBar.propTypes = {
  theme: PropTypes.theme,
  user: PropTypes.user,
  t: PropTypes.func.isRequired,
  loggedIn: PropTypes.bool,
  authDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  tenant: PropTypes.tenant
}

CookieConsentBar.defaultProps = {
  tenant: null,
  user: null,
  loggedIn: false,
  theme: {}
}

function mapDispatchToProps (dispatch) {
  return {
    authDispatch: bindActionCreators(authenticationActions, dispatch)
  }
}

export default withNamespaces('common')(connect(null, mapDispatchToProps)(CookieConsentBar))
