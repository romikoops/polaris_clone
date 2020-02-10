import React from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { intersection } from 'lodash'
import { withNamespaces } from 'react-i18next'
import RouteSectionLabel from './RouteSectionLabel/RouteSectionLabel'
import { bookingProcessActions, shipmentActions, errorActions } from '../../../actions'
import RouteSectionMap from './Map'
import RouteSectionForm from './Form'
import styles from './RouteSection.scss'
import OfferError from '../../ErrorHandling/OfferError'
import TruckingDetails from './TruckingDetails'
import {
  camelize, camelToSnakeCase, onlyUnique, isEmpty, isQuote, determineSpecialism
} from '../../../helpers'
import getRequests from './getRequests'

class RouteSection extends React.PureComponent {
  constructor (props) {
    super(props)

    this.state = {
      collapsedAddressFields: {
        origin: true,
        destination: true
      },
      truckingAvailability: {
        origin: null,
        destination: null
      },
      carriageOptions: props.scope.carriage_options,
      newRoute: false,
      hubSelected: { origin: false, destination: false },
      countries: { origin: [], destination: [] }
    }

    this.handleCarriageChange = this.handleCarriageChange.bind(this)
    this.handleInputBlur = this.handleInputBlur.bind(this)
    this.handleDropdownSelect = this.handleDropdownSelect.bind(this)
    this.handleAutocompleteTrigger = this.handleAutocompleteTrigger.bind(this)
    this.clearCarriage = this.clearCarriage.bind(this)
    this.handleTruckingDetailsChange = this.handleTruckingDetailsChange.bind(this)
    this.handleClickCollapser = this.handleClickCollapser.bind(this)
    this.updateCollapsedAddressFields = this.updateCollapsedAddressFields.bind(this)

    const { routes } = props
    routes.forEach((route) => {
      if (route.origin.truckTypes.length > 0) {
        this.state.countries.origin.push(route.origin.country.toLowerCase())
      }
      if (route.destination.truckTypes.length > 0) {
        this.state.countries.destination.push(route.destination.country.toLowerCase())
      }
    })
    this.truckTypes = {
      container: ['chassis', 'side_lifter'],
      cargo_item: ['default']
    }

    const { scope, shipment } = props
    Object.entries(scope.carriage_options).forEach(([carriage, option]) => {
      if (option[shipment.direction] !== 'mandatory') return

      this.handleCarriageChange({ target: { name: camelize(carriage), checked: true } }, { force: true })
    })

    this.specialty = determineSpecialism(scope.modes_of_transport)
  }

  static getDerivedStateFromProps (nextProps, prevState) {
    const {
      lookupTablesForRoutes, routes, shipment, tenant, bookingProcessDispatch, shipmentDispatch, addressErrors, scope
    } = nextProps

    const { collapsedAddressFields } = prevState
    const {
      preCarriage, onCarriage, origin, destination
    } = shipment
    const nextState = {
      preCarriage, onCarriage, origin, destination, collapsedAddressFields, countries: prevState.countries, truckTypes: prevState.truckTypes
    }

    if (
      origin !== prevState.origin ||
      destination !== prevState.destination ||
      preCarriage !== prevState.preCarriage ||
      onCarriage !== prevState.onCarriage
    ) {
      let originIndeces = [...Array(routes.length).keys()]
      let destinationIndeces = [...Array(routes.length).keys()]
      nextState.newRoute = true
      nextState.countries = { origin: [], destination: [] }

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
        const originCountryCode = route.origin.country.toLowerCase()
        const destinationCountryCode = route.destination.country.toLowerCase()

        if (route.origin.truckTypes.length > 0 && !nextState.countries.origin.includes(originCountryCode)) {
          nextState.countries.origin.push(originCountryCode)
        }
        if (route.destination.truckTypes.length > 0 && !nextState.countries.destination.includes(destinationCountryCode)) {
          nextState.countries.destination.push(destinationCountryCode)
        }
      })

      bookingProcessDispatch.updatePageData('ShipmentDetails', { availableRoutes, availableMots })

      // update lastAvailableDate (backend call -> for redux store)
      if (!isEmpty(origin) && !isEmpty(destination) && !isQuote(tenant) && availableRoutes.length > 0) {
        const country = preCarriage ? availableRoutes[0].origin.country : origin.country
        shipmentDispatch.getLastAvailableDate({ itinerary_ids: itineraryIds, country })
      }
    }
    if (origin === prevState.origin &&
      destination === prevState.destination &&
      preCarriage === prevState.preCarriage &&
      onCarriage === prevState.onCarriage) {
      nextState.newRoute = false
    }
    if (addressErrors.origin) {
      nextState.collapsedAddressFields.origin = false
    }
    if (addressErrors.destination) {
      nextState.collapsedAddressFields.destination = false
    }

    nextState.originTrucking = nextState.truckTypes.origin.length > 0
    nextState.destinationTrucking = nextState.truckTypes.destination.length > 0

    nextState.carriageOptions = scope.carriage_options

    return nextState
  }

  componentDidMount () {
    const { truckTypes } = this.state

    this.setState({
      originTrucking: (truckTypes.origin.length > 0),
      destinationTrucking: truckTypes.destination.length > 0
    })
  }

  componentDidUpdate (prevProps, prevState) {
    const { carriageOptions } = this.state
    const { scope, shipment } = this.props
    if (carriageOptions === prevState.carriageOptions) return

    Object.entries(scope.carriage_options).forEach(([carriage, option]) => {
      if (option[shipment.direction] !== 'mandatory') return

      this.handleCarriageChange({ target: { name: camelize(carriage), checked: true } }, { force: true })
    })
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
        country: value.country,
        fullAddress: `${value.name}, ${value.country}`
      }

      bookingProcessDispatch.updateShipment(target, targetData)

      setMarker(target, { lat, lng })
    } else {
      bookingProcessDispatch.updateShipment(target, {})
      setMarker(target, null)
    }
  }

  handleHubSelect (target, bool) {
    this.setState(prevState => (
      {
        hubSelected: {
          ...prevState.hubSelected,
          [target]: bool
        }
      }
    ))
    this.clearCarriage(target)
  }

  clearCarriage (target) {
    const { bookingProcessDispatch, shipment } = this.props

    if (target === 'origin' && shipment.preCarriage) {
      bookingProcessDispatch.updateShipment('preCarriage', false)
    }
    if (target === 'destination' && shipment.onCarriage) {
      bookingProcessDispatch.updateShipment('onCarriage', false)
    }
  }

  updateTruckingAvailability (target, value) {
    this.setState(prevState => ({
      truckingAvailability: {
        ...prevState.truckingAvailability,
        [target]: value
      }
    }))
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

    this.updateTruckingAvailability(target, 'request')
    this.updateCollapsedAddressFields(target, false)

    getRequests.findAvailability(
      address.latitude,
      address.longitude,
      loadType,
      prefix,
      availableHubIds,
      (truckingAvailable, nexusIds, hubIds) => {
        if (!truckingAvailable) {
          this.updateTruckingAvailability(target, 'not_available')
          this.updateCollapsedAddressFields(target, true)

          errorDispatch.setError({
            componentName: 'RouteSection',
            code: '1101',
            target,
            side: target === 'origin' ? 'left' : 'right',
            targetAddress: address.fullAddress
          })
          bookingProcessDispatch.updateShipment(target, { fullAddress: address.fullAddress })
        } else {
          this.updateTruckingAvailability(target, 'animate_available')
          setTimeout(() => this.updateTruckingAvailability(target, 'available'), 1000)
          setTimeout(() => this.updateCollapsedAddressFields(target, true), 5000)
          this.handleCarriageChange({ target: { name: `${prefix}Carriage`, checked: true } }, { force: true })
          bookingProcessDispatch.updateShipment(target, { ...address, hubIds })
          errorDispatch.clearError({
            componentName: 'RouteSection',
            target,
            side: target === 'origin' ? 'left' : 'right'
          })
          setMarker(target, { lat: address.latitude, lng: address.longitude, geojson: address.geojson })
        }
      }
    )
  }

  handleClickCollapser (target) {
    this.setState(prevState => (
      {
        collapsedAddressFields: {
          ...prevState.collapsedAddressFields,
          [target]: !prevState.collapsedAddressFields[target]
        }
      }
    ))
  }

  updateCollapsedAddressFields (target, value) {
    this.setState(prevState => (
      {
        collapsedAddressFields: {
          ...prevState.collapsedAddressFields,
          [target]: value
        }
      }
    ))
  }

  render () {
    const {
      shipment, theme, scope, availableMots, requiresFullAddress, t
    } = this.props

    const {
      onCarriage, preCarriage, origin, destination, trucking, loadType
    } = shipment

    const {
      origins, destinations, truckTypes, collapsedAddressFields, truckingAvailability, newRoute, hubSelected, originTrucking, destinationTrucking, countries
    } = this.state

    return (
      <div className="route_section flex-100 content_width_booking">
        <RouteSectionMap
          theme={theme}
          origin={origin}
          destination={destination}
          withDrivingDirections={this.specialty === 'truck'}
        >
          {
            ({ gMaps, map, setMarker }) => {
              const sharedFormProps = {
                onInputBlur: this.handleInputBlur,
                onDropdownSelect: (...args) => this.handleDropdownSelect(...args, setMarker),
                onAutocompleteTrigger: (...args) => this.handleAutocompleteTrigger(...args, setMarker),
                clearCarriage: (...args) => this.clearCarriage(...args),
                origins,
                destinations,
                theme,
                scope,
                gMaps,
                map,
                handleHubSelect: (...args) => this.handleHubSelect(...args)
              }

              return (
                <React.Fragment>
                  <div name="originAuto" className="flex-50 layout-row layout-wrap layout-align-space-around-start">
                    <div className={`${styles.label} flex-gt-md-30 flex-100 layout-row layout-wrap layout-align-space-between`}>
                      <div className={`${(loadType !== 'container' || !preCarriage) ? 'flex-100' : 'flex-40'} layout-row layout-align-center-start`}>
                        <p>
                          <RouteSectionLabel
                            truckingOptions={truckTypes.origin.length}
                            target="origin"
                          />
                        </p>
                      </div>
                      {(loadType === 'container' || preCarriage) && (
                        <div className="flex-60 layout-column layout-align-center-center">
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
                      )}
                    </div>
                    <RouteSectionForm
                      {...sharedFormProps}
                      collapsed={collapsedAddressFields.origin}
                      onClickCollapser={this.handleClickCollapser}
                      target="origin"
                      carriage={preCarriage}
                      formData={origin}
                      availableTargets={origins}
                      availableCounterparts={destinations}
                      countries={countries.origin.filter(onlyUnique)}
                      truckingAvailable={truckingAvailability.origin}
                      requiresFullAddress={requiresFullAddress}
                      hasTrucking={originTrucking}
                      hubSelected={hubSelected.origin}
                    />
                  </div>
                  <div name="destinationAuto" className="flex-50 layout-row layout-wrap layout-align-space-around-start">
                    <div className={`${styles.label} flex-gt-md-30 flex-100 layout-row layout-wrap layout-align-space-between`}>
                      <div className={`${(loadType !== 'container' || !onCarriage) ? 'flex-100' : 'flex-40'} layout-row layout-align-center-start`}>
                        <p>
                          <RouteSectionLabel
                            truckingOptions={truckTypes.destination.length}
                            target="destination"
                          />
                        </p>
                      </div>
                      {(loadType === 'container' || onCarriage) && (
                        <div className="flex-60 layout-column layout-align-center-center">
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
                      )}
                    </div>
                    <RouteSectionForm
                      {...sharedFormProps}
                      collapsed={collapsedAddressFields.destination}
                      onClickCollapser={this.handleClickCollapser}
                      target="destination"
                      carriage={onCarriage}
                      formData={destination}
                      availableTargets={destinations}
                      availableCounterparts={origins}
                      countries={countries.destination.filter(onlyUnique)}
                      truckingAvailable={truckingAvailability.destination}
                      requiresFullAddress={requiresFullAddress}
                      hasTrucking={destinationTrucking}
                      hubSelected={hubSelected.destination}
                    />
                  </div>
                  <OfferError availableMots={availableMots} newRoute={newRoute} componentName="RouteSection" />
                </React.Fragment>
              )
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

const connectedComponent = connect(mapStateToProps, mapDispatchToProps)(RouteSection)
export default withNamespaces(['shipment'])(connectedComponent)
