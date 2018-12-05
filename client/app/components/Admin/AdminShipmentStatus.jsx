import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from './AdminShipmentStatus.scss'

export class AdminShipmentStatus extends Component {
  constructor (props) {
    super(props)
    this.state = {
      shipments: props.shipments
    }
  }

  render () {
    return (
      <div className="layout-column flex-100 layout-wrap layout-align-start-stretch">
        <div className="layout-column flex-20 layout-wrap layout-align-start-center">
          <span className={`${styles.title}`}>{this.props.t('admin:shipmentStatus')}</span>
          <span className={`${styles.subtitle}`}>{this.props.t('admin:thisMonth')}</span>
        </div>
        <div className="layout-row flex-80 layout-wrap layout-align-center-center">
          <div className="layout-column flex-33 layout-wrap layout-align-center-center">
            <span className={`${styles.amount}`}>
              {this.state.shipments.finished ? this.state.shipments.finished.length : 0}
            </span><br />
            <span className={`${styles.amounttitle}`}>{this.props.t('account:shipments')}</span>
          </div>
          <div className="layout-column flex-33 layout-wrap layout-align-center-center">
            <span className={`${styles.amount}`}>
              {this.state.shipments.open ? this.state.shipments.open.length : 0}
            </span><br />
            <span className={`${styles.amounttitle}`}>{this.props.t('admin:active')}</span>
          </div>
          <div className="layout-column flex-33 layout-wrap layout-align-center-center">
            <span className={`${styles.amount}`}>
              {this.state.shipments.requested ? this.state.shipments.requested.length : 0}
            </span><br />
            <span className={`${styles.amounttitle}`}>{this.props.t('shipment:requested')}</span>
          </div>
          <div className="layout-column flex-33 layout-wrap layout-align-center-center">
            <span className={`${styles.amount}`}>
              {this.state.shipments.rejected ? this.state.shipments.rejected.length : 0}
            </span><br />
            <span className={`${styles.amounttitle}`}>{this.props.t('shipment:rejected')}</span>
          </div>
          <div className="layout-column flex-33 layout-wrap layout-align-center-center">
            <span className={`${styles.amount}`}>
              {this.state.shipments.archived ? this.state.shipments.archived.length : 0}
            </span><br />
            <span className={`${styles.amounttitle}`}>{this.props.t('shipment:archived')}</span>
          </div>
        </div>
      </div>
    )
  }
}

AdminShipmentStatus.propTypes = {
  t: PropTypes.func.isRequired,
  shipments: PropTypes.shape({
    open: PropTypes.arrayOf(PropTypes.shipment),
    requested: PropTypes.arrayOf(PropTypes.shipment),
    finished: PropTypes.arrayOf(PropTypes.shipment),
    archived: PropTypes.arrayOf(PropTypes.shipment),
    rejected: PropTypes.arrayOf(PropTypes.shipment)
  })
}

AdminShipmentStatus.defaultProps = {
  shipments: {}
}

export default withNamespaces(['admin', 'account', 'shipment'])(AdminShipmentStatus)
