import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import defs from '../../styles/default_classes.scss'
import styles from './RouteHubBox.scss'
import { moment } from '../../constants'

export class RouteHubBox extends Component {
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
      theme, shipment
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
          ? RouteHubBox.dashedGradient(theme.colors.primary, theme.colors.secondary)
          : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }
    const bg1 =
      startHub && startHub.photo
        ? { backgroundImage: `url(${startHub.photo})` }
        : {
          backgroundImage:
              'url("https://assets.itsmycargo.com/assets/default_images/crane_sm.jpg")'
        }
    const bg2 =
      endHub && endHub.photo
        ? { backgroundImage: `url(${endHub.photo})` }
        : {
          backgroundImage:
              'url("https://assets.itsmycargo.com/assets/default_images/destination_sm.jpg")'
        }
    const originAddress =
      shipment.pickup_address ? (
        <div className="flex-100 layout-row layout-align-center-start layout-wrap">
          <div className="flex-100 layout-row layout-align-center-center">
            <p className="flex-none">With Pickup From:</p>
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
        <div className="flex-100 layout-row layout-align-center-start layout-wrap">
          <div className="flex-100 layout-row layout-align-center-center">
            <p className="flex-none">With Delivery To:</p>
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
          className="flex-65 layout-row layout-wrap layout-align-center-stretch"
          style={{ marginTop: '25px' }}
        >
          <h4 className="no_m center" style={{ marginBottom: '10px' }}>
            {' '}
            Estimated Transit Time
          </h4>
          <p className="flex-100 no_m center">
            {' '}
            {moment(shipment.planned_eta).diff(moment(shipment.planned_etd), 'days')} days{' '}
          </p>
        </div>
      ) : (
        ''
      )
    return (
      <div className={` ${styles.outer_box} flex-100 layout-row layout-align-center-center`}>
        <div className={`flex-none ${defs.content_width} layout-row layout-align-start-start`}>
          <div className="flex layout-row layout-wrap layout-align-center-start">
            <h3 className={`flex-100 ${styles.rhb_header}`}>ORIGIN</h3>
            <div className={`flex-100 ${styles.hub_card} layout-row`} style={bg1}>
              <div className={styles.fade} />
              <div className={`${styles.content} layout-row`}>
                <div className="flex-15 layout-column layout-align-start-center">
                  <i className="fa fa-map-marker" style={gradientStyle} />
                </div>
                <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                  <h6 className="flex-100"> {startHub.name} </h6>
                  {/* <p className="flex-100">{startHub.location.geocoded_address}</p> */}
                </div>
              </div>
            </div>
            {originAddress}
          </div>
          <div
            className={`${styles.connection_graphics} flex-25 layout-row layout-align-center-center`}
          >
            <div className="flex-100 layout-row layout-align-center-center">
              <div
                className="flex-75 height_100 layout-column layout-align-end-center"
                style={{ marginTop: '100px' }}
              >
                <div className="flex-none width_100 layout-row layout-align-center-center">
                  {RouteHubBox.faIcon(shipment.mode_of_transport)}
                </div>
                <div className="flex" style={dashedLineStyles} />
                <br />
                {timeDiff}
              </div>
            </div>
          </div>

          <div className="flex layout-row layout-wrap layout-align-center-start">
            <h3 className={`flex-100 ${styles.rhb_header}`}> DESTINATION</h3>
            <div className={`flex-100 ${styles.hub_card} layout-row`} style={bg2}>
              <div className={styles.fade} />
              <div className={`${styles.content} layout-row`}>
                <div className="flex-15 layout-column layout-align-start-center">
                  <i className="fa fa-flag" style={gradientStyle} />
                </div>
                <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                  <h6 className="flex-100"> {endHub.name} </h6>
                  {/* <p className="flex-100">{endHub.location.geocoded_address}</p> */}
                </div>
              </div>
            </div>
            {destinationAddress}
          </div>
        </div>
      </div>
    )
  }
}
RouteHubBox.propTypes = {
  theme: PropTypes.theme,
  shipment: PropTypes.shipment.isRequired
}
RouteHubBox.defaultProps = {
  theme: null
}

export default RouteHubBox
