import React from 'react'
import styles from './RoundButton.scss'
import GradientBorder from '../GradientBorder'
import {
  gradientCSSGenerator,
  gradientBorderGenerator
} from '../../helpers'

export function RoundButton ({
  text, theme, active, back, icon, iconClass, size, disabled, handleNext, handleDisabled, inverse, classNames, flexContainer
}) {
  const activeBtnBackground =
    theme && theme.colors
      ? gradientCSSGenerator(theme.colors.primary, theme.colors.secondary)
      : 'black'
  const gradientBorderStyle =
    theme && theme.colors
      ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary)
      : { background: '#E0E0E0' }

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
    case 'medium':
      sizeClass = styles.medium
      break
    case 'full':
      sizeClass = styles.full
      break

    default:
      sizeClass = styles.large
      break
  }

  return (
    <div className={`flex-${flexContainer} ${classNames}`}>
      {!inverse ? (
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
      ) : (
        <GradientBorder
          wrapperClassName="flex pointy"
          gradient={gradientBorderStyle}
          className="layout-row layout-align-center-center flex-100"
          content={(
            <button
              className={`${styles.round_btn_inverse} ${bStyle} ${sizeClass} ${!disabled && styles.clickable}`}
              onClick={disabled ? handleDisabled : handleNext}
            >
              <div className="layout-fill layout-row layout-align-space-around-center">
                <p className={styles.content}>
                  <span className={styles.icon}>{iconC}</span>
                  {text}
                </p>
              </div>
            </button>
          )}
        />
      )}

    </div>
  )
}

RoundButton.defaultProps = {
  active: false,
  back: false,
  theme: null,
  icon: '',
  flexContainer: '100',
  iconClass: '',
  classNames: '',
  size: '',
  handleNext: null,
  handleDisabled: null,
  disabled: false,
  inverse: false
}

export default RoundButton
