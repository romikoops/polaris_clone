import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import Select from 'react-select'
import Toggle from 'react-toggle'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import '../../styles/react-toggle.scss'
import '../../styles/select-css-custom.scss'
import styles from './ShipmentLocationBox.scss'
import errorStyles from '../../styles/errors.scss'
import {
  colorSVG, determineSpecialism, isDefined, onlyUnique
} from '../../helpers'
import { mapStyling } from '../../constants/map.constants'
import { capitalize } from '../../helpers/stringTools'
import addressFromPlace from './addressFromPlace'
import getRequests from './getRequests'
import routeFilters from './routeFilters'
import routeHelpers from './routeHelpers'
import TruckingTooltip from './TruckingTooltip'
import TruckingDetails from '../TruckingDetails/TruckingDetails'
import Autocomplete from './Autocomplete'
import removeTabIndex from './removeTabIndex'
import LoadingSpinner from '../LoadingSpinner/LoadingSpinner'
import CircleCompletion from '../CircleCompletion/CircleCompletion'

const colourSVG = colorSVG
const mapStyles = mapStyling

function backgroundColor (props) {
  return !props.value && props.nextStageAttempt ? '#FAD1CA' : '#F9F9F9'
}
function placeholderColorOverwrite (props) {
  return !props.value && props.nextStageAttempt ? 'color: rgb(211, 104, 80);' : ''
}
const StyledSelect = styled(Select)`
  .Select-control {
    background-color: ${props => backgroundColor(props)};
    box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
    border: 1px solid #f2f2f2 !important;
  }
  .Select-menu-outer {
    box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
    border: 1px solid #f2f2f2;
  }
  .Select-value {
    background-color: ${props => backgroundColor(props)};
    border: 1px solid #f2f2f2;
  }
  .Select-placeholder {
    ${props => placeholderColorOverwrite(props)};
  }
  .Select-option {
    background-color: #f9f9f9;
  }
`

class ShipmentLocationBox extends PureComponent {
  static sortOptions (array) {
    return array.sort((a, b) => {
      const textA = a.label.toUpperCase()
      const textB = b.label.toUpperCase()

      return (textA < textB) ? -1 : (textA > textB) ? 1 : 0
    })
  }

  constructor (props) {
    super(props)

    this.defaultTruckType = 'chassis'

    this.state = {
      autoText: {
        origin: '',
        destination: ''
      },
      autoTextOrigin: '',
      autoTextDest: '',
      autoListener: {
        origin: false,
        destination: false
      },
      markers: {
        origin: {},
        destination: {}
      },
      locationData: {
        origin: {},
        destination: {}
      },
      showModal: false,
      addressFromModal: false,
      truckingOptions: {
        onCarriage: true,
        preCarriage: true
      },
      oSelect: '',
      dSelect: '',
      truckTypes: {
        origin: [],
        destination: []
      },
      truckingHubs: {},
      countries: {
        origin: [],
        destination: []
      },
      truckingFound: {
        origin: false,
        destination: false
      }
    }

    this.isOnFocus = {
      origin: false,
      destination: false
    }

    this.handleAddressChange = this.handleAddressChange.bind(this)
    this.selectLocation = this.selectLocation.bind(this)
    this.handleTrucking = this.handleTrucking.bind(this)
    this.setOriginNexus = this.setOriginNexus.bind(this)
    this.setDestNexus = this.setDestNexus.bind(this)
    this.setNexusesFromRoute = this.setNexusesFromRoute.bind(this)
    this.resetAuto = this.resetAuto.bind(this)
    this.setMarker = this.setMarker.bind(this)
    this.changeAddressFormVisibility = this.changeAddressFormVisibility.bind(this)
    this.toggleModal = this.toggleModal.bind(this)
    this.selectedRoute = this.selectedRoute.bind(this)
    this.loadPrevReq = this.loadPrevReq.bind(this)
    this.handleAddressFormFocus = this.handleAddressFormFocus.bind(this)
    this.scopeNexusOptions = this.scopeNexusOptions.bind(this)
  }

  componentWillMount () {
    if (this.props.reusedShipment && this.props.reusedShipment.shipment) {
      this.loadReusedShipment()
    } else if (this.props.prevRequest && this.props.prevRequest.shipment) {
      this.loadPrevReq(this.props)
    }

    if (this.props.scope) {
      const speciality = determineSpecialism(this.props.scope.modes_of_transport)
      this.setState({ speciality })
    }
    this.prepForSelect('origin')
    this.prepForSelect('destination')
  }

  componentDidMount () {
    this.initMap()
  }

  componentWillReceiveProps (nextProps) {
    if (this.props.has_on_carriage && !nextProps.has_on_carriage) {
      this.prepForSelect('destination')
    }
    if (this.props.has_pre_carriage && !nextProps.has_pre_carriage) {
      this.prepForSelect('origin')
    }
    if (this.props.nextStageAttempts < nextProps.nextStageAttempts) {
      this.changeAddressFormVisibility('origin', true)
      this.changeAddressFormVisibility('destination', true)
    }
    if (nextProps.scope) {
      const speciality = determineSpecialism(nextProps.scope.modes_of_transport)
      this.setState({ speciality })
    }
    if (nextProps.prevRequest !== this.props.prevRequest && nextProps.prevRequest.shipment) {
      this.loadPrevReq(nextProps)
    }
    if (typeof this.state.map === 'undefined') {
      this.initMap()
    }

    if (nextProps.shipmentData &&
        (this.state.countries.origin.length === 0 || this.state.countries.destination.length === 0)
    ) {
      this.extractCountries(nextProps)
    }
  }

  setDestNexus (event) {
    if (event) {
      const destination = {
        nexus_id: event.value.id,
        nexus_name: event.value.name,
        latitutde: event.value.latitude,
        longitude: event.value.longitude
      }
      const lat = event.value.latitude
      const lng = event.value.longitude
      const dSelect = event
      this.props.setNotesIds([event.value.id], 'destination')
      if (this.props.destination.nexus_id !== destination.nexus_id) {
        this.props.setTargetAddress('destination', destination)
      }
      this.setMarker({ lat, lng }, destination.nexus_name, 'destination')

      this.setState({ dSelect }, () => this.prepForSelect('destination'))
      this.props.handleSelectLocation('destination', false)
    } else {
      this.setState({
        truckingOptions: {
          ...this.state.truckingOptions,
          preCarriage: true
        },
        dSelect: ''
      }, () => this.prepForSelect('destination'))
      this.props.setNotesIds(null, 'destination')
      this.state.markers.destination.setMap(null)
      if (this.props.destination !== {}) {
        this.props.setTargetAddress('destination', {})
      }
    }
  }

  setNexusesFromRoute (route) {
    const selectedOrigin = this.props.allNexuses.origins.find(nx => (
      nx.value.id === route.firstStop.hub.nexus.id
    ))

    const selectedDestination = this.props.allNexuses.destinations.find(nx => (
      nx.value.id === route.lastStop.hub.nexus.id
    ))

    this.setState({
      oSelect: { ...selectedOrigin },
      dSelect: { ...selectedDestination }
    })

    this.props.setTargetAddress('origin', {
      nexus_id: selectedOrigin.value.id,
      nexus_name: selectedOrigin.value.name,
      latitude: selectedOrigin.value.latitude,
      longitude: selectedOrigin.value.longitude
    })

    this.props.setTargetAddress('destination', {
      nexus_id: selectedDestination.value.id,
      nexus_name: selectedDestination.value.name,
      latitude: selectedDestination.value.latitude,
      longitude: selectedDestination.value.longitude
    })

    if (this.state.map) {
      this.setMarker(
        { lat: selectedOrigin.value.latitude, lng: selectedOrigin.value.longitude },
        selectedOrigin.value.name,
        'origin'
      )
      this.setMarker(
        {
          lat: selectedDestination.value.latitude,
          lng: selectedDestination.value.longitude
        },
        selectedDestination.value.name,
        'destination'
      )
    } else {
      setTimeout(() => {
        this.setMarker(
          { lat: selectedOrigin.value.latitude, lng: selectedOrigin.value.longitude },
          selectedOrigin.value.name,
          'origin'
        )
      }, 750)
      setTimeout(() => {
        this.setMarker(
          { lat: selectedDestination.value.latitude, lng: selectedDestination.value.longitude },
          selectedDestination.value.name,
          'destination'
        )
      }, 750)
    }
  }

  setOriginNexus (event) {
    if (event) {
      const origin = {
        nexus_id: event.value.id,
        nexus_name: event.value.name,
        latitude: event.value.latitude,
        longitude: event.value.longitude
      }
      const lat = event.value.latitude
      const lng = event.value.longitude
      const oSelect = event
      if (this.props.origin.nexus_id !== origin.nexus_id) {
        this.props.setTargetAddress('origin', origin)
      }
      this.setMarker({ lat, lng }, origin.nexus_name, 'origin')
      this.setState({ oSelect }, () => this.prepForSelect('origin'))
      this.props.setNotesIds([event.value.id], 'origin')
      this.props.handleSelectLocation('origin', false)
    } else {
      this.setState({
        truckingOptions: {
          ...this.state.truckingOptions,
          preCarriage: true
        },
        oSelect: ''
      }, () => this.prepForSelect('origin'))
      this.props.setNotesIds(false, 'origin')
      this.state.markers.origin.setMap(null)
      if (this.props.origin !== {}) {
        this.props.setTargetAddress('origin', {})
      }
    }
  }

  setLocationMap (location, target) {
    const {
      map, locationData, directionsDisplay, directionsService, markers
    } = this.state

    const counterpart = target === 'origin' ? 'destination' : 'origin'
    if (locationData[target].title !== undefined) {
      map.data.remove(locationData[target][0])
    }

    const targetKml = map.data.addGeoJson(location.geojson)
    locationData[target] = targetKml
    const bounds = new this.props.gMaps.LatLngBounds()
    const lats = []
    const lngs = []
    targetKml.forEach((feature) => {
      feature.getGeometry().forEachLatLng((latlng) => {
        bounds.extend(latlng)
        lats.push(latlng.lat())
        lngs.push(latlng.lng())
      })
    })
    const latLng = routeHelpers.centerFromGeoJson(lats, lngs)
    this.setMarker(latLng, location.city, target)

    this.setState({ locationData })
    map.fitBounds(bounds)

    if (this.state.speciality === 'truck' && markers[counterpart].title && latLng) {
      directionsDisplay.setMap(map)
      const request = {
        [target]: latLng,
        [counterpart]: markers[counterpart].getPosition(),
        travelMode: 'DRIVING'
      }
      directionsService.route(request, (result, status) => {
        if (status === 'OK') {
          directionsDisplay.setDirections(result)
        }
      })
    }

    return latLng
  }

  setMarker (address, name, target) {
    const {
      markers, map, directionsDisplay, directionsService
    } = this.state
    const { theme } = this.props
    const newMarkers = []
    if (markers[target].title !== undefined) {
      markers[target].setMap(null)
    }
    let icon
    if (target === 'origin') {
      icon = {
        url: colourSVG('location', theme),
        anchor: new this.props.gMaps.Point(18, 36),
        scaledSize: new this.props.gMaps.Size(36, 36)
      }
    } else {
      icon = {
        url: colourSVG('flag', theme),
        anchor: new this.props.gMaps.Point(10, 25),
        scaledSize: new this.props.gMaps.Size(36, 36)
      }
    }
    const marker = new this.props.gMaps.Marker({
      position: address,
      map,
      title: name,
      icon,
      optimized: false,
      keyboard: false
    })
    markers[target] = marker
    if (markers.origin.title !== undefined) {
      newMarkers.push(markers.origin)
    }
    if (markers.destination.title !== undefined) {
      newMarkers.push(markers.destination)
    }
    this.setState({ markers })
    const bounds = new this.props.gMaps.LatLngBounds()
    for (let i = 0; i < newMarkers.length; i++) {
      bounds.extend(newMarkers[i].getPosition())
    }
    if (!markers.origin.title && !markers.destination.title) {
      map.fitBounds(bounds)
    } else if (
      (markers.origin.title && !markers.destination.title) ||
      (!markers.origin.title && markers.destination.title)
    ) {
      map.setCenter(bounds.getCenter())
    } else {
      map.fitBounds(bounds, { top: 100, bottom: 20 })
    }
    if (this.state.speciality === 'truck' && markers.origin.title && markers.destination.title) {
      directionsDisplay.setMap(map)
      const request = {
        origin: markers.origin.getPosition(),
        destination: markers.destination.getPosition(),
        travelMode: 'DRIVING'
      }
      directionsService.route(request, (result, status) => {
        if (status === 'OK') {
          directionsDisplay.setDirections(result)
        }
      })
    }
  }

  setRouteError (origin, destination) {
    const { shipmentDispatch, t } = this.props
    const errors = []
    if (isDefined(origin) && isDefined(destination)) {
      errors.push({
        type: 'error',
        text: t('errors:noRoutesBetween', { origin, destination })
      })
    } else if (isDefined(origin) && !isDefined(destination)) {
      errors.push({
        type: 'error',
        text: t('errors:noRoutesFrom', { origin })
      })
    } else if (!origin && destination) {
      errors.push({
        type: 'error',
        text: t('errors:noRoutesTo', { destination })
      })
    } else {
      errors.push({
        type: 'error',
        text: t('errors:noRoutesFound')
      })
    }
    shipmentDispatch.setError({ stage: 'stage2', errors })
  }

  getPlace (placeId, callback) {
    const service = new this.props.gMaps.places.PlacesService(this.state.map)
    service.getDetails({ placeId }, place => callback(place))
  }

  extractCountries (props) {
    const { routes } = props.shipmentData
    const countries_origin = []
    const countries_destination = []
    routes.forEach((route) => {
      countries_origin.push(route.origin.country.toLowerCase())
      countries_destination.push(route.destination.country.toLowerCase())
    })

    const countries = {
      origin: countries_origin.filter(onlyUnique),
      destination: countries_destination.filter(onlyUnique)
    }

    this.setState({ countries })
  }

  initMap () {
    const mapsOptions = {
      center: {
        lat: 55.675647,
        lng: 12.567848
      },
      zoom: 5,
      mapTypeId: this.props.gMaps.MapTypeId.ROADMAP,
      disableDefaultUI: true,
      styles: mapStyles,
      keyboard: false
    }

    const map = new this.props.gMaps.Map(document.getElementById('map'), mapsOptions)
    removeTabIndex(map, this.props.gMaps)

    let directionsDisplay = false
    let directionsService = false
    if (this.state.speciality === 'truck') {
      directionsService = new this.props.gMaps.DirectionsService()
      directionsDisplay = new this.props.gMaps.DirectionsRenderer({ suppressMarkers: true })
    }
    this.setState({
      map,
      directionsService,
      directionsDisplay
    })
  }

  changeAddressFormVisibility (target, visibility) {
    this.setState((prevState) => {
      const key = `show${capitalize(target)}Fields`
      const value = visibility != null ? visibility : !prevState[key]

      return { [key]: value }
    })
  }

  triggerPlaceChanged (input, target) {
    // triggers a place change with the first result from google
    const service = new this.props.gMaps.places.AutocompleteService()
    service.getPlacePredictions({ input }, (_input) => {
      _input && _input[0] && this.getPlace(_input[0].place_id, (place) => {
        this.handlePlaceChange(place, target)
      })
    })
  }

  handlePlaceChange (place, target) {
    this.changeAddressFormVisibility(target, true)

    if (!place.geometry) {
      return
    }

    this.setMarker(
      {
        lat: place.geometry.location.lat(),
        lng: place.geometry.location.lng()
      },
      place.name,
      target
    )

    this.selectLocation(place, target)
  }

  handleLocationChange (location, target) {
    this.changeAddressFormVisibility(target, true)

    const latLng = this.setLocationMap(
      location,
      target
    )
    const address = {
      zipCode: location.postal_code,
      city: location.city,
      country: location.country,
      latitude: latLng.lat,
      longitude: latLng.lng,
      fullAddress: location.description
    }

    this.selectLocation(address, target)
  }

  filterTruckTypesByHub (truckTypeObject) {
    this.setState({ truckTypeObject })
  }

  updateAddressFieldsErrors (target) {
    if (this.props.nextStageAttempts === 0) {
      return
    }
    const counterpart = target === 'origin' ? 'destination' : 'origin'
    const fieldsHaveErrors = !this.state[target].fullAddress
    this.setState({ [`${target}FieldsHaveErrors`]: fieldsHaveErrors })
    const addressFormsHaveErrors = fieldsHaveErrors || this.state[`${counterpart}FieldsHaveErrors`]
    this.props.handleSelectLocation(target, addressFormsHaveErrors)
  }

  handleTrucking (event) {
    const { name, checked } = event.target
    if (name === 'has_pre_carriage') {
      if (checked) {
        this.updateAddressFieldsErrors('origin')
      }
      this.props.handleCarriageChange('has_pre_carriage', checked)
    }

    if (name === 'has_on_carriage') {
      if (checked) {
        this.updateAddressFieldsErrors('destination')
      }
      this.props.handleCarriageChange('has_on_carriage', checked)
    }
  }

  handleAddressChange (event) {
    this.props.handleAddressChange(event)
    const eventKeys = event.target.name.split('-')
    const key1 = eventKeys[0]
    const key2 = eventKeys[1]
    const val = event.target.value

    this.setState(prevState => ({
      ...prevState,
      [key1]: {
        ...prevState[key1],
        [key2]: val
      }
    }))
  }

  scopeNexusOptions (nexusIds, hubIds, target) {
    getRequests.nexuses(nexusIds, hubIds, target, this.props.routeIds, (data) => {
      if (Object.values(data)[0].length > 0) {
        this.setState(data)
      } else {
        target === 'origin' ? this.setDestNexus() : this.setOriginNexus()
      }
    })
  }

  showCompletionTick (target) {
    this.setState(prevState => ({
      truckingFound: {
        ...prevState.truckingFound,
        [target]: true
      }
    }))
    setTimeout(() => {
      this.setState(prevState => ({
        truckingFound: {
          ...prevState.truckingFound,
          [target]: false
        }
      }))
    }, 1500)
  }

  selectLocation (place, target) {
    this.setState({ fetchingtruckingAvailability: true }, () => {
      const counterpart = target === 'origin' ? 'destination' : 'origin'
      const isLocationObj = (place.latitude && place.longitude)

      const { shipmentData, filteredRouteIndexes } = this.props
      const { lookupTablesForRoutes, routes, shipment } = shipmentData

      const lat = isLocationObj ? place.latitude : place.geometry.location.lat()
      const lng = isLocationObj ? place.longitude : place.geometry.location.lng()
      const fullAddress = isLocationObj ? place.fullAddress : place.formatted_address
      const tenantId = shipment.tenant_id
      const loadType = shipment.load_type

      const prefix = target === 'origin' ? 'pre' : 'on'
      const indexesToUse = this.state.lastTarget === target ? routes.map((_, i) => i) : filteredRouteIndexes

      const availableHubIds = routeFilters.getHubIds(indexesToUse, lookupTablesForRoutes, routes, target)

      getRequests.findAvailability(
        lat,
        lng,
        tenantId,
        loadType,
        prefix,
        availableHubIds,
        (truckingAvailable, nexusIds, hubIds) => {
          if (!truckingAvailable) {
            getRequests.findNexus(lat, lng, (nexus) => {
              const { direction } = this.props.shipmentData.shipment
              const { scope } = this.props
              const carriageOptionScope = scope.carriage_options[`${prefix}_carriage`][direction]
              let nexusOption
              if (nexus && carriageOptionScope === 'optional') {
                nexusOption = routeFilters.getNexusOption(nexus.id, lookupTablesForRoutes, routes, target)
              }

              if (nexusOption) {
                this.handleTrucking({
                  target: {
                    name: `has_${prefix}_carriage`,
                    checked: false
                  }
                })

                this.setState(prevState => ({
                  autoText: {
                    ...prevState.autoText,
                    [target]: ''
                  }
                }))
              }
              target === 'origin' ? this.setOriginNexus(nexusOption) : this.setDestNexus(nexusOption)

              const fieldsHaveErrors = !nexusOption
              this.setState({ [`${target}FieldsHaveErrors`]: fieldsHaveErrors, lastTarget: target })
              this.props.handleSelectLocation(target, fieldsHaveErrors)
            })
          } else {
            this.props.handleSelectLocation(target, this.state[`${target}FieldsHaveErrors`])
            this.props.setNotesIds(nexusIds, target)
            if (isLocationObj) {
              this.props.setTargetAddress(target, { ...place, nexusIds })
            } else {
              addressFromPlace(place, this.props.gMaps, this.state.map, (address) => {
                this.props.setTargetAddress(target, { ...address, nexusIds })
              })
            }
          }
          this.showCompletionTick(target)
          this.setState(prevState => ({
            fetchingtruckingAvailability: false,
            truckingOptions: {
              ...prevState.truckingOptions,
              [`${prefix}Carriage`]: truckingAvailable
            },
            [`${target}FieldsHaveErrors`]: false,
            truckingHubs: {
              ...this.state.truckingHubs,
              [target]: hubIds
            },
            lastTarget: target
          }), () => {
            this.prepForSelect(target)
            setTimeout(() => {
              if (!this.isOnFocus[target]) this.changeAddressFormVisibility(target, false)
            }, 5000)
          })
        }
      )

      this.setState(prevState => ({
        autoText: { ...prevState.autoText, [target]: fullAddress }
      }))
    })
  }

  resetAuto (target) {
    const tmpAddress = {
      number: '',
      street: '',
      zipCode: '',
      city: '',
      country: '',
      fullAddress: ''
    }

    this.setState(prevState => ({
      autoText: { ...prevState.autoText, [target]: '' },
      [target]: tmpAddress
    }), () => this.props.setTargetAddress(target, tmpAddress))
  }

  handleAddressFormFocus (event) {
    const target = event.target.name.split('-')[0]
    this.isOnFocus[target] = event.type === 'focus'
    const targetLocation = this.props[target]
    if (targetLocation && event.type !== 'focus') {
      const newAutotext = `${targetLocation.street} ${targetLocation.number} ${targetLocation.city} ${targetLocation.zipCode} ${
        targetLocation.country
      }`
      this.triggerPlaceChanged(newAutotext, target)
    }
  }

  toggleModal () {
    this.setState({ showModal: !this.state.showModal })
  }

  loadPrevReq (props) {
    const {
      prevRequest,
      shipmentData
    } = props
    const { routes } = shipmentData
    if (!prevRequest || (prevRequest && !prevRequest.shipment)) {
      return
    }

    const { shipment } = prevRequest
    const newState = {}
    if (!props.has_pre_carriage) {
      const newStateOrigin = routes.find(o => (
        o.origin.nexusId === shipment.origin.nexus_id
      ))

      newState.oSelect = newStateOrigin
        ? routeHelpers.routeOption(newStateOrigin.origin)
        : {}
    }
    if (!props.has_on_carriage) {
      const newStateDestination = routes.find(d => (
        d.destination.nexusId === shipment.destination.nexus_id
      ))
      newState.dSelect = newStateDestination
        ? routeHelpers.routeOption(newStateDestination.destination)
        : {}
    }
    newState.autoText = {
      origin: shipment.origin.fullAddress || '',
      destination: shipment.destination.fullAddress || ''
    }
    if (newState.oSelect && newState.oSelect.label && shipment.origin.nexus_id) {
      this.state.map
        ? this.setOriginNexus(newState.oSelect)
        : setTimeout(() => {
          this.setOriginNexus(newState.oSelect)
        }, 500)
    }
    if (newState.dSelect && newState.dSelect.label && shipment.destination.nexus_id) {
      this.state.map
        ? this.setDestNexus(newState.dSelect)
        : setTimeout(() => {
          this.setDestNexus(newState.dSelect)
        }, 1000)
    }

    this.setState(newState, () => {
      this.prepForSelect('destination')
      this.prepForSelect('origin')
    })
  }

  selectedRoute (route) {
    const origin = {
      city: '',
      country: '',
      fullAddress: '',
      nexus_id: route.origin_id,
      nexus_name: route.origin_nexus
    }
    const destination = {
      city: '',
      country: '',
      fullAddress: '',
      nexus_id: route.origin_id,
      nexus_name: route.origin_nexus
    }
    this.setState({ origin, destination })
    this.setState({ showModal: !this.state.showModal })
    this.setState({ addressFromModal: !this.state.addressFromModal })
    this.setNexusesFromRoute(route)
  }

  loadReusedShipment () {
    const { reusedShipment, shipmentData } = this.props
    const { routes } = shipmentData
    if (!reusedShipment.shipment) {
      return
    }
    const { shipment } = reusedShipment
    const newState = {}
    if (!this.props.has_pre_carriage) {
      const newStateOrigin = routes.find(o => (
        o.origin.nexusId === shipment.origin_nexus_id
      ))
      newState.oSelect = routeHelpers.routeOption(newStateOrigin.origin)
    }
    if (!this.props.has_on_carriage) {
      const newStateDestination = routes.find(d => (
        d.destination.nexusId === shipment.destination_nexus_id
      ))
      newState.dSelect = routeHelpers.routeOption(newStateDestination.destination)
    }
    newState.autoText = {
      origin: shipment.has_pre_carriage ? shipment.pickup_address.geocoded_address : '',
      destination: shipment.has_on_carriage ? shipment.delivery_address.geocoded_address : ''
    }
    if (shipment.origin_nexus_id) {
      this.state.map
        ? this.setOriginNexus(newState.oSelect)
        : setTimeout(() => {
          this.setOriginNexus(newState.oSelect)
        }, 500)
    }
    if (shipment.destination_nexus_id) {
      this.state.map
        ? this.setDestNexus(newState.dSelect)
        : setTimeout(() => {
          this.setDestNexus(newState.dSelect)
        }, 500)
    }

    this.setState(newState)
  }

  clearAddressFields (target) {
    const targets = target ? [target] : ['origin', 'destination']
    targets.forEach((t) => {
      const selectKey = t === 'origin' ? 'oSelect' : 'dSelect'
      this.setState(prevState => ({
        truckingHubs: {
          ...prevState.truckingHubs,
          [t]: {}
        },
        autoText: {
          ...prevState.autoText,
          [t]: ''
        },
        [selectKey]: {}
      }), () => this.props.setTargetAddress(t, {}))
    })
  }

  prepForSelect (target) {
    this.setState((prevState) => {
      const {
        truckingHubs, oSelect, dSelect
      } = prevState
      const { filteredRouteIndexes } = this.props
      const { lookupTablesForRoutes, routes } = this.props.shipmentData
      const targetLocation = target === 'origin' ? oSelect : dSelect
      const targetTrucking = truckingHubs[target]
      const counterpart = target === 'origin' ? 'destination' : 'origin'
      const counterpartLocation = target === 'origin' ? dSelect : oSelect
      const counterpartTrucking = truckingHubs[counterpart]
      let indexes = filteredRouteIndexes.slice()
      const unfilteredRouteIndexes = routes.map((_, i) => i)
      if (targetLocation.label) {
        indexes = routeFilters.selectFromLookupTable(
          lookupTablesForRoutes,
          [targetLocation.value.id], `${target}Nexus`
        )
      } else if (targetTrucking) {
        indexes = routeFilters.selectFromLookupTable(
          lookupTablesForRoutes,
          targetTrucking, `${target}Hub`
        )
      } else if (!targetLocation.label && !targetTrucking) {
        indexes = unfilteredRouteIndexes
      }

      const indexesToUse = (counterpartLocation.label || counterpartTrucking)
        ? filteredRouteIndexes : unfilteredRouteIndexes

      let newFilteredRouteIndexes = routeFilters.scopeIndexes(
        indexesToUse,
        indexes
      )

      let fieldsHaveErrors = false
      if (targetTrucking && newFilteredRouteIndexes.length === 0) {
        newFilteredRouteIndexes = filteredRouteIndexes
        fieldsHaveErrors = true
        const addressFormsHaveErrors =
          fieldsHaveErrors || prevState[`${counterpart}FieldsHaveErrors`]
        this.props.handleSelectLocation(target, addressFormsHaveErrors)
      }
      const newFilteredRoutes = []
      const selectOptions = []
      const counterpartNexusIds = []
      indexes.forEach((idx) => {
        const route = routes[idx]
        newFilteredRoutes.push(route)
        if (counterpartNexusIds.includes(route[counterpart].nexusId)) return

        counterpartNexusIds.push(route[counterpart].nexusId)

        selectOptions.push(routeHelpers.routeOption(route[counterpart]))
      })

      const truckingBoolean = newFilteredRouteIndexes.some(i => routes[i][counterpart].truckTypes.length > 0)

      const carriage = target === 'destination' ? this.props.has_on_carriage : this.props.has_pre_carriage

      if (targetTrucking && carriage) this.prepTruckTypes(newFilteredRoutes, target)
      if (newFilteredRouteIndexes.length === 0) {
        this.setRouteError(counterpartLocation.label, targetLocation.label)
      }

      this.props.updateFilteredRouteIndexes(newFilteredRouteIndexes)

      return {
        [`available${capitalize(counterpart)}Nexuses`]: selectOptions,
        [`${counterpart}TruckingAvailable`]: truckingBoolean,
        [`${target}FieldsHaveErrors`]: fieldsHaveErrors
      }
    })
  }

  prepTruckTypes (routes, target) {
    const { selectedTrucking } = this.props
    const truckingTarget = target === 'origin' ? 'pre_carriage' : 'on_carriage'
    const truckTypes = []
    routes.forEach((route) => {
      if (route[target].truckTypes) {
        route[target].truckTypes.forEach((truckType) => {
          if (!truckTypes.includes(truckType)) {
            truckTypes.push(truckType)
          }
        })
      }
    })
    this.setState({
      truckTypes: {
        ...this.state.truckTypes,
        [target]: truckTypes
      }
    })

    if (!truckTypes.includes(selectedTrucking[truckingTarget])) {
      const truckType = truckTypes.includes(this.defaultTruckType)
        ? this.defaultTruckType
        : truckTypes[0]

      const syntheticEvent = { target: { id: `${truckingTarget}-${truckType}` } }
      this.props.handleTruckingDetailsChange(syntheticEvent)
    }
  }

  isSwitchable () {
    const { oSelect, dSelect, autoText } = this.state

    return (
      (!!oSelect.label && autoText.destination !== '') ||
      (!!dSelect.label && autoText.origin !== '') ||
      (!!dSelect.label && !!oSelect.label) ||
      (autoText.origin !== '' && autoText.destination !== '')
    )
  }

  render () {
    const {
      scope, shipmentData, nextStageAttempts, origin, destination, selectedTrucking, t
    } = this.props

    let originOptions = []
    let destinationOptions = []

    const {
      originFieldsHaveErrors,
      destinationFieldsHaveErrors,
      availableOriginNexuses,
      availableDestinationNexuses,
      truckingOptions,
      speciality,
      truckTypes,
      originTruckingAvailable,
      destinationTruckingAvailable,
      fetchingtruckingAvailability,
      countries,
      truckingFound
    } = this.state

    if (availableDestinationNexuses) destinationOptions = ShipmentLocationBox.sortOptions(availableDestinationNexuses)
    if (availableOriginNexuses) originOptions = ShipmentLocationBox.sortOptions(availableOriginNexuses)
    const requireFullAddress = scope.require_full_address
    const showOriginError = !this.state.oSelect && nextStageAttempts > 0
    const originNexus = (
      <div style={{ position: 'relative' }} className="flex-100 layout-row layout-wrap">
        <StyledSelect
          name="origin-hub"
          className={styles.select}
          value={this.state.oSelect}
          placeholder={t('shipment:origin')}
          options={originOptions.sort((a, b) => a.label - b.label)}
          disabled={fetchingtruckingAvailability}
          onChange={this.setOriginNexus}
          nextStageAttempt={nextStageAttempts > 0}
        />
        <span className={errorStyles.error_message} style={{ color: 'white' }}>
          {showOriginError ? t('errors:notBlank') : ''}
        </span>
      </div>
    )

    const showDestinationError = !this.state.dSelect && nextStageAttempts > 0
    const destNexus = (
      <div style={{ position: 'relative' }} className="flex-100 layout-row layout-wrap">
        <StyledSelect
          name="destination-hub"
          className={styles.select}
          value={this.state.dSelect}
          disabled={fetchingtruckingAvailability}
          placeholder={t('shipment:destination')}
          options={destinationOptions.sort((a, b) => a.label - b.label)}
          onChange={this.setDestNexus}
          backgroundColor={backgroundColor}
          nextStageAttempt={nextStageAttempts > 0}
        />
        <span className={errorStyles.error_message} style={{ color: 'white' }}>
          {showDestinationError ? t('errors:notBlank') : ''}
        </span>
      </div>
    )
    let toggleLogic =
      this.props.has_pre_carriage && this.state.showOriginFields ? styles.visible : ''
    const originFields = (
      <div
        className={`flex-100 layout-row layout-wrap ${styles.address_form_wrapper} ${toggleLogic}`}
      >
        <div
          className={`flex-100 layout-row layout-align-center-center ${styles.btn_address_form} ${
            this.props.has_pre_carriage ? '' : styles.hidden
          }`}
          onClick={() => this.changeAddressFormVisibility('origin')}
        >
          <i className={`${styles.down} flex-none fa fa-angle-double-down`} />
          <i className={`${styles.up} flex-none fa fa-angle-double-up`} />
        </div>
        <div
          className={`${styles.address_form} flex-100 layout-row layout-wrap layout-align-center ccb_pre_address_form`}
        >
          { fetchingtruckingAvailability ? <LoadingSpinner size="medium" /> : '' }
          { truckingFound.origin ? (
            <CircleCompletion
              icon="fa fa-check"
              iconColor="white"
              animated={truckingFound.origin}
              size="150px"
              opacity={truckingFound.origin ? '1' : '0'}
            />
          ) : '' }
          { (!fetchingtruckingAvailability && !truckingFound.origin) ? (
            <div
              className="flex-100 layout-row layout-wrap layout-align-center"
            >
              <div
                className={`${styles.address_form_title} flex-100 layout-row layout-align-start-center`}
              >
                <p className="flex-none">{t('shipment:enterPickUp')}</p>
              </div>

              <input
                name="origin-street"
                className={
                  `flex-90 ${styles.input} ` +
                `${nextStageAttempts > 0 && !origin.street && requireFullAddress ? styles.with_errors : ''}`
                }
                type="string"
                onChange={this.handleAddressChange}
                onFocus={this.handleAddressFormFocus}
                onBlur={this.handleAddressFormFocus}
                value={origin.street || ''}
                autoComplete="off"
                placeholder={t('user:street')}
              />
              <input
                id="not-auto"
                name="origin-number"
                className={
                  `flex-90 ${styles.input} ` +
                `${nextStageAttempts > 0 && !origin.number && requireFullAddress ? styles.with_errors : ''}`
                }
                type="string"
                onChange={this.handleAddressChange}
                onFocus={this.handleAddressFormFocus}
                onBlur={this.handleAddressFormFocus}
                value={origin.number || ''}
                autoComplete="off"
                placeholder={t('user:number')}
              />
              <input
                name="origin-zipCode"
                className={
                  `flex-90 ${styles.input} ` +
                `${nextStageAttempts > 0 && !origin.zipCode ? styles.with_errors : ''}`
                }
                type="string"
                onChange={this.handleAddressChange}
                onFocus={this.handleAddressFormFocus}
                onBlur={this.handleAddressFormFocus}
                value={origin.zipCode || ''}
                autoComplete="off"
                placeholder={t('user:postalCode')}
              />
              <input
                name="origin-city"
                className={
                  `flex-90 ${styles.input} ` +
                `${nextStageAttempts > 0 && !origin.city ? styles.with_errors : ''}`
                }
                type="string"
                onChange={this.handleAddressChange}
                onFocus={this.handleAddressFormFocus}
                onBlur={this.handleAddressFormFocus}
                value={origin.city || ''}
                autoComplete="off"
                placeholder={t('user:city')}
              />
              <input
                name="origin-country"
                className={
                  `flex-90 ${styles.input} ` +
                `${nextStageAttempts > 0 && !origin.country ? styles.with_errors : ''}`
                }
                type="string"
                onChange={this.handleAddressChange}
                onFocus={this.handleAddressFormFocus}
                onBlur={this.handleAddressFormFocus}
                value={origin.country || ''}
                autoComplete="off"
                placeholder={t('user:country')}
              />
              <div className="flex-100 layout-row layout-align-start-center">
                <div
                  className={`${styles.clear_sec} flex-none layout-row layout-align-end-center`}
                  onClick={() => this.resetAuto('origin')}
                >
                  <i className="fa fa-times flex-none" />
                  <p className="offset-5 flex-none" style={{ paddingRight: '10px' }}>
                  Clear
                  </p>
                </div>
              </div>
            </div>
          )
            : ''
          }
        </div>
      </div>
    )

    const originAuto = (
      <div className="flex-100 ccb_origin_carriage_input layout-row layout-wrap">
        <Autocomplete
          gMaps={this.props.gMaps}
          theme={this.props.theme}
          map={this.state.map}
          input={this.state.autoText.origin}
          hasErrors={originFieldsHaveErrors}
          handlePlaceSelect={place => this.handlePlaceChange(place, 'origin')}
          handleLocationSelect={place => this.handleLocationChange(place, 'origin')}
          countries={countries.origin}
        />
      </div>
    )

    toggleLogic =
      this.props.has_on_carriage && this.state.showDestinationFields ? styles.visible : ''
    const destFields = (
      <div
        className={`flex-100 layout-row layout-wrap ${styles.address_form_wrapper} ${toggleLogic}`}
      >
        <div
          className={`flex-100 layout-row layout-align-center-center ${styles.btn_address_form} ${
            this.props.has_on_carriage ? '' : styles.hidden
          }`}
          onClick={() => this.changeAddressFormVisibility('destination')}
        >
          <i className={`${styles.down} flex-none fa fa-angle-double-down`} />
          <i className={`${styles.up} flex-none fa fa-angle-double-up`} />
        </div>
        <div className={`${styles.address_form} ${toggleLogic} flex-100 layout-row layout-wrap layout-align-center ccb_on_address_form`}>
          { fetchingtruckingAvailability ? <LoadingSpinner size="medium" /> : '' }
          { truckingFound.destination ? (
            <CircleCompletion
              icon="fa fa-check"
              iconColor="white"
              animated={truckingFound.destination}
              size="150px"
              opacity={truckingFound.destination ? '1' : '0'}
            />
          ) : '' }
          { (!fetchingtruckingAvailability && !truckingFound.destination) ? (
            <div
              className="flex-100 layout-row layout-wrap layout-align-center"
            >
              <div
                className={`${styles.address_form_title} flex-100 layout-row layout-align-start-center`}
              >
                <p className="flex-none">{t('shipment:enterDelivery')}</p>
              </div>

              <input
                name="destination-street"
                className={
                  `flex-90 ${styles.input} ` +
              `${nextStageAttempts > 0 && !destination.street && requireFullAddress ? styles.with_errors : ''}`
                }
                onChange={this.handleAddressChange}
                onFocus={this.handleAddressFormFocus}
                onBlur={this.handleAddressFormFocus}
                value={destination.street || ''}
                autoComplete="off"
                placeholder={t('user:street')}
                disabled={!this.state.showDestinationFields}
              />
              <input
                name="destination-number"
                className={
                  `flex-90 ${styles.input} ` +
              `${nextStageAttempts > 0 && !destination.number && requireFullAddress ? styles.with_errors : ''}`
                }
                type="string"
                onChange={this.handleAddressChange}
                onFocus={this.handleAddressFormFocus}
                onBlur={this.handleAddressFormFocus}
                value={destination.number || ''}
                autoComplete="off"
                placeholder={t('user:number')}
                disabled={!this.state.showDestinationFields}
              />
              <input
                name="destination-zipCode"
                className={
                  `flex-90 ${styles.zipCode} ${styles.input}` +
              `${nextStageAttempts > 0 && !destination.number ? styles.with_errors : ''}`
                }
                onChange={this.handleAddressChange}
                onFocus={this.handleAddressFormFocus}
                onBlur={this.handleAddressFormFocus}
                value={destination.zipCode || ''}
                autoComplete="off"
                placeholder={t('user:postalCode')}
                disabled={!this.state.showDestinationFields}
              />
              <input
                name="destination-city"
                className={
                  `flex-90 ${styles.input} ` +
              `${nextStageAttempts > 0 && !destination.city ? styles.with_errors : ''}`
                }
                onChange={this.handleAddressChange}
                onFocus={this.handleAddressFormFocus}
                onBlur={this.handleAddressFormFocus}
                value={destination.city || ''}
                autoComplete="off"
                placeholder={t('user:city')}
                disabled={!this.state.showDestinationFields}
              />
              <input
                name="destination-country"
                className={
                  `flex-90 ${styles.input} ` +
              `${nextStageAttempts > 0 && !destination.country ? styles.with_errors : ''}`
                }
                onChange={this.handleAddressChange}
                onFocus={this.handleAddressFormFocus}
                onBlur={this.handleAddressFormFocus}
                value={destination.country || ''}
                autoComplete="off"
                placeholder={t('user:country')}
                disabled={!this.state.showDestinationFields}
              />
              <div className="flex-100 layout-row layout-align-start-center">
                <div
                  className={`${styles.clear_sec} flex-none layout-row layout-align-end-center`}
                  onClick={() => this.resetAuto('destination')}
                >
                  <i className="fa fa-times flex-none" />
                  <p className="offset-5 flex-none" style={{ paddingRight: '10px' }}>
                    {t('common:clear')}
                  </p>
                </div>
              </div>
            </div>
          ) : ''
          }
        </div>
      </div>
    )

    const destAuto = (
      <div className="flex-100 ccb_destination_carriage_input layout-row layout-wrap">
        <div className={styles.input_wrapper}>
          <Autocomplete
            gMaps={this.props.gMaps}
            theme={this.props.theme}
            t={t}
            hasErrors={destinationFieldsHaveErrors}
            map={this.state.map}
            input={this.state.autoText.destination}
            handlePlaceSelect={place => this.handlePlaceChange(place, 'destination')}
            handleLocationSelect={place => this.handleLocationChange(place, 'destination')}
            countries={countries.destination}
          />
        </div>
      </div>
    )
    const displayLocationOptions = (target) => {
      if (target === 'origin' && !this.props.has_pre_carriage) {
        return originNexus
      }
      if (target === 'destination' && !this.props.has_on_carriage) {
        return destNexus
      }

      return ''
    }
    const { shipment } = shipmentData
    /* eslint-disable camelcase */
    const { theme, has_pre_carriage, has_on_carriage } = this.props
    const errorClass =
      (has_pre_carriage && originFieldsHaveErrors) || (has_on_carriage && destinationFieldsHaveErrors)
        ? styles.with_errors
        : ''
    /* eslint-enable camelcase */

    const toggleCSS = `
      .react-toggle--checked .react-toggle-track {
        background: linear-gradient(
          90deg,
          ${theme.colors.brightPrimary} 0%,
          ${theme.colors.brightSecondary} 100%
        );
        border: 0.5px solid rgba(0, 0, 0, 0);
      }
    `

    const loadType = shipment.load_type
    const preCarriageTruckTypes = (
      <div className="flex-100 layout-row layout-align-center-center">
        <TruckingDetails
          theme={theme}
          trucking={selectedTrucking}
          truckTypes={truckTypes.origin}
          target="pre_carriage"
          handleTruckingDetailsChange={this.props.handleTruckingDetailsChange}
        />
      </div>)
    const onCarriageTruckTypes = (
      <div className="flex-100 layout-row layout-align-center-center">
        <TruckingDetails
          className="flex-100"
          theme={theme}
          trucking={selectedTrucking}
          truckTypes={truckTypes.destination}
          target="on_carriage"
          handleTruckingDetailsChange={this.props.handleTruckingDetailsChange}
        />
      </div>)
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''
    const truckTypesStyle =
      loadType === 'container' && (this.props.has_on_carriage || this.props.has_pre_carriage)
        ? styles.with_truck_types : ''
    const mapStyle = {
      width: '100%',
      height: '600px',
      borderRadius: '3px',
      boxShadow: '1px 1px 2px 2px rgba(0,1,2,0.25)'
    }
    if (this.props.hideMap) {
      mapStyle.display = 'none'
    }

    return (
      <div className="layout-row flex-100 layout-wrap layout-align-center-center">
        <div
          className={`layout-row flex-100 layout-wrap layout-align-center-start ${styles.slbox}`}
        >
          <div className={`${styles.map_container} layout-row flex-none layout-align-start-start`}>
            <div
              className={`flex-100 layout-row layout-wrap layout-align-center-start ${
                styles.input_box
              } ${truckTypesStyle} ${errorClass}`}
            >
              <div className="flex-45 layout-row layout-wrap layout-align-start-start mc">
                {speciality !== 'truck'
                  ? (
                    <div
                      className={
                        'flex-45 layout-row layout-align-start layout-wrap ' +
                      `${styles.toggle_box} ` +
                      `${!truckingOptions.preCarriage ? styles.not_available : ''}`
                      }
                    >
                      { originTruckingAvailable ? (
                        <TruckingTooltip
                          truckingBoolean={!originTruckingAvailable}
                          truckingOptions={truckingOptions}
                          carriage="preCarriage"
                          hubName={this.state.oSelect.label}
                          direction={shipment.direction}
                          scope={scope}
                        />
                      ) : '' }

                      { originTruckingAvailable ? (
                        <Toggle
                          className="flex-none ccb_pre_carriage"
                          id="has_pre_carriage"
                          name="has_pre_carriage"
                          tabIndex="-1"
                          checked={this.props.has_pre_carriage}
                          onChange={this.handleTrucking}
                        />
                      ) : '' }
                      <label htmlFor="pre-carriage" style={{ marginLeft: '15px' }}>
                        {t('shipment:pickUp')}
                      </label>
                      {loadType === 'container' && this.props.has_pre_carriage ? preCarriageTruckTypes : ''}
                    </div>
                  ) : (
                    <div className={`flex-20 layout-row layout-align-end-center ${styles.trucking_text}`}>
                      <p className="flex-none">
                        {t('shipment:pickUp')}
:
                      </p>
                    </div>
                  )}
                <div className={`flex-55 layout-row layout-wrap ${styles.search_box}`}>
                  {this.props.has_pre_carriage ? originAuto : ''}
                  {displayLocationOptions('origin')}
                  {originFields}
                </div>
              </div>

              <div
                className="flex-5 layout-row layout-align-center-center"
                style={{ height: '60px' }}
              />

              <div className="flex-45 layout-row layout-wrap layout-align-end-start">
                {speciality !== 'truck'
                  ? (
                    <div
                      className={
                        'flex-45 layout-row layout-align-start layout-wrap ' +
                      `${styles.toggle_box} ` +
                      `${!truckingOptions.onCarriage ? styles.not_available : ''}`
                      }
                    >
                      { destinationTruckingAvailable ? (
                        <TruckingTooltip
                          truckingBoolean={!destinationTruckingAvailable}
                          truckingOptions={truckingOptions}
                          carriage="onCarriage"
                          hubName={this.state.dSelect.label}
                          direction={shipment.direction}
                          scope={scope}
                        />
                      ) : '' }

                      <label htmlFor="on-carriage" style={{ marginRight: '15px' }}>
                        {t('shipment:delivery')}
                      </label>
                      { destinationTruckingAvailable ? (
                        <Toggle
                          className="flex-none ccb_on_carriage"
                          id="has_on_carriage"
                          name="has_on_carriage"
                          tabIndex="-1"
                          checked={this.props.has_on_carriage}
                          onChange={this.handleTrucking}
                        />
                      ) : '' }
                      {loadType === 'container' && this.props.has_on_carriage ? onCarriageTruckTypes : ''}
                    </div>
                  ) : (
                    <div className={`flex-20 layout-row layout-align-end-center ${styles.trucking_text}`}>
                      <p className="flex-none">
                        {t('shipment:delivery')}
:
                      </p>
                    </div>
                  )}
                <div className={`flex-55 layout-row layout-wrap ${styles.search_box}`}>
                  {this.props.has_on_carriage ? destAuto : ''}
                  {displayLocationOptions('destination')}
                  {destFields}
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div id="map" style={mapStyle} />
            </div>
          </div>
          {styleTagJSX}
        </div>
      </div>
    )
  }
}

ShipmentLocationBox.propTypes = {
  nextStageAttempts: PropTypes.integer,
  t: PropTypes.func.isRequired,
  handleSelectLocation: PropTypes.func.isRequired,
  gMaps: PropTypes.gMaps.isRequired,
  theme: PropTypes.theme,
  setNotesIds: PropTypes.func,
  shipmentData: PropTypes.shipmentData,
  shipmentDispatch: PropTypes.objectOf(PropTypes.func),
  setTargetAddress: PropTypes.func.isRequired,
  handleAddressChange: PropTypes.func.isRequired,
  handleCarriageChange: PropTypes.func.isRequired,
  allNexuses: PropTypes.shape({
    origins: PropTypes.array,
    destinations: PropTypes.array
  }).isRequired,
  has_on_carriage: PropTypes.bool,
  has_pre_carriage: PropTypes.bool,
  selectedTrucking: PropTypes.objectOf(PropTypes.any),
  handleTruckingDetailsChange: PropTypes.func,
  origin: PropTypes.objectOf(PropTypes.any).isRequired,
  destination: PropTypes.objectOf(PropTypes.any).isRequired,
  routeIds: PropTypes.arrayOf(PropTypes.number),
  prevRequest: PropTypes.shape({
    shipment: PropTypes.shipment
  }),
  reusedShipment: PropTypes.shape({
    shipment: PropTypes.shipment
  }),
  scope: PropTypes.scope.isRequired,
  filteredRouteIndexes: PropTypes.arrayOf(PropTypes.number).isRequired,
  updateFilteredRouteIndexes: PropTypes.func.isRequired,
  hideMap: PropTypes.bool
}

ShipmentLocationBox.defaultProps = {
  nextStageAttempts: 0,
  theme: null,
  selectedTrucking: {},
  shipmentDispatch: {},
  shipmentData: null,
  setNotesIds: null,
  routeIds: [],
  prevRequest: null,
  has_on_carriage: true,
  has_pre_carriage: true,
  handleTruckingDetailsChange: null,
  reusedShipment: null,
  hideMap: false
}

export default withNamespaces(['errors', 'shipment', 'user', 'nav', 'common'])(ShipmentLocationBox)
