import React, { Component } from 'react'
// import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
// import { UserShipmentRow } from './'
import adminStyles from '../Admin/Admin.scss'
import { adminDashboard as adminTip } from '../../constants'
import { AdminSearchableShipments } from '../Admin/AdminSearchables'
import Tab from '../Tabs/Tab'
import Tabs from '../Tabs/Tabs'

export class UserShipments extends Component {
  static prepShipment (baseShipment, user, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = user
      ? `${user.first_name} ${user.last_name}`
      : ''
    shipment.companyName = user
      ? `${user.company_name}`
      : ''

    return shipment
  }

  componentDidMount () {
    window.scrollTo(0, 0)
    this.props.setNav('shipments')
  }

  render () {
    const {
      theme,
      user,
      shipments,
      userDispatch
    } = this.props
    if (!shipments) {
      return ''
    }
    const mergedOpenShipments = shipments.open.map(sh =>
      UserShipments.prepShipment(sh, user))
    const mergedReqShipments = shipments.requested.map(sh =>
      UserShipments.prepShipment(sh, user))
    const mergedFinishedShipments = shipments.finished.map(sh =>
      UserShipments.prepShipment(sh, user))

    const listView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start padding_top">
        <Tabs>
          <Tab
            tabTitle="Requested"
            theme={theme}
          >
            <AdminSearchableShipments
              handleClick={this.viewShipment}
              dispatches={userDispatch}
              shipments={mergedReqShipments}
              title="Requested Shipments"
              theme={theme}
              userView
              tooltip={adminTip.requested}
              seeAll={false}
            />
          </Tab>
          <Tab
            tabTitle="Open"
            theme={theme}
          >
            <AdminSearchableShipments
              handleClick={this.viewShipment}
              dispatches={userDispatch}
              shipments={mergedOpenShipments}
              title="Open Shipments"
              theme={theme}
              userView
              tooltip={adminTip.open}
              seeAll={false}
            />
          </Tab>
          <Tab
            tabTitle="Finished"
            theme={theme}
          >
            <AdminSearchableShipments
              handleClick={this.viewShipment}
              dispatches={userDispatch}
              shipments={mergedFinishedShipments}
              title="Finished Shipments"
              theme={theme}
              userView
              tooltip={adminTip.finished}
              seeAll={false}
            />
          </Tab>
        </Tabs>

        {mergedOpenShipments.length === 0 &&
          mergedReqShipments.length === 0 &&
          mergedFinishedShipments.length === 0 ? (
            <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-start">
              <div
                className={`flex-100 layout-row layout-align-space-between-center ${
                  adminStyles.sec_subheader
                }`}
              >
                <p className={` ${adminStyles.sec_subheader_text} flex-none`}> No Shipments yet</p>
              </div>
              <p className="flex-none"> As shipments are requested, they will appear here</p>
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

UserShipments.propTypes = {
  setNav: PropTypes.func.isRequired,
  userDispatch: PropTypes.shape({
    getShipment: PropTypes.func
  }).isRequired,
  theme: PropTypes.theme,
  user: PropTypes.user,
  shipments: PropTypes.shipments.isRequired
}

UserShipments.defaultProps = {
  theme: null,
  user: null
}

export default UserShipments
