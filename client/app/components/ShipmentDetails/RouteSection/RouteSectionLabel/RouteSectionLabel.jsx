import { withNamespaces } from 'react-i18next'

function RouteSectionLabel (props) {
  const { truckingOptions, target, t } = props

  if (target === 'origin') {
    return truckingOptions >= 1 ? t('shipment:pickUp') : t('shipment:portOfLoading')
  }

  return truckingOptions >= 1 ? t('shipment:delivery') : t('shipment:portOfDischarge')
}

export default withNamespaces('shipment')(RouteSectionLabel)
