import React, { Component } from 'react'
import moment from 'moment'
import PropTypes from 'prop-types'
import { v4 } from 'uuid'
import styles from './ShipmentCard.scss'
import adminStyles from '../Admin/Admin.scss'
import {
  gradientTextGenerator,
  switchIcon,
  totalPrice,
  formattedPriceValue,
  splitName,
  humanizeSnakeCase
} from '../../helpers'

export class UserShipmentQuotationCard extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  handleView () {
    const { shipment, dispatches } = this.props
    dispatches.getShipment(shipment.id, true)
  }
  render () {
    const {
      shipment,
      theme
    } = this.props

    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const deselectedStyle = {
      ...gradientTextGenerator('#DCDBDC', '#DCDBDC')
    }
    const destinationHubObj = splitName(shipment.destination_hub.name)
    const originHubObj = splitName(shipment.origin_hub.name)

    return (
      <div
        key={v4()}
        className={
          `flex-100 layout-align-start-stretch
          ${styles.container}`
        }
      >
        <hr className={`flex-100 layout-row ${styles.hr_divider}`} />
        <div className={adminStyles.card_link} onClick={() => this.handleView()} />

        <div
          className={`layout-row flex-100 layout-align-space-between-stretch ${styles.top_box}`}
        >
          <div className={`layout-row flex-10 layout-align-center-center ${styles.routeIcon}`}>
            {switchIcon(shipment.mode_of_transport, gradientFontStyle)}
          </div>
          <div className={`flex-60 layout-row layout-align-start-center ${styles.hub_name}`}>
            <div className="layout-column layout-align-center-start">
              <p>From:&nbsp;<span>{originHubObj.name}</span></p>
              <p>To:&nbsp;<span>{destinationHubObj.name}</span></p>
            </div>
          </div>
          <div className={`layout-row flex-20 layout-align-start-center ${styles.ett}`}>
            { shipment.planned_eta ? (<div>
              <b>{moment(shipment.planned_eta).diff(shipment.planned_etd, 'days')} days</b><br />
              <span className={`${styles.grey}`}>
              Estimated Transit Time
              </span>
            </div>) : '' }
          </div>
        </div>
        <div
          className={`layout-row flex-100 layout-align-space-between-stretch ${styles.middle_top_box} ${styles.middle_top_box_quote}`}
        >
          <div className="layout-row flex-35 layout-align-center-center">
            <div className=" flex-100">
              <b className={styles.ref_row_card}>Ref:&nbsp;{shipment.imc_reference}</b>
            </div>
          </div>
          <span className="flex-25 layout-align-center-center layout-row">
            <i
              className="fa fa-check-square clip"
              style={shipment.trucking.has_pre_carriage ? gradientFontStyle : deselectedStyle}
            />
            <p> Pre-carriage</p>
          </span>
          <span className="flex-25 layout-align-center-center layout-row">
            <i
              className="fa fa-check-square clip"
              style={shipment.trucking.has_on_carriage ? gradientFontStyle : deselectedStyle}
            />
            <p> On-carriage</p>
          </span>
        </div>

        <div className={`layout-row flex-100 layout-align-space-between-center
            ${styles.bottom_box}`}
        >
          <div className="layout-row flex-65 layout-align-start-center">
            <div className="layout-row flex-10">
              <div className="layout-row layout-align-center-center">
                <span className={`${styles.smallText}`}>
                  <b>x</b><span className={`${styles.bigText}`}>{shipment.cargo_items ? shipment.cargo_items.count : '1'}</span>
                </span>
              </div>
            </div>
            <span className="flex-35">{shipment.load_type ? humanizeSnakeCase(shipment.load_type) : 'Cargo item'}</span>
          </div>
          <div className="layout-row flex layout-align-end-end">
            <span className={`${styles.bigText} ${styles.price_style}`}>
              <span> {totalPrice(shipment).currency} </span>
              <span>
                {formattedPriceValue(totalPrice(shipment).value)}
              </span>
            </span>
          </div>
        </div>
      </div>
    )
  }
}

UserShipmentQuotationCard.propTypes = {
  shipment: PropTypes.objectOf(PropTypes.shipment),
  dispatches: PropTypes.objectOf(PropTypes.func),
  theme: PropTypes.theme
}

UserShipmentQuotationCard.defaultProps = {
  shipment: {},
  dispatches: {},
  theme: {}
}

export default UserShipmentQuotationCard
