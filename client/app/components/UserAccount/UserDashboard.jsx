import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import ustyles from './UserAccount.scss'
import defaults from '../../styles/default_classes.scss'
import { UserLocations } from './'
import { AdminSearchableClients } from '../Admin/AdminSearchables'
// import { ShipmentOverviewCard } from '../ShipmentCard/ShipmentOverviewCard'
import { gradientTextGenerator } from '../../helpers'
import SquareButton from '../SquareButton'
import { AdminShipmentsComp } from '../Admin/Shipments/Comp'

export class UserDashboard extends Component {
  static prepShipment (baseShipment, user) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = user ? `${user.first_name} ${user.last_name}` : ''
    shipment.companyName = user ? `${user.company_name}` : ''

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
      theme,
      // hubs,
      dashboard,
      user,
      userDispatch
    } = this.props
    if (!user || !dashboard) {
      return <h1>NO DATA</h1>
    }
    const {
      // shipments,
      contacts,
      locations
    } = dashboard

    // const mergedRequestedShipments =
    //   shipments && shipments.requested
    //     ? shipments.requested
    //       .sort((a, b) => new Date(b.booking_placed_at) - new Date(a.booking_placed_at))
    //       .slice(0, 4)
    //       .map(sh => UserDashboard.prepShipment(sh, user, hubs))
    //     : false
    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-center extra_padding">
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-start ${
            ustyles.dashboard_main
          }`}
        >
          <div
            className={
              `layout-row flex-100 layout-align-space-between-start ${ustyles.header}`
            }
          >
            <div
              className={`layout-row flex-100 layout-align-start-center
              ${ustyles.headerElement}`}
            >
              <div className="flex-60 layout-row layout-align-space-around-center">
                <div className="layout-row flex-none layout-align-center-center">
                  <i
                    className={`fa fa-user clip ${ustyles.bigProfile}`}
                    style={gradientFontStyle}
                  />
                </div>
                <div className={`${ustyles.welcome} flex layout-row`}>
                Welcome back,&nbsp; <b>{user.first_name}</b>
                </div>
              </div>
              <SquareButton
                theme={theme}
                handleNext={this.startBooking}
                active
                border
                size="large"
                text="Find Rates"
                iconClass="fa-archive"
              />
            </div>
          </div>
          <div
            className="layout-row flex-100 layout-wrap layout-align-center-center"
            style={{ marginTop: '50px' }}
          >
            <AdminShipmentsComp isUser />
          </div>
          {/* <ShipmentOverviewCard
            dispatches={userDispatch}
            shipments={mergedRequestedShipments}
            theme={theme}
          />  <div className={`layout-row flex-100 layout-align-center-center ${ustyles.space}`}>
            <span className="flex-15" onClick={() => this.handleViewShipments()}>
              <u><b>See more shipments</b></u>
            </span>
            <div className={`flex-85 ${ustyles.separator}`} />
          </div> */}
        </div>
        <div
          className="layout-row flex-100 layout-wrap layout-align-center-center"
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-stretch">
            <AdminSearchableClients
              theme={theme}
              clients={contacts}
              placeholder="Search Contacts"
              title="Most used Contacts"
              handleClick={this.viewClient}
              seeAll={() => userDispatch.getContacts(true, 1)}
            />
          </div>
        </div>
        <div
          className={`layout-row flex-100 layout-wrap layout-align-center-center ${
            defaults.border_divider
          }`}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-start-center">
            <div className="flex-100 layout-row layout-align-space-between-center">
              <div
                className="flex-100 layout-align-start-center greyBg"
              >
                <span><b>My Shipment Addresses</b></span>
              </div>
            </div>
            {locations.length === 0 ? (
              'No addresses yet'
            ) : (
              <UserLocations
                setNav={() => {}}
                userDispatch={userDispatch}
                locations={locations}
                makePrimary={this.makePrimary}
                theme={theme}
                user={user}
              />
            )}

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
  // hubs: PropTypes.objectOf(PropTypes.object),
  dashboard: PropTypes.shape({
    shipments: PropTypes.shipments,
    pricings: PropTypes.objectOf(PropTypes.string),
    contacts: PropTypes.arrayOf(PropTypes.object),
    locations: PropTypes.arrayOf(PropTypes.location)
  })
}

UserDashboard.defaultProps = {
  seeAll: null,
  // hubs: null,
  dashboard: null,
  theme: null
}

export default UserDashboard
