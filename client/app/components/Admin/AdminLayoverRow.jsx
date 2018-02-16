import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './AdminScheduleLine.scss'
import { moment } from '../../constants'

export class AdminLayoverRow extends Component {
  constructor (props) {
    super(props)
  }
  switchIcon (sched) {
    let icon
    switch (sched.mode_of_transport) {
      case 'ocean':
        icon = <i className="fa fa-ship" />
        break
      case 'air':
        icon = <i className="fa fa-plane" />
        break
      case 'train':
        icon = <i className="fa fa-train" />
        break
      default:
        icon = <i className="fa fa-ship" />
        break
    }
    return icon
  }

  dashedGradient (color1, color2) {
    return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${
      color1
    }, ${color2})`
  }
  render () {
    const {
      theme, schedule, hub, itinerary
    } = this.props
    if (!schedule || !hub) {
      return ''
    }
    const gradientFontStyle = {
      background:
                theme && theme.colors
                  ? `-webkit-linear-gradient(left, ${
                    theme.colors.brightPrimary
                  }, ${theme.colors.brightSecondary})`
                  : 'black'
    }
    const startTime = schedule.eta ? schedule.eta : schedule.start_date
    const endTime = schedule.etd ? schedule.etd : schedule.end_date
    return (
      <div
        key={schedule.id}
        className={`flex-100 layout-row ${styles.route_result}`}
      >
        <div className="flex-100 layout-row layout-wrap">
          <div
            className={`flex-40 layout-row layout-align-start-center ${
              styles.top_row
            }`}
          >
            <div className="flex-20 layout-row layout-align-center-center">
              {this.switchIcon(schedule)}
            </div>
            <div className={`flex-80 ${styles.header_hub}`}>
              <div className="flex-100 layout-row">
                <h4 className="flex-100"> {itinerary.name} </h4>
              </div>
              <div className="flex-100">
                <p className="flex-100">
                  {' '}
                  {hub.hub_code
                    ? hub.hub_code
                    : ''}{' '}
                </p>
              </div>
            </div>
          </div>
          <div className="flex-60 layout-row layout-align-start-center">
            <div className="flex-33 layout-wrap layout-row layout-align-center-center" />
            <div className="flex-33 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4
                  className={styles.date_title}
                  style={gradientFontStyle}
                >
                  {' '}
                                    Date of Arrival
                </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(startTime).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(startTime).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-33 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4
                  className={styles.date_title}
                  style={gradientFontStyle}
                >
                  {' '}
                                    Date of Departure
                </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(endTime).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(endTime).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
AdminLayoverRow.propTypes = {
  theme: PropTypes.object,
  schedule: PropTypes.object,
  selectResult: PropTypes.func,
  hubs: PropTypes.object
}
