import React from 'react'
import { withNamespaces } from 'react-i18next'
import interpolate from '../../../../helpers/interpolate'
import styles from './index.scss'

function ErrorMessage ({
  error, type, name, tenant, t
}) {
  if (name === 'chargeableWeight') {
    return chargableWeightError(t, error)
  }

  if (type === 'error' && name === 'payloadInKg') {
    return payloadInKgError(t, error, tenant)
  }

  if (name === 'volume') {
    return volumeError(t, error)
  }

  return null
}

export default withNamespaces(['cargo', 'acronym'])(ErrorMessage)

function payloadInKgError (t, error, tenant) {
  return (
    <div className={styles.error}>
      {`
        ${t('cargo:excessWeight')}
        (${error.actual} ${t('acronym:kg')}) ${t('cargo:exceedsMaximum')} (${error.max} ${t('acronym:kg')}).
      `}
      {t('cargo:pleaseContact')}
      {' '}
      <a href={`mailto:${tenant.emails.support.general}?subject=Excess Dimensions Request`}>
        {tenant.emails.support.general}
      </a>
    </div>
  )
}

function chargableWeightError (t, error) {
  const { max, actual, allMotsExceeded } = error

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

function volumeError (t, error) {
  const { max, actual, allMotsExceeded } = error

  let className = styles.error
  let mot = t('common:all')

  if (!allMotsExceeded) {
    mot = t(`shipment:${error.modeOfTransport}`)
    className = styles.warning
  }

  return (
    <div className={className}>
      {interpolate(t('cargo:excessVolume'), { mot, actual: Math.round(actual), max: Math.round(max) })}
    </div>
  )
}
