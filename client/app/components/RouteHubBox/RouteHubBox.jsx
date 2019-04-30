import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import PropTypes from '../../prop-types'
import defs from '../../styles/default_classes.scss'
import styles from './RouteHubBox.scss'
import { moment } from '../../constants'
import { capitalize, formatAddress } from '../../helpers'

function formatDate (date) {
  const format = 'DD/MM/YYYY'

  return `${moment(date).format(format)}`
}

class RouteHubBox extends Component {
  static faIcon (mot) {
    if (mot) {
      const faKeywords = {
        ocean: 'anchor',
        air: 'plane',
        train: 'train'
      }
      const faClass = `flex-none fa fa-${faKeywords[mot]}`

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
      theme, shipment, t, scope
    } = this.props
    const startHub = shipment.origin_hub
    const endHub = shipment.destination_hub
    const voyageInfo = get(scope, ['voyage_info'], {})
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
        <div className={`flex-100 layout-row layout-align-center-start ${styles.address_padding}`}>
          <div className="flex-50 layout-row layout-align-start-center">
            <p className="flex-none">
              <b>
                {`${t('common:withPickupFrom')}:`}
              </b>
            </p>
          </div>
          <div className="flex-50 layout-row layout-align-end-center">
            <p className={` ${styles.itinerary_address} flex-none`}>
              {formatAddress(shipment.pickup_address)}
            </p>
          </div>

        </div>
      ) : (
        ''
      )
    const destinationAddress =
      shipment.delivery_address ? (
        <div className={`flex-100 layout-row layout-align-center-start layout-wrap ${styles.address_padding}`}>
          <div className="flex-50 layout-row layout-align-start-center">
            <p className="flex-none">
              <b>
                {`${t('common:withDeliveryTo')}:`}
              </b>
            </p>
          </div>
          <div className="flex-50 layout-row layout-align-end-center">
            <p className={` ${styles.itinerary_address} flex-none`}>
              {formatAddress(shipment.delivery_address)}

            </p>
          </div>

        </div>
      ) : (
        ''
      )
    const dateOfArrival = (

      <div className={`flex-100 layout-row layout-align-center-start layout-wrap ${styles.address_padding}`}>
        <div className="flex layout-row layout-align-start-center">
          <p className="flex-none">
            <b>
              {`${t('bookconf:expectedArrivalTerminal')}:`}
            </b>
          </p>
        </div>
        <div className="flex-none layout-row layout-align-end-center">
          <p className="flex-none">{formatDate(shipment.planned_eta)}</p>
        </div>

      </div>)

    const dateOfDeparture = (

      <div className={`flex-100 layout-row layout-align-center-start layout-wrap ${styles.address_padding}`}>
        <div className="flex layout-row layout-align-start-center">
          <p className="flex-none">
            <b>
              {`${t('bookconf:expectedDepartureTerminal')}:`}
            </b>
          </p>
        </div>
        <div className="flex-none layout-row layout-align-end-center">
          <p className="flex-none">{formatDate(shipment.planned_etd)}</p>
        </div>

      </div>
    )

    return (
      <div className={` ${styles.outer_box} flex-100 layout-row layout-align-center-center`}>
        <div className={`flex-none ${defs.content_width} layout-row layout-align-start-start`}>
          <div className="flex layout-row layout-wrap layout-align-center-start">
            <h3 className={`flex-100 ${styles.rhb_header}`}>{t('shipment:origin').toUpperCase()}</h3>
            <div className={`flex-100 ${styles.hub_card} layout-row`} style={bg1}>
              <div className={styles.fade} />
              <div className={`${styles.content} layout-row`}>
                <div className="flex-15 layout-column layout-align-start-center">
                  <i className="fa fa-map-marker" />
                </div>
                <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                  <h6 className="flex-100">
                    {' '}
                    {startHub.name}
                    {' '}
                  </h6>
                </div>
              </div>
            </div>
            {originAddress}
            {dateOfDeparture}
          </div>
          <div
            className={`${styles.connection_graphics} flex-40 layout-row layout-align-center-center layout-wrap`}
          >
            <div className="flex-100 layout-row layout-align-center-center">
              <div
                className="flex-85 height_100 layout-row layout-wrap layout-align-end-center"
                style={{ marginTop: '75px' }}
              >
                <div
                  className="flex-100 width_100 layout-row layout-align-center-center"
                  style={{ marginBottom: '25px' }}
                >
                  {RouteHubBox.faIcon(shipment.mode_of_transport)}
                </div>
                <div className="flex" style={dashedLineStyles} />
                <br />
              </div>
            </div>
            <div className="flex-85 layout-row layout-wrap ">
              <table className="flex-100">
                {shipment.planned_eta
                  ? (
                    <tr>
                      <td className="flex-none">
                        <b>
                          {`${t('shipment:estimatedTransitTime')}: `}
                        </b>
                      </td>
                      <td className="flex-none end">
                        {` ${moment(shipment.planned_eta).diff(moment(shipment.planned_etd), 'days')} 
                        ${t('common:days')}`}
                      </td>
                    </tr>) : ''}
                {voyageInfo.service_level && shipment.service_level
                  ? (
                    <tr>
                      <td className="flex-none">
                        <b>
                          {`${t('shipment:serviceLevel')}: `}
                        </b>
                      </td>
                      <td className="flex-none end">{` ${capitalize(shipment.service_level)}`}</td>
                    </tr>) : ''}
                {voyageInfo.carrier && shipment.carrier
                  ? (
                    <tr>

                      <td className="flex-none">
                        <b>
                          {`${capitalize(t('shipment:carrier'))}: `}
                        </b>
                        {' '}
                      </td>
                      <td className="flex-none end">{capitalize(shipment.carrier)}</td>

                    </tr>
                  )
                  : '' }
                {voyageInfo.vessel && shipment.vessel_name
                  ? (
                    <tr>

                      <td className="flex-none">
                        <b>
                          {`${t('shipment:vesselName')}: `}
                        </b>
                        {' '}
                      </td>
                      <td className="flex-none end">{capitalize(shipment.vessel_name)}</td>

                    </tr>
                  )
                  : '' }
                {voyageInfo.voyage_code && shipment.voyage_code
                  ? (
                    <tr>

                      <td className="flex-none">
                        <b>
                          {`${t('shipment:vesselName')}: `}
                        </b>
                        {' '}
                      </td>
                      <td className="flex-none end">{capitalize(shipment.voyage_code)}</td>

                    </tr>
                  )
                  : '' }
              </table>
            </div>
          </div>

          <div className="flex layout-row layout-wrap layout-align-center-start">
            <h3 className={`flex-100 ${styles.rhb_header}`}>{t('shipment:destination').toUpperCase()}</h3>
            <div className={`flex-100 ${styles.hub_card} layout-row`} style={bg2}>
              <div className={styles.fade} />
              <div className={`${styles.content} layout-row`}>
                <div className="flex-15 layout-column layout-align-start-center">
                  <i className="fa fa-flag" />
                </div>
                <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                  <h6 className="flex-100">
                    {' '}
                    {endHub.name}
                    {' '}
                  </h6>
                </div>
              </div>
            </div>
            {destinationAddress}
            {dateOfArrival}
          </div>
        </div>
      </div>
    )
  }
}

RouteHubBox.defaultProps = {
  theme: null
}

export default withNamespaces(['common', 'shipment'])(RouteHubBox)
