import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from '../../../Admin/Admin.scss'
import { AdminSearchableShipments } from '../../../Admin/AdminSearchables'
import { adminDashboard as adminTip } from '../../../../constants'
import { history } from '../../../../helpers'

export class UserShipmentsGroup extends Component {
  static goBack () {
    history.goBack()
  }
  static prepShipment (baseShipment, user, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = user ? `${user.first_name} ${user.last_name}` : ''
    shipment.companyName = user ? `${user.company_name}` : ''
    const hubKeys = shipment.schedule_set[0].hub_route_key.split('-')
    shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]].name : ''
    shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]].name : ''

    return shipment
  }
  constructor (props) {
    super(props)
    this.viewShipment = this.viewShipment.bind(this)
  }
  viewShipment (shipment) {
    const { userDispatch } = this.props
    userDispatch.getShipment(shipment.id, true)
  }

  render () {
    const {
      theme,
      shipments,
      user,
      handleShipmentAction,
      hubHash,
      userDispatch,
      title,
      target,
      t
    } = this.props
    // ;
    if (!shipments || !hubHash || !user) {
      return ''
    }

    if (!shipments || (shipments && !shipments[target])) {
      return ''
    }
    const mergedShipments = shipments[target].map(sh =>
      UserShipmentsGroup.prepShipment(sh, user, hubHash))

    const listView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <AdminSearchableShipments
          handleClick={this.viewShipment}
          hubs={hubHash}
          adminDispatch={userDispatch}
          shipments={mergedShipments}
          title={t('account:titleShipments', { title })}
          theme={theme}
          userView
          handleShipmentAction={handleShipmentAction}
          tooltip={adminTip.requested}
          seeAll={false}
        />

        {mergedShipments.length === 0 ? (
          <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_subheader
              }`}
            >
              <p className={` ${styles.sec_subheader_text} flex-none`}>{t('shipment:noShipments')}</p>
            </div>
            <p className="flex-none">{t('shipment:noShipmentExplaination')}</p>
          </div>
        ) : (
          ''
        )}
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        {listView}
      </div>
    )
  }
}
UserShipmentsGroup.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  title: PropTypes.string,
  target: PropTypes.string,
  shipments: PropTypes.arrayOf(PropTypes.shipment),
  user: PropTypes.clients,
  handleShipmentAction: PropTypes.func.isRequired,
  hubHash: PropTypes.objectOf(PropTypes.hub),
  userDispatch: PropTypes.objectOf(PropTypes.func)
}

UserShipmentsGroup.defaultProps = {
  theme: null,
  shipments: [],
  user: {},
  hubHash: {},
  userDispatch: {},
  title: '',
  target: ''
}

export default withNamespaces('shipment')(UserShipmentsGroup)
