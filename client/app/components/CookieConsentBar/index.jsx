import React from 'react'
import CookieConsent from 'react-cookie-consent'
import PropTypes from '../../prop-types'
import styles from './CookieConsentBar.scss'

export default function CookieConsentBar ({ theme }) {
  const cookieBackground = theme && theme.colors ? theme.colors.secondary : '#aaa'

  return (
    <CookieConsent
      buttonText={<i className={`${styles.cookie_exit_icon} fa fa-times`} />}
      buttonStyle={{ color: 'white', background: 'unset' }}
      style={{ background: cookieBackground, filter: 'grayscale(60%)' }}
    >
      <p className={styles.cookie_text}>
        This website uses cookies to enhance your user experience.
      </p>
    </CookieConsent>
  )
}

CookieConsentBar.propTypes = {
  theme: PropTypes.theme
}

CookieConsentBar.defaultProps = {
  theme: null
}
