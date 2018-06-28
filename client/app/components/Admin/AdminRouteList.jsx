import React, { Component } from 'react'
import { v4 } from 'uuid'
import PropTypes from 'prop-types'
import styles from './AdminRouteList.scss'
import { gradientGenerator, switchIcon } from '../../helpers'

function listItineraries (itineraries, handleClick, hoverFn, theme) {
  const gradientStyle =
    theme && theme.colors
      ? gradientGenerator(theme.colors.primary, theme.colors.secondary)
      : { background: '#E0E0E0' }

  return itineraries.length > 0 ? itineraries.map((itinerary) => {
    const firstStopArray = itinerary.stops[0].hub.name.split(' ')
    const firstStopType = firstStopArray.splice(-1)
    const firstStopName = firstStopArray.join(' ')
    const lastStopArray = itinerary.stops[itinerary.stops.length - 1].hub.name.split(' ')
    const lastStopType = lastStopArray.splice(-1)
    const lastStopName = lastStopArray.join(' ')
    const stopCount = itinerary.stops.length - 2
    const modeOfTransport = itinerary.mode_of_transport

    return (
      <div
        className={`layout-row layout-padding layout-align-space-around-stretch
        ${styles.listelement}`}
        key={v4()}
        onClick={() => handleClick(itinerary)}
        onMouseEnter={() => hoverFn(itinerary.id)}
        onMouseLeave={() => hoverFn(itinerary.id)}
      >
        <div className="layout-row flex-25 layout-align-center-center">
          <div className={`layout-row layout-align-center-center ${styles.routeIcon}`} style={gradientStyle}>
            {switchIcon(modeOfTransport)}
          </div>
        </div>
        <div className="layout-column flex-25 layout-align-center-start">
          <span className="layout-padding">
            {firstStopName}<br />
            {firstStopType}
          </span>
        </div>
        <div className={`layout-row flex-25 layout-align-center-center ${styles.icon}`}>
          <p className={`flex-none ${styles.stop_count}`}>
            {stopCount > 0 ? `+ ${stopCount} stops` : 'direct'}
          </p>
        </div>
        <div className="layout-column flex-25 layout-align-center-start">
          <span className="layout-padding">
            {lastStopName}<br />
            {lastStopType}
          </span>
        </div>
      </div>
    )
  }) : (<span className={`${styles.bottomSpace}`}>No routes available</span>)
}

export class AdminRouteList extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    const {
      itineraries,
      handleClick,
      hoverFn,
      theme
    } = this.props

    return (
      <div className={`layout-column flex-100 layout-align-start-stretch ${styles.container}`}>
        <div className={`layout-padding layout-align-start-center ${styles.greyBg}`}>
          <span><b>Routes</b></span>
        </div>
        <div className={`layout-align-start-stretch ${styles.list}`}>
          {listItineraries(itineraries, handleClick, hoverFn, theme)}
        </div>
      </div>
    )
  }
}

AdminRouteList.propTypes = {
  itineraries: PropTypes.arrayOf(PropTypes.itinerary),
  handleClick: PropTypes.func,
  hoverFn: PropTypes.func,
  theme: PropTypes.theme
}

AdminRouteList.defaultProps = {
  itineraries: [],
  handleClick: null,
  hoverFn: null,
  theme: null
}

export default AdminRouteList
