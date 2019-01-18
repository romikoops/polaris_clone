import React from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { intersection } from 'lodash'
import { bookingProcessActions, shipmentActions, errorActions } from '../../../actions'
import RouteSectionMap from './Map'
import RouteSectionForm from './Form'
import CarriageToggle from './CarriageToggle'
import OfferError from '../../ErrorHandling/OfferError'
import TruckingDetails from './TruckingDetails'
import {
  camelize, camelToSnakeCase, onlyUnique, isQuote
} from '../../../helpers'
import getRequests from './getRequests'

class RouteSection extends React.PureComponent {
  constructor (props) {
    super(props)

    this.state = {}

    this.handleCarriageChange = this.handleCarriageChange.bind(this)
    this.handleInputBlur = this.handleInputBlur.bind(this)
    this.handleDropdownSelect = this.handleDropdownSelect.bind(this)
    this.handleAutocompleteTrigger = this.handleAutocompleteTrigger.bind(this)
    this.handleCarriageChange = this.handleCarriageChange.bind(this)
    this.handleTruckingDetailsChange = this.handleTruckingDetailsChange.bind(this)

    const { routes } = props
    this.countries = { origin: [], destination: [] }
    routes.forEach((route) => {
      this.countries.origin.push(route.origin.country.toLowerCase())
      this.countries.destination.push(route.destination.country.toLowerCase())
    })

    this.truckTypes = {
      container: ['side_lifter', 'chassis'],
      cargo_item: ['default']
    }

    const { scope, shipment } = props

    Object.entries(scope.carriage_options).forEach(([carriage, option]) => {
      if (option[shipment.direction] !== 'mandatory') return

      this.handleCarriageChange({ target: { name: camelize(carriage), checked: true } }, { force: true })
    })
  }

  static getDerivedStateFromProps (nextProps, prevState) {
    const {
      lookupTablesForRoutes, routes, shipment, tenant, bookingProcessDispatch, shipmentDispatch
    } = nextProps
    const {
      preCarriage, onCarriage, origin, destination
    } = shipment
    const nextState = {
      preCarriage, onCarriage, origin, destination
    }

    if (
      origin !== prevState.origin ||
      destination !== prevState.destination ||
      preCarriage !== prevState.preCarriage ||
      onCarriage !== prevState.onCarriage
    ) {
      let originIndeces = [...Array(routes.length).keys()]
      let destinationIndeces = [...Array(routes.length).keys()]

      // update origins (for react state)
      if (!onCarriage && destination.nexusId) {
        originIndeces = lookupTablesForRoutes.destinationNexus[destination.nexusId]
        nextState.origins = originIndeces.map(idx => routes[idx].origin)
      } else if (onCarriage && destination.hubIds) {
        originIndeces = destination.hubIds.reduce((indeces, hubId) => (
          [...indeces, ...lookupTablesForRoutes.destinationHub[hubId]]
        ), []).filter(onlyUnique)
        nextState.origins = originIndeces.map(idx => routes[idx].origin)
      } else {
        nextState.origins = routes.map(route => route.origin)
      }

      // update destinations (for react state)
      if (!preCarriage && origin.nexusId) {
        destinationIndeces = lookupTablesForRoutes.originNexus[origin.nexusId]
        nextState.destinations = destinationIndeces.map(idx => routes[idx].destination)
      } else if (preCarriage && origin.hubIds) {
        destinationIndeces = origin.hubIds.reduce((indeces, hubId) => (
          [...indeces, ...lookupTablesForRoutes.originHub[hubId]]
        ), []).filter(onlyUnique)
        nextState.destinations = destinationIndeces.map(idx => routes[idx].destination)
      } else {
        nextState.destinations = routes.map(route => route.destination)
      }

      // update availableRoutes, availableMots, truckTypes and lastAvailableDate
      const availableRoutes = []
      const availableMots = []
      const itineraryIds = []
      nextState.truckTypes = { origin: [], destination: [] }

      const indeces = intersection(originIndeces, destinationIndeces)

      indeces.filter(onlyUnique).forEach((idx) => {
        const route = routes[idx]

        // availableRoutes (for redux store)
        availableRoutes.push(route)

        // availableMots (for redux store)
        itineraryIds.push(route.itineraryId)

        const { modeOfTransport } = route
        if (!availableMots.includes(modeOfTransport)) availableMots.push(modeOfTransport)

        itineraryIds.push(route.itineraryId)

        // truckTypes (for react state)
        route.origin.truckTypes.forEach((truckType) => {
          if (!nextState.truckTypes.origin.includes(truckType)) {
            nextState.truckTypes.origin.push(truckType)
          }
        })

        route.destination.truckTypes.forEach((truckType) => {
          if (!nextState.truckTypes.destination.includes(truckType)) {
            nextState.truckTypes.destination.push(truckType)
          }
        })
      })

      bookingProcessDispatch.updatePageData('ShipmentDetails', { availableRoutes, availableMots })

      // update lastAvailableDate (backend call -> for redux store)
      if (!isQuote(tenant) && availableRoutes.length > 0) {
        const country = preCarriage ? availableRoutes[0].origin.country : origin.country
        shipmentDispatch.getLastAvailableDate({ itinerary_ids: itineraryIds, country })
      }
    }

    return nextState
  }

  handleTruckingDetailsChange (e) {
    const { shipment, bookingProcessDispatch } = this.props
    const [carriage, truckType] = e.target.id.split('-')

    bookingProcessDispatch.updateShipment(
      'trucking',
      {
        ...shipment.trucking,
        [carriage]: {
          ...shipment.trucking[carriage],
          truckType
        }
      }
    )
  }

  handleCarriageChange (e, options = {}) {
    const { checked } = e.target
    const carriage = e.target.name

    // Break out of function, in case the change should not apply, based on the tenant scope.
    const { scope, shipment } = this.props
    const carriageOptionScope = scope.carriage_options[camelToSnakeCase(carriage)][shipment.direction]
    const changeShouldApply = carriageOptionScope === 'optional' || (options.force)
    if (!changeShouldApply) return

    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.updateShipment(carriage, checked)

    // Update trucking according to carriage properties
    const artificialEvent = { target: {} }
    if (!checked) {
      // Set truckType to '', if carriage is toggled off
      artificialEvent.target.id = `${carriage}-`
    } else if (!shipment.trucking[carriage].truckType) {
      // Set first truckType, if carriage is toggled on and truckType is empty
      const truckType = this.truckTypes[shipment.loadType][0]
      artificialEvent.target.id = `${carriage}-${truckType}`
    }

    if (!artificialEvent.target.id) return
    this.handleTruckingDetailsChange(artificialEvent)
  }

  handleInputBlur (e) {
    const [target, key] = e.target.name.split('-')
    const { shipment } = this.props

    const address = { ...shipment[target], [key]: e.target.value }

    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.updateShipment(target, address)
  }

  handleDropdownSelect (target, selectedOption, setMarker) {
    const { bookingProcessDispatch } = this.props

    if (selectedOption) {
      const { value } = selectedOption

      const lat = value.latitude
      const lng = value.longitude

      const targetData = {
        latitude: lat,
        longitude: lng,
        nexusId: value.id,
        nexusName: value.name,
        country: value.country
      }

      bookingProcessDispatch.updateShipment(target, targetData)

      setMarker(target, { lat, lng }, value.name)
    } else {
      bookingProcessDispatch.updateShipment(target, {})

      setMarker(target, null)
    }
  }

  handleAutocompleteTrigger (target, address, setMarker) {
    const {
      bookingProcessDispatch, errorDispatch, shipment
    } = this.props

    const { loadType } = shipment

    const { origins, destinations } = this.state

    const prefix = target === 'origin' ? 'pre' : 'on'
    const targets = target === 'origin' ? origins : destinations
    const availableHubIds = targets.map(targetData => targetData.hubId)

    getRequests.findAvailability(
      address.latitude,
      address.longitude,
      loadType,
      prefix,
      availableHubIds,
      (truckingAvailable, nexusIds, hubIds) => {
        if (!truckingAvailable) {
          errorDispatch.setError({
            componentName: 'RouteSection',
            code: '1101',
            target,
            side: target === 'origin' ? 'left' : 'right',
            targetAddress: address.fullAddress
          })
          bookingProcessDispatch.updateShipment(target, { fullAddress: address.fullAddress })
        } else {
          bookingProcessDispatch.updateShipment(target, { ...address, hubIds })

          setMarker(target, { lat: address.latitude, lng: address.longitude }, address.fullAddress)
        }
      }
    )
  }

  render () {
    const {
      shipment, theme, scope, availableMots
    } = this.props

    const {
      onCarriage, preCarriage, origin, destination, trucking, loadType
    } = shipment

    const { origins, destinations, truckTypes } = this.state

    return (
      <div className="route_section flex-100 content_width_booking margin_top">
        <RouteSectionMap theme={theme}>
          {
            ({ gMaps, map, setMarker }) => {
              const sharedFormProps = {
                onInputBlur: this.handleInputBlur,
                onDropdownSelect: (...args) => this.handleDropdownSelect(...args, setMarker),
                onAutocompleteTrigger: (...args) => this.handleAutocompleteTrigger(...args, setMarker),
                origins,
                destinations,
                theme,
                scope,
                gMaps,
                map
              }
              const preCarriageSection = (
                <div className="flex-45 layout-row layout-wrap layout-align-start-start">
                  <div className="flex-45 layout-row layout-wrap">
                    <CarriageToggle carriage="pre" theme={theme} checked={preCarriage} onChange={this.handleCarriageChange} />
                    <TruckingDetails
                      carriageType="pre"
                      hide={loadType !== 'container' || !preCarriage}
                      theme={theme}
                      trucking={trucking}
                      truckTypes={truckTypes.origin}
                      target="preCarriage"
                      onTruckingDetailsChange={this.handleTruckingDetailsChange}
                    />
                  </div>
                  <RouteSectionForm
                    {...sharedFormProps}
                    target="origin"
                    carriage={preCarriage}
                    formData={origin}
                    availableTargets={origins}
                    availableCounterparts={destinations}
                    countries={this.countries.origin}
                  />
                </div>
              )
              const onCarriageSection = (
                <div className="flex-45 layout-row layout-wrap layout-align-start-start">
                  <div className="flex-35 layout-row layout-wrap">
                    <CarriageToggle carriage="on" theme={theme} checked={onCarriage} onChange={this.handleCarriageChange} />
                    <TruckingDetails
                      carriageType="on"
                      hide={loadType !== 'container' || !onCarriage}
                      theme={theme}
                      trucking={trucking}
                      truckTypes={truckTypes.destination}
                      target="onCarriage"
                      onTruckingDetailsChange={this.handleTruckingDetailsChange}
                    />
                  </div>
                  <RouteSectionForm
                    {...sharedFormProps}
                    target="destination"
                    carriage={onCarriage}
                    formData={destination}
                    availableTargets={destinations}
                    availableCounterparts={origins}
                    countries={this.countries.destination}
                  />
                </div>
              )

              return [
                preCarriageSection,
                onCarriageSection,
                <OfferError availableMots={availableMots} componentName="RouteSection" />
              ]
            }
          }
        </RouteSectionMap>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { bookingProcess, bookingData, app } = state
  const { shipment, ShipmentDetails } = bookingProcess
  const { response } = bookingData
  const { routes, lookupTablesForRoutes } = response.stage1
  const { tenant } = app
  const { theme, scope } = tenant

  return {
    ...ShipmentDetails, shipment, routes, lookupTablesForRoutes, theme, scope, tenant
  }
}

function mapDispatchToProps (dispatch) {
  return {
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch),
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch),
    errorDispatch: bindActionCreators(errorActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(RouteSection)
