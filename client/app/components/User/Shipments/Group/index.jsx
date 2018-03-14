import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from '../../../Admin/Admin.scss'
import { AdminSearchableShipments } from '../../../Admin/AdminSearchables'
import { adminDashboard as adminTip } from '../../../../constants'
import { history } from '../../../../helpers'
import { RoundButton } from '../../../RoundButton/RoundButton'

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
    console.log(this.props)
    // const {selectedShipment} = this.state;
    const {
      theme,
      shipments,
      user,
      handleShipmentAction,
      hubHash,
      userDispatch,
      title,
      target
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
          title={`${title} Shipments`}
          theme={theme}
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
              <p className={` ${styles.sec_subheader_text} flex-none`}> No Shipments yet</p>
            </div>
            <p className="flex-none"> As shipments are requested, they will appear here</p>
          </div>
        ) : (
          ''
        )}
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-end-center">
          <div className="flex-none layout-row">
            <RoundButton
              theme={theme}
              size="small"
              text="Back"
              handleNext={() => UserShipmentsGroup.goBack()}
              iconClass="fa-chevron-left"
            />
          </div>
        </div>
        {listView}
      </div>
    )
  }
}
UserShipmentsGroup.propTypes = {
  theme: PropTypes.theme,
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

export default UserShipmentsGroup
