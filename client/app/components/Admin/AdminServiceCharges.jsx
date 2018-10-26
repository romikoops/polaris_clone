import React, { Component } from 'react'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { AdminHubTile } from './Hubs/AdminHubTile'
import { AdminChargePanel } from './AdminChargePanel'
import FileUploader from '../../components/FileUploader/FileUploader'
import GenericError from '../../components/ErrorHandling/Generic'

export class AdminServiceCharges extends Component {
  constructor (props) {
    super(props)
    this.state = {
      selectedHub: false
    }
    this.selectHub = this.selectHub.bind(this)
    this.deselectHub = this.deselectHub.bind(this)
  }
  selectHub (hub) {
    this.setState({ selectedHub: hub })
  }
  deselectHub () {
    this.setState({ selectedHub: false })
  }
  render () {
    const {
      theme, hubs, charges, adminTools
    } = this.props
    const { selectedHub } = this.state
    let hubList
    if (hubs) {
      hubList = hubs.map(hub => (
        <AdminHubTile key={v4()} hub={hub} theme={theme} handleClick={this.selectHub} />
      ))
    } else {
      hubList = []
    }
    let chargeList = ''
    if (charges && selectedHub) {
      charges.forEach((charge) => {
        if (charge.hub_id === selectedHub.id) {
          chargeList = (
            <AdminChargePanel
              key={selectedHub.id}
              hub={selectedHub}
              theme={theme}
              charge={charge}
              backFn={this.deselectHub}
              adminTools={adminTools}
            />
          )
        }
      })
    }

    const scUrl = '/admin/service_charges/process_csv'
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }

    return (
      <GenericError theme={theme}>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
            <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
              service charges
            </p>
          </div>
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}
          >
            <p className="flex-none">Upload Service Charges Sheet</p>
            <FileUploader theme={theme} url={scUrl} type="xlsx" text="Service Charges .xlsx" />
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            {selectedHub ? chargeList : hubList}
          </div>
        </div>
      </GenericError>
    )
  }
}
AdminServiceCharges.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  charges: PropTypes.arrayOf(PropTypes.charge),
  adminTools: PropTypes.shape({
    updateServiceCharge: PropTypes.func
  }).isRequired
}

AdminServiceCharges.defaultProps = {
  theme: null,
  hubs: [],
  charges: []
}

export default AdminServiceCharges
