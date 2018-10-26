import React, { Component } from 'react'
import { translate } from 'react-i18next'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import styles from './UserShipmentRow.scss'
import { moment } from '../../constants'
import { totalPrice, formattedPriceValue } from '../../helpers'

export class UserShipmentRow extends Component {
  static switchIcon (sched) {
    let icon
    switch (sched.mode_of_transport) {
      case 'ocean':
        icon = <i className="fa fa-ship" />
        break
      case 'air':
        icon = <i className="fa fa-plane" />
        break
      case 'train':
        icon = <i className="fa fa-train" />
        break
      default:
        icon = <i className="fa fa-ship" />
        break
    }

    return icon
  }
  static calcCargoLoad (feeHash, loadType) {
    const cargoCount = Object.keys(feeHash.cargo).length
    let noun = ''
    if (loadType === 'cargo_item' && cargoCount > 1) {
      noun = 'Cargo Items'
    } else if (loadType === 'cargo_item' && cargoCount === 1) {
      noun = 'Cargo Item'
    } else if (loadType === 'container' && cargoCount > 1) {
      noun = 'Containers'
    } else if (loadType === 'container' && cargoCount === 1) {
      noun = 'Container'
    }

    return `${cargoCount} X ${noun}`
  }

  static dashedGradient (color1, color2) {
    return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`
  }

  constructor (props) {
    super(props)
    this.selectShipment = this.selectShipment.bind(this)
    this.handleDeny = this.handleDeny.bind(this)
    this.handleAccept = this.handleAccept.bind(this)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }
  selectShipment () {
    const { shipment, handleSelect } = this.props
    handleSelect(shipment)
  }
  handleDeny () {
    const { shipment, handleAction } = this.props
    handleAction(shipment.id, 'decline')
  }

  handleAccept () {
    const { shipment, handleAction } = this.props
    handleAction(shipment.id, 'accept')
  }
  render () {
    const {
      theme, shipment, hubs, user, t
    } = this.props
    const schedule = {}
    const originHub = hubs[shipment.origin_hub_id].data
    const destHub = hubs[shipment.destination_hub_id].data
    const gradientFontStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.brightPrimary}, ${
            theme.colors.brightSecondary
          })`
          : 'black'
    }
    const dashedLineStyles = {
      marginTop: '6px',
      height: '2px',
      width: '100%',
      background:
        theme && theme.colors
          ? UserShipmentRow.dashedGradient(theme.colors.primary, theme.colors.secondary)
          : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }

    const feeHash = shipment.selected_offer

    return (
      <div key={v4()} className={`flex-100 layout-row pointy ${styles.route_result}`}>
        <div
          className={`${styles.port_box} flex-25 layout-row layout-wrap`}
          onClick={this.selectShipment}
        >
          <div className="flex-100 layout-row layout-align-center-center">
            <h5 className="flex-none no_m">
              {' '}
              {`${t('bookconf:bookingPlacedAt')} ${moment(shipment.booking_placed_at).format('DD/MM/YYYY | HH:mm')}`}
            </h5>
          </div>
          <div className={`${styles.hub_half} flex-100 layout-row layout-align-center-center`}>
            <div className="flex-10 layout-row layout-align-center-center">
              <i className={`flex-none fa fa-map-marker ${styles.map_marker}`} />
            </div>
            <div className="flex layout-row layout-align-center-center">
              <h4 className="flex-100 center letter_3"> {originHub.name} </h4>
            </div>
          </div>
          <div
            className={`${
              styles.hub_mid_line
            } flex-none layout-row layout-align-space-around-center layout-wrap`}
          >
            <div className="flex-100 layout-row layout-align-center-end">
              {UserShipmentRow.switchIcon(schedule, gradientFontStyle)}
            </div>
            <div style={dashedLineStyles} />
          </div>
          <div className={`${styles.hub_half} flex-100 layout-row layout-align-center-center`}>
            <div className="flex-10 layout-row layout-align-center-center">
              <i className={`flex-none fa fa-flag-o ${styles.flag}`} />
            </div>
            <div className="flex layout-row layout-align-center-center">
              <h4 className="flex-100 center letter_3"> {destHub.name} </h4>
            </div>
          </div>
        </div>
        <div
          className={`${styles.main_info} flex layout-row layout-align-none-start layout-wrap`}
          onClick={this.selectShipment}
        >
          <div className="flex-100 layout-row layout-align-none-center">
            <div className="flex-50 layout-row layout-align-start-center">
              <h4 className="flex-none no_m letter_3"> {`Ref: ${shipment.imc_reference}`}</h4>
            </div>

            <div className="flex-50 layout-row layout-align-end-center">
              <h4 className="flex-none letter_3 no_m">
                {' '}
                {`${UserShipmentRow.calcCargoLoad(feeHash, shipment.load_type)} `}
              </h4>
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-none-center">
            <div className={`${styles.user_info} flex-50 layout-row layout-align-start-center`}>
              <i className={`flex-none fa fa-user ${styles.flag}`} style={gradientFontStyle} />
              <h4 className="flex-none letter_3"> {`${user.first_name} ${user.last_name}`} </h4>
            </div>
            <div className="flex-50 layout-row layout-align-end-center">
              <h4 className="flex-none letter_3 no_m">
                {' '}
                {`Total: ${totalPrice(shipment).currency} ${formattedPriceValue(totalPrice(shipment).value)}`}
              </h4>
            </div>
          </div>

          <div className="flex-100 layout-row layout-align-none-center">
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}>
                  {shipment.has_pre_carriage ? t('common:pickUpDate') : t('common:closingDate')}
                </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_pickup_date).format('DD/MM/YYYY')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_pickup_date).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}> {t('common:etd')} </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_etd).format('DD/MM/YYYY')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_etd).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}> {t('common:eta')} </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_eta).format('DD/MM/YYYY')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_eta).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}> {t('shipment:estimatedTransitTime')} </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_eta).diff(shipment.planned_etd, t('common:days'))}
                  {'  '}{t('common:capitalDays')}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
UserShipmentRow.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  handleSelect: PropTypes.func.isRequired,
  handleAction: PropTypes.func.isRequired,
  hubs: PropTypes.arrayOf(PropTypes.object),
  shipment: PropTypes.shipment.isRequired,
  user: PropTypes.objectOf(PropTypes.String).isRequired
}

UserShipmentRow.defaultProps = {
  theme: null,
  hubs: []
}

export default translate(['common', 'shipment', 'bookconf'])(UserShipmentRow)
