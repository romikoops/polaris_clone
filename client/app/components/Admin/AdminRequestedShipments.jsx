import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from './AdminRequestedShipments.scss'

export class AdminRequestedShipments extends Component {
  constructor (props) {
    super(props)
    this.showShipments = this.showShipments.bind(this)
    this.state = {
      requested: this.props.requested
    }
  }

  showShipments () {
    return this.state.requested.map(r => (
      <div className={`layout-row layout-wrap layout-align-center-stretch ${styles.shipmentinfo}`}>
        <div className="layout-column flex-25 layout-wrap">
          <div className="layout-row flex-50 layout-wrap layout-align-space-around-center">
            <span className="layout-row flex-25 layout-wrap layout-align-center-center">I</span>
            <span className="layout-row flex-75 layout-wrap layout-align-center-center">{this.props.t('admin:name')}</span>
          </div>
          <div className="layout-row flex-50 layout-wrap layout-align-space-around-center">
            <span className="layout-row flex-25 layout-wrap layout-align-center-center">I</span>
            <span className="layout-row flex-75 layout-wrap layout-align-center-center">{this.props.t('admin:comp')}</span>
          </div>
        </div>
        <div className="layout-row flex-25 layout-wrap layout-align-center-center">
          <span>{this.props.t('admin:icon')}</span>
        </div>
        <div className="layout-column flex-25 layout-wrap layout-align-space-around-center">
          <span>{this.props.t('common:from')}</span>
          <span>{this.props.t('common:to')}</span>
        </div>
        <div className="layout-column flex-25 layout-wrap layout-align-space-around-center">
          <span>{this.props.t('admin:amount')}</span>
          <span>{this.props.t('doc:type')}</span>
        </div>
      </div>
    ))
  }

  render () {
    return (
      <div className="layout-column flex-100 layout-align-space-start-center">
        <div className="layout-row flex-10 layout-wrap layout-align-space-start-start">
          <span className={`${styles.title}`}>{this.props.t('admin:pendingBookings')}</span>
        </div>
        <div className="layout-column layout-align-space-start-center">
          <div className={`layout-align-start-stretch ${styles.shipments}`}>
            {this.showShipments()}
          </div>
        </div>
      </div>
    )
  }
}

AdminRequestedShipments.propTypes = {
  t: PropTypes.func.isRequired,
  requested: PropTypes.node
}

AdminRequestedShipments.defaultProps = {
  requested: ['']
}

export default withNamespaces(['admin', 'common', 'doc'])(AdminRequestedShipments)
