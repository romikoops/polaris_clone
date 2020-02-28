import React from 'react'

import Spinner from '../LoadingSpinner/LoadingSpinner'
import styles from './LoadingBackfill.scss'

const LoadingBackfill = (props) => {
  const { className, show, ...childProps } = props

  if (!show) { return null }

  const composedClassName = `${styles.loadingBackfill} ${className}`

  return (
    <div className={composedClassName}>
      <Spinner {...childProps} />
    </div>
  )
}

LoadingBackfill.defaultProps = {
  loadingWrapper: '',
  show: false
}

export default LoadingBackfill
