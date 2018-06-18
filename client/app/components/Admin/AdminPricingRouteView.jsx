import React, { Component } from 'react'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import { AdminClientTile, AdminPriceEditor } from './'
import styles from './Admin.scss'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import AdminPromptConfirm from './Prompt/Confirm'

import {
  CONTAINER_DESCRIPTIONS,
  fclChargeGlossary,
  lclChargeGlossary,
  chargeGlossary
} from '../../constants'
import { history } from '../../helpers'

const containerDescriptions = CONTAINER_DESCRIPTIONS
const fclChargeGloss = fclChargeGlossary
const lclChargeGloss = lclChargeGlossary
const chargeGloss = chargeGlossary
export class AdminPricingRouteView extends Component {
  static backToIndex () {
    history.goBack()
  }
  constructor (props) {
    super(props)
    this.state = {
      selectedClient: false
    }
    this.editThis = this.editThis.bind(this)
    this.closeEdit = this.closeEdit.bind(this)
    this.selectClient = this.selectClient.bind(this)
    this.closeClientView = this.closeClientView.bind(this)
  }
  componentDidMount () {
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
  closeEdit () {
    this.setState({
      editPricing: false,
      editHubRoute: false,
      editTransport: false,
      editorBool: false
    })
  }
  selectClient (client) {
    console.log(client)
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
      pricingToDelete
    } = this.state
    const { selectedClient } = this.state
    console.log(this.props)
    if (!pricingData || !itineraryPricings) {
      return ''
    }
    const fauxShipment = {
    }
    console.log(itineraryPricings)
    const { transportCategories } = pricingData
    const {
      itinerary,
      itineraryPricingData,
      stops,
      detailedItineraries,
      userPricings
    } = itineraryPricings
    if (!itinerary || !itineraryPricingData) {
      return ''
    }
    fauxShipment.origin_hub = stops[0].hub
    fauxShipment.destination_hub = stops[stops.length - 1].hub

    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const RPBInner = ({ hubRoute, pricing, transport }) => {
      const panel = []
      let gloss
      if (transport.cargo_class.includes('lcl')) {
        gloss = lclChargeGloss
      } else {
        gloss = fclChargeGloss
      }
      Object.keys(pricing.data).forEach((key) => {
        const cells = []
        Object.keys(pricing.data[key]).forEach((chargeKey) => {
          if (
            chargeKey !== 'currency' &&
            chargeKey !== 'rate_basis' &&
            chargeKey !== 'hw_rate_basis' &&
            chargeKey !== 'range'
          ) {
            cells.push(<div className={`flex-25 layout-row layout-align-none-center ${styles.price_cell}`}>
              <p className="flex-none">{chargeGloss[chargeKey]}</p>
              <p className="flex">
                {pricing.data[key][chargeKey]} {pricing.data[key].currency}
              </p>
            </div>)
          } else if (chargeKey === 'rate_basis' || chargeKey === 'hw_rate_basis') {
            cells.push(<div className={`flex-25 layout-row layout-align-none-center ${styles.price_cell}`}>
              <p className="flex-none">{chargeGloss[chargeKey]}</p>
              <p className="flex">{chargeGloss[pricing.data[key][chargeKey]]}</p>
            </div>)
          } else if (chargeKey === 'range') {
            pricing.data[key].range.forEach((rangeFee, i) => {
              const ellipsis = (
                <div className="flex-10 layout-row layout-align-center-center">
                  <i className="flex-none fa fa-balance-scale" />
                </div>
              )
              const rangeCells = [ellipsis]
              Object.keys(rangeFee).forEach((rfKey) => {
                if (rfKey !== 'currency' && rfKey !== 'max' && rfKey !== 'min') {
                  rangeCells.push(<div
                    className={`flex-20 layout-row layout-align-none-center ${styles.price_cell}`}
                  >
                    <p className="flex-none">{chargeGloss[rfKey]}</p>
                    <p className="flex">
                      {pricing.data[key].range[i][rfKey]} {pricing.data[key].currency}
                    </p>
                  </div>)
                } else if (rfKey === 'min' || rfKey === 'max') {
                  rangeCells.push(<div
                    className={`flex-20 layout-row layout-align-none-center ${styles.price_cell}`}
                  >
                    <p className="flex-none">{rfKey}</p>
                    <p className="flex">{pricing.data[key].range[i][rfKey]} kg</p>
                  </div>)
                }
              })
              cells
                .push(<div className="flex-100 layout-row layout-align-start-center">
                  {rangeCells}
                </div>)
            })
          }
        })
        panel.push(<div className="flex-100 layout-row layout-align-none-center layout-wrap">
          <div
            className={`flex-100 layout-row layout-align-start-center ${styles.price_subheader}`}
          >
            <p className="flex-none">
              {key} - {gloss[key]}
            </p>
          </div>
          <div className="flex-100 layout-row layout-align-start-center layout-wrap">{cells}</div>
        </div>)
      })

      return (
        <div
          key={v4()}
          className={` ${
            styles.hub_route_price
          } flex-100 layout-row layout-wrap layout-align-center-start`}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <div className="flex layout-row layout-align-start-center">
              <i className="fa fa-map-signs clip" style={textStyle} />
              <p className="flex-none offset-5">{hubRoute.name}</p>
            </div>
            <div
              className="flex-5 layout-row layout-align-center-center"
              onClick={() => this.editThis(pricing, hubRoute, transport)}
            >
              <i className="flex-none fa fa-pencil clip pointy" style={textStyle} />
            </div>
            <div
              className="flex-5 layout-row layout-align-center-center"
              onClick={() => this.confirmDelete(pricing)}
            >
              <i className="flex-none fa fa-trash pointy" />
            </div>
          </div>
          <div
            className={`flex-33 layout-row layout-align-space-between-center ${
              styles.price_row_detail
            }`}
          >
            <p className="flex-none">MoT:</p>
            <p className="flex-none"> {transport.mode_of_transport}</p>
          </div>
          <div
            className={`flex-33 layout-row layout-align-space-between-center ${
              styles.price_row_detail
            }`}
          >
            <p className="flex-none">Cargo Type: </p>
            <p className="flex-none">{transport.name}</p>
          </div>
          <div
            className={`flex-33 layout-row layout-align-space-between-center ${
              styles.price_row_detail
            }`}
          >
            <p className="flex-none">Cargo Class:</p>
            <p className="flex-none"> {containerDescriptions[transport.cargo_class]}</p>
          </div>
          {panel}
        </div>
      )
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
    const RoutePricingBox = ({ routeData, pricingsArr, userId }) => {
      const filteredPricingsArr =
        userId === 'open' ? pricingsArr : pricingsArr.filter(pr => pr.user_id === userId)
      const inner = filteredPricingsArr.map((pricingObj) => {
        const innerInner = []
        innerInner.push(<RPBInner
          key={v4()}
          hubRoute={routeData}
          transport={pricingObj.transport_category}
          pricing={pricingObj.pricing}
          theme={theme}
        />)
        return innerInner
      })
      return (
        <div
          key={v4()}
          className={` ${
            styles.route_price
          } flex-100 layout-row layout-wrap layout-align-start-start `}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <h3 className="flex-none clip"> {routeData.name} </h3>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
            {inner}
          </div>
        </div>
      )
    }
    const clientTiles = clients.map(cl => (
      <AdminClientTile
        key={v4()}
        client={cl}
        theme={theme}
        handleClick={() => this.selectClient(cl)}
      />
    ))
    const clientsView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-center">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
        >
          <p className={` ${styles.sec_header_text} flex-none`}> Client Pricings </p>
        </div>
        {clientTiles}
      </div>
    )
    const clientPriceView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-center">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
        >
          <p className={` ${styles.sec_header_text} flex-none`}> Dedicated Pricing </p>
          <div
            className="flex-none layout-row layout-align-center-center"
            onClick={this.closeClientView}
          >
            <i className="fa fa-times clip flex-none" style={textStyle} />
          </div>
        </div>
        <RoutePricingBox
          key={v4()}
          routeData={itinerary}
          pricingsArr={userPricings}
          transports={transportCategories}
          userId={selectedClient.id}
        />
      </div>
    )
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {itinerary.name}
          </p>
        </div>
        <RouteHubBox shipment={fauxShipment} itinerary={detailedItineraries} theme={theme} />
        <div className="flex-100 layout-row layout-wrap layout-align-center-center">
          <div
            className={`flex-80 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Open Pricing </p>
          </div>
          <div className="flex-80 layout-row layout-wrap layout-align-space-between-center">
            <RoutePricingBox
              key={v4()}
              routeData={itinerary}
              pricingsArr={itineraryPricingData}
              userId="open"
            />
          </div>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-center-center">
          <div
            className={`flex-80 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}>
              {' '}
              Users With Dedicated Pricings{' '}
            </p>
          </div>
          <div className="flex-80 layout-row layout-wrap layout-align-space-between-center">
            {selectedClient ? clientPriceView : clientsView}
          </div>
          {confimPrompt}
        </div>
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
