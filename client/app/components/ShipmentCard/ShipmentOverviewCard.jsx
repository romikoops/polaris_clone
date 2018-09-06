import React, { Component } from 'react'
import { translate } from 'react-i18next'
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
      confirmShipmentData,
      hubs,
      t
    } = this.props

    return shipments.length > 0 ? shipments.map((shipment) => {
      const ShipCard = this.state.admin ? (
        <AdminShipmentCard
          shipment={shipment}
          dispatches={dispatches}
          confirmShipmentData={confirmShipmentData}
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
          className="flex-100 flex-lg-50
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
      {t('shipment:noShipmentsAvailable')}
    </span>)
  }

  render () {
    const {
      shipments,
      noTitle,
      t
    } = this.props
    const titleBox = (<div
      className="greyBg layout-padding flex-100 layout-align-start-center"
    >
      <span><b>{t('shipment:requestedShipments')}</b></span>
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
  t: PropTypes.func.isRequired,
  shipments: PropTypes.arrayOf(PropTypes.shipment),
  dispatches: PropTypes.objectOf(PropTypes.func).isRequired,
  theme: PropTypes.theme,
  confirmShipmentData: PropTypes.objectOf(PropTypes.any),
  hubs: PropTypes.objectOf(PropTypes.hub),
  noTitle: PropTypes.bool

}

ShipmentOverviewCard.defaultProps = {
  admin: false,
  shipments: [],
  theme: null,
  hubs: {},
  confirmShipmentData: {},
  noTitle: false
}

export default translate('shipment')(ShipmentOverviewCard)
