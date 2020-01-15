import React from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import { has } from 'lodash'
import TruncateText from '../TruncateText'
import styles from './BookingSummary.scss'
import { dashedGradient, switchIcon, numberSpacing } from '../../helpers'

function BookingSummary (props) {
  const {
    theme, totalWeight, totalVolume, cities, nexuses, trucking, modeOfTransport, loadType, t, scope
  } = props
  const { values } = scope
  const { weight } = values
  const dashedLineStyles = {
    marginTop: '6px',
    height: '2px',
    width: '100%',
    background:
      theme && theme.colors
        ? dashedGradient(theme.colors.primary, theme.colors.secondary)
        : 'black',
    backgroundSize: '16px 2px, 100% 2px'
  }
  const icon = modeOfTransport ? switchIcon(modeOfTransport) : ' '
  const weightToRender = weight.unit === 'kg' ? totalWeight : (totalWeight / 1000)

  return (
    <div className={`${styles.booking_summary} hide-sm hide-xs flex-50 layout-align-sm-center-center layout-row`}>
      <div className={`${styles.route_sec} flex-70 layout-column layout-align-stretch`}>
        <div className="flex-none layout-row layout-align-center">
          <div className={`flex-none ${styles.connection_graphics}`}>
            <i className={`fa fa-map-marker ${styles.map_marker}`} />
            <i className={`fa fa-flag-o ${styles.flag}`} />
            <div className={`${styles.mot_wrapper} layout-row layout-align-center-center`}>
              {icon}
            </div>
            <div style={dashedLineStyles} />
          </div>
        </div>
        <div className="flex-50 layout-row layout-align-space-between">
          <div className="flex-50 layout-row layout-align-center-center">
            <h4>{t('common:from')}</h4>
          </div>
          <div className="flex-50 layout-row layout-align-center-center">
            <h4>{t('common:to')}</h4>
          </div>
        </div>
        <div className="flex-50 layout-row layout-align-space-between">
          <div className={`flex-50 layout-row layout-align-center-center layout-wrap ${styles.header_hub}`}>
            <h4 className="flex-100">
              <TruncateText lines={1}>
                {cities.origin || nexuses.origin}
              </TruncateText>
            </h4>
            <p className={`${styles.trucking_elem} flex-none`}>
              {
                (
                  (cities.origin && trucking.preCarriage.truckType) ||
                  (nexuses.origin && !trucking.preCarriage.truckType)
                ) && `${(trucking.preCarriage.truckType ? t('common:withPickup') : t('common:withoutPickup'))}`
              }
            </p>
          </div>
          <div className={`flex-50 layout-row layout-align-center-center layout-wrap ${styles.header_hub}`}>
            <h4 className="flex-100">
              <TruncateText lines={1}>
                {cities.destination || nexuses.destination}
              </TruncateText>
            </h4>
            <p className={`${styles.trucking_elem} flex-none`}>
              {
                (
                  (cities.destination && trucking.onCarriage.truckType) ||
                  (nexuses.destination && !trucking.onCarriage.truckType)
                ) && `${(trucking.onCarriage.truckType ? t('common:with') : t('common:without'))} 
                ${t('shipment:delivery').toLowerCase()}`
              }
            </p>
          </div>
        </div>
      </div>
      <div className="flex flex-sm-30 layout-column layout-align-stretch">
        <h4 className="flex-50 layout-row layout-align-center-center">{t('cargo:totalWeight')}</h4>
        <p className="flex-50 layout-row layout-align-center-start">
          { numberSpacing(weightToRender, weight.decimals) }
          {' '}
          {weight.unit}
        </p>
      </div>
      {
        loadType === 'cargo_item' && (
          <div className="flex layout-column layout-align-stretch">
            <h4 className="flex-50 layout-row layout-align-center-center">{t('cargo:totalVolume')}</h4>
            <p className="flex-50 layout-row layout-align-center-start">
              { numberSpacing(totalVolume, 3) }
              {' '}
              m³
            </p>
          </div>
        )
      }
    </div>
  )
}

BookingSummary.defaultProps = {
  theme: null,
  modeOfTransport: '',
  totalWeight: 0,
  totalVolume: 0,
  cities: {
    origin: '',
    destination: ''
  },
  nexuses: {
    origin: '',
    destination: ''
  },
  trucking: {
    onCarriage: { truckType: '' },
    preCarriage: { truckType: '' }
  },
  loadType: ''
}

function mapStateToProps (state) {
  const { app, bookingProcess } = state
  const { tenant } = app
  const { theme } = tenant
  const { shipment } = bookingProcess

  let totalWeight = 0
  let totalVolume = 0

  const { loadType, trucking, modeOfTransport } = shipment

  if (loadType === 'container') {
    shipment.cargoUnits.forEach((container) => {
      totalWeight += container.quantity * container.payloadInKg
    })
  } else if (shipment.aggregatedCargo) {
    totalVolume = (shipment.cargoUnits[0] && shipment.cargoUnits[0].totalVolume) || 0
    totalWeight = (shipment.cargoUnits[0] && shipment.cargoUnits[0].totalWeight) || 0
  } else if (loadType === 'cargo_item') {
    shipment.cargoUnits.forEach((cargoItem) => {
      totalVolume += cargoItem.quantity * ['X', 'Y', 'Z'].reduce((product, coordinate) => (
        product * cargoItem[`dimension${coordinate}`]
      ), 1) / 1000000
      totalWeight += cargoItem.quantity * cargoItem.payloadInKg
    })
  }

  const cities = {}
  if (has(shipment, ['origin', 'city'])) {
    cities.origin = shipment.origin.city
  }
  if (has(shipment, ['destination', 'city'])) {
    cities.destination = shipment.destination.city
  }
  const nexuses = {}
  if (shipment.origin) nexuses.origin = shipment.origin.nexusName
  if (shipment.destination) nexuses.destination = shipment.destination.nexusName

  return {
    totalWeight, totalVolume, cities, nexuses, loadType, trucking, modeOfTransport, theme
  }
}

export default withNamespaces(['cargo', 'common', 'shipment'])(withRouter(connect(mapStateToProps)(BookingSummary)))
