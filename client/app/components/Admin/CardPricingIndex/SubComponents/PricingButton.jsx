import React from 'react'
import PropTypes from '../../../../prop-types'
import styles from '../Card.scss'
import adminStyles from '../../Admin.scss'

function PricingButton ({ onClick, onDisabledClick, disabled }) {
  const disabledClass = disabled ? styles.disabled : ''

  return (
    <div
      className={`${
        styles.pricing_button
      } ${adminStyles.margin_bottom} ${disabledClass} flex-100 layout-row layout-align-center-center`}
      onClick={disabled ? onDisabledClick : onClick}
    >
      <p className="flex-none">+ New Route Pricing</p>
    </div>
  )
}
PricingButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  onDisabledClick: PropTypes.func.isRequired,
  disabled: PropTypes.bool
}
PricingButton.defaultProps = {
  disabled: false
}
export default PricingButton
