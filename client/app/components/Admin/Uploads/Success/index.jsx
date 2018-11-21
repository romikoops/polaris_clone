import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './index.scss'
import { documentGlossary } from '../../../../constants'
import { history } from '../../../../helpers'
import TextHeading from '../../../TextHeading/TextHeading'
import { RoundButton } from '../../../RoundButton/RoundButton'

export class AdminUploadsSuccess extends Component {
  static goBack () {
    history.goBack()
  }
  static prepShipment (baseShipment, clients, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].first_name} ${clients[shipment.user_id].last_name}`
      : ''
    shipment.companyName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].company_name}`
      : ''
    const hubKeys = shipment.schedule_set[0].hub_route_key.split('-')
    shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]].name : ''
    shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]].name : ''
    return shipment
  }

  render () {
    console.log(this.props)
    // const {selectedShipment} = this.state;
    const { theme, data } = this.props
    const { stats, results } = data
    console.log(results)
    const statView = Object.keys(stats)
      .filter(key => key !== 'type' && key !== 'userAffected')
      .map(k => (
        <div className={`${styles.stat_row} flex-100 layout-row layout-align-space-between-center`}>
          <div className="flex-33 layout-row layout-align-start-center">
            <p className="flex-none">
              <strong>{documentGlossary[k]}</strong>
            </p>
          </div>
          <div className="flex-33 layout-row layout-align-start-center">
            <p className="flex-none">{`No. created: ${stats[k].number_created}`}</p>
          </div>
          <div className="flex-33 layout-row layout-align-start-center">
            <p className="flex-none">{`No. updated: ${stats[k].number_updated}`}</p>
          </div>
        </div>
      ))
    return (
      <div
        className={`flex-none layout-row layout-wrap layout-align-center-center ${
          styles.results_backdrop
        }`}
      >
        <div
          className={`flex-none layout-row layout-wrap layout-align-start-start ${
            styles.results_fade
          }`}
          onClick={this.props.closeDialog}
        />
        <div
          className={`flex-none layout-row layout-wrap layout-align-start-start ${
            styles.results_box
          }`}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <TextHeading theme={theme} text="Upload Successful!" size={3} />
          </div>
          <div className="flex-100 layout-row layout-align-start-center layout-wrap">
            {statView}
          </div>
          <div className="flex-100 layout-row layout-align-end-center layout-wrap">
            <RoundButton
              text="Continue"
              theme={theme}
              size="small"
              handleNext={this.props.closeDialog}
              iconClass="fa-chevron-right"
              active
            />
          </div>
        </div>
      </div>
    )
  }
}
AdminUploadsSuccess.propTypes = {
  theme: PropTypes.theme,
  data: PropTypes.objectOf(PropTypes.any),
  closeDialog: PropTypes.func.isRequired
}

AdminUploadsSuccess.defaultProps = {
  theme: null,
  data: {}
}

export default AdminUploadsSuccess
