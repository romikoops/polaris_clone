import React from 'react'
import PropTypes from '../../prop-types'

export function Infobox (convoKey, eta, etd, origin, totalprice, status) {
  return (
    <p className="flex-none">Shipment Reference: {convoKey}</p>
  )
}

Infobox.PropTypes = {
  id: PropTypes.number.isRequired,
  shipments: PropTypes.object.isRequired
}

export default Infobox
