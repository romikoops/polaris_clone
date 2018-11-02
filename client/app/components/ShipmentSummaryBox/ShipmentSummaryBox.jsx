import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './ShipmentSummaryBox.scss'
import { moment } from '../../constants'
import { Price } from '../Price/Price'
import { Tooltip } from '../Tooltip/Tooltip'
import {
  capitalize,
  gradientCSSGenerator,
  gradientGenerator,
  gradientTextGenerator
} from '../../helpers'
import TextHeading from '../TextHeading/TextHeading'

class ShipmentSummaryBox extends Component {
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

  static dashedGradient (color1, color2) {
    return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`
  }
  constructor (props) {
    super(props)
    this.onChangeFunc = this.onChangeFunc.bind(this)
  }
  onChangeFunc (optionsSelected) {
    const nameKey = this.props.name
    this.props.onChange(nameKey, optionsSelected)
  }
  render () {
    const {
      theme, shipment, hubs, route, user, total, locations, t
    } = this.props
    const { startHub, endHub } = hubs
    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const brightGradientStyle =
      theme && theme.colors
        ? gradientGenerator(theme.colors.brightPrimary, theme.colors.brightSecondary)
        : { background: 'black' }
    const dashedLineStyles = {
      marginTop: '6px',
      height: '2px',
      width: '100%',
      background:
        theme && theme.colors
          ? gradientCSSGenerator(theme.colors.primary, theme.colors.secondary)
          : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }
    const originAddress = (
      <div className="flex-100 flex-gt-sm-50
      layout-wrap layout-row layout-align-space-between-center"
      >
        <div className="flex-100 layout-row">
          <TextHeading theme={theme} size={4} text={t('shipment:pickUpAddress')} />
        </div>
        <address className="flex-100 layout-row layout-wrap">
          {locations.origin.street_number} {locations.origin.street} <br />
          {locations.origin.city} <br />
          {locations.origin.zip_code} <br />
          {locations.origin.country} <br />
        </address>
      </div>
    )
    const destinationAddress = (
      <div className="flex-100 flex-gt-sm-50
      layout-wrap layout-row layout-align-space-between-center"
      >
        <div className="flex-100 layout-row">
          <TextHeading theme={theme} size={4} text={t('shipment:deliveryAddress')} />
        </div>
        <address className="flex-100 layout-row layout-wrap">
          {locations.destination.street_number} {locations.destination.street} <br />
          {locations.destination.city} <br />
          {locations.destination.zip_code} <br />
          {locations.destination.country} <br />
        </address>
      </div>
    )

    return (
      <div
        className={`flex-100 layout-row layout-wrap layout-align-center-start ${
          styles.summary_container
        }`}
      >
        <div className="flex-100 layout-row layout-wrap">
          <div className={`flex-100 layout-row layout-align-start-center ${styles.top_row}`}>
            <div className={`flex-65 layout-row layout-align-start-center ${styles.hubs_row}`}>
              <div className={`flex ${styles.header_hub}`}>
                <div className="flex-100 layout-row">
                  <div className="flex-15 layout-row layout-align-center-center">
                    <i
                      className={`fa fa-map-marker clip ${styles.map_marker}`}
                      style={gradientFontStyle}
                    />
                  </div>

                  <h4 className="flex-85"> {startHub.data.name} </h4>
                </div>
              </div>
              <div className={`${styles.connection_graphics}`}>
                <div className="flex-none layout-row layout-align-center-center">
                  {this.switchIcon(route[0])}
                </div>
                <div style={dashedLineStyles} />
              </div>
              <div className={`flex ${styles.header_hub}`}>
                <div className="flex-100 layout-row">
                  <div className="flex-15 layout-row layout-align-center-center">
                    <i className={`fa fa-flag-o clip ${styles.flag}`} style={gradientFontStyle} />
                  </div>
                  <h4 className="flex-85"> {endHub.data.name} </h4>
                </div>
              </div>
            </div>
            <div className={`flex-35 layout-row layout-align-start-center ${styles.load_type}`}>
              <div
                className={`${
                  styles.tot_price
                } flex-none layout-row layout-align-space-between-center`}
                style={brightGradientStyle}
              >
                <p>{t('shipment:totalPrice')}</p>{' '}
                <Tooltip theme={theme} icon="fa-info-circle" color="white" text="total_price" />
                <Price value={total} currency={user.currency} />
              </div>
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-start-center">
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <TextHeading theme={theme} size={4} text={t('shipment:pickUpDate')} />
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(this.props.pickupDate).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(this.props.pickupDate).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <TextHeading theme={theme} size={4} text={t('shipment:dateOfDeparture')} />
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(route.etd).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(route.etd).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <TextHeading theme={theme} size={4} text={t('shipment:etaTerminal')} />
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(route.eta).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(route.eta).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-100 flex-gt-sm-25
            layout-wrap layout-row layout-align-space-between-center"
            >
              <div className="flex-100 layout-row">
                <TextHeading theme={theme} size={4} text={t('shipment:shipmentType')} />
              </div>
              <p className="flex-none"> {shipment.load_type === 'cargo_item' ? 'LCL' : 'FCL'} </p>
            </div>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
            <div className="flex-100 flex-gt-sm-25
            layout-wrap layout-row layout-align-space-between-center"
            >
              <div className="flex-100 layout-row">
                <TextHeading theme={theme} size={4} text={t('shipment:incoterm')} />
              </div>
              <p className="flex-none"> {shipment.incoterm} </p>
            </div>
            <div className="flex-100 flex-gt-sm-25
            layout-wrap layout-row layout-align-space-between-center"
            >
              <div className="flex-100 layout-row">
                <TextHeading theme={theme} size={4} text={t('shipment:MoT')} />
              </div>
              <p className="flex-none"> {capitalize(route[0].mode_of_transport)} </p>
            </div>
            <div className="flex-100 flex-gt-sm-25
            layout-wrap layout-row layout-align-space-between-center"
            >
              <div className="flex-100 layout-row">
                <TextHeading theme={theme} size={4} text={t('shipment:preCarriage')} />
              </div>
              <p className="flex-none"> {shipment.has_pre_carriage ? t('common:yes') : t('common:no')} </p>
            </div>
            <div className="flex-100 flex-gt-sm-25
            layout-wrap layout-row layout-align-space-between-center"
            >
              <div className="flex-100 layout-row">
                <TextHeading theme={theme} size={4} text={t('shipment:onCarriage')} />
              </div>
              <p className="flex-none"> {shipment.has_on_carriage ? t('common:yes') : t('common:no')} </p>
            </div>
            {shipment.has_pre_carriage ? originAddress : ''}
            {shipment.has_on_carriage ? destinationAddress : ''}
          </div>
        </div>
      </div>
    )
  }
}

ShipmentSummaryBox.propTypes = {
  name: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  pickupDate: PropTypes.number.isRequired,
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  shipment: PropTypes.shipment,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  route: PropTypes.route,
  user: PropTypes.user,
  total: PropTypes.number,
  locations: PropTypes.locations
}

ShipmentSummaryBox.defaultProps = {
  theme: null,
  shipment: null,
  hubs: [],
  route: null,
  user: null,
  locations: null,
  total: 0
}

export default withNamespaces(['shipment', 'common'])(ShipmentSummaryBox)
