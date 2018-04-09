import React from 'react'
import PropTypes from '../../prop-types'
import styles from './RoundButton.scss'
import { gradientCSSGenerator } from '../../helpers'

export function RoundButton ({
  text, theme, active, back, icon, iconClass, size, disabled, handleNext, handleDisabled
}) {
  const activeBtnBackground =
    theme && theme.colors
      ? gradientCSSGenerator(theme.colors.primary, theme.colors.secondary)
      : 'black'

  const btnStyle = active ? { background: activeBtnBackground } : {}

  let bStyle
  if (active) {
    bStyle = styles.active
  } else if (back) {
    bStyle = styles.back
  } else if (!active && !back) {
    bStyle = styles.neutral
  }

  let iconC

  if (icon) {
    iconC = <img src={icon} alt="" className="flex-none icon" />
  } else if (iconClass) {
    const classStr = `flex-none icon_f fa ${iconClass}`
    iconC = <i className={classStr} />
  }

  let sizeClass

  switch (size) {
    case 'large':
      sizeClass = styles.large
      break
    case 'small':
      sizeClass = styles.small
      break
    case 'full':
      sizeClass = styles.full
      break

    default:
      sizeClass = styles.large
      break
  }
  return (
    <button
      className={`${styles.round_btn} ${bStyle} ${sizeClass} ${!disabled && styles.clickable}`}
      onClick={disabled ? handleDisabled : handleNext}
      style={btnStyle}
    >
      <div className="layout-fill layout-row layout-align-space-around-center">
        <p className={styles.content}>
          <span className={styles.icon}>{iconC}</span>
          {text}
        </p>
      </div>
    </button>
  )
}

RoundButton.propTypes = {
  text: PropTypes.string.isRequired,
  handleNext: PropTypes.func,
  handleDisabled: PropTypes.func,
  active: PropTypes.bool,
  back: PropTypes.bool,
  theme: PropTypes.theme,
  icon: PropTypes.string,
  iconClass: PropTypes.string,
  size: PropTypes.string,
  disabled: PropTypes.bool
}

RoundButton.defaultProps = {
  active: false,
  back: false,
  theme: null,
  icon: '',
  iconClass: '',
  size: '',
  handleNext: null,
  handleDisabled: null,
  disabled: false
}

export default RoundButton
