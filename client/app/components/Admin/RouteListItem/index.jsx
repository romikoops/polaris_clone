import React from 'react'
import uuid from 'uuid'
import styles from './AdminRouteListItem.scss'
import { switchIcon, gradientTextGenerator } from '../../../helpers'

function AdminRouteListItem ({
  theme, route, clickable, onClick, onMouseEnter, onMouseLeave
}) {
  const gradientStyle =
    theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { background: '#E0E0E0' }

  // TODO: Once api response is updated, remove legacy logic regarding itinerary data model
  //       (ex: first/last stops, spliting hub name etc...)

  const firstStopArray = route.stops[0].hub.name.split(' ')
  const firstStopType = firstStopArray.splice(-1)
  const firstStopName = firstStopArray.join(' ')
  const lastStopArray = route.stops[route.stops.length - 1].hub.name.split(' ')
  const lastStopType = lastStopArray.splice(-1)
  const lastStopName = lastStopArray.join(' ')
  const stopCount = route.stops.length - 2
  const modeOfTransport = route.mode_of_transport

  return (
    <div
      className={`
        layout-row layout-padding layout-align-space-around-stretch
        ${styles.list_item} ${clickable ? styles.clickable : ''}
      `}
      key={uuid.v4()}
      onClick={clickable ? onClick : null}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
    >
      <div className="layout-row flex-10 layout-align-center-center">
        <div className={`layout-row layout-align-center-center ${styles.route_icon}`}>
          {switchIcon(modeOfTransport, gradientStyle)}
        </div>
      </div>
      <div className="layout-column flex-30 layout-align-center-start">
        <span className="layout-padding">
          {firstStopName}<br />
          <p>{firstStopType}</p>
        </span>
      </div>
      <div className={`layout-row flex-10 layout-align-center-center ${styles.icon}`}>
        <b className={`flex-none ${styles.stop_count}`}>
          {stopCount > 0 ? `+ ${stopCount} stops` : (
            <div>
              <i className="fa fa-chevron-right clip" style={gradientStyle} />
              <i className="fa fa-chevron-right clip" style={gradientStyle} />
            </div>
          )}
        </b>
      </div>
      <div className="layout-column flex-40 layout-align-center-start">
        <span className="layout-padding">
          {lastStopName}<br />
          <p>{lastStopType}</p>
        </span>
      </div>
    </div>
  )
}

AdminRouteListItem.defaultProps = {
  theme: null,
  clickable: true,
  onClick: null,
  onMouseEnter: null,
  onMouseLeave: null
}

export default AdminRouteListItem
