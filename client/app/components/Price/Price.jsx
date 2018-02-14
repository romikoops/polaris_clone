import React from 'react'
import PropTypes from '../../prop-types'
import styles from './Price.scss'

function format2Digit (n) {
  return `0${n}`.slice(-2)
}

export function Price ({ value, scale, user }) {
  const scaleTransformation = scale
    ? { transform: `scale(${scale})`, transformOrigin: `0 ${35.5 * scale / 2}px` }
    : {}
  const priceUnits = Math.floor(value)
  const priceCents = format2Digit(Math.floor((value * 100) % 100))
  return (
    <p className={`flex-none ${styles.price}`} style={scaleTransformation}>
      {priceUnits}
      <sup>.{priceCents}</sup> <span className={styles.price_currency}>{user.currency}</span>
    </p>
  )
}

Price.propTypes = {
  value: PropTypes.number.isRequired,
  scale: PropTypes.string.isRequired,
  user: PropTypes.user.isRequired
}

export default Price
