import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import ustyles from './UserAccount.scss'
import defaults from '../../styles/default_classes.scss'
import UserLocations from './UserLocations'
import { AdminSearchableClients } from '../Admin/AdminSearchables'
import ShipmentOverviewCard from '../ShipmentCard/ShipmentOverviewCard'
import { gradientTextGenerator } from '../../helpers'
import isQuote from '../../helpers/tenant'
import SquareButton from '../SquareButton'
import Loading from '../Loading/Loading'

class UserDashboard extends Component {
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
    this.state = {
      perPage: 3
    }
    this.viewShipment = this.viewShipment.bind(this)
    this.viewClient = this.viewClient.bind(this)
    this.makePrimary = this.makePrimary.bind(this)
    this.startBooking = this.startBooking.bind(this)
    this.determinePerPage = this.determinePerPage.bind(this)
    this.seeAll = this.seeAll.bind(this)
  }

  componentDidMount () {
    this.props.setNav('dashboard')
    window.scrollTo(0, 0)
    this.determinePerPage()
    window.addEventListener('resize', this.determinePerPage)
    this.props.setCurrentUrl(this.props.match.url)
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.determinePerPage)
  }

  viewShipment (shipment) {
    const { userDispatch } = this.props
    userDispatch.getShipment(shipment.id, true)
  }

  viewClient (client) {
    const { userDispatch } = this.props
    userDispatch.getContact(client.id, true)
  }

  determinePerPage () {
    const width = window.innerWidth
    const perPage = width >= 1920 ? 3 : 2
    this.setState({ perPage })
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

  handleViewShipments () {
    const { userDispatch } = this.props
    userDispatch.getShipments({}, 4, true)
  }

  render () {
    const {
      theme,
      dashboard,
      user,
      userDispatch,
      tenant,
      t
    } = this.props
    if (!user || !dashboard) {
      return <Loading theme={theme} text={t('bookconf:loading')} />
    }
    const { perPage } = this.state
    const {
      shipments,
      contacts,
      locations
    } = dashboard

    const shipmentsToDisplay = isQuote(tenant) ? shipments.quoted : shipments.requested
    const preppedShipments = shipmentsToDisplay ? shipmentsToDisplay.slice(0, perPage)
      .sort((a, b) => new Date(b.booking_placed_at) - new Date(a.booking_placed_at))
      .map(s => UserDashboard.prepShipment(s, user)) : []
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
                <div className={`${ustyles.welcome} flex layout-row ccb_dashboard`}>
                  {t('common:welcomeBack')}&nbsp; <b>{user.first_name}</b>
                </div>
              </div>
              <div className="flex-40 layout-row layout-align-end-center">
                <SquareButton
                  theme={theme}
                  handleNext={this.startBooking}
                  active
                  border
                  classNames="ccb_find_rates"
                  size="large"
                  text={t('landing:callToAction')}
                  iconClass="fa-archive"
                />
              </div>

            </div>
          </div>
          <div className="layout-padding flex-100 layout-align-start-center greyBg">
            <span><b>{isQuote(tenant) ? t('shipment:quotedShipments') : t('shipment:requestedShipments') }</b></span>
          </div>
          <ShipmentOverviewCard
            dispatches={userDispatch}
            noTitle
            shipments={preppedShipments}
            theme={theme}
          />
          <div className={`layout-row flex-100 layout-align-center-center ${ustyles.space}`}>
            <span className="flex-15" onClick={() => this.handleViewShipments()}>
              <u><b>{t('shipment:seeMoreShipments')}</b></u>
            </span>
            <div className={`flex-85 ${ustyles.separator}`} />
          </div>
        </div>
        { isQuote(tenant) ? '' : <div
          className="layout-row flex-100 layout-wrap layout-align-center-center"
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-stretch">
            <AdminSearchableClients
              theme={theme}
              clients={contacts}
              placeholder={t('account:searchContacts')}
              title={t('account:mostUsedContacts')}
              handleClick={this.viewClient}
              seeAll={() => userDispatch.getContacts({ page: 1 }, true)}
            />
          </div>
        </div> }
        { isQuote(tenant) ? '' : <div
          className={`layout-row flex-100 layout-wrap layout-align-center-center ${
            defaults.border_divider
          }`}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-start-center">
            <div className="flex-100 layout-row layout-align-space-between-center">
              <div
                className="flex-100 layout-align-start-center greyBg"
              >
                <span><b>{t('shipment:myShipmentAddresses')}</b></span>
              </div>
            </div>
            {locations.length === 0 ? (
              t('shipment:noAddresses')
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
        </div> }
      </div>
    )
  }
}
UserDashboard.propTypes = {
  setNav: PropTypes.func.isRequired,
  scope: PropTypes.objectOf(PropTypes.bool),
  setCurrentUrl: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired,
  userDispatch: PropTypes.shape({
    getShipment: PropTypes.func,
    goTo: PropTypes.func
  }).isRequired,
  match: PropTypes.shape({
    url: PropTypes.string
  }).isRequired,
  seeAll: PropTypes.func,
  theme: PropTypes.theme,
  tenant: PropTypes.tenant.isRequired,
  user: PropTypes.user.isRequired,
  dashboard: PropTypes.shape({
    shipments: PropTypes.shipments,
    pricings: PropTypes.objectOf(PropTypes.string),
    contacts: PropTypes.arrayOf(PropTypes.object),
    locations: PropTypes.arrayOf(PropTypes.location)
  })
}

UserDashboard.defaultProps = {
  seeAll: null,
  scope: null,
  dashboard: null,
  theme: null
}

export default withNamespaces(['common', 'user', 'shipment', 'account'])(UserDashboard)
