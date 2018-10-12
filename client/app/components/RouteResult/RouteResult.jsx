import React, { Component } from 'react'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './RouteResult.scss'
import { moment } from '../../constants'
import { RoundButton } from '../RoundButton/RoundButton'
import { Price } from '../Price/Price'
import { switchIcon, capitalize } from '../../helpers'

class RouteResult extends Component {
  static returnHubType (hub) {
    let hubType = ''
    switch (hub.hub_type) {
      case 'ocean':
        hubType = 'Port'
        break
      case 'air':
        hubType = 'Airport'
        break
      case 'rail':
        hubType = 'Railyard'
        break
      case 'truck':
        hubType = 'Depot'
        break
      default:
        break
    }

    return hubType
  }
  static dashedGradient (color1, color2) {
    return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`
  }
  constructor (props) {
    super(props)
    this.selectRoute = this.selectRoute.bind(this)
  }
  selectRoute () {
    const { schedule } = this.props
    this.props.selectResult({ schedule, total: schedule.total_price })
  }
  render () {
    const {
      theme, schedule, pickup, truckingTime, t
    } = this.props
    const adjustedTruckingTime = truckingTime + 86400

    const originHub = schedule.origin_hub
    const destinationHub = schedule.destination_hub
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
        <div className="flex-70 layout-row layout-wrap">
          <div className={`flex-100 layout-row layout-align-start-center ${styles.top_row}`}>
            <div className={`flex-80 layout-row layout-align-start-center ${styles.hubs_row}`}>
              <div className={`${styles.header_hub}`}>
                <i className={`fa fa-map-marker ${styles.map_marker}`} />
                <h4 className="flex-100"> {originHub.name} </h4>
                {originHub.hub_code ? (
                  <div className="flex-100">
                    <p className="flex-100"> {originHub.hub_code}</p>
                  </div>
                ) : (
                  ''
                )}
              </div>
              <div className={`${styles.connection_graphics} flex`}>
                <div className="flex-none layout-row layout-align-center-center">
                  {switchIcon(schedule.mode_of_transport)}
                </div>
                <div style={dashedLineStyles} />
              </div>
              <div className={`${styles.header_hub}`}>
                <i className={`fa fa-flag-o ${styles.flag}`} />
                <h4 className="flex-100"> {destinationHub.name} </h4>
                <div className="flex-100">
                  <p className="flex-100"> {destinationHub.hub_code ? destinationHub.hub_code : ''} </p>
                </div>
              </div>
            </div>
            <div className={`flex-20 layout-row layout-wrap layout-align-start-center ${styles.carrier_service_level}`}>
              { schedule.carrier_name ? <div className="flex-100 layout-row layout-align-center-center">
                <i className="flex-10 fa fa-ship" />
                <p className="flex-90 no_m">{schedule.carrier_name}</p>
              </div> : '' }
              { schedule.vehicle_name ? <div className="flex-100 layout-row layout-align-center-center">
                <i className="flex-10 fa fa-bell-o" />
                <p className="flex-90 no_m">{capitalize(schedule.vehicle_name)}</p>
              </div> : '' }
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-start-center">
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}>{pickup ? t('common:pickupDate') : t('common:closingDate')}</h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {pickup
                    ? moment(schedule.closing_date).subtract(adjustedTruckingTime, 'seconds').format('DD-MM-YYYY')
                    : moment(schedule.closing_date).format('DD-MM-YYYY')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}>{`${t('common:etd')} ${RouteResult.returnHubType(originHub)}`}</h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(schedule.etd).format('DD-MM-YYYY')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}>{`${t('common:eta')} ${RouteResult.returnHubType(destinationHub)} `}</h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(schedule.eta).format('DD-MM-YYYY')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}>{t('shipment:estimatedTransitTime')}<sup>*</sup></h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(schedule.eta).diff(schedule.etd, t('common:days'))}
                  {t('common:days')}
                </p>
              </div>
            </div>
          </div>
        </div>
        <div className="flex-30 layout-row layout-wrap layout-align-center">
          <div className="flex-90 layout-row layout-align-space-between-center layout-wrap">
            <p className="flex-none">{t('shipment:totalPrice')}</p>
            <Price
              value={schedule.total_price.value}
              currency={schedule.total_price.currency}
            />
          </div>
          <div className="flex-90 layout-row layout-align-space-between-center layout-wrap">
            <RoundButton
              text={t('common:choose')}
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
  t: PropTypes.func.isRequired,
  schedule: PropTypes.schedule.isRequired,
  selectResult: PropTypes.func.isRequired,
  pickup: PropTypes.bool,
  truckingTime: PropTypes.number
}
RouteResult.defaultProps = {
  theme: null,
  pickup: false,
  truckingTime: 0
}

export default translate(['common', 'shipment'])(RouteResult)
