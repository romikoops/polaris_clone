import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import styles from './RouteResult.scss'
import { moment } from '../../constants'
import { RoundButton } from '../RoundButton/RoundButton'
import { Price } from '../Price/Price'

export class RouteResult extends Component {
  static switchIcon (sched) {
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
  static dashedGradient (color1, color2) {
    return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`
  }
  constructor (props) {
    super(props)
    this.selectRoute = this.selectRoute.bind(this)
  }
  selectRoute () {
    const { schedule, fees } = this.props
    const schedKey = schedule.hub_route_key
    const totalFees = fees[schedKey].total
    this.props.selectResult({ schedule, total: totalFees })
  }
  render () {
    const {
      theme, schedule, user, pickup
    } = this.props
    const schedKey = schedule.hub_route_key
    const hubKeyArr = schedKey.split('-')
    let originHub = {}
    let destHub = {}
    if (this.props.originHubs) {
      this.props.originHubs.forEach((hub) => {
        if (String(hub.id) === hubKeyArr[0]) {
          originHub = hub
        }
      })
      this.props.destinationHubs.forEach((hub) => {
        if (String(hub.id) === hubKeyArr[1]) {
          destHub = hub
        }
      })
    }
    // const gradientFontStyle = {
    //     background:
    //         theme && theme.colors
    //             ? `-webkit-linear-gradient(left, ${
    //                 theme.colors.brightPrimary
    //             }, ${theme.colors.brightSecondary})`
    //             : 'black'
    // };
    const dashedLineStyles = {
      marginTop: '6px',
      height: '2px',
      width: '100%',
      background:
        theme && theme.colors
          ? RouteResult.dashedGradient(theme.colors.primary, theme.colors.secondary)
          : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }
    return (
      <div key={schedule.id} className={`flex-100 layout-row ${styles.route_result}`}>
        <div className="flex-75 layout-row layout-wrap">
          <div className={`flex-100 layout-row layout-align-start-center ${styles.top_row}`}>
            <div className={`flex-80 layout-row layout-align-start-center ${styles.hubs_row}`}>
              <div className={`${styles.header_hub}`}>
                <i className={`fa fa-map-marker ${styles.map_marker}`} />
                <div className="flex-100 layout-row">
                  <h4 className="flex-100"> {originHub.name} </h4>
                </div>
                {originHub.hub_code ? (
                  <div className="flex-100">
                    <p className="flex-100"> {originHub.hub_code}</p>
                  </div>
                ) : (
                  ''
                )}
              </div>
              <div className={`${styles.connection_graphics}`}>
                <div className="flex-none layout-row layout-align-center-center">
                  {RouteResult.switchIcon(schedule)}
                </div>
                <div style={dashedLineStyles} />
              </div>
              <div className={`${styles.header_hub}`}>
                <i className={`fa fa-flag-o ${styles.flag}`} />
                <div className="flex-100 layout-row">
                  <h4 className="flex-100"> {destHub.name} </h4>
                </div>
                <div className="flex-100">
                  <p className="flex-100"> {destHub.hub_code ? destHub.hub_code : ''} </p>
                </div>
              </div>
            </div>
            <div className={`flex-20 layout-row layout-align-start-center ${styles.load_type}`}>
              {/* <p className="flex-none no_m">{loadType}</p> */}
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-start-center">
            <div className="flex-33 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}>{pickup ? 'Pickup Date' : 'Closing Date'}</h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(this.props.pickupDate).format('DD-MM-YYYY')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(this.props.pickupDate).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-33 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}> Date of Departure</h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(schedule.etd).format('DD-MM-YYYY')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(schedule.etd).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-33 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}> ETA terminal</h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(schedule.eta).format('DD-MM-YYYY')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(schedule.eta).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
          </div>
        </div>
        <div className="flex-25 layout-row layout-wrap">
          <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
            <p className="flex-none">Total price: </p>
            <Price value={this.props.fees[schedKey].total} user={user} />
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
            <RoundButton
              text="Choose"
              size="full"
              handleNext={this.selectRoute}
              theme={theme}
              active
            />
          </div>
        </div>
      </div>
    )
  }
}
RouteResult.propTypes = {
  theme: PropTypes.theme,
  schedule: PropTypes.schedule.isRequired,
  selectResult: PropTypes.func.isRequired,
  pickupDate: PropTypes.string.isRequired,
  fees: PropTypes.objectOf(PropTypes.shape({
    total: PropTypes.any
  })).isRequired,
  originHubs: PropTypes.arrayOf(PropTypes.hub),
  destinationHubs: PropTypes.arrayOf(PropTypes.hub),
  user: PropTypes.user.isRequired,
  pickup: PropTypes.bool
}
RouteResult.defaultProps = {
  theme: null,
  pickup: false,
  originHubs: [],
  destinationHubs: []
}

export default RouteResult
