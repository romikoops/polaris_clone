import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import GreyBox from '../GreyBox/GreyBox'
import UserShipmentCard from './UserShipmentCard'
import AdminShipmentCard from './AdminShipmentCard'
import ShipmentQuotationCard from './ShipmentQuotationCard'
import styles from './ShipmentOverviewCard.scss'
import CircleCompletion from '../CircleCompletion/CircleCompletion'
import adminStyles from '../Admin/Admin.scss'
import Pagination from '../../containers/Pagination'

class ShipmentOverviewCard extends Component {
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
      const ShipmentConfirmed = (
        <CircleCompletion
          icon="fa fa-check"
          iconColor={theme.colors.primary || 'green'}
          optionalText={t('admin:shipmentAccepted')}
          opacity={confirmShipmentData.confirmedShipment ? '1' : '0'}
          animated
        />
      )

      const QuoteCard = (
        <ShipmentQuotationCard
          shipment={shipment}
          dispatches={dispatches}
          theme={theme}
        />
      )
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

      const ShipmentLoading = confirmShipmentData.confirmedShipment && confirmShipmentData.shipmentId === shipment.id
        ? (ShipmentConfirmed) : (ShipCard)

      return (
        <div
          className="flex-100 flex-lg-50
          flex-gt-lg-33 layout-row card_padding card_lineup"
        >
          <GreyBox
            wrapperClassName="layout-row"
            contentClassName="layout-row flex-100"
            content={shipment.status !== 'quoted' ? ShipmentLoading : QuoteCard}
          />
        </div>
      )
    }) : (
      <span className={`${styles.wideelement}`}>
        {t('shipment:noShipmentsAvailable')}
      </span>
    )
  }

  render () {
    const {
      shipments,
      noTitle,
      t,
      paginate
    } = this.props
    const titleBox = (
      <div
        className="greyBg layout-padding flex-100 layout-align-start-center"
      >
        <span><b>{t('shipment:requestedShipments')}</b></span>
      </div>
    )

    return (
      <div className="layout-wrap flex-100 layout-row layout-align-start-stretch">
        { !noTitle ? titleBox : ''}
        <div className={` ${adminStyles.margin_box_right} flex-100
        layout-row layout-wrap padding_bottom`}
        >
          { paginate
            ? (
              <Pagination
                items={shipments}
                pageNavigation
                perPage={2}
              >
                {({ items }) => this.listShipments(items)}
              </Pagination>
            ) : this.listShipments(shipments)
          }
        </div>

      </div>
    )
  }
}

ShipmentOverviewCard.defaultProps = {
  admin: false,
  shipments: [],
  theme: null,
  hubs: {},
  confirmShipmentData: {},
  noTitle: false,
  paginate: false
}

export default withNamespaces(['shipment', 'admin'])(ShipmentOverviewCard)
