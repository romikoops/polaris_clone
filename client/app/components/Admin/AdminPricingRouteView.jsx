import React, { Component } from 'react'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import { AdminClientTile, AdminPriceEditor } from './'
import styles from './Admin.scss'
import shipmentStyles from './AdminShipments.scss'
import AdminPromptConfirm from './Prompt/Confirm'
import AlternativeGreyBox from '../GreyBox/AlternativeGreyBox'
import { history, gradientGenerator, gradientBorderGenerator, switchIcon } from '../../helpers'
import GradientBorder from '../GradientBorder'
import ShipmentOverviewShowCard from './AdminShipmentView/ShipmentOverviewShowCard'
import { AdminPricingDedicated } from './Pricing/Dedicated'

export class AdminPricingRouteView extends Component {
  static backToIndex () {
    history.goBack()
  }
  constructor (props) {
    super(props)
    this.state = {
      selectedClient: false,
      showPricingAdder: false,
      expander: {}
    }
    this.editThis = this.editThis.bind(this)
    this.closeEdit = this.closeEdit.bind(this)
    this.selectClient = this.selectClient.bind(this)
    this.closeClientView = this.closeClientView.bind(this)
    this.viewClient = this.viewClient.bind(this)
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
  viewClient (client) {
    const { adminActions } = this.props
    adminActions.getClientPricings(client.id, true)
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
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
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
      expander,
      pricingToDelete,
      showPricingAdder
    } = this.state
    const { selectedClient } = this.state
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

    const clientTiles = userPricings.map((up, i) => {
      const client = clients.filter(cl => cl.id === up.user_id)[0]

      return (
        <div className="flex-20 layout-row">
          {userPricings[i].length !== 0 ? (
            <AdminClientTile
              showCollapsing
              key={v4()}
              toggleExpander={() => this.toggleExpander(client.id)}
              expander={!expander[client.id]}
              flexClasses="layout-row flex-100"
              client={client}
              theme={theme}
              handleClick={() => this.viewClient(client)}
              content={(
                <div>
                  ...
                </div>
              )}
            />
          ) : '' }
        </div>
      )
    })
    // const clientsView = (
    //   <div className="flex-100 layout-row layout-wrap layout-align-space-around-center padding_top">
    //     {clientTiles}
    //   </div>
    // )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start extra_padding">
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
            {/* <AdminPricingBox
              itinerary={itinerary}
              charges={itineraryPricingData}
              theme={theme}
              adminDispatch={adminActions}
              title="Open Pricing"
            /> */}
          </div>
        </div>

        <div className="flex-100 layout-row layout-wrap layout-align-center-center buffer_10">
          <div className={`layout-padding flex-100 layout-align-start-center ${styles.greyBg}`}>
            <span><b>Dedicated Pricings</b></span>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
            {!showPricingAdder ? (
              <div className={`flex-20 layout-row ${styles.set_button_height} pointy`} onClick={() => this.addNewPricings()}>
                <AlternativeGreyBox
                  wrapperClassName="layout-row flex-100"
                  contentClassName="layout-column flex layout-align-center-center"
                  content={(
                    <div>
                      <h1><strong>+</strong></h1>
                      <p>New Dedicated Pricing</p>
                    </div>
                  )}
                />
              </div>
            ) : (
              ''
            )}
            {!selectedClient && !showPricingAdder ? clientTiles : ''}
            <div className="flex-100 layout-row layout-wrap layout-align-start-center" style={showPricingAdder ? {} : { display: 'none' }}>
              <AdminPricingDedicated
                theme={theme}
                backBtn={() => this.addNewPricings()}
                closePricingView={() => this.addNewPricings()}
                adminDispatch={adminActions}
                charges={itineraryPricingData}
                clients={clients}
              />
            </div>
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
