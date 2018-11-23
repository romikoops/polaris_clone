import React from 'react'
import styles from './CircleCompletion.scss'
import { dimensionToPx } from '../../helpers'

function CircleCompletion ({
  icon,
  animated,
  iconColor,
  optionalText,
  opacity,
  size
}) {
  const animatedStyle = { border: `${iconColor} solid 2px`, color: iconColor }
  const sanitizedSize = dimensionToPx({ value: size })

  const style = {
    height: sanitizedSize,
    width: sanitizedSize,
    ...(animated ? animatedStyle : {})
  }

  return (
    <div className="flex-100 layout-column layout-align-center-center" style={{ opacity, transition: '0.5s' }}>
      <p className={animated ? `${styles.display}` : `${styles.display_none}`}>
        {optionalText}
      </p>
      <div
        className={`${animated && 'circle_animate'} ${styles.circle} layout-row layout-align-center-center`}
        style={style}
      >
        <i className={icon} style={{ fontSize: `${sanitizedSize / 2}px` }} />
      </div>
    </div>
  )
}

CircleCompletion.defaultProps = {
  icon: '',
  optionalText: '',
  animated: false,
  size: '100px',
  opacity: 1,
  fadeIn: false
}

export default CircleCompletion
