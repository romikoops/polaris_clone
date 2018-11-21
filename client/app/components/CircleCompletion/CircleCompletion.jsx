import React from 'react'
import PropTypes from 'prop-types'
import styles from './CircleCompletion.scss'

function CircleCompletion ({
  icon,
  animated,
  iconColor,
  optionalText
}) {
  return (
    <div className="flex-100 layout-column layout-align-center-center">
      <p className={animated ? `${styles.display}` : `${styles.display_none}`}>
        {optionalText}
      </p>
      <div
        className={animated ? `${styles.circle_animate} ${styles.circle}` : `${styles.circle}`}
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
  iconColor: PropTypes.string.isRequired
}

CircleCompletion.defaultProps = {
  icon: '',
  optionalText: '',
  animated: false
}
export default CircleCompletion
