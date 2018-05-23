import React from 'react'
import PropTypes from '../../prop-types'
import styles from './CookieConsentBar.scss'
import ConsentButton from "./ConsentButton"
import { moment } from '../../constants'

function handleAccept (user, tenant, loggedIn, authDispatch) {
  if (loggedIn) {
    authDispatch.updateUser(user, { cookie_consent: true })
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
        guest: true,
        cookie_consent: true
      }
    )
  }
}

export default function CookieConsentBar ({
  user,
  theme,
  tenant,
  loggedIn,
  authDispatch
 }) {
  if (!tenant) return ''
  const cookieBackground = theme && theme.colors ? theme.colors.secondary : '#aaa'
  return (
    <div
      className={`${styles.cookie_flex} ${user && user.cookie_consent ? styles.hidden : ''}`}
      style={{ background: cookieBackground, filter: 'grayscale(60%)' }}
    >
      <p className={styles.cookie_text}>
        This website uses cookies to enhance your user experience.
      </p>

      <ConsentButton
        theme={theme}
        handleNext={() => handleAccept(user, tenant, loggedIn, authDispatch)}
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
