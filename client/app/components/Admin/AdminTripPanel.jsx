import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from './AdminTripPanel.scss'
import { moment } from '../../constants'
import { AdminLayoverTile } from './'
import { gradientTextGenerator } from '../../helpers'
import AdminPromptConfirm from './Prompt/Confirm'

export class AdminTripPanel extends Component {
  static switchIcon (itinerary) {
    let icon
    switch (itinerary.mode_of_transport) {
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
    this.state = {
      confirm: false
    }
  }
  showPanel () {
    const { trip, toggleShowPanel } = this.props
    toggleShowPanel(trip.trip_id)
  }
  deleteTrip (id) {
    const { adminDispatch } = this.props
    adminDispatch.deleteTrip(id)
    this.closeConfirm()
  }
  confirmDelete () {
    this.setState({
      confirm: true
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }
  doNothing () {
    console.log(this.props)
  }
  render () {
    const {
      t, theme, trip, itinerary, layovers, showPanel
    } = this.props
    const { confirm } = this.state
    if (!trip || !itinerary) {
      return ''
    }
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common:areYouSure')}
        text={t('admin:confirmDeleteSchedule')}
        confirm={() => this.deleteTrip(trip.trip_id)}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const hubNames = itinerary.name.split(' - ')
    // const originHub = hubs[hubKeys[0]].data;
    // const destHub = hubs[hubKeys[1]].data;
    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.brightPrimary, theme.colors.brightSecondary)
        : { color: 'black' }
    const dashedLineStyles = {
      marginTop: '6px',
      height: '2px',
      width: '100%',
      background:
        theme && theme.colors
          ? AdminTripPanel.dashedGradient(theme.colors.primary, theme.colors.secondary)
          : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }
    const startTime = trip.eta ? trip.etd : trip.start_date
    const endTime = trip.etd ? trip.eta : trip.end_date
    const closingDate = layovers[0]
      ? layovers[0].closing_date
      : moment(startTime).subtract(4, 'days')
    const panelStyle = showPanel ? styles.panel_open : ''
    const layoverArray =
      layovers && layovers[trip.trip_id]
        ? layovers[trip.trip_id].map(l => <AdminLayoverTile layoverData={l} theme={theme} />)
        : []

    return (
      <div key={trip.trip_id} className={`flex-100 layout-row layout-wrap ${styles.route_result}`}>
        {confimPrompt}
        <div className="flex-100 layout-row layout-wrap relative">
          <div
            className={`flex-40 layout-row layout-align-start-center ${styles.top_row}`}
            onClick={() => this.showPanel()}
          >
            <div className={`${styles.header_hub}`}>
              <i className={`fa fa-map-marker ${styles.map_marker}`} />
              <div className="flex-100 layout-row">
                <h4 className="flex-100"> {hubNames[0]} </h4>
              </div>
            </div>
            <div
              className={`${
                styles.connection_graphics
              } flex-none layout-column layout-align-center-center`}
            >
              <div className="flex-none layout-row layout-align-center-center">
                {AdminTripPanel.switchIcon(itinerary)}
              </div>
              <div style={dashedLineStyles} />
            </div>
            <div className={`${styles.header_hub}`}>
              <i className={`fa fa-flag-o ${styles.flag}`} />
              <div className="flex-100 layout-row">
                <h4 className="flex-100"> {hubNames[1]} </h4>
              </div>
            </div>
          </div>
          <div className="flex-60 layout-row layout-align-start-center">
            <div
              className="flex-33 layout-wrap layout-row layout-align-center-center"
              onClick={() => this.showPanel()}
            >
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title} style={gradientFontStyle}>
                  {' '}
                  {t('common:closingDate')}
                </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(closingDate).format('YYYY-MM-DD')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(closingDate).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div
              className="flex-33 layout-wrap layout-row layout-align-center-center"
              onClick={() => this.showPanel()}
            >
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title} style={gradientFontStyle}>
                  {' '}
                  {t('admin:dateOfDeparture')}
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
            <div
              className="flex-33 layout-wrap layout-row layout-align-center-center"
              onClick={() => this.showPanel()}
            >
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title} style={gradientFontStyle}>
                  {' '}
                  {t('admin:etaTerminal')}
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
          <div
            className={`${
              styles.delete_btn
            } flex-none layout-row layout-align-center-center pointy`}
            onClick={() => this.confirmDelete()}
          >
            <i className="flex-none fa fa-trash" />
          </div>
        </div>
        <div className={`flex-100 layout-row layout-wrap ${panelStyle} ${styles.layover_panel}`}>
          <div className="flex-100 layout-row layout-align-start-center">
            <h4 className="flex-none clip" style={gradientFontStyle}>
              {t('admin:stops')}
            </h4>
          </div>
          {layoverArray}
        </div>
      </div>
    )
  }
}
AdminTripPanel.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  trip: PropTypes.objectOf(PropTypes.any),
  showPanel: PropTypes.bool,
  itinerary: PropTypes.objectOf(PropTypes.any),
  layovers: PropTypes.arrayOf(PropTypes.any),
  toggleShowPanel: PropTypes.func,
  adminDispatch: PropTypes.objectOf(PropTypes.func)
}
AdminTripPanel.defaultProps = {
  theme: {},
  trip: {},
  showPanel: false,
  itinerary: {},
  layovers: [],
  toggleShowPanel: null,
  adminDispatch: {}
}

export default withNamespaces(['admin', 'common'])(AdminTripPanel)
