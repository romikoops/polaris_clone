import React from 'react'
import { withNamespaces } from 'react-i18next'

function ErrorMessage ({
  error, type, name, tenant, t
}) {
  const { max, actual } = error

  if (name === 'chargeableWeight') {
    return `
      ${t('cargo:excessChargeableWeight')}
      (${actual} ${t('acronym:kg')}) ${t('cargo:exceedsMaximum')}
      (${max} ${t('acronym:kg')}).
    `
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
