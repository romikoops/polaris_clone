import React from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import Truncate from 'react-truncate'
import PropTypes from '../../prop-types'
import styles from './BookingSummary.scss'
import { dashedGradient, switchIcon } from '../../helpers'

import {
  ALIGN_CENTER_START,
  ALIGN_SPACE_BETWEEN,
  ROW,
  COLUMN,
  WRAP_ROW,
  ALIGN_CENTER
} from '../../classNames'

const CONTAINER = `BOOKING_SUMMARY ${styles.booking_summary} ${ROW(50)}`
const MARKER_ICON = 'fa fa-map-marker'
const FLAG_ICON = 'fa fa-flag-o'

function BookingSummary (props) {
  const {
    theme,
    totalWeight,
    totalVolume,
    cities,
    nexuses,
    trucking,
    modeOfTransport,
    loadType
  } = props
  const destination = trucking.on_carriage.truck_type
    ? cities.destination
    : nexuses.destination

  const backgroundDashedLineStyles = theme && theme.colors
    ? dashedGradient(theme.colors.primary, theme.colors.secondary)
    : 'black'

  const dashedLineStyles = {
    marginTop: '6px',
    height: '2px',
    width: '100%',
    background: backgroundDashedLineStyles,
    backgroundSize: '16px 2px, 100% 2px'
  }
  const icon = modeOfTransport ? switchIcon(modeOfTransport) : ' '

  const truckingWrapper = `${styles.trucking_elem} flex-none`
  const TruckingElementOrigin = () => {
    const originFlag = cities.origin && trucking.pre_carriage.truck_type
    const nexusesFlag = nexuses.origin && !trucking.pre_carriage.truck_type
    const ok = originFlag || nexusesFlag
    const text = ok && `${(trucking.pre_carriage.truck_type ? 'with' : 'without')} pick-up`

    return <p className={truckingWrapper}>{text}</p>
  }
  const TruckingElementDestination = () => {
    const originFlag = cities.destination && trucking.on_carriage.truck_type
    const nexusesFlag = nexuses.destination && !trucking.on_carriage.truck_type
    const ok = originFlag || nexusesFlag
    const text = ok && `${(trucking.on_carriage.truck_type ? 'with' : 'without')} delivery`

    return <p className={truckingWrapper}>{text}</p>
  }
  const TotalVolume = () => {
    if (loadType !== 'cargo_item') {
      return ''
    }

    return (
      <div className="flex layout-column layout-align-stretch">
        <h4 className={`${ROW(50)} ${ALIGN_CENTER}`}>Total Volume</h4>
        <p className={`${ROW(50)} ${ALIGN_CENTER_START}`}>
          { totalVolume.toFixed(3) } m³
        </p>
      </div>
    )
  }

  const Icons = (
    <div className={`${ROW('none')} layout-align-center`}>
      <div className={`flex-none ${styles.connection_graphics}`}>
        <i className={`${MARKER_ICON} ${styles.map_marker}`} />
        <i className={`${FLAG_ICON} ${styles.flag}`} />
        <div className={`${styles.mot_wrapper} layout-row ${ALIGN_CENTER}`}>
          {icon}
        </div>
        <div style={dashedLineStyles} />
      </div>
    </div>
  )
  const FromTo = (
    <div className={`${ROW(50)} ${ALIGN_SPACE_BETWEEN}`}>
      <div className={`${ROW(50)} ${ALIGN_CENTER}`}>
        <h4>From</h4>
      </div>
      <div className={`${ROW(50)} ${ALIGN_CENTER}`}>
        <h4>To</h4>
      </div>
    </div>
  )
  const TruckingElements = (
    <div className={`${ROW(50)} ${ALIGN_SPACE_BETWEEN}`}>
      <div className={`${WRAP_ROW(50)} ${ALIGN_CENTER} ${styles.header_hub}`}>
        <h4 className="flex-100">
          <Truncate lines={1}>
            {trucking.pre_carriage.truck_type ? cities.origin : nexuses.origin}
          </Truncate>
        </h4>
        {TruckingElementOrigin()}
      </div>
      <div className={`${WRAP_ROW(50)} ${ALIGN_CENTER} ${styles.header_hub}`}>
        <h4 className="flex-100">
          {destination}
        </h4>
        {TruckingElementDestination()}
      </div>
    </div>
  )

  return (
    <div className={CONTAINER}>
      <div className={`${styles.route_sec} ${COLUMN(40)} layout-align-stretch`}>
        {Icons}
        {FromTo}
        {TruckingElements}
      </div>
      <div className="flex layout-column layout-align-stretch">
        <h4 className={`${ROW(50)} ${ALIGN_CENTER}`}>Total Weight</h4>
        <p className={`${ROW(50)} ${ALIGN_CENTER_START}`}>
          { totalWeight.toFixed(1) } kg
        </p>
      </div>
      {TotalVolume()}
    </div>
  )
}

BookingSummary.propTypes = {
  theme: PropTypes.theme,
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
  const { tenant, bookingSummary } = state
  const { theme } = tenant.data

  return { ...bookingSummary, theme }
}

export default withRouter(connect(mapStateToProps)(BookingSummary))
