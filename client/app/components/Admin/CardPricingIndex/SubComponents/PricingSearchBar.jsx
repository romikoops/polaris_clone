import React from 'react'
import PropTypes from '../../../../prop-types'
import styles from '../Card.scss'

function PricingSearchBar ({ onChange, value, target }) {
  return (
    <div className={`${styles.pricing_search} flex-100 layout-row layout-align-center-center`}>
      <input
        type="text"
        value={value}
        onChange={e => onChange(e, target)}
        placeholder="Type something..."
      />
    </div>
  )
}

PricingSearchBar.propTypes = {
  onChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  target: PropTypes.string.isRequired
}
PricingSearchBar.defaultProps = {
}
export default PricingSearchBar
