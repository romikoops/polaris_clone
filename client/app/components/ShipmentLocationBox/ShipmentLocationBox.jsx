import React, { Component } from 'react'
import Select from 'react-select'
import Toggle from 'react-toggle'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import '../../styles/react-toggle.scss'
import '../../styles/select-css-custom.css'
import styles from './ShipmentLocationBox.scss'
import errorStyles from '../../styles/errors.scss'
// import defaults from '../../styles/default_classes.scss'
import { colorSVG, determineSpecialism } from '../../helpers'
import { mapStyling } from '../../constants/map.constants'
// import { Modal } from '../Modal/Modal'
// import { AvailableRoutes } from '../AvailableRoutes/AvailableRoutes'
// import { RoundButton } from '../RoundButton/RoundButton'
import { capitalize } from '../../helpers/stringTools'
import addressFromPlace from './addressFromPlace'
import getRequests from './getRequests'
import routeFilters from './routeFilters'
import routeHelpers from './routeHelpers'
import TruckingTooltip from './TruckingTooltip'
import TruckingDetails from '../TruckingDetails/TruckingDetails'

const mapStyle = {
  width: '100%',
  height: '600px',
  borderRadius: '3px',
  boxShadow: '1px 1px 2px 2px rgba(0,1,2,0.25)'
}

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
    background-color: ${props => backgroundColor(props)};
    ${props => placeholderColorOverwrite(props)};
  }
  .Select-option {
    background-color: #f9f9f9;
  }
`

export class ShipmentLocationBox extends Component {
  constructor (props) {
    super(props)
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
      showModal: false,
      locationFromModal: false,
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
      truckingHubs: {}
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
    this.postToggleAutocomplete = this.postToggleAutocomplete.bind(this)
    this.initAutocomplete = this.initAutocomplete.bind(this)
    this.setNexusesFromRoute = this.setNexusesFromRoute.bind(this)
    this.resetAuto = this.resetAuto.bind(this)
    this.setMarker = this.setMarker.bind(this)
    this.handleAuto = this.handleAuto.bind(this)
    this.changeAddressFormVisibility = this.changeAddressFormVisibility.bind(this)
    this.toggleModal = this.toggleModal.bind(this)
    this.selectedRoute = this.selectedRoute.bind(this)
    this.loadPrevReq = this.loadPrevReq.bind(this)
    this.handleAddressFormFocus = this.handleAddressFormFocus.bind(this)
    this.handleSwap = this.handleSwap.bind(this)
    this.scopeNexusOptions = this.scopeNexusOptions.bind(this)
    this.removeAutocompleteListener = this.removeAutocompleteListener.bind(this)
  }

  componentWillMount () {
    if (this.props.reusedShipment && this.props.reusedShipment.shipment) {
      this.loadReusedShipment()
    } else if (this.props.prevRequest && this.props.prevRequest.shipment) {
      this.loadPrevReq()
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
    if (!this.props.has_on_carriage && nextProps.has_pre_carriage) {
      this.postToggleAutocomplete('origin')
    }
    if (!this.props.has_pre_carriage && nextProps.has_on_carriage) {
      this.postToggleAutocomplete('destination')
    }
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
  }

  componentWillUnmount () {
    ['origin', 'destination'].forEach(target => this.removeAutocompleteListener(target))
  }

  setDestNexus (event) {
    // this.scopeNexusOptions(event && event.value ? [event.value.id] : [], 'origin')

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
      this.props.setTargetAddress('destination', destination)
      this.setMarker({ lat, lng }, destination.nexus_name, 'destination')
      this.setState({ dSelect }, () => this.prepForSelect('destination'))
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
      this.props.setTargetAddress('destination', {})
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
    // this.scopeNexusOptions(event && event.value ? [event.value.id] : [], 'destination')
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

      this.props.setTargetAddress('origin', origin)
      this.setMarker({ lat, lng }, origin.nexus_name, 'origin')
      this.setState({ oSelect }, () => this.prepForSelect('origin'))
      this.props.setNotesIds([event.value.id], 'origin')
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
      this.props.setTargetAddress('origin', {})
    }
  }

  setMarker (location, name, target) {
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
        anchor: new this.props.gMaps.Point(18, 18),
        scaledSize: new this.props.gMaps.Size(36, 36)
      }
    } else {
      icon = {
        url: colourSVG('flag', theme),
        anchor: new this.props.gMaps.Point(18, 18),
        scaledSize: new this.props.gMaps.Size(36, 36)
      }
    }
    const marker = new this.props.gMaps.Marker({
      position: location,
      map,
      title: name,
      icon,
      optimized: false
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
      map.fitBounds(bounds, { top: 20 })
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

  getPlace (placeId, callback) {
    const service = new this.props.gMaps.places.PlacesService(this.state.map)
    service.getDetails({ placeId }, place => callback(place))
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
    this.setState({ locationFromModal: !this.state.locationFromModal })
    this.setNexusesFromRoute(route)
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
      styles: mapStyles
    }

    const map = new this.props.gMaps.Map(document.getElementById('map'), mapsOptions)
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

    if (this.props.has_pre_carriage) {
      this.initAutocomplete(map, 'origin')
      setTimeout(() => {
        this.triggerPlaceChanged(this.state.autoText.origin, 'origin')
      }, 750)
    }

    if (this.props.has_on_carriage) {
      this.initAutocomplete(map, 'destination')
      setTimeout(() => {
        this.triggerPlaceChanged(this.state.autoText.destination, 'destination')
      }, 750)
    }
  }

  initAutocomplete (map, target) {
    const input = document.getElementById(target)
    const autocomplete = new this.props.gMaps.places.Autocomplete(input)
    autocomplete.bindTo('bounds', map)

    this.removeAutocompleteListener(target)

    const autoListener = this.addAutocompleteListener(map, autocomplete, target)

    this.setState(prevState => (
      { autoListener: { ...prevState.autoListener, [target]: autoListener } }
    ))
  }

  postToggleAutocomplete (target) {
    const { map } = this.state

    if (target === 'origin' || target === 'destination') {
      setTimeout(() => this.initAutocomplete(map, target), 1000)
    }
  }

  changeAddressFormVisibility (target, visibility) {
    const key = `show${capitalize(target)}Fields`
    const value = visibility != null ? visibility : !this.state[key]
    this.setState({ [key]: value })
  }

  removeAutocompleteListener (target) {
    const autoListener = this.state.autoListener[target]
    autoListener && autoListener.remove()
  }

  addAutocompleteListener (aMap, autocomplete, target) {
    this.infowindow = new this.props.gMaps.InfoWindow()
    this.infowindowContent = document.getElementById('infowindow-content')
    this.infowindow.setContent(this.infowindowContent)

    this.marker = new this.props.gMaps.Marker({
      map: aMap,
      anchorPoint: new this.props.gMaps.Point(0, -29)
    })
    if (autocomplete.getPlace()) this.handlePlaceChange(autocomplete, target)

    return autocomplete.addListener('place_changed', () => {
      this.handlePlaceChange(autocomplete.getPlace(), target)
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

    this.infowindow.close()
    this.marker.setVisible(false)
    if (!place.geometry) {
      console.error(`No details available for input: '${place.name}'`)

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
  filterTruckTypesByHub (truckTypeObject) {
    this.setState({ truckTypeObject })
    console.log(truckTypeObject)
  }

  updateAddressFieldsErrors (target) {
    if (this.props.nextStageAttempts === 0) {
      return
    }
    const counterpart = target === 'origin' ? 'destination' : 'origin'
    const fieldsHaveErrors = !this.state[target].fullAddress
    this.setState({ [`${target}FieldsHaveErrors`]: fieldsHaveErrors })
    const addressFormsHaveErrors = fieldsHaveErrors || this.state[`${counterpart}FieldsHaveErrors`]
    this.props.handleSelectLocation(addressFormsHaveErrors)
  }

  handleTrucking (event) {
    const { name, checked } = event.target
    if (name === 'has_pre_carriage') {
      if (checked) {
        this.postToggleAutocomplete('origin')
        this.updateAddressFieldsErrors('origin')
      }
      this.props.handleCarriageChange('has_pre_carriage', checked)
    }

    if (name === 'has_on_carriage') {
      if (checked) {
        this.postToggleAutocomplete('destination')
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

    this.setState({
      ...this.state,
      [key1]: {
        ...this.state[key1],
        [key2]: val
      }
    })
  }

  scopeNexusOptions (nexusIds, hubIds, target) {
    getRequests.nexuses(nexusIds, hubIds, target, this.props.routeIds, (data) => {
      console.log(Object.values(data)[0])
      if (Object.values(data)[0].length > 0) {
        this.setState(data)
      } else {
        target === 'origin' ? this.setDestNexus() : this.setOriginNexus()
      }
    })
  }

  handleAuto (event) {
    const { name, value } = event.target
    this.setState({ autoText: { [name]: value } })
  }

  selectLocation (place, target) {
    const counterpart = target === 'origin' ? 'destination' : 'origin'

    setTimeout(() => {
      if (!this.isOnFocus[target]) this.changeAddressFormVisibility(target, false)
    }, 6000)

    const { shipmentData, filteredRouteIndexes } = this.props
    const { lookupTablesForRoutes, routes, shipment } = shipmentData
    const lat = place.geometry.location.lat()
    const lng = place.geometry.location.lng()

    const tenantId = shipment.tenant_id
    const loadType = shipment.load_type

    const prefix = target === 'origin' ? 'pre' : 'on'

    const availableHubIds = routeFilters.getHubIds(filteredRouteIndexes, lookupTablesForRoutes, routes, target)
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
              this.setState({
                autoText: { [target]: '' }
              })
            }
            target === 'origin' ? this.setOriginNexus(nexusOption) : this.setDestNexus(nexusOption)

            const fieldsHaveErrors = !nexusOption
            this.setState({ [`${target}FieldsHaveErrors`]: fieldsHaveErrors })
            const addressFormsHaveErrors =
              fieldsHaveErrors || this.state[`${counterpart}FieldsHaveErrors`]
            this.props.handleSelectLocation(addressFormsHaveErrors)
          })
        } else {
          this.setState({
            [`${target}FieldsHaveErrors`]: false,
            truckingHubs: {
              ...this.state.truckingHubs,
              [target]: hubIds
            }
          }, () => this.prepForSelect(target))
          this.props.handleSelectLocation(this.state[`${counterpart}FieldsHaveErrors`])
          this.props.setNotesIds(nexusIds, target)
          // this.scopeNexusOptions(nexusIds, hubIds, counterpart)

          addressFromPlace(place, this.props.gMaps, this.state.map, (address) => {
            this.props.setTargetAddress(target, { ...address, nexusIds })
          })
        }

        this.setState({
          truckingOptions: {
            ...this.state.truckingOptions,
            [`${prefix}Carriage`]: truckingAvailable
          }
        })
      }
    )

    this.setState({
      autoText: { [target]: place.formatted_address }
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
    this.setState({
      autoText: { ...this.state.autoText, [target]: '' },
      [target]: tmpAddress
    })
  }
  handleAddressFormFocus (event) {
    const target = event.target.name.split('-')[0]
    this.isOnFocus[target] = event.type === 'focus'
  }
  toggleModal () {
    this.setState({ showModal: !this.state.showModal })
  }

  loadPrevReq () {
    const { prevRequest, shipmentData } = this.props
    const { routes } = shipmentData
    if (!prevRequest.shipment) {
      return
    }
    const { shipment } = prevRequest
    const newState = {}
    if (!this.props.has_pre_carriage) {
      const newStateOrigin = routes.find(o => (
        o.origin.nexusId === shipment.origin.nexus_id
      ))
      newState.oSelect = routeHelpers.routeOption(newStateOrigin.origin)
    }
    if (!this.props.has_on_carriage) {
      const newStateDestination = routes.find(d => (
        d.destination.nexusId === shipment.destination.nexus_id
      ))
      newState.dSelect = routeHelpers.routeOption(newStateDestination.destination)
    }
    newState.autoText = {
      origin: shipment.origin.fullAddress || '',
      destination: shipment.destination.fullAddress || ''
    }

    if (shipment.origin.nexus_id) {
      this.state.map
        ? this.setOriginNexus(newState.oSelect)
        : setTimeout(() => {
          this.setOriginNexus(newState.oSelect)
        }, 500)
    }
    if (shipment.destination.nexus_id) {
      this.state.map
        ? this.setDestNexus(newState.dSelect)
        : setTimeout(() => {
          this.setDestNexus(newState.dSelect)
        }, 500)
    }

    this.setState(newState)
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
  handleSwap () {
    /* eslint-disable camelcase */
    const { has_on_carriage, has_pre_carriage } = this.props

    // Handle the cases for when trucking exists
    if (has_pre_carriage || has_on_carriage) {
      this.handleTrucking({
        target: {
          name: 'has_on_carriage',
          checked: has_pre_carriage
        }
      })
      this.handleTrucking({
        target: {
          name: 'has_pre_carriage',
          checked: has_on_carriage
        }
      })

      // Origin/Destination
      this.props.setTargetAddress('origin', { ...this.props.destination })
      this.props.setTargetAddress('destination', { ...this.props.origin })

      // Autocomplete Text
      const { autoText } = this.state
      const prevOrigin = autoText.origin
      autoText.origin = autoText.destination || ''
      autoText.destination = prevOrigin || ''
      this.setState({ autoText })

      // Address Fields Errors
      const originFieldsHaveErrors = this.state.destinationFieldsHaveErrors
      const destinationFieldsHaveErrors = this.state.originFieldsHaveErrors
      this.setState({ originFieldsHaveErrors, destinationFieldsHaveErrors })
    }

    // Origin/Destination without trucking
    if (!has_on_carriage) {
      this.setOriginNexus(this.state.dSelect)
    }
    if (!has_pre_carriage) {
      this.setDestNexus(this.state.oSelect)
    }

    /* eslint-enable camelcase */
  }

  prepForSelect (target) {
    console.log('target')
    this.setState((prevState) => {
      const {
        truckingHubs, oSelect, dSelect
      } = prevState
      const { filteredRouteIndexes } = this.props
      const { lookupTablesForRoutes, routes } = this.props.shipmentData
      const targetLocation = target === 'origin' ? oSelect : dSelect
      const targetTrucking = truckingHubs[target]
      const counterpart = target === 'origin' ? 'destination' : 'origin'

      let indexes = filteredRouteIndexes.slice()
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
      }

      let newFilteredRouteIndexes = routeFilters.scopeIndexes(
        filteredRouteIndexes,
        indexes
      )

      let fieldsHaveErrors = false

      if (targetTrucking && newFilteredRouteIndexes.length === 0) {
        newFilteredRouteIndexes = filteredRouteIndexes
        fieldsHaveErrors = true
        const addressFormsHaveErrors =
          fieldsHaveErrors || prevState[`${counterpart}FieldsHaveErrors`]
        this.props.handleSelectLocation(addressFormsHaveErrors)
      }

      const newFilteredRoutes = []
      const selectOptions = []
      const counterpartNexusIds = []
      newFilteredRouteIndexes.forEach((idx) => {
        const route = routes[idx]
        newFilteredRoutes.push(route)
        if (counterpartNexusIds.includes(route[counterpart].nexusId)) return

        counterpartNexusIds.push(route[counterpart].nexusId)

        selectOptions.push(routeHelpers.routeOption(route[counterpart]))
      })

      if (targetTrucking) this.prepTruckTypes(newFilteredRoutes, target)

      this.props.updateFilteredRouteIndexes(newFilteredRouteIndexes)

      return {
        [`available${capitalize(counterpart)}Nexuses`]: selectOptions,
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
    if (!truckTypes.includes(selectedTrucking[truckingTarget])) {
      const availableTruckType = truckTypes
        .filter(tt => tt !== selectedTrucking[truckingTarget])[0]
      const syntheticEvent = { target: { id: `${truckingTarget}-${availableTruckType}` } }
      this.props.handleTruckingDetailsChange(syntheticEvent)
    }
    this.setState({
      truckTypes: {
        ...this.state.truckTypes,
        [target]: truckTypes
      }
    })
  }

  render () {
    const {
      scope, shipmentData, nextStageAttempts, origin, destination, selectedTrucking
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
      truckTypes
    } = this.state
    if (availableDestinationNexuses) destinationOptions = availableDestinationNexuses
    if (availableOriginNexuses) originOptions = availableOriginNexuses

    const showOriginError = !this.state.oSelect && nextStageAttempts > 0
    const originNexus = (
      <div style={{ position: 'relative' }} className="flex-100 layout-row layout-wrap">
        <StyledSelect
          name="origin-hub"
          className={styles.select}
          value={this.state.oSelect}
          placeholder="Origin"
          options={originOptions}
          onChange={this.setOriginNexus}
          nextStageAttempt={nextStageAttempts > 0}
        />
        <span className={errorStyles.error_message} style={{ color: 'white' }}>
          {showOriginError ? 'Must not be blank' : ''}
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
          placeholder="Destination"
          options={destinationOptions}
          onChange={this.setDestNexus}
          backgroundColor={backgroundColor}
          nextStageAttempt={nextStageAttempts > 0}
        />
        <span className={errorStyles.error_message} style={{ color: 'white' }}>
          {showDestinationError ? 'Must not be blank' : ''}
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
          className={`${styles.address_form} flex-100 layout-row layout-wrap layout-align-center`}
        >
          <div
            className={`${styles.address_form_title} flex-100 layout-row layout-align-start-center`}
          >
            <p className="flex-none">Enter Pickup Address</p>
          </div>
          <input
            id="not-auto"
            name="origin-number"
            className={
              `flex-90 ${styles.input} ` +
              `${nextStageAttempts > 0 && !origin.number ? styles.with_errors : ''}`
            }
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={origin.number}
            placeholder="Number"
          />
          <input
            name="origin-street"
            className={
              `flex-90 ${styles.input} ` +
              `${nextStageAttempts > 0 && !origin.street ? styles.with_errors : ''}`
            }
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={origin.street}
            placeholder="Street"
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
            value={origin.zipCode}
            placeholder="Zip Code"
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
            value={origin.city}
            placeholder="City"
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
            value={origin.country}
            placeholder="Country"
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
      </div>
    )

    const originAuto = (
      <div className="flex-100 layout-row layout-wrap">
        <div className={styles.input_wrapper}>
          <input
            id="origin"
            name="origin"
            ref={input => (this.originAutoInput = input)}
            className={`flex-none ${styles.input} ${
              originFieldsHaveErrors ? styles.with_errors : ''
            }`}
            type="string"
            onChange={this.handleAuto}
            value={this.state.autoText.origin}
            placeholder="Search for address"
          />
          <span className={errorStyles.error_message} style={{ color: 'white' }}>
            {originFieldsHaveErrors ? 'No routes from this address' : ''}
          </span>
        </div>
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
        <div className={`${styles.address_form} ${toggleLogic} flex-100 layout-row layout-wrap layout-align-center`}>
          <div
            className={`${styles.address_form_title} flex-100 layout-row layout-align-start-center`}
          >
            <p className="flex-none">Enter Delivery Address</p>
          </div>
          <input
            name="destination-number"
            className={
              `flex-90 ${styles.input} ` +
              `${nextStageAttempts > 0 && !destination.number ? styles.with_errors : ''}`
            }
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={destination.number}
            placeholder="Number"
          />
          <input
            name="destination-street"
            className={
              `flex-90 ${styles.input} ` +
              `${nextStageAttempts > 0 && !destination.street ? styles.with_errors : ''}`
            }
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={destination.street}
            placeholder="Street"
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
            value={destination.zipCode}
            placeholder="Zip Code"
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
            value={destination.city}
            placeholder="City"
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
            value={destination.country}
            placeholder="Country"
          />
          <div className="flex-100 layout-row layout-align-start-center">
            <div
              className={`${styles.clear_sec} flex-none layout-row layout-align-end-center`}
              onClick={() => this.resetAuto('destination')}
            >
              <i className="fa fa-times flex-none" />
              <p className="offset-5 flex-none" style={{ paddingRight: '10px' }}>
                Clear
              </p>
            </div>
          </div>
        </div>
      </div>
    )

    const destAuto = (
      <div className="flex-100 layout-row layout-wrap">
        <div className={styles.input_wrapper}>
          <input
            id="destination"
            name="destination"
            ref={input => (this.destinationAutoInput = input)}
            className={
              `flex-none ${styles.input} ` +
              `${destinationFieldsHaveErrors ? styles.with_errors : ''}`
            }
            type="string"
            onChange={this.handleAuto}
            value={this.state.autoText.destination}
            placeholder="Search for address"
          />
          <span className={errorStyles.error_message} style={{ color: 'white' }}>
            {destinationFieldsHaveErrors ? 'No routes to this address' : ''}
          </span>
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
    const { theme } = this.props
    const { shipment } = shipmentData
    const errorClass =
      originFieldsHaveErrors || destinationFieldsHaveErrors ? styles.with_errors : ''

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
                { speciality !== 'truck'
                  ? <div
                    className={
                      'flex-45 layout-row layout-align-start layout-wrap ' +
                    `${styles.toggle_box} ` +
                    `${!truckingOptions.preCarriage ? styles.not_available : ''}`
                    }
                  >
                    <TruckingTooltip
                      truckingOptions={truckingOptions}
                      carriage="preCarriage"
                      hubName={this.state.oSelect.label}
                      direction={shipment.direction}
                      scope={scope}
                    />

                    <Toggle
                      className="flex-none"
                      id="has_pre_carriage"
                      name="has_pre_carriage"
                      checked={this.props.has_pre_carriage}
                      onChange={this.handleTrucking}
                    />
                    <label htmlFor="pre-carriage" style={{ marginLeft: '15px' }}>
                    Pickup
                    </label>
                    {loadType === 'container' && this.props.has_pre_carriage ? preCarriageTruckTypes : ''}
                  </div> : <div className={`flex-20 layout-row layout-align-end-center ${styles.trucking_text}`}><p className="flex-none">Pickup:</p></div> }
                <div className={`flex-55 layout-row layout-wrap ${styles.search_box}`}>
                  {this.props.has_pre_carriage ? originAuto : ''}
                  {displayLocationOptions('origin')}
                  {originFields}
                </div>
              </div>

              <div
                className="flex-5 layout-row layout-align-center-center"
                onClick={this.handleSwap}
                style={{ height: '60px' }}
              >
                <i className={`${styles.fa_exchange_style} fa fa-exchange `} />
              </div>

              <div className="flex-45 layout-row layout-wrap layout-align-end-start">
                { speciality !== 'truck'
                  ? <div
                    className={
                      'flex-45 layout-row layout-align-start layout-wrap ' +
                    `${styles.toggle_box} ` +
                    `${!truckingOptions.onCarriage ? styles.not_available : ''}`
                    }
                  >
                    <TruckingTooltip
                      truckingOptions={truckingOptions}
                      carriage="onCarriage"
                      hubName={this.state.dSelect.label}
                      direction={shipment.direction}
                      scope={scope}
                    />

                    <label htmlFor="on-carriage" style={{ marginRight: '15px' }}>
                    Delivery
                    </label>
                    <Toggle
                      className="flex-none"
                      id="has_on_carriage"
                      name="has_on_carriage"
                      checked={this.props.has_on_carriage}
                      onChange={this.handleTrucking}
                    />
                    {loadType === 'container' && this.props.has_on_carriage ? onCarriageTruckTypes : ''}
                  </div> : <div className={`flex-20 layout-row layout-align-end-center ${styles.trucking_text}`}><p className="flex-none">Delivery:</p></div> }
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
  handleSelectLocation: PropTypes.func.isRequired,
  gMaps: PropTypes.gMaps.isRequired,
  theme: PropTypes.theme,
  // user: PropTypes.user,
  setNotesIds: PropTypes.func,
  shipmentData: PropTypes.shipmentData,
  setTargetAddress: PropTypes.func.isRequired,
  handleAddressChange: PropTypes.func.isRequired,
  handleCarriageChange: PropTypes.func.isRequired,
  allNexuses: PropTypes.shape({
    origins: PropTypes.array,
    destinations: PropTypes.array
  }).isRequired,
  has_on_carriage: PropTypes.bool,
  has_pre_carriage: PropTypes.bool,
  // shipmentDispatch: PropTypes.shape({
  //   goTo: PropTypes.func,
  //   getDashboard: PropTypes.func
  // }).isRequired,
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
  updateFilteredRouteIndexes: PropTypes.func.isRequired
}

ShipmentLocationBox.defaultProps = {
  nextStageAttempts: 0,
  theme: null,
  selectedTrucking: {},
  shipmentData: null,
  setNotesIds: null,
  routeIds: [],
  prevRequest: null,
  has_on_carriage: true,
  has_pre_carriage: true,
  handleTruckingDetailsChange: null,
  reusedShipment: null
}

export default ShipmentLocationBox
