import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import defs from '../../styles/default_classes.scss'
import styles from './RouteHubBox.scss'
import { moment } from '../../constants'
import { capitalize } from '../../helpers'

class RouteTextBox extends Component {
  static faIcon (sched) {
    if (sched) {
      const faKeywords = {
        ocean: 'ship',
        air: 'plane',
        train: 'train'
      }
      const faClass = `flex-none fa fa-${faKeywords[sched.mode_of_transport]}`

      return (
        <div className="flex-33 layout-row layout-align-center">
          <i className={faClass} />
        </div>
      )
    }

    return [
      <div className="flex-33 layout-row layout-align-center">
        <i className="fa fa-ship flex-none" />
      </div>,
      <div className="flex-33 layout-row layout-align-center">
        <i className="fa fa-plane flex-none" />
      </div>,
      <div className="flex-33 layout-row layout-align-center">
        <i className="fa fa-train flex-none" />
      </div>
    ]
  }
  static dashedGradient (color1, color2) {
    return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`
  }
  render () {
    const {
      theme, shipment, t
    } = this.props
    const startHub = shipment.origin_hub
    const endHub = shipment.destination_hub

    const gradientStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary}, ${theme.colors.secondary})`
          : 'black'
    }
    const dashedLineStyles = {
      marginTop: '6px',
      height: '2px',
      width: '100%',
      background:
        theme && theme.colors
          ? RouteTextBox.dashedGradient(theme.colors.primary, theme.colors.secondary)
          : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }
    const originAddress =
      shipment.pickup_address ? (
        <div className={`flex-100 layout-row layout-align-center-start layout-wrap ${styles.address_padding}`}>
          <div className="flex-100 layout-row layout-align-center-center">
            <p className="flex-none">{t('common:withPickupFrom')}:</p>
          </div>
          <address className={` ${styles.itinerary_address} flex-none`}>
            {`${shipment.pickup_address.street_number || ''} ${shipment.pickup_address.street || ''}`}, <br />
            {`${shipment.pickup_address.city || ''}, ${' '} `}
            {`${shipment.pickup_address.zip_code || ''}, `}
            {`${shipment.pickup_address.country.name || ''}`} <br />
          </address>
        </div>
      ) : (
        ''
      )
    const destinationAddress =
      shipment.delivery_address ? (
        <div className={`flex-100 layout-row layout-align-center-start layout-wrap ${styles.address_padding}`}>
          <div className="flex-100 layout-row layout-align-center-center">
            <p className="flex-none">{t('common:withDeliveryTo')}:</p>
          </div>
          <address className={` ${styles.itinerary_address} flex-none`}>
            {`${shipment.delivery_address.street_number || ''} ${shipment.delivery_address.street || ''}`}, <br />
            {`${shipment.delivery_address.city || ''}, ${' '} `}
            {`${shipment.delivery_address.zip_code || ''}, `}
            {`${shipment.delivery_address.country.name || ''}`} <br />
          </address>
        </div>
      ) : (
        ''
      )
    const timeDiff =
      shipment.planned_eta ? (
        <div
          className="flex layout-row layout-wrap layout-align-center-stretch"
          style={{ marginTop: '25px' }}
        >
          <h4 className="no_m center" style={{ marginBottom: '10px' }}>
            {' '}
            {t('shipment:estimatedTransitTime')}
          </h4>
          <p className="flex-100 no_m center">
            {' '}
            {moment(shipment.planned_eta).diff(moment(shipment.planned_etd), t('common:days'))} days{' '}
          </p>
        </div>
      ) : (
        ''
      )
    return (
      <div className={` ${styles.outer_box} flex-100 layout-row layout-align-center-center`}>
        <div className={`flex-none ${defs.content_width} layout-row layout-align-start-start layout-wrap`}>
          <div className="flex-100 layout-row layout-wrap">
            <div className="flex-40 layout-row layout-wrap layout-align-center-start">
              <h3 className={`flex-100 flex-gt-sm-40 ${styles.rhb_header}`}>{t('shipment:origin').toUpperCase()}</h3>
              <div className="flex-100 flex-gt-sm-60 layout-row" >
                <div className="flex-15 layout-column layout-align-center-center">
                  <i className="fa fa-map-marker clip" style={gradientStyle} />
                </div>
                <div className="flex-85 layout-row layout-wrap layout-align-start-center">
                  <h4 className="flex-100"> {startHub.name} </h4>
                </div>
              </div>
              {originAddress}
            </div>
           
            <div className="flex-40 layout-row layout-wrap layout-align-center-start">
              <h3 className={`flex-100 flex-gt-sm-40 ${styles.rhb_header}`}>{t('shipment:destination').toUpperCase()}</h3>
              <div className="flex-100 flex-gt-sm-60 layout-row" >
                <div className="flex-15 layout-column layout-align-center-center">
                  <i className="fa fa-map-marker clip" style={gradientStyle} />
                </div>
                <div className="flex-85 layout-row layout-wrap layout-align-start-center">
                  <h4 className="flex-100"> {endHub.name} </h4>
                </div>
              </div>
              {destinationAddress}
            </div>
          </div>
          <div className="flex-100 layout-row">
            <div className="flex-40 layout-row layout-align-center-center">
              <h4 className="flex-none">{`${t('common:etd')}: ${moment(shipment.planned_etd).format('ll')}`}</h4>
            </div>
            <div
              className={`${styles.connection_graphics} flex-20 layout-row layout-align-center-center`}
            >
              <div className="flex-100 layout-row layout-align-center-center">
                <div
                  className="flex-75 height_100 layout-column layout-align-end-center"
                >
                  {timeDiff}
                </div>
              </div>
            </div>
            <div className="flex-40 layout-row layout-align-center-center">
              <h4 className="flex-none">{`${t('common:eta')}: ${moment(shipment.planned_eta).format('ll')}`}</h4>
            </div>
          </div>
          <div className="flex-100 layout-row">
            <div className="flex-33 layout-row layout-align-center-center">
              {shipment.carrier ? <p className="flex-none">{`${t('shipment:carrier')}: ${capitalize(shipment.carrier)}`}</p> : '' }
            </div>
            <div className="flex-33 layout-row layout-align-center-center">
              <p className="flex-none">{`${t('shipment:serviceLevel')}: ${capitalize(shipment.service_level)}`}</p>
            </div>
            <div className="flex-33 layout-row layout-align-center-center">
              {shipment.vessel_name ? <p className="flex-none">{`${t('shipment:vesselName')}: ${capitalize(shipment.vessel_name)}`}</p> : '' }
            </div>
          </div>
        </div>
      </div>
    )
  }
}
RouteTextBox.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  shipment: PropTypes.shipment.isRequired
}
RouteTextBox.defaultProps = {
  theme: null
}

export default withNamespaces(['common', 'shipment'])(RouteTextBox)
