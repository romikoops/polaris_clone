import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../../prop-types'
import styles from '../Card.scss'

function PricingButton ({
  onClick, onDisabledClick, disabled, t
}) {
  const disabledClass = disabled ? styles.disabled : ''

  return (
    <div
      className={`${
        styles.pricing_button
      } margin_bottom ${disabledClass} flex-100 layout-row layout-align-center-center`}
      onClick={disabled ? onDisabledClick : onClick}
    >
      <p className="flex-none">{t('admin:newRoute')}</p>
    </div>
  )
}
PricingButton.propTypes = {
  t: PropTypes.func.isRequired,
  onClick: PropTypes.func.isRequired,
  onDisabledClick: PropTypes.func.isRequired,
  disabled: PropTypes.bool
}
PricingButton.defaultProps = {
  disabled: false
}
export default withNamespaces('admin')(PricingButton)
