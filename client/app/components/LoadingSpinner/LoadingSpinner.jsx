import React from 'react'
import './LoadingSpinner.scss'
import PropTypes from '../../prop-types'

export function LoadingSpinner ({ size }) {
  return (
    <div id="floatingCirclesG" className={size}>
      <div className="f_circleG" id="frotateG_01" />
      <div className="f_circleG" id="frotateG_02" />
      <div className="f_circleG" id="frotateG_03" />
      <div className="f_circleG" id="frotateG_04" />
      <div className="f_circleG" id="frotateG_05" />
      <div className="f_circleG" id="frotateG_06" />
      <div className="f_circleG" id="frotateG_07" />
      <div className="f_circleG" id="frotateG_08" />
    </div>
  )
}
LoadingSpinner.propTypes = {
  size: PropTypes.string
}

LoadingSpinner.defaultProps = {
  size: ''
}

export default LoadingSpinner
