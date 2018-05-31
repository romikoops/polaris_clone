import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { GreyBox as GBox } from '../GreyBox/GreyBox'
import { UserShipmentCard as AShipCard } from './UserShipmentCard'
import styles from './ShipmentCards.scss'

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

export class ShipmentCards extends Component {
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
        <div className={`layout-padding flex-100 layout-align-start-center ${styles.greyBg}`}>
          <span><b>Requested Shipments</b></span>
        </div>
        {listShipments(shipments)}
      </div>
    )
  }
}

ShipmentCards.propTypes = {
  shipments: PropTypes.objectOf(PropTypes.shipments)
}

ShipmentCards.defaultProps = {
  shipments: {}
}

export default ShipmentCards
