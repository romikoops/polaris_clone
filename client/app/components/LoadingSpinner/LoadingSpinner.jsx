import React from 'react'
import './LoadingSpinner.scss'

export function LoadingSpinner ({ size, show }) {
  if (!show) { return null }

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

LoadingSpinner.defaultProps = {
  size: '',
  show: true
}

export default LoadingSpinner
