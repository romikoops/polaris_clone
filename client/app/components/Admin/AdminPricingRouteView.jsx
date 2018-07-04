import React, { Component } from 'react'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import { AdminClientTile, AdminPriceEditor } from './'
import styles from './Admin.scss'
import shipmentStyles from './AdminShipments.scss'
import AdminPromptConfirm from './Prompt/Confirm'

import { history, gradientGenerator, gradientBorderGenerator, switchIcon } from '../../helpers'
import GradientBorder from '../GradientBorder'
import ShipmentOverviewShowCard from './AdminShipmentView/ShipmentOverviewShowCard'
import { AdminPricingBox } from './Pricing/Box'
import { AdminPricingDedicated } from './Pricing/Dedicated'
import { RoundButton } from '../RoundButton/RoundButton'

export class AdminPricingRouteView extends Component {
  static backToIndex () {
    history.goBack()
  }
  constructor (props) {
    super(props)
    this.state = {
      selectedClient: false,
      showPricingAdder: false
    }
    this.editThis = this.editThis.bind(this)
    this.closeEdit = this.closeEdit.bind(this)
    this.selectClient = this.selectClient.bind(this)
    this.closeClientView = this.closeClientView.bind(this)
  }
  componentDidMount () {
    console.log('PARENT REMOUNTING')
    const {
      routePricings, loading, adminActions, match
    } = this.props
    if (!routePricings && !loading) {
      adminActions.getItineraryPricings(parseInt(match.params.id, 10), false)
    }
    window.scrollTo(0, 0)
  }

  editThis (pricing, hubRoute, transport) {
    this.setState({
      editPricing: pricing,
      editHubRoute: hubRoute,
      editTransport: transport,
      editorBool: true
    })
  }
  addNewPricings () {
    this.setState({ showPricingAdder: !this.state.showPricingAdder })
  }
  closeEdit () {
    this.setState({
      editPricing: false,
      editHubRoute: false,
      editTransport: false,
      editorBool: false
    })
  }
  selectClient (client) {
    this.setState({ selectedClient: client })
  }
  closeClientView () {
    this.setState({ selectedClient: false })
  }
  deletePricing () {
    const { adminActions } = this.props
    const { pricingToDelete } = this.state
    adminActions.deletePricing(pricingToDelete)
    this.closeConfirm()
  }
  confirmDelete (pricing) {
    this.setState({
      confirm: true,
      pricingToDelete: pricing
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }
  render () {
    const {
      theme, pricingData, itineraryPricings, clients, adminActions
    } = this.props
    const {
      editorBool,
      editTransport,
      editPricing,
      editHubRoute,
      confirm,
      pricingToDelete,
      showPricingAdder
    } = this.state
    const { selectedClient } = this.state
    console.log(this.props)
    if (!pricingData || !itineraryPricings) {
      return ''
    }
    const fauxShipment = {
    }
    const {
      itinerary,
      itineraryPricingData,
      stops,
      userPricings
    } = itineraryPricings
    if (!itinerary || !itineraryPricingData) {
      return ''
    }
    fauxShipment.origin_hub = stops[0].hub
    fauxShipment.destination_hub = stops[stops.length - 1].hub
    const gradientStyle =
    theme && theme.colors
      ? gradientGenerator(theme.colors.primary, theme.colors.secondary)
      : { background: 'black' }

    const gradientBorderStyle =
    theme && theme.colors
      ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary)
      : { background: 'black' }
    const bg1 =
      fauxShipment.origin_hub && fauxShipment.origin_hub.photo
        ? { backgroundImage: `url(${fauxShipment.origin_hub.photo})` }
        : {
          backgroundImage:
            'url("https://assets.itsmycargo.com/assets/default_images/crane_sm.jpg")'
        }
    const bg2 =
      fauxShipment.destination_hub && fauxShipment.destination_hub.photo
        ? { backgroundImage: `url(${fauxShipment.destination_hub.photo})` }
        : {
          backgroundImage:
            'url("https://assets.itsmycargo.com/assets/default_images/destination_sm.jpg")'
        }

    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading="Are you sure?"
        text="This will delete the pricing immediately and all related data"
        confirm={() => this.deletePricing(pricingToDelete)}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const clientTiles = userPricings.map((up) => {
      const client = clients.filter(cl => cl.id === up.user_id)[0]

      return (
        <AdminClientTile
          key={v4()}
          client={client}
          theme={theme}
          handleClick={() => this.selectClient(client)}
        />
      )
    })
    const clientsView = (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-center padding_top">
        {clientTiles}
      </div>
    )

    const pricingAdder = (
      <AdminPricingDedicated
        theme={theme}
        adminDispatch={adminActions}
        charges={itineraryPricingData}
        clients={clients}
      />
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        <div className={`layout-row flex-95 ${styles.margin_bottom}`}>

          <GradientBorder
            wrapperClassName={`layout-row flex-40 ${shipmentStyles.hub_box_shipment}`}
            gradient={gradientBorderStyle}
            className="layout-row flex"
            content={(
              <div className="layout-row flex-100">
                <ShipmentOverviewShowCard
                  hub={stops[0].hub}
                  bg={bg1}
                />
              </div>
            )}
          />
          <div className="layout-row flex-20 layout-align-center-center">
            <div className={`layout-column flex layout-align-center-center ${shipmentStyles.font_adjustaments}`}>
              <div className="layout-align-center-center layout-row" >
                {switchIcon(itinerary.mode_of_transport, gradientStyle)}
              </div>
            </div>
          </div>

          <GradientBorder
            wrapperClassName={`layout-row flex-40 ${shipmentStyles.hub_box_shipment}`}
            gradient={gradientBorderStyle}
            className="layout-row flex"
            content={(
              <div className="layout-row flex-100">
                <ShipmentOverviewShowCard
                  hub={stops[1].hub}
                  bg={bg2}
                />
              </div>
            )}
          />
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-center-center">

          <div className="flex-95 layout-row layout-wrap layout-align-space-between-center">
            <AdminPricingBox
              itinerary={itinerary}
              charges={itineraryPricingData}
              theme={theme}
              adminDispatch={adminActions}
              title="Open Pricing"
            />
          </div>
        </div>

        <div className="flex-100 layout-row layout-wrap layout-align-center-center buffer_10">
          <div
            className={`flex-95 layout-row layout-align-space-between-center ${styles.title_grey_with_button}`}
          >
            <p className=" flex-none">
              {' '}
                Users With Dedicated Pricings{' '}
            </p>
            <RoundButton
              text="New Dedicated Pricing"
              theme={theme}
              active
              iconClass="fa-plus"
              size="large"
              handleNext={() => this.addNewPricings()}
              border
            />
          </div>
          <div className="flex-95 layout-row layout-wrap layout-align-space-between-center">
            <div className="flex-100 layout-row layout-wrap layout-align-start-center" style={selectedClient && !showPricingAdder ? {} : { display: 'none' }}>
              <AdminPricingBox
                itinerary={itinerary}
                charges={userPricings.filter(up => up.user_id === selectedClient.id)}
                theme={theme}
                adminDispatch={adminActions}
                closeView={this.closeClientView}
                title={`Dedicated Pricing fro ${selectedClient.first_name} ${selectedClient.last_name}`}
              />
            </div>
            {!selectedClient && !showPricingAdder ? clientsView : ''}
            {showPricingAdder ? pricingAdder : ''}
          </div>

        </div>

        {confimPrompt}
        {editorBool ? (
          <AdminPriceEditor
            closeEdit={this.closeEdit}
            theme={theme}
            hubRoute={editHubRoute}
            transport={editTransport}
            userId={selectedClient.id}
            isNew={false}
            pricing={editPricing}
            adminTools={adminActions}
          />
        ) : (
          ''
        )}
      </div>
    )
  }
}
AdminPricingRouteView.propTypes = {
  theme: PropTypes.theme,
  adminActions: PropTypes.shape({
    getRoutePricings: PropTypes.func
  }).isRequired,
  routePricings: PropTypes.shape({
    route: PropTypes.object,
    routePricingData: PropTypes.object
  }),
  pricingData: PropTypes.shape({
    pricings: PropTypes.array,
    hubRoutes: PropTypes.array,
    transportCategories: PropTypes.array
  }),
  clients: PropTypes.arrayOf(PropTypes.client),
  loading: PropTypes.bool,
  match: PropTypes.match.isRequired,
  itineraryPricings: PropTypes.objectOf(PropTypes.any).isRequired
}

AdminPricingRouteView.defaultProps = {
  theme: null,
  loading: false,
  routePricings: null,
  pricingData: null,
  clients: []
}

export default AdminPricingRouteView
