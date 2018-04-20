import React from 'react'
import { gradientGenerator } from '../../../helpers'
import PropTypes from '../../../prop-types'
import styles from '../ShipmentContactForm.scss'

export default function IconLable ({ theme, faClass }) {
  const gradientBackground = gradientGenerator(theme.colors.primary, theme.colors.secondary)
  return (
    <i className={`${styles.icon_label} fa fa-${faClass} clip`} style={gradientBackground} />
  )
}

IconLable.propTypes = {
  theme: PropTypes.theme,
  faClass: PropTypes.string
}

IconLable.defaultProps = {
  theme: null,
  faClass: ''
}
