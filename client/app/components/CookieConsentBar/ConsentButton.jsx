import React from 'react'
import PropTypes from 'prop-types'
import styles from './CookieConsentBar.scss'

function ConsentButton ({
  text,
  theme,
  disabled,
  active,
  handleNext,
  handleDisabled
}) {
  const cookieBackground = theme && theme.colors ? theme.colors.secondary : '#aaa'

  let bStyle
  if (active) {
    bStyle = styles.active
  } else {
    bStyle = styles.neutral
  }

  let btnToggle

  switch (text) {
    case 'accept':
      btnToggle = styles.accept
      break
    case 'decline':
      btnToggle = styles.decline
      break

    default:
      btnToggle = styles.accept
      break
  }

  return (
    <button
      className={`${styles.btn_cookie} ${bStyle} ${btnToggle}`}
      onClick={disabled ? handleDisabled : handleNext}
      style={{ color: cookieBackground }}
    > {text}
    </button>
  )
}

// ConsentButton.propTypes = {
//   text: PropTypes.string.isRequired
// }

export default ConsentButton
