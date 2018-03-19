import React from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import PropTypes from '../../prop-types'
import styles from './BookingSummary.scss'
import { dashedGradient, switchIcon } from '../../helpers'

function BookingSummary (props) {
  const {
    theme, totalWeight, totalVolume, nexuses, hubs, trucking, modeOfTransport
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
  // const modesOfTransport = Object.keys(scope.modes_of_transport)
  //   .filter(mot => scope.modes_of_transport[mot])
  // const icons = modesOfTransport.map(mot => switchIcon(mot))
  const icon = modeOfTransport ? switchIcon(modeOfTransport) : ' '
  return (
    <div className={`${styles.booking_summary} flex-50 layout-row`}>
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
            <h4>From</h4>
          </div>
          <div className="flex-50 layout-row layout-align-center-center">
            <h4>To</h4>
          </div>
        </div>
        <div className="flex-50 layout-row layout-align-space-between">
          <div className={`flex-50 layout-row layout-align-center-center ${styles.header_hub}`}>
            <h4> {trucking.pre_carriage.truck_type ? nexuses.origin : hubs.origin} </h4>
            <p className={styles.trucking_elem}>
              {
                (
                  (nexuses.origin && trucking.pre_carriage.truck_type) ||
                  (hubs.origin && !trucking.pre_carriage.truck_type)
                ) && `${(trucking.pre_carriage.truck_type ? 'with' : 'without')} pick-up`
              }
            </p>
          </div>
          <div className={`flex-50 layout-row layout-align-center-center ${styles.header_hub}`}>
            <h4> {trucking.on_carriage.truck_type ? nexuses.destination : hubs.destination} </h4>
            <p className={styles.trucking_elem}>
              {
                (
                  (nexuses.destination && trucking.on_carriage.truck_type) ||
                  (hubs.destination && !trucking.on_carriage.truck_type)
                ) && `${(trucking.on_carriage.truck_type ? 'with' : 'without')} delivery`
              }
            </p>
          </div>
        </div>
      </div>
      <div className="flex layout-column layout-align-stretch">
        <h4 className="flex-50 layout-row layout-align-center-center">Total Weight</h4>
        <p className="flex-50 layout-row layout-align-center-start">
          { totalWeight.toFixed(1) } kg
        </p>
      </div>
      <div className="flex layout-column layout-align-stretch">
        <h4 className="flex-50 layout-row layout-align-center-center">Total Volume</h4>
        <p className="flex-50 layout-row layout-align-center-start">
          { totalVolume.toFixed(1) } m³
        </p>
      </div>
    </div>
  )
}

BookingSummary.propTypes = {
  theme: PropTypes.theme,
  modeOfTransport: PropTypes.string,
  totalWeight: PropTypes.number,
  totalVolume: PropTypes.number,
  nexuses: PropTypes.shape({
    origin: PropTypes.string,
    destination: PropTypes.string
  }),
  hubs: PropTypes.shape({
    origin: PropTypes.string,
    destination: PropTypes.string
  }),
  trucking: PropTypes.shape({
    onCarriage: PropTypes.objectOf(PropTypes.string),
    preCarriage: PropTypes.objectOf(PropTypes.string)
  })
}

BookingSummary.defaultProps = {
  theme: null,
  modeOfTransport: '',
  totalWeight: 0,
  totalVolume: 0,
  nexuses: {
    origin: '',
    destination: ''
  },
  hubs: {
    origin: '',
    destination: ''
  },
  trucking: {
    on_carriage: { truck_type: '' },
    pre_carriage: { truck_type: '' }
  }
}

function mapStateToProps (state) {
  const { tenant, bookingSummary } = state
  const { theme } = tenant.data
  return { ...bookingSummary, theme }
}

export default withRouter(connect(mapStateToProps)(BookingSummary))
