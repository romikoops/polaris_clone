import React from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import Truncate from 'react-truncate'
import { get } from 'lodash'
import PropTypes from '../../prop-types'
import styles from './BookingSummary.scss'
import { dashedGradient, switchIcon } from '../../helpers'

const ROW = 'layout-row layout-align-center'
const HALF_ROW = 'flex-50 layout-row'
const CENTER = 'layout-align-center-center'

const BOOKING_SUMMARY = `${styles.booking_summary} ${HALF_ROW}`
const ROUTE = `${styles.route_sec} flex-40 layout-column layout-align-stretch`
const MAP_MARKER = `fa fa-map-marker ${styles.map_marker}`
const FLAG = `fa fa-flag-o ${styles.flag}`
const MOT_WRAPPER = `${styles.mot_wrapper} layout-row ${CENTER}`
const HEADER = `${HALF_ROW} ${CENTER} ${styles.header_hub}`

function BookingSummary (props) {
  const {
    cities,
    hubs,
    modeOfTransport,
    theme,
    totalVolume,
    totalWeight,
    trucking
  } = props

  const dashedLineStyles = getDashedLineStyles(theme)
  const icon = modeOfTransport ? switchIcon(modeOfTransport) : ' '

  const truckTypePre = get(trucking, 'pre_carriage.truck_type')
  const truckTypeOn = get(trucking, 'on_carriage.truck_type')

  const origin = truckTypePre ? cities.origin : hubs.origin
  const destination = truckTypeOn ? cities.destination : hubs.destination

  const pickUpTextFlag = (cities.origin && truckTypePre) || (hubs.origin && !truckTypePre)
  const deliveryTextFlag = (cities.destination && truckTypeOn) ||
  (hubs.destination && !truckTypeOn)

  const pickUpText = pickUpTextFlag && `${(truckTypePre ? 'with' : 'without')} pick-up`
  const deliveryText = deliveryTextFlag && `${(truckTypeOn ? 'with' : 'without')} delivery`

  const Icons = (
    <div className={`flex-none ${ROW}`}>
      <div className={`flex-none ${styles.connection_graphics}`}>
        <i className={MAP_MARKER} />
        <i className={FLAG} />
        <div className={MOT_WRAPPER}>{icon}</div>
        <div style={dashedLineStyles} />
      </div>
    </div>
  )

  const Weight = (
    <div className="flex layout-column layout-align-stretch">
      <h4 className={`${HALF_ROW} ${CENTER}`}>Total Weight</h4>
      <p className={`${HALF_ROW} layout-align-center-start`}>
        { totalWeight.toFixed(1) } kg
      </p>
    </div>
  )

  const Volume = (
    <div className="flex layout-column layout-align-stretch">
      <h4 className={`${HALF_ROW} ${CENTER}`}>Total Volume</h4>
      <p className={`${HALF_ROW} layout-align-center-start`}>
        { totalVolume.toFixed(3) } m³
      </p>
    </div>
  )

  return (
    <div className={BOOKING_SUMMARY}>
      <div className={ROUTE}>

        {Icons}

        <div className={`${HALF_ROW} layout-align-space-between`}>
          <div className={`${HALF_ROW} ${CENTER}`}>
            <h4>From</h4>
          </div>
          <div className={`${HALF_ROW} ${CENTER}`}>
            <h4>To</h4>
          </div>
        </div>

        <div className={`${HALF_ROW} layout-align-space-between`}>
          <div className={`${HALF_ROW} ${CENTER} ${styles.header_hub}`}>
            <h4>
              <Truncate lines={1}>
                {origin}
              </Truncate>
            </h4>
            <p className={styles.trucking_elem}>
              {pickUpText}
            </p>
          </div>

          <div className={HEADER}>
            <h4> {destination} </h4>
            <p className={styles.trucking_elem}>
              {deliveryText}
            </p>
          </div>
        </div>
      </div>

      {Weight}

      {Volume}

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
  cities: {
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

function getDashedLineStyles (theme) {
  const background = theme && theme.colors
    ? dashedGradient(theme.colors.primary, theme.colors.secondary)
    : 'black'

  return {
    marginTop: '6px',
    height: '2px',
    width: '100%',
    background,
    backgroundSize: '16px 2px, 100% 2px'
  }
}

export default withRouter(connect(mapStateToProps)(BookingSummary))
