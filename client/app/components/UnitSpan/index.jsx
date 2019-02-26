import React from 'react'
import styles from './index.scss'

function UnitSpan ({ unit }) {
  switch (unit) {
    case 'kg':
    case 't':
      return (
        <span>
          &nbsp;
          {unit}
          &nbsp;
        </span>
      )
    case 'm':
      return (
        <span>
          &nbsp;m
          <sup className={styles.sup}>3</sup>
        </span>
      )

    default:
      return ''
  }
}

export default UnitSpan
