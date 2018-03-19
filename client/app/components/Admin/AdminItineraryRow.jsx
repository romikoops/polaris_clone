import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { v4 } from 'node-uuid'
import styles from './Admin.scss'
import { gradientTextGenerator, capitalize } from '../../helpers'
import AdminPromptConfirm from './Prompt/Confirm'

export default class AdminItineraryRow extends Component {
  constructor (props) {
    super(props)
    this.state = {
      confirm: false
    }
    this.selectItinerary = this.selectItinerary.bind(this)
  }
  switchIcon (itinerary) {
    const { theme } = this.props
    const iconStyle = gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    let icon
    switch (itinerary.mode_of_transport) {
      case 'ocean':
        icon = <i style={iconStyle} className={`clip fa fa-ship ${styles.icon_buffer}`} />
        break
      case 'air':
        icon = <i style={iconStyle} className={`clip fa fa-plane ${styles.icon_buffer}`} />
        break
      case 'train':
        icon = <i style={iconStyle} className={`clip fa fa-train ${styles.icon_buffer}`} />
        break
      default:
        icon = <i style={iconStyle} className={`clip fa fa-ship ${styles.icon_buffer}`} />
        break
    }
    return icon
  }
  selectItinerary () {
    const { itinerary, handleClick } = this.props
    handleClick(itinerary)
  }
  deleteItinerary (id) {
    const { adminDispatch } = this.props
    adminDispatch.deleteItinerary(id)
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

  render () {
    const { confirm } = this.state
    const { itinerary, theme } = this.props
    const iconStyle = gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading="Are you sure?"
        text="This will delete the route and all related data (pricings, schedules etc)"
        confirm={() => this.deleteItinerary(itinerary.id)}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    return (
      <div
        key={v4()}
        className={`flex-100 layout-row layout-align-space-between-center pointy ${
          styles.itinerary_row
        }`}
      >
        {confimPrompt}
        <div className="flex-none layout-row layout-align-start-center">
          <i style={iconStyle} className={`clip fa fa-flag ${styles.icon_buffer}`} />
          <div className="flex-5" />
          <p className="flex-none">{itinerary.name}</p>
        </div>
        <div className="flex-none layout-row layout-align-end-center">
          <div className="flex-none layout-row layout-align-center-center">
            {this.switchIcon(itinerary)}
            <p className="flex-none">
              {itinerary.mode_of_transport ? capitalize(itinerary.mode_of_transport) : ''}
            </p>
          </div>
          <div
            className={`${styles.icon_btn_view} flex-none layout-row layout-align-center-center`}
            onClick={() => this.selectItinerary()}
          >
            <i className="fa fa-eye flex-none" />
          </div>
          <div
            className={`${styles.icon_btn_delete} flex-none layout-row layout-align-center-center`}
            onClick={() => this.confirmDelete()}
          >
            <i className="fa fa-times flex-none" />
          </div>
        </div>
      </div>
    )
  }
}
AdminItineraryRow.propTypes = {
  theme: PropTypes.theme.isRequired,
  handleClick: PropTypes.func.isRequired,
  itinerary: PropTypes.objectOf(PropTypes.any).isRequired
}

AdminItineraryRow.defaultPropTypes = {}
