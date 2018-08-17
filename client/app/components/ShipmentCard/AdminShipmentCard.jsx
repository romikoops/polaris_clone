import React, { Component } from 'react'
import moment from 'moment'
import PropTypes from 'prop-types'
import { v4 } from 'uuid'
import styles from './ShipmentCard.scss'
import adminStyles from '../Admin/Admin.scss'
import AdminPromptConfirm from '../Admin/Prompt/Confirm'
import {
  gradientTextGenerator,
  switchIcon,
  totalPrice,
  formattedPriceValue,
  splitName
} from '../../helpers'

function loadIsComplete (confirmShipmentData, id, dispatches) {
  return confirmShipmentData.accepted &&
    id === confirmShipmentData.shipmentId &&
    confirmShipmentData.action === 'accept'
}
function shouldRenderAnimation (confirmShipmentData, id, dispatches) {
  return confirmShipmentData.requested &&
    id === confirmShipmentData.shipmentId &&
    confirmShipmentData.action === 'accept'
}

export class AdminShipmentCard extends Component {
  constructor (props) {
    super(props)

    this.state = {
      confirm: false
    }
    this.selectShipment = this.selectShipment.bind(this)
  }
  handleDeny () {
    const { shipment, dispatches } = this.props
    dispatches.confirmShipment(shipment.id, 'decline')
  }

  handleAccept () {
    const { shipment, dispatches } = this.props
    dispatches.confirmShipment(shipment.id, 'accept')
  }

  handleIgnore () {
    const { shipment, dispatches } = this.props
    dispatches.confirmShipment(shipment.id, 'ignore')
    this.closeConfirm()
  }

  handleEdit () {
    const { shipment, dispatches } = this.props
    dispatches.getShipment(shipment.id, true)
  }
  handleView () {
    const { shipment, dispatches } = this.props
    dispatches.getShipment(shipment.id, true)
  }
  handleFinished () {
    const { shipment, dispatches } = this.props
    dispatches.confirmShipment(shipment.id, 'finished')
  }
  confirmDelete () {
    this.setState({
      confirm: true
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }
  selectShipment () {
    const { shipment, dispatches } = this.props
    dispatches.getShipment(shipment.id, true)
  }
  render () {
    const {
      shipment,
      theme,
      confirmShipmentData
    } = this.props

    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const deselectedStyle = {
      ...gradientTextGenerator('#DCDBDC', '#DCDBDC')
    }

    const { confirm } = this.state
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading="Are you sure?"
        text={`This will reject the requested shipment ${shipment.imc_reference}.
        This shipment can be still be recovered after being ignored`}
        confirm={() => this.handleIgnore()}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const plannedDate =
    shipment.has_pre_carriage ? shipment.planned_pickup_date : shipment.planned_origin_drop_off_date

    const requestedLinks = ['requested', 'requested_by_unconfirmed_account'].includes(shipment.status) ? (
      <div className={`layout-row layout-align-center-center ${styles.topRight}`}>
        <p className={`${styles.check} pointy`} onClick={() => this.handleAccept()}>Accept</p>
        &nbsp;&nbsp;|&nbsp;&nbsp;
        <p className={`${styles.edit} pointy`} onClick={() => this.handleEdit()}>Modify</p>
        &nbsp;&nbsp;|&nbsp;&nbsp;
        <p className={`${styles.trash} pointy`} onClick={() => this.confirmDelete()}>Reject</p>
      </div>
    ) : ''

    const destinationHubObj = splitName(shipment.destination_hub.name)
    const originHubObj = splitName(shipment.origin_hub.name)

    const loadingCheck = (
      <div className={`${adminStyles.card_link} ${styles.loader_wrapper}`}>
        <div className={`${styles.circle_loader} ${loadIsComplete(confirmShipmentData, shipment.id) ? styles.load_complete : ''}`}>
          <div className={`${loadIsComplete(confirmShipmentData, shipment.id) ? styles.checkmark : ''} ${styles.draw}`} />
        </div>
      </div>
    )

    return (
      <div
        key={v4()}
        className={
          `flex-100 layout-align-start-stretch
          ${styles.container}`
        }
      >
        {shouldRenderAnimation(confirmShipmentData, shipment.id) && loadIsComplete(confirmShipmentData, shipment.id) ? loadingCheck : ''}
        <hr className={`flex-100 layout-row ${styles.hr_divider}`} />
        {confimPrompt}
        <div className={adminStyles.card_link} onClick={() => this.handleView()} />

        {requestedLinks}

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
            <div>
              <b>{moment(shipment.planned_eta).diff(shipment.planned_etd, 'days')} days</b><br />
              <span className={`${styles.grey}`}>
              Estimated Transit Time
              </span>
            </div>
          </div>
        </div>
        <div
          className={`layout-row flex-100 layout-align-space-between-stretch ${styles.middle_top_box}`}
        >
          <div className="layout-row flex-35 layout-align-center-center">
            <div className="flex-100">
              <b className={styles.ref_row_card}>Ref:&nbsp;{shipment.imc_reference}</b>
              <p>Placed at&nbsp;{moment(shipment.booking_placed_at).format('DD/MM/YYYY - hh:mm')}</p>
            </div>
          </div>

          <hr />

          <div className="layout-row flex-60 layout-align-center-center">
            <div className="flex-100">
              <div className="layout-row flex-100 layout-align-start-center">
                <div className="flex-10 layout-row layout-align-center-center">
                  <i className="fa fa-user clip" style={gradientFontStyle} />
                </div>
                <div className="flex-80 layout-row layout-align-start-start">
                  <h4>{shipment.clientName}</h4>
                </div>
              </div>
              <div className="layout-row flex-100 layout-align-start-center">
                <span className="flex-10 layout-row layout-align-center-center">
                  <i className="fa fa-building clip" style={gradientFontStyle} />
                </span>
                <span className={`flex-80 layout-row layout-align-start-center ${styles.grey}`}>
                  <p>{shipment.companyName}</p>
                </span>
              </div>
            </div>
          </div>

        </div>

        {shipment.status !== 'finished' ? (
          <div className={`layout-row flex-100 layout-align-start-center
            ${styles.middle_bottom_box} ${styles.smallText}`}
          >
            <div className="flex-20 layout-align-center-start">
              <span className="flex-100"><b>Pick-up Date</b><br />
                <span className={`${styles.grey}`}>
                  {moment(plannedDate).format('DD/MM/YYYY')}
                </span>
              </span>
            </div>
            <div className="flex-20 layout-align-center-start">
              <span className="flex-100"><b>ETD</b><br />
                <span className={`${styles.grey}`}>
                  {moment(shipment.planned_etd).format('DD/MM/YYYY')}
                </span>
              </span>
            </div>
            <div className="flex-20 layout-align-center-start">
              <span className="flex-100"><b>ETA</b><br />
                <span className={`${styles.grey}`}>
                  {moment(shipment.planned_eta).format('DD/MM/YYYY')}
                </span>
              </span>
            </div>
            <div className={`flex-40 layout-align-start-end ${styles.carriages}`}>
              <div className="layout-row layout-align-end-end">
                <i
                  className={shipment.has_pre_carriage ? 'fa fa-check clip' : 'fa fa-times'}
                  style={shipment.has_pre_carriage ? gradientFontStyle : { color: '#E0E0E0' }}
                />
                <p>Pre-carriage</p>
              </div>
              <div className="layout-row layout-align-end-end">
                <i
                  className={shipment.has_on_carriage ? 'fa fa-check clip' : 'fa fa-times'}
                  style={shipment.has_on_carriage ? gradientFontStyle : { color: '#E0E0E0' }}
                />
                <p>On-carriage</p>
              </div>
            </div>
          </div>
        ) : (
          <div className={`layout-row flex-40 layout-align-start-stretch
            ${styles.middle_bottom_box} ${styles.smallText}`}
          >
            <div className="flex-100 layout-row"><b>Arrived on:&nbsp;</b>
              <span className={`${styles.grey}`}>
                {moment(shipment.planned_eta).format('DD/MM/YYYY')}
              </span>
            </div>
          </div>
        )}

        <div className={`layout-row flex-100 layout-align-space-between-center
            ${styles.bottom_box}`}
        >
          <div className="layout-row flex-65 layout-align-start-center">
            <div className="layout-row flex-10">
              <div className="layout-row layout-align-center-center">
                <span className={`${styles.smallText}`}>
                  <b>x</b><span className={`${styles.bigText}`}>1</span>
                </span>
              </div>
            </div>
            <span className="flex-35">Cargo item</span>
            <span className="flex-25 layout-row">
              <i
                className="fa fa-check-square clip"
                style={shipment.pickup_address ? gradientFontStyle : deselectedStyle}
              />
              <p> Pick-up</p>
            </span>
            <span className="flex-25 layout row">
              <i
                className="fa fa-check-square clip"
                style={shipment.delivery_address ? gradientFontStyle : deselectedStyle}
              />
              <p> Delivery</p>
            </span>
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

AdminShipmentCard.propTypes = {
  shipment: PropTypes.objectOf(PropTypes.shipment),
  confirmShipmentData: PropTypes.objectOf(PropTypes.any),
  dispatches: PropTypes.objectOf(PropTypes.func).isRequired,
  theme: PropTypes.theme
}

AdminShipmentCard.defaultProps = {
  shipment: {},
  confirmShipmentData: {},
  theme: {}
}

export default AdminShipmentCard
