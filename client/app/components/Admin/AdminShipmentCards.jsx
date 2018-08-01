import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { GreyBox as GBox } from '../GreyBox/GreyBox'
import { AdminShipmentCard as AShipCard } from './AdminShipmentCard'

function listShipments (shipments) {
  return shipments.map((shipment) => {
    const ShipCard = (
      <AShipCard
        shipment={shipment}
      />
    )

    return (
      <GBox
        title=""
        subtitle=""
        flex={45}
        component={ShipCard}
      />
    )
  })
}

export class AdminShipmentCards extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    const {
      shipments
    } = this.props

    return (
      <div className="layout-wrap layout-row layout-align-space-between-start">
        <div className="layout-padding flex-100 layout-align-start-center greyBg">
          <span><b>Requested Shipments</b></span>
        </div>
        {listShipments(shipments)}
      </div>
    )
  }
}

AdminShipmentCards.propTypes = {
  shipments: PropTypes.objectOf(PropTypes.shipments)
}

AdminShipmentCards.defaultProps = {
  shipments: {}
}

export default AdminShipmentCards
