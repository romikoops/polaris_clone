import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'

function TotalProperty ({
  value, unit, property, t
}) {
  return (
    <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.total_property}`}>
      <p className={`${styles.input_label} flex-none`}>
        {t('common:total')}
        &nbsp;
        {t(`common:${property}`)}
        :&nbsp;&nbsp;
        <span className={styles.input_value}>
          {value}
        </span>
        {unit}
      </p>
    </div>

  )
}

export default withNamespaces('common')(TotalProperty)
