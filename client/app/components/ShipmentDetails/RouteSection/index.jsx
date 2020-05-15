import React from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { intersection, flatten, get, has } from 'lodash'
import { withNamespaces } from 'react-i18next'
import RouteSectionLabel from './RouteSectionLabel/RouteSectionLabel'
import { bookingProcessActions, shipmentActions } from '../../../actions'
import RouteSectionMap from './Map'
import RouteSectionForm from './Form'
import styles from './RouteSection.scss'
import OfferError from '../../ErrorHandling/OfferError'
import TruckingDetails from './TruckingDetails'
import {
  camelize, camelToSnakeCase, onlyUnique, isEmpty, isQuote, determineSpecialism
} from '../../../helpers'
import getRequests from './getRequests'
import addressFromPlace from './Form/addressFromPlace'

class RouteSection extends React.PureComponent {
  constructor (props) {
    super(props)
    const { routes } = props

    this.state = {
      loading: { origin: false, destination: false },
      routeSelectionErrors: { origin: false, destination: false },
      truckingAvailability: { origin: null, destination: null },
      originTrucking: false,
      destinationTrucking: false,
      carriageOptions: props.scope.carriage_options,
      newRoute: false,
      countries: RouteSection.getCountriesList(routes)
    }
    const emptyFn = () => {}
    this.setGoogleApi(emptyFn, {}, emptyFn, emptyFn)

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
      lookupTablesForRoutes, routes, shipment, tenant, bookingProcessDispatch, shipmentDispatch, scope
    } = nextProps

    const { collapsedAddressFields } = prevState
    const {
      preCarriage, onCarriage, origin, destination
    } = shipment
    const nextState = {
      preCarriage,
      onCarriage,
      origin,
      destination,
      collapsedAddressFields,
      countries: prevState.countries,
      truckTypes: prevState.truckTypes,
      requiresFullAddress: scope.require_full_address
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
      const motLookup = {
        origin: {},
        destination: {}
      }

      const prepareHub = (target, route) => {
        const hub = route[target]
        const mot = route.modeOfTransport

        if (!has(motLookup, [target, hub.nexusId])) {
          motLookup[target][hub.nexusId] = { ...hub, mots: [], hubIds: [] }
        }

        if (!motLookup[target][hub.nexusId].mots.includes(mot)) {
          motLookup[target][hub.nexusId].mots.push(mot)
        }
        if (!motLookup[target][hub.nexusId].hubIds.includes(hub.hubId)) {
          motLookup[target][hub.nexusId].hubIds.push(hub.hubId)
        }
      }

      const definedLookupHubs = (hubIds, directionHubs) => {
        const filteredByLookup = hubIds.filter((hubId) => lookupTablesForRoutes[directionHubs][hubId] !== undefined)

        return filteredByLookup
      }

      // update origins (for react state)
      if (!onCarriage && destination.nexusId) {
        originIndeces = lookupTablesForRoutes.destinationNexus[destination.nexusId]
        originIndeces.map((idx) => prepareHub('origin', routes[idx]))
      } else if (onCarriage && destination.hubIds) {
        originIndeces = definedLookupHubs(destination.hubIds, 'destinationHub').reduce((indeces, hubId) => (
          [...indeces, ...lookupTablesForRoutes.destinationHub[hubId]]
        ), []).filter(onlyUnique)
        originIndeces.map((idx) => prepareHub('origin', routes[idx]))
      } else {
        routes.map((route) => prepareHub('origin', route))
      }

      nextState.origins = Object.values(motLookup.origin)

      // update destinations (for react state)
      if (!preCarriage && origin.nexusId) {
        destinationIndeces = lookupTablesForRoutes.originNexus[origin.nexusId]
        destinationIndeces.map((idx) => prepareHub('destination', routes[idx]))
      } else if (preCarriage && origin.hubIds) {
        destinationIndeces = definedLookupHubs(origin.hubIds, 'originHub').reduce((indeces, hubId) => (
          [...indeces, ...lookupTablesForRoutes.originHub[hubId]]
        ), []).filter(onlyUnique)
        destinationIndeces.map((idx) => prepareHub('destination', routes[idx]))
      } else {
        routes.map((route) => prepareHub('destination', route))
      }

      nextState.destinations = Object.values(motLookup.destination)

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
      if (!isEmpty(origin) && !isEmpty(destination) && availableRoutes.length > 0) {
        shipmentDispatch.refreshMaxDimensions(itineraryIds)
      }
    }
    if (origin === prevState.origin &&
      destination === prevState.destination &&
      preCarriage === prevState.preCarriage &&
      onCarriage === prevState.onCarriage) {
      nextState.newRoute = false
    }

    nextState.originTrucking = nextState.truckTypes.origin.length > 0
    nextState.destinationTrucking = nextState.truckTypes.destination.length > 0

    nextState.carriageOptions = scope.carriage_options

    return nextState
  }

  static getCountriesList (routes) {
    const origins = []
    const destinations = []

    routes.forEach((route) => {
      if (route.origin.truckTypes.length > 0) {
        origins.push(route.origin.country.toLowerCase())
      }
      if (route.destination.truckTypes.length > 0) {
        destinations.push(route.destination.country.toLowerCase())
      }
    })

    return { origin: origins, destination: destinations }
  }

  componentDidMount () {
    const { truckTypes } = this.state

    this.setState({
      originTrucking: (truckTypes.origin.length > 0),
      destinationTrucking: truckTypes.destination.length > 0
    })
  }

  componentDidUpdate (_prevProps, prevState) {
    const { carriageOptions } = this.state
    const { scope, shipment } = this.props
    if (carriageOptions === prevState.carriageOptions) return

    Object.entries(scope.carriage_options).forEach(([carriage, option]) => {
      if (option[shipment.direction] !== 'mandatory') return

      this.handleCarriageChange({ target: { name: camelize(carriage), checked: true } }, { force: true })
    })
  }

  get addressFields () {
    const { scope } = this.props

    return scope.address_fields
  }

  setGoogleApi = (gMaps, map, setMarker, adjustMapBounds) => {
    this.gmaps = { gMaps, map, setMarker, adjustMapBounds }
  }

  setRouteSelectionError = (target, message) => {
    const { routeSelectionErrors } = this.state

    routeSelectionErrors[target] = message
    this.setState({ routeSelectionErrors })
  }

  setLoading = (target, value) => {
    const { loading } = this.state

    loading[target] = value
    this.setState(loading)
  }

  setTruckingType = (carriage, truckType) => {
    const { shipment, bookingProcessDispatch } = this.props

    bookingProcessDispatch.updateShipment('trucking',
      {
        ...shipment.trucking,
        [carriage]: { ...shipment.trucking[carriage], truckType }
      })
  }

  onTruckingDetailsChange = (e) => {
    const [carriage, truckType] = e.target.id.split('-')

    this.setTruckingType(carriage, truckType)
  }

  handleCarriageChange = (e, options = {}) => {
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
    this.onTruckingDetailsChange(artificialEvent)
  }

  clearCarriage = (target) => {
    const { bookingProcessDispatch } = this.props
    let carriage = 'preCarriage'

    if (target === 'destination') {
      carriage = 'onCarriage'
    }

    bookingProcessDispatch.updateShipment(carriage, false)
    this.setTruckingType(carriage, '')
  }

  clearShipmentLocation = (target) => {
    const { bookingProcessDispatch } = this.props
    const { adjustMapBounds, setMarker } = this.gmaps

    bookingProcessDispatch.updateShipment(target, {})

    setMarker(target, null)
    adjustMapBounds()
  }

  updateTruckingAvailability = (target, value) => {
    const { truckingAvailability } = this.state

    truckingAvailability[target] = value

    this.setState(truckingAvailability)
  }

  updateAddress = (target, address) => new Promise((resolve) => {
    const {
      bookingProcessDispatch,
      shipment,
      t
    } = this.props

    const { loadType } = shipment
    const { setMarker } = this.gmaps
    const { origins, destinations } = this.state

    const prefix = target === 'origin' ? 'pre' : 'on'
    const targets = target === 'origin' ? origins : destinations
    const availableHubIds = targets.flatMap((targetData) => targetData.hubIds)

    const onTruckingAvailable = (hubIds) => {
      this.updateTruckingAvailability(target, true)

      this.handleCarriageChange({ target: { name: `${prefix}Carriage`, checked: true } }, { force: true })
      bookingProcessDispatch.updateShipment(target, { ...address, hubIds })
      setMarker(target, { lat: address.latitude, lng: address.longitude, geojson: address.geojson })

      resolve()
    }

    const onTruckingNotAvailable = () => {
      this.updateTruckingAvailability(target, false)
      bookingProcessDispatch.updateShipment(target, { })

      this.setRouteSelectionError(target, t('errors:truckingNotAvailable', { code: 1101 }))
      resolve()
    }

    getRequests.findAvailability(
      address.latitude,
      address.longitude,
      loadType,
      prefix,
      availableHubIds,
      (truckingAvailable, _nexusIds, hubIds) => {
        if (truckingAvailable) {
          onTruckingAvailable(hubIds)
        } else {
          onTruckingNotAvailable()
        }
      }
    )
  })

  updateAddressFields = (target, addressFields, changedField) => new Promise((resolve) => {
    const { setMarker } = this.gmaps
    const { bookingProcessDispatch, shipment, t } = this.props
    const [changedKey, changedValue] = Object.entries(changedField)[0]

    const currentAddress = shipment[target]
    currentAddress[changedKey] = changedValue
    bookingProcessDispatch.updateShipment(target, currentAddress)

    const searchComplete = (result) => {
      if (currentAddress.city && currentAddress.city !== result.city) {
        resolve()

        return
      }

      if (currentAddress.postalCode && currentAddress.postalCode !== result.postalCode) {
        resolve()

        return
      }

      const updatedAddress = {
        ...currentAddress,
        fullAddress: result.fullAddress,
        latitude: result.latitude,
        longitude: result.longitude
      }

      bookingProcessDispatch.updateShipment(target, updatedAddress)
      setMarker(target, { lat: result.latitude, lng: result.longitude })
      resolve()
    }
    const combinedAddress = [addressFields.street, addressFields.number].join(' ').trim()
    this.gmapsGeocodeAddress(combinedAddress, addressFields.city, addressFields.zipCode).then((geocodedResults) => {
      if (!geocodedResults) {
        this.setRouteSelectionError(target, t('errors:invalidAddress'))
        resolve()

        return
      }

      const result = geocodedResults[0]
      this.gmapsAddressFetch(result.place_id).then(searchComplete)
    }).catch(resolve)
  })

  updateHub = (target, value) => {
    const { setMarker } = this.gmaps
    const { bookingProcessDispatch } = this.props

    if (!value) {
      this.clearShipmentLocation()

      return
    }

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
  }

  onRouteSelectionChange = (target, item, field) => {
    this.validateTarget(target)
    this.setRouteSelectionError(target, false)

    if (!item) {
      this.clearShipmentLocation(target)
      this.clearCarriage(target)

      return
    }

    if (item.type === 'hub') {
      this.updateHub(target, item.rawResult)
      this.clearCarriage(target)

      return
    }

    this.setLoading(target, true)
    if (item.type === 'address') {
      this.updateAddress(target, item.address)
        .finally(() => this.setLoading(target, false))

      return
    }

    if (item.type === 'addressFields') {
      this.updateAddressFields(target, item.rawResult, field)
        .finally(() => this.setLoading(target, false))
    }
  }

  onRouteSelectionBlur = (target) => {
    this.validateTarget(target)

    const { adjustMapBounds } = this.gmaps

    adjustMapBounds()
  }

  onRouteSelectionFocus = (target) => {
    this.validateTarget(target)

    const { map } = this.gmaps
    const { shipment } = this.props
    const fieldName = `${target}Focused`

    const selected = shipment[target]

    if (!(selected && selected.latitude && selected.longitude)) { return }

    map.setZoom(14)
    map.setCenter({ lat: selected.latitude, lng: selected.longitude })

    this.setState({ [fieldName]: true })
  }

  addressSearch = (target, query) => {
    const { countries } = this.state
    const groupedCountries = countries[target].filter(onlyUnique)

    const executeSearch = (grouped) => {
      const options = {
        input: query,
        componentRestrictions: { country: grouped }
      }

      return this.gmapsAddressAutocomplete(options)
    }

    const promises = groupedCountries.map(executeSearch)

    return Promise.all(promises)
      .then((predictions) => flatten(predictions))
  }

  addressFetch = (item) => this.gmapsAddressFetch(item.rawResult.place_id)

  gmapsAddressFetch = (placeId) => new Promise((resolve) => {
    const { gMaps, map } = this.gmaps

    const placesService = new gMaps.places.PlacesService(map)
    placesService.getDetails({ placeId }, (place) => {
      addressFromPlace(place, gMaps, map, (address) => {
        resolve(address)
      })
    })
  })

  gmapsAddressAutocomplete = (options) => new Promise((resolve) => {
    const { gMaps } = this.gmaps

    const addressSearchService = new gMaps.places.AutocompleteService({ types: ['address'] })
    addressSearchService.getPlacePredictions(options, (predictions, status) => {
      if (!['ZERO_RESULTS', 'OK'].includes(status)) {
        resolve([])
      }

      resolve(predictions)
    })
  })

  gmapsGeocodeAddress = (address, city, postalCode) => new Promise((resolve, reject) => {
    const { gMaps } = this.gmaps

    const options = {
      componentRestrictions: {}
    }

    if (address) {
      options.address = address
    }

    if (city) {
      options.componentRestrictions.administrativeArea = city
    }

    if (postalCode) {
      options.componentRestrictions.postalCode = postalCode
    }

    const geocodeService = new gMaps.Geocoder()
    geocodeService.geocode(options, (geocoderResults, status) => {
      if (!['ZERO_RESULTS', 'OK'].includes(status)) {
        resolve([])
      }

      resolve(geocoderResults)
    })
  })

  hasHubs = (target) => {
    this.validateTarget(target)

    const { scope, shipment } = this.props
    const { direction } = shipment

    const carriageType = target === 'origin' ? 'pre_carriage' : 'on_carriage'
    const carriageOption = get(scope, ['carriage_options', carriageType, direction], 'optional')

    return carriageOption !== 'mandatory'
  }

  hasTrucking = (target) => {
    this.validateTarget(target)

    const {
      originTrucking,
      destinationTrucking,
      truckingAvailability
    } = this.state

    if (originTrucking && target === 'origin') {
      return truckingAvailability.origin === null || truckingAvailability.origin
    }

    if (destinationTrucking && target === 'destination') {
      return truckingAvailability.destination === null || truckingAvailability.destination
    }

    return false
  }

  validateTarget = (target) => {
    if (target !== 'origin' && target !== 'destination') {
      throw new Error(`Invalid target ${target}`)
    }
  }

  routeSelectionErrors = (target) => {
    const { routeSelectionErrors } = this.state

    const error = routeSelectionErrors[target]
    if (!error) { return null }

    return (
      <div className={styles.routeSelectionErrors}>
        <i className="fa fa-exclamation-triangle" />
        { error }
      </div>
    )
  }

  render () {
    const {
      shipment, theme, availableMots
    } = this.props

    const {
      destination,
      loadType,
      onCarriage,
      origin,
      preCarriage,
      trucking
    } = shipment

    const {
      destinations,
      destinationTrucking,
      loading,
      newRoute,
      origins,
      originTrucking,
      requiresFullAddress,
      truckTypes,
      truckingAvailability
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
            ({ gMaps, map, setMarker, adjustMapBounds }) => {
              this.setGoogleApi(gMaps, map, setMarker, adjustMapBounds)

              return (
                <>
                  <div name="originAuto" className={styles.routeContainer}>

                    <RouteSectionLabel
                      className={styles.label}
                      truckingOptions={truckTypes.origin.length}
                      target="origin"
                    />

                    <RouteSectionForm
                      addressFetch={(item) => this.addressFetch(item)}
                      addressSearch={(query) => this.addressSearch('origin', query)}
                      hasHubs={this.hasHubs('origin')}
                      hasTrucking={this.hasTrucking('origin')}
                      hubs={origins}
                      loading={loading.origin}
                      requiresFullAddress={requiresFullAddress}
                      showAddress={this.addressFields && originTrucking}
                      value={origin}
                      foundTrucking={truckingAvailability.origin}
                      onBlur={() => this.onRouteSelectionBlur('origin')}
                      onChange={(item, field) => this.onRouteSelectionChange('origin', item, field)}
                      onFocus={() => this.onRouteSelectionFocus('origin')}
                    />

                    <TruckingDetails
                      wrapperClassName={styles.truckingDetails}
                      hide={loadType !== 'container' || !preCarriage}
                      theme={theme}
                      trucking={trucking}
                      truckTypes={truckTypes.origin}
                      target="preCarriage"
                      onTruckingDetailsChange={this.onTruckingDetailsChange}
                    />

                    { this.routeSelectionErrors('origin') }
                  </div>

                  <OfferError
                    availableMots={availableMots}
                    newRoute={newRoute}
                    componentName="RouteSection"
                  />

                  <div name="destinationAuto" className={styles.routeContainer}>

                    <RouteSectionLabel
                      className={styles.label}
                      truckingOptions={truckTypes.destination.length}
                      target="destination"
                    />

                    <RouteSectionForm
                      addressFetch={(item) => this.addressFetch(item)}
                      addressSearch={(query) => this.addressSearch('destination', query)}
                      hasHubs={this.hasHubs('destination')}
                      hasTrucking={this.hasTrucking('destination')}
                      hubs={destinations}
                      loading={loading.destination}
                      requiresFullAddress={requiresFullAddress}
                      showAddress={this.addressFields && destinationTrucking}
                      value={destination}
                      foundTrucking={truckingAvailability.destination}
                      onBlur={() => this.onRouteSelectionBlur('destination')}
                      onChange={(item, field) => this.onRouteSelectionChange('destination', item, field)}
                      onFocus={() => this.onRouteSelectionFocus('destination')}
                    />

                    <TruckingDetails
                      wrapperClassName={styles.truckingDetails}
                      hide={loadType !== 'container' || !onCarriage}
                      theme={theme}
                      trucking={trucking}
                      truckTypes={truckTypes.destination}
                      target="onCarriage"
                      onTruckingDetailsChange={this.onTruckingDetailsChange}
                    />

                    { this.routeSelectionErrors('destination') }
                  </div>
                </>
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
    ...ShipmentDetails,
    lookupTablesForRoutes,
    routes,
    scope,
    shipment,
    tenant,
    theme
  }
}

function mapDispatchToProps (dispatch) {
  return {
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch),
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch)
  }
}

const connectedComponent = connect(mapStateToProps, mapDispatchToProps)(RouteSection)
export default withNamespaces(['shipment', 'errors'])(connectedComponent)
