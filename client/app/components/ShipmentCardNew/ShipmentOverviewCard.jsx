import React, { Component } from 'react'
import PropTypes from 'prop-types'
import AlternativeGreyBox from '../GreyBox/AlternativeGreyBox'
import { UserShipmentCard } from './UserShipmentCard'
import { AdminShipmentCardNew } from './AdminShipmentCardNew'
import styles from './ShipmentOverviewCard.scss'
import adminStyles from '../Admin/Admin.scss'

export class ShipmentOverviewCard extends Component {
  constructor (props) {
    super(props)

    this.state = {
      admin: this.props.admin
    }
  }

  listShipments (shipments) {
    const {
      dispatches,
      theme,
      hubs
    } = this.props

    return shipments.length > 0 ? shipments.map((shipment) => {
      const ShipCard = this.state.admin ? (
        <AdminShipmentCardNew
          shipment={shipment}
          dispatches={dispatches}
          theme={theme}
          hubs={hubs}
        />
      ) : (
        <UserShipmentCard
          shipment={shipment}
          dispatches={dispatches}
        />
      )

      return (
        <div className={` ${adminStyles.margin_bottom} flex-100 flex-lg-50 flex-gt-lg-33 layout-row`}>
          <AlternativeGreyBox
            wrapperClassName="layout-row flex layout-align-center-center"
            contentClassName="layout-row flex-100"
            content={ShipCard}
          />
        </div>
      )
    }) : (<span className={`${styles.wideelement}`}>No shipments available</span>)
  }

  render () {
    const {
      shipments
    } = this.props

    return (
      <div className="layout-wrap flex-100 layout-row layout-align-start-start">
        <div className={`layout-padding flex-100 layout-align-start-center  ${styles.greyBg}`}>
          <span><b>Requested Shipments</b></span>
        </div>
        <div className={` ${adminStyles.margin_box_right} flex-100 layout-row layout-align-start-start`}>
          {this.listShipments(shipments)}
        </div>
        
      </div>
    )
  }
}

ShipmentOverviewCard.propTypes = {
  admin: PropTypes.bool,
  shipments: PropTypes.arrayOf(PropTypes.shipment),
  dispatches: PropTypes.objectOf(PropTypes.func),
  theme: PropTypes.theme,
  hubs: PropTypes.objectOf(PropTypes.hub)

}

ShipmentOverviewCard.defaultProps = {
  admin: false,
  shipments: [],
  dispatches: {},
  theme: null,
  hubs: {}
}

export default ShipmentOverviewCard
