import React from 'react'
import PropTypes from 'prop-types'
import styles from './CircleCompletion.scss'

function CircleCompletion ({
  icon,
  animated,
  iconColor,
  optionalText,
  opacity,
  size
}) {
  let sizeClass

  switch (size) {
    case 'small':
      sizeClass = styles.small
      break
    case 'medium':
      sizeClass = styles.medium
      break
    default:
      sizeClass = styles.medium
      break
  }

  return (
    <div className="flex-100 layout-column layout-align-center-center" style={{ opacity, transition: '0.5s' }}>
      <p className={animated ? `${styles.display}` : `${styles.display_none}`}>
        {optionalText}
      </p>
      <div
        className={animated ? `${styles.circle_animate} ${styles.circle} ${sizeClass}` : `${styles.circle} ${sizeClass}`}
        style={animated ? { border: `${iconColor} solid 2px`, color: iconColor } : { color: 'white' }}
      >
        <i className={`${icon} ${styles.icon}`} />
      </div>
    </div>

  )
}

CircleCompletion.propTypes = {
  icon: PropTypes.string,
  optionalText: PropTypes.string,
  animated: PropTypes.bool,
  iconColor: PropTypes.string.isRequired,
  size: PropTypes.string,
  opacity: PropTypes.string
}

CircleCompletion.defaultProps = {
  icon: '',
  optionalText: '',
  animated: false,
  size: 'medium',
  opacity: ''
}
export default CircleCompletion
