import React from 'react'
import PropTypes from 'prop-types'
import styles from './NavDropdown.scss'
import defaults from '../../styles/default_classes.scss'

export function NavDropdown ({
  invert, linkOptions, dropDownImage, dropDownText
}) {
  const textClass = invert ? styles.white : styles.black
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
    <div className={`${styles.dropdown} ${textClass}`}>
      <div className={`${styles.dropbtn} layout-row layout-align-center-center`}>
        {dropDownImage ? (
          <img src={dropDownImage} className={`flex-none ${styles.dropDownImage}`} alt="" />
        ) : (
          ''
        )}
        {dropDownText ? <span className="flex-none">{dropDownText}</span> : ''}
        <i
          className={`flex-none fa fa-caret-down ${defaults.spacing_sm_left}`}
          aria-hidden="true"
        />
      </div>
      <div className={`${styles.dropdowncontent}`}>{links}</div>
    </div>
  )
}

NavDropdown.propTypes = {
  invert: PropTypes.bool,
  dropDownImage: PropTypes.string,
  dropDownText: PropTypes.string,
  linkOptions: PropTypes.arrayOf(PropTypes.shape({
    text: PropTypes.string,
    fontAwesomeIcon: PropTypes.string
  })).isRequired
}

NavDropdown.defaultProps = {
  invert: false,
  dropDownImage: PropTypes.string,
  dropDownText: PropTypes.string
}

export default NavDropdown
