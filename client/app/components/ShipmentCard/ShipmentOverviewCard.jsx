import React, { Component } from 'react'
import PropTypes from 'prop-types'
import GreyBox from '../GreyBox/GreyBox'
import { UserShipmentCard } from './UserShipmentCard'
import { AdminShipmentCard } from './AdminShipmentCard'
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
        <AdminShipmentCard
          shipment={shipment}
          dispatches={dispatches}
          theme={theme}
          hubs={hubs}
        />
      ) : (
        <UserShipmentCard
          shipment={shipment}
          dispatches={dispatches}
          theme={theme}
        />
      )

      return (
        <div
          className="margin_bottom flex-100 flex-lg-50
          flex-gt-lg-33 layout-row card_padding card_lineup"
        >
          <GreyBox
            wrapperClassName="layout-row"
            contentClassName="layout-row flex-100"
            content={ShipCard}
          />
        </div>
      )
    }) : (<span className={`${styles.wideelement}`}>
      No shipments available
    </span>)
  }

  render () {
    const {
      shipments,
      noTitle
    } = this.props
    const titleBox = (<div
      className="greyBg layout-padding flex-100 layout-align-start-center"
    >
      <span><b>Requested Shipments</b></span>
    </div>)

    return (
      <div className="layout-wrap flex-100 layout-row layout-align-start-stretch">
        { !noTitle ? titleBox : ''}
        <div className={` ${adminStyles.margin_box_right} flex-100
        layout-row layout-wrap padding_bottom`}
        >
          {this.listShipments(shipments)}
        </div>

      </div>
    )
  }
}

ShipmentOverviewCard.propTypes = {
  admin: PropTypes.bool,
  shipments: PropTypes.arrayOf(PropTypes.shipment),
  dispatches: PropTypes.objectOf(PropTypes.func).isRequired,
  theme: PropTypes.theme,
  hubs: PropTypes.objectOf(PropTypes.hub),
  noTitle: PropTypes.bool

}

ShipmentOverviewCard.defaultProps = {
  admin: false,
  shipments: [],
  theme: null,
  hubs: {},
  noTitle: false
}

export default ShipmentOverviewCard
