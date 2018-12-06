import React from 'react'
import PropTypes from 'prop-types'
import styles from './NavDropdown.scss'
import defaults from '../../styles/default_classes.scss'
import { accountIconColor } from '../../helpers'

const iconColorer = accountIconColor

function profileIconJSX (src, hide) {
  return (
    <img
      src={src}
      className={`flex-none ${styles.profile_icon} ${hide ? styles.hidden : ''}`}
    />
  )
}

export function NavDropdown ({
  linkOptions, dropDownText, invert, user, toggleShowLogin, isLanding, loginText
}) {
  const whiteProfileIconJSX = profileIconJSX(iconColorer('white'), !invert) || ''
  const blackProfileIconJSX = profileIconJSX(iconColorer('black'), invert) || ''

  const links = linkOptions.map((op) => {
    const icon = (
      <i className={`fa ${op.fontAwesomeIcon} ${defaults.spacing_sm_right}`} aria-hidden="true" />
    )

    if (op.url) {
      return (
        <a key={op.key} href={op.url}>
          {op.fontAwesomeIcon ? icon : ''}
          {op.text}
        </a>
      )
    }

    return <div onClick={op.select}>{op.key}</div>
  })

  return (
    <div className={`${styles.dropdown}`}>
      {user && user.first_name && !user.guest ? (
        <div className="layout-row layout-align-center-center">
          <div className={`${styles.dropbtn} layout-row layout-align-center-center`}>
            <div className={styles.wrapper_profile_icon}>
              {whiteProfileIconJSX}
              {blackProfileIconJSX}
            </div>
            {dropDownText ? <span className="flex-none">{dropDownText}</span> : ''}
            <i
              className={`flex-none fa fa-caret-down ${defaults.spacing_sm_left}`}
              aria-hidden="true"
            />
          </div>
          <div className={`${styles.dropdowncontent}`}>{links}</div>
        </div>
      ) : (
        <div className={`pointy layout-row layout-align-center-center ${styles.dropbtn} ccb_login`}>
          <a onClick={toggleShowLogin} style={isLanding ? {} : { color: '#4F4F4F' }}> {loginText} </a>
        </div>
      )}
    </div>
  )
}

NavDropdown.propTypes = {
  dropDownText: PropTypes.string,
  user: PropTypes.user,
  isLanding: PropTypes.bool,
  toggleShowLogin: PropTypes.func,
  linkOptions: PropTypes.arrayOf(PropTypes.shape({
    text: PropTypes.string,
    fontAwesomeIcon: PropTypes.string
  })).isRequired,
  invert: PropTypes.bool,
  loginText: PropTypes.string
}

NavDropdown.defaultProps = {
  dropDownText: '',
  invert: false,
  isLanding: false,
  user: null,
  toggleShowLogin: null,
  loginText: 'Log In / Register'
}

export default NavDropdown
