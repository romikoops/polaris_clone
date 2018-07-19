import React from 'react'
import PropTypes from '../../../../prop-types'
import styles from '../Card.scss'

function PricingButton ({ onClick, onDisabledClick, disabled, text }) {
  const disabledClass = disabled ? styles.disabled : ''

  return (
    <div
      className={`${
        styles.pricing_button
      } margin_bottom ${disabledClass} flex-100 layout-row layout-align-center-center`}
      onClick={disabled ? onDisabledClick : onClick}
    >
      <p className="flex-none">{`+ ${text}`}</p>
    </div>
  )
}
PricingButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  onDisabledClick: PropTypes.func.isRequired,
  disabled: PropTypes.bool,
  text: PropTypes.string
}
PricingButton.defaultProps = {
  disabled: false,
  text: 'New Route'
}
export default PricingButton
