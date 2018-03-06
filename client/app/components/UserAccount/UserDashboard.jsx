import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import ustyles from './UserAccount.scss'
import defaults from '../../styles/default_classes.scss'
import { UserLocations } from './'
import { RoundButton } from '../RoundButton/RoundButton'
import { Carousel } from '../Carousel/Carousel'
import { activeRoutesData } from '../../constants'
import { AdminSearchableClients } from '../Admin/AdminSearchables'
import { TextHeading } from '../TextHeading/TextHeading'
import { UserMergedShipment } from './UserMergedShipment'
import { UserMergedShipHeaders } from './UserMergedShipHeaders'

export class UserDashboard extends Component {
  static prepShipment (baseShipment, user, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = user ? `${user.first_name} ${user.last_name}` : ''
    shipment.companyName = user ? `${user.company_name}` : ''
    const hubKeys = shipment.schedule_set[0].hub_route_key.split('-')
    shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]].data.name : ''
    shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]].data.name : ''
    return shipment
  }

  static limitArray (shipments, limit) {
    return limit ? shipments.slice(0, limit) : shipments
  }
  constructor (props) {
    super(props)
    this.state = {}
    this.viewShipment = this.viewShipment.bind(this)
    this.viewClient = this.viewClient.bind(this)
    this.makePrimary = this.makePrimary.bind(this)
    this.startBooking = this.startBooking.bind(this)
    this.seeAll = this.seeAll.bind(this)
  }
  componentDidMount () {
    this.props.setNav('dashboard')
    window.scrollTo(0, 0)
  }
  viewShipment (shipment) {
    const { userDispatch } = this.props
    userDispatch.getShipment(shipment.id, true)
  }
  viewClient (client) {
    const { userDispatch } = this.props
    userDispatch.getContact(client.id, true)
  }
  startBooking () {
    this.props.userDispatch.goTo('/booking')
  }
  makePrimary (locationId) {
    const { userDispatch, user } = this.props
    userDispatch.makePrimary(user.id, locationId)
  }
  // handleReqClick() {
  //     this.seeAll('account/shipments');
  // }
  // handleOpClick() {
  //    this.seeAll('account/shipments');
  // }
  seeAll () {
    const { userDispatch, seeAll } = this.props
    if (seeAll) {
      this.seeAll()
    } else {
      userDispatch.goTo('/account/shipments')
    }
  }
  render () {
    const {
      theme, hubs, dashboard, user, userDispatch, seeAll
    } = this.props
    if (!user || !dashboard) {
      return <h1>NO DATA</h1>
    }
    const { shipments, contacts, locations } = dashboard
    const mergedOpenShipments =
      shipments && shipments.open
        ? shipments.open.map(sh => UserDashboard.prepShipment(sh, user, hubs))
        : false
    const mergedRequestedShipments =
      shipments && shipments.requested
        ? shipments.requested.map(sh => UserDashboard.prepShipment(sh, user, hubs))
        : false
    const mergedFinishedShipments =
      shipments && shipments.finished
        ? shipments.finished.map(sh => UserDashboard.prepShipment(sh, user, hubs))
        : false
    const newReqShips =
      mergedRequestedShipments.length > 0 ? (
        UserDashboard.limitArray(mergedRequestedShipments, 3).map(ship => (
          <UserMergedShipment key={v4()} ship={ship} viewShipment={this.viewShipment} />
        ))
      ) : (
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none"> No Shipments requested.</p>
        </div>
      )
    const newOpenShips =
      mergedOpenShipments.length > 0 ? (
        UserDashboard.limitArray(mergedOpenShipments, 3).map(ship => (
          <UserMergedShipment key={v4()} ship={ship} viewShipment={this.viewShipment} />
        ))
      ) : (
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none"> No Shipments in process.</p>
        </div>
      )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-center">
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-start ${
            ustyles.dashboard_main
          }`}
        >
          <div
            className={`flex-100 layout-row layout-wrap layout-align-start-start ${
              ustyles.dashboard_top
            }`}
          >
            <div className={`flex-100 layout-row ${ustyles.left} layout-align-center-center`}>
              <div className={`flex-100 layout-row layout-align-start-center ${ustyles.welcome}`}>
                <h2 className="flex-none">Welcome back, {user.first_name}</h2>
              </div>
              <div
                className={`flex-none layout-row layout-align-center-center ${ustyles.carousel}`}
              >
                <Carousel theme={this.props.theme} slides={activeRoutesData} noSlides={1} fade />
              </div>
              <div
                className={`flex-none layout-row layout-align-center-center ${ustyles.dash_btn}`}
              >
                <RoundButton
                  theme={theme}
                  handleNext={this.startBooking}
                  active
                  size="large"
                  text="Make a Booking"
                  iconClass="fa-archive"
                />
              </div>
              <div
                className={`flex-50 layout-row ${
                  ustyles.right
                } layout-wrap layout-align-space-between-space-between`}
              >
                <div
                  className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}
                >
                  <h1 className="flex-none">
                    {mergedOpenShipments.length +
                      mergedFinishedShipments.length +
                      mergedRequestedShipments.length}
                  </h1>
                  <div
                    className={`flex-none layout-row layout-align-center-center ${
                      ustyles.stat_box_title
                    }`}
                  >
                    <h3 className="flex-none">Total Shipments</h3>
                  </div>
                </div>
                <div
                  className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}
                >
                  <h1 className="flex-none">{mergedRequestedShipments.length}</h1>
                  <div
                    className={`flex-none layout-row layout-align-center-center ${
                      ustyles.stat_box_title
                    }`}
                  >
                    <h3 className="flex-none">Requested Shipments</h3>
                  </div>
                </div>
                <div
                  className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}
                >
                  <h1 className="flex-none">{mergedOpenShipments.length}</h1>
                  <div
                    className={`flex-none layout-row layout-align-center-center ${
                      ustyles.stat_box_title
                    }`}
                  >
                    <h3 className="flex-none">Shipments in Progress</h3>
                  </div>
                </div>
                <div
                  className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}
                >
                  <h1 className="flex-none">{mergedFinishedShipments.length}</h1>
                  <div
                    className={`flex-none layout-row layout-align-center-center ${
                      ustyles.stat_box_title
                    }`}
                  >
                    <h3 className="flex-none">Completed Shipments</h3>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div
            className={`layout-row flex-100 layout-wrap layout-align-center-center ${
              defaults.border_divider
            }`}
          >
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
              <TextHeading className="flex-non clip" size={1} theme={theme} text="Shipments" />
              <UserMergedShipHeaders
                title="Requested Shipments"
                total={mergedRequestedShipments.length}
              />

              <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                {newReqShips}
                {seeAll !== false ? (
                  <div className="flex-100 layout-row layout-align-end-center">
                    <div
                      className="flex-none layout-row layout-align-center-center pointy"
                      value="1"
                      onClick={() => userDispatch.goTo('/account/shipments/requested')}
                    >
                      <p className="flex-none">See all</p>
                    </div>
                  </div>
                ) : (
                  ''
                )}
              </div>
              <UserMergedShipHeaders title="In Process" total={mergedOpenShipments.length} />
              <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                {newOpenShips}
                {seeAll !== false ? (
                  <div className="flex-100 layout-row layout-align-end-center">
                    <div
                      className="flex-none layout-row layout-align-center-center pointy"
                      value="2"
                      onClick={() => userDispatch.goTo('/account/shipments/open')}
                    >
                      <p className="flex-none">See all</p>
                    </div>
                  </div>
                ) : (
                  ''
                )}
              </div>
            </div>
          </div>
        </div>
        <div
          className={`layout-row flex-100 layout-wrap layout-align-center-center ${
            defaults.border_divider
          }`}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center">
            <AdminSearchableClients
              theme={theme}
              clients={contacts}
              title="Most used Contacts"
              handleClick={this.viewClient}
              seeAll={() => userDispatch.goTo('/account/contacts')}
            />
          </div>
        </div>
        <div
          className={`layout-row flex-100 layout-wrap layout-align-center-center ${
            defaults.border_divider
          }`}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-start-center">
            <TextHeading theme={theme} size={1} text="My Shipment Addresses" />
            <UserLocations
              setNav={() => {}}
              userDispatch={userDispatch}
              locations={locations}
              makePrimary={this.makePrimary}
              theme={theme}
              user={user}
            />
          </div>
        </div>
      </div>
    )
  }
}
UserDashboard.propTypes = {
  setNav: PropTypes.func.isRequired,
  userDispatch: PropTypes.shape({
    getShipment: PropTypes.func,
    goTo: PropTypes.func
  }).isRequired,
  seeAll: PropTypes.func,
  theme: PropTypes.theme,
  user: PropTypes.user.isRequired,
  hubs: PropTypes.objectOf(PropTypes.object),
  dashboard: PropTypes.shape({
    shipments: PropTypes.shipments,
    pricings: PropTypes.objectOf(PropTypes.string),
    contacts: PropTypes.arrayOf(PropTypes.object),
    locations: PropTypes.arrayOf(PropTypes.location)
  })
}

UserDashboard.defaultProps = {
  seeAll: null,
  hubs: null,
  dashboard: null,
  theme: null
}

export default UserDashboard
