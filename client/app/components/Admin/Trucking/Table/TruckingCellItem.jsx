import React from 'react'
import styles from './index.scss'

export default ({ displayText, handleClick, id }) => (
  <div
    className={`flexlay out-row layout-align-start-center ${styles.pricing_cell} `}
    onClick={handleClick}
    id={id}
  >
    <p className="flex-none">
      {displayText}
    </p>
  </div>
)
