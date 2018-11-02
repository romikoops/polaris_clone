import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'

function Infobox (convoKey, eta, etd, origin, totalprice, status, t) {
  return (
    <p className="flex-none">{t('bookconf:shipmentReference')}: {convoKey}</p>
  )
}

Infobox.PropTypes = {
  id: PropTypes.number.isRequired,
  shipments: PropTypes.object.isRequired,
  t: PropTypes.func.isRequired
}

export default withNamespaces('bookconf')(Infobox)
