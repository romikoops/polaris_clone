import React from 'react'
import PropTypes from '../../prop-types'
import styles from './CookieConsentBar.scss'
import ConsentButton from "./ConsentButton"
import { moment } from '../../constants'

function handleAccept (tenant, loggedIn, authDispatch, userDispatch) {
  if (loggedIn) {
    // userDispatch.goTo('/booking')
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
      }
    )
  }
}

export default function CookieConsentBar ({
  theme,
  tenant,
  loggedIn,
  authDispatch,
  userDispatch
 }) {
  const cookieBackground = theme && theme.colors ? theme.colors.secondary : '#aaa'

  return (
    <div className={styles.cookie_flex} style={{ background: cookieBackground, filter: 'grayscale(60%)' }}>
      <p className={styles.cookie_text}>
        This website uses cookies to enhance your user experience.
      </p>

      <ConsentButton
        theme={theme}
        handleNext={() => handleAccept(tenant, loggedIn, authDispatch, userDispatch)}
        text="accept"
        active
      />
      <ConsentButton
        theme={theme}
        handleNext={() => this.hello()}
        text="decline"
        active
      />
    </div>
  )
}

CookieConsentBar.propTypes = {
  theme: PropTypes.theme
}

CookieConsentBar.defaultProps = {
  theme: null
}

// buttonText = {< i className = {`${styles.cookie_exit_icon} fa fa-times`} />}
// buttonStyle = {{ color: 'white', background: 'unset' }}
//
