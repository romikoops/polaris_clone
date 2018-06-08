import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { GreyBox as GBox } from '../GreyBox/GreyBox'
import { UserShipmentCard as UShipCard } from './UserShipmentCard'
import { AdminShipmentCard as AShipCard } from './AdminShipmentCard'
import styles from './ShipmentCards.scss'

export class ShipmentCards extends Component {
  constructor (props) {
    super(props)

    this.state = {
      admin: this.props.admin
    }
  }

  listShipments (shipments) {
    const { dispatches } = this.props
    return shipments.length > 0 ? shipments.map((shipment) => {
      const ShipCard = this.state.admin ? (
        <AShipCard
          shipment={shipment}
          dispatches={dispatches}
        />
      ) : (
        <UShipCard
          shipment={shipment}
          dispatches={dispatches}
        />
      )

      return (
        <GBox
          title=""
          subtitle=""
          flexMd={100}
          flex={50}
          flexGtLg={33}
          component={ShipCard}
        />
      )
    }) : (<span className={`${styles.wideelement}`}>No shipments available</span>)
  }

  render () {
    const {
      shipments
    } = this.props

    return (
      <div className="layout-wrap flex-100 layout-row layout-align-space-between-start">
        <div className={`layout-padding flex-100 layout-align-start-center  ${styles.greyBg}`}>
          <span><b>Requested Shipments</b></span>
        </div>
        {this.listShipments(shipments)}
      </div>
    )
  }
}

ShipmentCards.propTypes = {
  admin: PropTypes.bool,
  shipments: PropTypes.arrayOf(PropTypes.shipment),
  dispatches: PropTypes.objectOf(PropTypes.func)
}

ShipmentCards.defaultProps = {
  admin: false,
  shipments: [],
  dispatches: {}
}

export default ShipmentCards
