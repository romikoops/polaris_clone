import React from 'react'
import PropTypes from '../../prop-types'
import styles from './SquareButton.scss'
import { gradientGenerator, browserType } from '../../helpers'

export default function SquareButton ({
  text,
  theme,
  active,
  back,
  icon,
  iconClass,
  size,
  disabled,
  handleNext,
  handleDisabled,
  border,
  classNames
}) {
  const btnStyle = active ? { background: 'white' } : {}

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
  let borderClass
  if (border) {
    borderClass = styles.show_border
  } else {
    borderClass = styles.hide_border
  }
  const borderGradient =
    theme && theme.colors
      ? gradientGenerator(theme.colors.primary, theme.colors.secondary)
      : { background: 'black' }
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
  let wrapperSizeClass

  switch (size) {
    case 'large':
      wrapperSizeClass = styles.large_wrapper
      break
    case 'small':
      wrapperSizeClass = styles.small_wrapper
      break
    case 'full':
      wrapperSizeClass = styles.full_wrapper
      break

    default:
      wrapperSizeClass = styles.large_wrapper
      break
  }
  const contentStyle = browserType() === 'IE' ? styles.ie_content : styles.content

  return (
    <div
      className={`flex-none layout-row layout-align-center-center layout-align-lg-start-center ${sizeClass} ${borderClass} ${wrapperSizeClass}`}
      style={borderGradient}
    >
      <button
        className={`${styles.square_btn} ${bStyle} ${sizeClass} ${!disabled && styles.clickable} ${classNames}`}
        onClick={disabled ? handleDisabled : handleNext}
        style={btnStyle}
      >
        <div className="layout-fill layout-row layout-align-space-around-center">
          <p className={contentStyle}>
            <span className={styles.icon}>{iconC}</span>
            {text}
          </p>
        </div>
      </button>
    </div>
  )
}

SquareButton.propTypes = {
  text: PropTypes.string.isRequired,
  handleNext: PropTypes.func,
  handleDisabled: PropTypes.func,
  active: PropTypes.bool,
  back: PropTypes.bool,
  theme: PropTypes.theme,
  icon: PropTypes.string,
  iconClass: PropTypes.string,
  size: PropTypes.string,
  disabled: PropTypes.bool,
  border: PropTypes.bool,
  classNames: PropTypes.string
}

SquareButton.defaultProps = {
  active: false,
  back: false,
  theme: null,
  icon: '',
  iconClass: '',
  size: '',
  handleNext: null,
  handleDisabled: null,
  disabled: false,
  border: false,
  classNames: ''
}
