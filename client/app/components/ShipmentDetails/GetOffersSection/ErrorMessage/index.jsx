import React from 'react'
import { withNamespaces } from 'react-i18next'
import interpolate from '../../../../helpers/interpolate'
import styles from './index.scss'

function ErrorMessage ({
  error, type, name, tenant, t
}) {
  const { max, actual, allMotsExceeded } = error

  if (name === 'chargeableWeight') {
    let className = styles.error
    let mot = t('common:all')

    if (!allMotsExceeded) {
      mot = t(`shipment:${error.modeOfTransport}`)
      className = styles.warning
    }

    return (
      <div className={className}>
        {interpolate(t('cargo:excessChargeableWeight'), { mot, actual: Math.round(actual), max: Math.round(max) })}
      </div>
    )
  }

  if (type === 'error' && name === 'payloadInKg') {
    return (
      <div>
        {
          `
            ${t('cargo:excessWeight')}
            (${actual} ${t('acronym:kg')}) ${t('cargo:exceedsMaximum')}
            (${max} ${t('acronym:kg')}).
          `
        }
        {t('cargo:pleaseContact')}
        {' '}
        <a href={`mailto:${tenant.emails.support.general}?subject=Excess Dimensions Request`}>
          {tenant.emails.support.general}
        </a>
      </div>
    )
  }

  return ''
}

export default withNamespaces(['cargo', 'acronym'])(ErrorMessage)
