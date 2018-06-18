import React from 'react'
import PropTypes from 'prop-types'
import styles from './GradientBorder.scss'

export default function GradientBorder ({
  gradient, content, wrapperClassName, className
}) {
  return (
    <div className={`${styles.wrapper} ${wrapperClassName}`}>
      <div className={styles.gradient} style={gradient} />
      <div className={`${styles.content} ${className}`}>
        {content}
      </div>
    </div>
  )
}

GradientBorder.propTypes = {
  gradient: PropTypes.objectOf(PropTypes.string).isRequired,
  content: PropTypes.node.isRequired,
  wrapperClassName: PropTypes.string,
  className: PropTypes.string
}

GradientBorder.defaultProps = {
  wrapperClassName: '',
  className: ''
}
