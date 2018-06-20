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
      hubs,
      handleSelect,
      handleAction
    } = this.props

    return shipments.length > 0 ? shipments.map((shipment) => {
      const ShipCard = this.state.admin ? (
        <AdminShipmentCardNew
          shipment={shipment}
          dispatches={dispatches}
          theme={theme}
          hubs={hubs}
          handleSelect={handleSelect}
          handleAction={handleAction}
        />
      ) : (
        <UserShipmentCard
          shipment={shipment}
          dispatches={dispatches}
        />
      )

      return (
        <div className={`${adminStyles.margin_box_right} ${adminStyles.margin_bottom} flex-100 layout-row`}>
          <AlternativeGreyBox
            wrapperClassName="layout-row flex-50 flex-md-100
              flex-sm-100 flex-xs-100 layout-align-center-center"
            contentClassName="layout-row flex-100"
            content={ShipCard}
          />
        </div>
      )
    }) : (<span className={`${styles.wideelement}`}>No shipments available</span>)
  }

  render () {
    const {
      shipments,
      showTitle
    } = this.props

    return (
      <div className="layout-wrap flex-100 layout-row layout-align-space-between-start">
        {showTitle ? (
          <div className={`layout-padding flex-100 layout-align-start-center ${styles.greyBg}`}>
            <span><b>Requested Shipments</b></span>
          </div>
        ) : (
          ''
        )}
        {this.listShipments(shipments)}
      </div>
    )
  }
}

ShipmentOverviewCard.propTypes = {
  admin: PropTypes.bool,
  shipments: PropTypes.arrayOf(PropTypes.shipment),
  dispatches: PropTypes.objectOf(PropTypes.func).isRequired,
  handleSelect: PropTypes.func.isRequired,
  handleAction: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  hubs: PropTypes.objectOf(PropTypes.hub),
  showTitle: PropTypes.bool
}

ShipmentOverviewCard.defaultProps = {
  admin: false,
  shipments: [],
  theme: null,
  hubs: {},
  showTitle: false
}

export default ShipmentOverviewCard
