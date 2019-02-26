import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'

function ChargeableProperty ({
  key, value, unit, available, icon, t
}) {
  return (
    <div key={key} className={`flex-none layout-align-center-center layout-row ${styles.single_charge}`}>
      { icon }
      <p className={`${styles.chargeable_weight_value} ${styles.input_value}`}>
        {
          available
            ? (
              <React.Fragment>
                {value}
                {unit}
              </React.Fragment>
            )
            : t('common:unavailable')
        }
      </p>
    </div>
  )
}

export default withNamespaces('common')(ChargeableProperty)
