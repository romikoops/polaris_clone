import React from 'react'
import { withNamespaces } from 'react-i18next'

function RouteSectionLabel (props) {
  const { truckingOptions, target, t, className } = props

  let label = truckingOptions >= 1 ? t('shipment:origin') : t('shipment:portOfLoading')

  if (target === 'destination') {
    label = truckingOptions >= 1 ? t('shipment:destination') : t('shipment:portOfDischarge')
  }

  return (<div className={className}>{label}</div>)
}

export default withNamespaces('shipment')(RouteSectionLabel)
