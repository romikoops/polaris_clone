import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from '../../Admin.scss'
import { AdminSearchableShipments } from '../../AdminSearchables'
import { adminDashboard as adminTip } from '../../../../constants'
import { history } from '../../../../helpers'
import { RoundButton } from '../../../RoundButton/RoundButton'

export class AdminShipmentsGroup extends Component {
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
  constructor (props) {
    super(props)
    this.viewShipment = this.viewShipment.bind(this)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }
  viewShipment (shipment) {
    this.props.viewShipment(shipment)
  }

  render () {
    console.log(this.props)
    // const {selectedShipment} = this.state;
    const {
      t,
      theme,
      hubs,
      shipments,
      clients,
      handleShipmentAction,
      hubHash,
      adminDispatch,
      title,
      target
    } = this.props
    // ;
    if (!shipments || !hubs || !clients) {
      return ''
    }
    const clientHash = {}
    clients.forEach((cl) => {
      clientHash[cl.id] = cl
    })
    if (!shipments || (shipments && !shipments[target])) {
      return ''
    }
    const mergedShipments = shipments[target].map(sh =>
      AdminShipmentsGroup.prepShipment(sh, clientHash, hubHash))

    const listView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <AdminSearchableShipments
          handleClick={this.viewShipment}
          hubs={hubHash}
          adminDispatch={adminDispatch}
          shipments={mergedShipments}
          title={`${title} Shipments`}
          theme={theme}
          handleShipmentAction={handleShipmentAction}
          tooltip={adminTip.requested}
          seeAll={false}
        />

        {mergedShipments.length === 0 ? (
          <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
            <div className="flex-100 layout-row layout-align-end-center">
              <div className="flex-none layout-row">
                <RoundButton
                  theme={theme}
                  size="small"
                  text={t('common:basicBack')}
                  handleNext={() => AdminShipmentsGroup.goBack()}
                  iconClass="fa-chevron-left"
                />
              </div>
            </div>
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_subheader
              }`}
            >
              <p className={` ${styles.sec_subheader_text} flex-none`}>{t('admin:waitingShipments')}</p>
            </div>
            <p className="flex-none">{t('admin:shipmentsAreRequested')}</p>
          </div>
        ) : (
          ''
        )}
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">{listView}</div>
    )
  }
}
AdminShipmentsGroup.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  title: PropTypes.string,
  target: PropTypes.string,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  shipments: PropTypes.arrayOf(PropTypes.shipment),
  clients: PropTypes.arrayOf(PropTypes.clients),
  handleShipmentAction: PropTypes.func.isRequired,
  viewShipment: PropTypes.func.isRequired,
  hubHash: PropTypes.objectOf(PropTypes.hub),
  adminDispatch: PropTypes.objectOf(PropTypes.func)
}

AdminShipmentsGroup.defaultProps = {
  theme: null,
  hubs: [],
  shipments: [],
  clients: [],
  hubHash: {},
  adminDispatch: {},
  title: '',
  target: ''
}

export default withNamespaces(['admin', 'common'])(AdminShipmentsGroup)
