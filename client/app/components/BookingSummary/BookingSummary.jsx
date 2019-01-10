import React from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import Truncate from 'react-truncate'
import PropTypes from '../../prop-types'
import styles from './BookingSummary.scss'
import { dashedGradient, switchIcon, numberSpacing } from '../../helpers'

function BookingSummary (props) {
  const {
    theme, totalWeight, totalVolume, cities, nexuses, trucking, modeOfTransport, loadType, t
  } = props
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

  return (
    <div className={`${styles.booking_summary} hide-sm hide-xs flex-50 layout-align-sm-center-center layout-row`}>
      <div className={`${styles.route_sec} flex-40 layout-column layout-align-stretch`}>
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
              <Truncate lines={1}>
                {trucking.pre_carriage.truck_type ? cities.origin : nexuses.origin}
              </Truncate>
            </h4>
            <p className={`${styles.trucking_elem} flex-none`}>
              {
                (
                  (cities.origin && trucking.pre_carriage.truck_type) ||
                  (nexuses.origin && !trucking.pre_carriage.truck_type)
                ) && `${(trucking.pre_carriage.truck_type ? t('common:withPickup') : t('common:withoutPickup'))}`
              }
            </p>
          </div>
          <div className={`flex-50 layout-row layout-align-center-center layout-wrap ${styles.header_hub}`}>
            <h4 className="flex-100">
              {trucking.on_carriage.truck_type ? cities.destination : nexuses.destination}
            </h4>
            <p className={`${styles.trucking_elem} flex-none`}>
              {
                (
                  (cities.destination && trucking.on_carriage.truck_type) ||
                  (nexuses.destination && !trucking.on_carriage.truck_type)
                ) && `${(trucking.on_carriage.truck_type ? t('common:with') : t('common:without'))} 
                ${t('shipment:delivery').toLowerCase()}`
              }
            </p>
          </div>
        </div>
      </div>
      <div className="flex flex-sm-40 layout-column layout-align-stretch">
        <h4 className="flex-50 layout-row layout-align-center-center">{t('cargo:totalWeight')}</h4>
        <p className="flex-50 layout-row layout-align-center-start">
          { numberSpacing(totalWeight, 2) } kg
        </p>
      </div>
      {
        loadType === 'cargo_item' && (
          <div className="flex layout-column layout-align-stretch">
            <h4 className="flex-50 layout-row layout-align-center-center">{t('cargo:totalVolume')}</h4>
            <p className="flex-50 layout-row layout-align-center-start">
              { numberSpacing(totalVolume, 3) } m³
            </p>
          </div>
        )
      }
    </div>
  )
}

BookingSummary.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  modeOfTransport: PropTypes.string,
  totalWeight: PropTypes.number,
  totalVolume: PropTypes.number,
  cities: PropTypes.shape({
    origin: PropTypes.string,
    destination: PropTypes.string
  }),
  nexuses: PropTypes.shape({
    origin: PropTypes.string,
    destination: PropTypes.string
  }),
  trucking: PropTypes.shape({
    onCarriage: PropTypes.objectOf(PropTypes.string),
    preCarriage: PropTypes.objectOf(PropTypes.string)
  }),
  loadType: PropTypes.string
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
    on_carriage: { truck_type: '' },
    pre_carriage: { truck_type: '' }
  },
  loadType: ''
}

function mapStateToProps (state) {
  const { app, bookingSummary } = state
  const { tenant } = app
  const { theme } = tenant

  return { ...bookingSummary, theme }
}

export default withNamespaces(['cargo', 'common', 'shipment'])(withRouter(connect(mapStateToProps)(BookingSummary)))
