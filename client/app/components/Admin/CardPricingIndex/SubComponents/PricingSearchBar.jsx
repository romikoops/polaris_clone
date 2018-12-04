import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../../prop-types'
import styles from '../Card.scss'

function PricingSearchBar ({
  onChange, value, target, t
}) {
  return (
    <div className={`${styles.pricing_search} flex-100 layout-row layout-align-center-center`}>
      <input
        type="text"
        value={value}
        onChange={e => onChange(e, target)}
        placeholder={t('admin:search')}
      />
    </div>
  )
}

PricingSearchBar.propTypes = {
  t: PropTypes.func.isRequired,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  target: PropTypes.string.isRequired
}
PricingSearchBar.defaultProps = {
}
export default withNamespaces('admin')(PricingSearchBar)
