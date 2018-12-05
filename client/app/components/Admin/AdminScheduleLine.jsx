import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './AdminScheduleLine.scss'
import { moment } from '../../constants'

export class AdminScheduleLine extends Component {
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
  render () {
    const {
      t, theme, schedule, hubs
    } = this.props
    if (!schedule || !schedule.hub_route_key) {
      return ''
    }
    const hubKeys = schedule.hub_route_key.split('-')
    if (!hubs[hubKeys[0]] || !hubs[hubKeys[1]]) {
      // ;
      return ''
    }
    const originHub = hubs[hubKeys[0]].data
    const destHub = hubs[hubKeys[1]].data
    const gradientFontStyle = {
      background:
                theme && theme.colors
                  ? `-webkit-linear-gradient(left, ${
                    theme.colors.brightPrimary
                  }, ${theme.colors.brightSecondary})`
                  : 'black'
    }
    const dashedLineStyles = {
      marginTop: '6px',
      height: '2px',
      width: '100%',
      background:
                theme && theme.colors
                  ? AdminScheduleLine.dashedGradient(
                    theme.colors.primary,
                    theme.colors.secondary
                  )
                  : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }

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
            <div className={`${styles.header_hub}`}>
              <i
                className={`fa fa-map-marker ${
                  styles.map_marker
                }`}
              />
              <div className="flex-100 layout-row">
                <h4 className="flex-100"> {originHub.name} </h4>
              </div>
              <div className="flex-100">
                <p className="flex-100">
                  {' '}
                  {originHub.hub_code
                    ? originHub.hub_code
                    : ''}{' '}
                </p>
              </div>
            </div>
            <div className={`${styles.connection_graphics}`}>
              <div className="flex-none layout-row layout-align-center-center">
                {AdminScheduleLine.switchIcon(schedule)}
              </div>
              <div style={dashedLineStyles} />
            </div>
            <div className={`${styles.header_hub}`}>
              <i className={`fa fa-flag-o ${styles.flag}`} />
              <div className="flex-100 layout-row">
                <h4 className="flex-100"> {destHub.name} </h4>
              </div>
              <div className="flex-100">
                <p className="flex-100">
                  {' '}
                  {destHub.hub_code
                    ? destHub.hub_code
                    : ''}{' '}
                </p>
              </div>
            </div>
          </div>
          <div className="flex-60 layout-row layout-align-start-center">
            <div className="flex-33 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4
                  className={styles.date_title}
                  style={gradientFontStyle}
                >
                  {t('common:pickupDate')}
                </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(this.props.pickupDate).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(this.props.pickupDate).format('HH:mm')}{' '}
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
                  {t('admin:dateOfDeparture')}
                </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(schedule.eta).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(schedule.eta).format('HH:mm')}{' '}
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
                  {t('admin:etaTerminal')}
                </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(schedule.eta).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(schedule.eta).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
AdminScheduleLine.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  schedule: PropTypes.objectOf(PropTypes.any),
  hubs: PropTypes.arrayOf(PropTypes.hub),
  pickupDate: PropTypes.number
}

AdminScheduleLine.defaultProps = {
  theme: null,
  hubs: [],
  schedule: {},
  pickupDate: null
}

export default withNamespaces(['admin', 'shipment', 'common'])(AdminScheduleLine)
