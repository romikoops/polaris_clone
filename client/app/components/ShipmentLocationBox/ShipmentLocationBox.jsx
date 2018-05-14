import React, { Component } from 'react'
import Select from 'react-select'
import Toggle from 'react-toggle'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import '../../styles/react-toggle.scss'
import '../../styles/select-css-custom.css'
import styles from './ShipmentLocationBox.scss'
import errorStyles from '../../styles/errors.scss'
import defaults from '../../styles/default_classes.scss'
import { colorSVG } from '../../helpers'
import { mapStyling } from '../../constants/map.constants'
import { Modal } from '../Modal/Modal'
import { AvailableRoutes } from '../AvailableRoutes/AvailableRoutes'
import { RoundButton } from '../RoundButton/RoundButton'
import { capitalize } from '../../helpers/stringTools'
import addressFromPlace from './addressFromPlace'
import getRequests from './getRequests'
import TruckingTooltip from './TruckingTooltip'

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
      origin: {
        street: '',
        zipCode: '',
        city: '',
        country: '',
        fullAddress: '',
        hub_id: '',
        hub_name: ''
      },
      destination: {
        street: '',
        zipCode: '',
        city: '',
        fullAddress: '',
        hub_id: '',
        hub_name: ''
      },
      autoText: {
        origin: '',
        destination: ''
      },
      autoTextOrigin: '',
      autoTextDest: '',
      autocomplete: {
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
      dSelect: ''
    }

    this.isOnFocus = {
      origin: false,
      destination: false
    }

    this.handleAddressChange = this.handleAddressChange.bind(this)
    this.selectLocation = this.selectLocation.bind(this)
    this.handleTrucking = this.handleTrucking.bind(this)
    this.setOriginHub = this.setOriginHub.bind(this)
    this.setDestHub = this.setDestHub.bind(this)
    this.postToggleAutocomplete = this.postToggleAutocomplete.bind(this)
    this.initAutocomplete = this.initAutocomplete.bind(this)
    this.setHubsFromRoute = this.setHubsFromRoute.bind(this)
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
  }

  componentWillMount () {
    if (this.props.prevRequest && this.props.prevRequest.shipment) {
      this.loadPrevReq()
    }
  }

  componentDidMount () {
    this.initMap()
  }
  componentWillReceiveProps (nextProps) {
    if (nextProps.has_pre_carriage) {
      this.postToggleAutocomplete('origin')
    }
    if (nextProps.has_on_carriage) {
      this.postToggleAutocomplete('destination')
    }
  }
  getCoordinates (hub, hubName) {
    const { allNexuses } = this.props
    let tmpCoord = {}
    switch (hub) {
      case 'origins':
        allNexuses.origins.forEach(nx =>
          (nx.label === hubName ? (tmpCoord = { lat: nx.value.latitude, lng: nx.longitude }) : ''))
        break
      case 'destinations':
        allNexuses.destinations.forEach(nx =>
          (nx.label === hubName ? (tmpCoord = { lat: nx.value.latitude, lng: nx.longitude }) : ''))
        break
      default:
        break
    }
    return tmpCoord
  }
  setDestHub (event) {
    this.scopeNexusOptions(event && event.value ? [event.value.id] : [], 'origin')

    if (event) {
      const destination = {
        ...this.state.destination,
        hub_id: event.value.id,
        hub_name: event.value.name,
        lat: event.value.latitude,
        lng: event.value.longitude
      }
      const lat = event.value.latitude
      const lng = event.value.longitude
      const dSelect = event
      this.props.setNotesIds([event.value.id], 'destination')
      this.props.setTargetAddress('destination', destination)
      this.setMarker({ lat, lng }, destination.hub_name, 'destination')
      this.setState({ dSelect, destination })
    } else {
      this.setState({
        truckingOptions: {
          ...this.state.truckingOptions,
          preCarriage: true
        },
        dSelect: '',
        destination: {}
      })
      this.props.setNotesIds(null, 'destination')
      this.state.markers.destination.setMap(null)
      this.props.setTargetAddress('destination', {})
    }
  }

  setHubsFromRoute (route) {
    let tmpOrigin = {}
    let tmpDest = {}

    this.props.allNexuses.origins.forEach((nx) => {
      if (nx.value.id === route.firstStop.hub.nexus.id) {
        tmpOrigin = nx.value
      }
    })
    this.props.allNexuses.destinations.forEach((nx) => {
      if (nx.value.id === route.lastStop.hub.nexus.id) {
        tmpDest = nx.value
      }
    })

    this.setState({
      oSelect: { value: tmpOrigin, label: tmpOrigin.name },
      dSelect: { value: tmpDest, label: tmpDest.name },
      origin: {
        ...this.state.origin,
        hub_id: tmpOrigin.id,
        hub_name: tmpOrigin.name,
        lat: tmpOrigin.latitude,
        lng: tmpOrigin.longitude
      },
      destination: {
        ...this.state.destination,
        hub_id: tmpDest.id,
        hub_name: tmpDest.name,
        lat: tmpDest.latitude,
        lng: tmpDest.longitude
      }
    })

    this.props.setTargetAddress('origin', {
      ...this.state.origin,
      hub_id: tmpOrigin.id,
      hub_name: tmpOrigin.name,
      lat: tmpOrigin.latitude,
      lng: tmpOrigin.longitude
    })

    this.props.setTargetAddress('destination', {
      ...this.state.destination,
      hub_id: tmpDest.id,
      hub_name: tmpDest.name,
      lat: tmpDest.latitude,
      lng: tmpDest.longitude
    })

    if (this.state.map) {
      this.setMarker(
        { lat: tmpOrigin.latitude, lng: tmpOrigin.longitude },
        tmpOrigin.name,
        'origin'
      )
      this.setMarker({ lat: tmpDest.latitude, lng: tmpDest.longitude }, tmpDest.name, 'destination')
    } else {
      setTimeout(() => {
        this.setMarker(
          { lat: tmpOrigin.latitude, lng: tmpOrigin.longitude },
          tmpOrigin.name,
          'origin'
        )
      }, 750)
      setTimeout(() => {
        this.setMarker(
          { lat: tmpDest.latitude, lng: tmpDest.longitude },
          tmpDest.name,
          'destination'
        )
      }, 750)
    }
  }
  setOriginHub (event) {
    this.scopeNexusOptions(event && event.value ? [event.value.id] : [], 'destination')
    if (event) {
      const origin = {
        ...this.state.origin,
        hub_id: event.value.id,
        hub_name: event.value.name,
        lat: event.value.latitude,
        lng: event.value.longitude
      }
      const lat = event.value.latitude
      const lng = event.value.longitude
      const oSelect = event

      this.props.setTargetAddress('origin', origin)
      this.setMarker({ lat, lng }, origin.hub_name, 'origin')
      this.setState({ oSelect, origin })
      this.props.setNotesIds([event.value.id], 'origin')
    } else {
      this.setState({
        truckingOptions: {
          ...this.state.truckingOptions,
          preCarriage: true
        },
        oSelect: '',
        origin: {}
      })
      this.props.setNotesIds(false, 'origin')
      this.state.markers.origin.setMap(null)
      this.props.setTargetAddress('origin', {})
    }
  }

  setMarker (location, name, target) {
    const { markers, map } = this.state
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
      hub_id: route.origin_id,
      hub_name: route.origin_nexus
    }
    const destination = {
      city: '',
      country: '',
      fullAddress: '',
      hub_id: route.origin_id,
      hub_name: route.origin_nexus
    }
    this.setState({ origin, destination })
    this.setState({ showModal: !this.state.showModal })
    this.setState({ locationFromModal: !this.state.locationFromModal })
    this.setHubsFromRoute(route)
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
    this.setState({ map })

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
    this.setState({ autoListener: { ...this.state.autoListener, [target]: autocomplete } })
    this.autocompleteListener(map, autocomplete, target)
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

  autocompleteListener (aMap, autocomplete, target) {
    this.infowindow = new this.props.gMaps.InfoWindow()
    this.infowindowContent = document.getElementById('infowindow-content')
    this.infowindow.setContent(this.infowindowContent)

    this.marker = new this.props.gMaps.Marker({
      map: aMap,
      anchorPoint: new this.props.gMaps.Point(0, -29)
    })
    if (autocomplete.getPlace()) this.handlePlaceChange(aMap, autocomplete, target)
    autocomplete.addListener('place_changed', () => {
      this.handlePlaceChange(aMap, autocomplete.getPlace(), target)
    })
  }

  triggerPlaceChanged (input, target) {
    // triggers a place change with the first result from google
    const service = new this.props.gMaps.places.AutocompleteService()
    service.getPlacePredictions({ input }, (_input) => {
      // eslint-disable-next-line no-debugger
      debugger
      this.getPlace(_input[0].place_id, (place) => {
        this.handlePlaceChange(this.state.map, place, target)
      })
    })
  }

  handlePlaceChange (aMap, place, target) {
    this.changeAddressFormVisibility(target, true)

    this.infowindow.close()
    this.marker.setVisible(false)
    if (!place.geometry) {
      window.alert(`No details available for input: '${place.name}'`)
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

  updateAddressFieldsErrors (target) {
    if (!this.props.nextStageAttempt) {
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

  scopeNexusOptions (nexusIds, target) {
    getRequests.nexuses(nexusIds, target, this.props.routeIds, (data) => {
      if (Object.values(data)[0].length > 0) {
        this.setState(data)
      } else {
        target === 'origin' ? this.setDestHub() : this.setOriginHub()
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

    const { allNexuses } = this.props
    const lat = place.geometry.location.lat()
    const lng = place.geometry.location.lng()

    const tenantId = this.props.shipmentData.shipment.tenant_id
    const loadType = this.props.shipmentData.shipment.load_type

    const prefix = target === 'origin' ? 'pre' : 'on'
    let availableNexuses = allNexuses && allNexuses[`${target}s`] ? allNexuses[`${target}s`] : []
    const stateAvailableNexuses = this.state[`available${capitalize(target)}s`]
    if (stateAvailableNexuses) availableNexuses = stateAvailableNexuses
    const availableNexusesIds = availableNexuses.map(availableNexus => availableNexus.value.id)

    getRequests.findAvailability(
      lat,
      lng,
      tenantId,
      loadType,
      availableNexusesIds,
      prefix,
      (truckingAvailable, nexusIds) => {
        if (!truckingAvailable) {
          getRequests.findNexus(lat, lng, (nexus) => {
            let nexusOption
            if (nexus) {
              nexusOption = availableNexuses.find(option => option.label === nexus.name)
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
            target === 'origin' ? this.setOriginHub(nexusOption) : this.setDestHub(nexusOption)

            const fieldsHaveErrors = !nexusOption
            this.setState({ [`${target}FieldsHaveErrors`]: fieldsHaveErrors })
            const addressFormsHaveErrors =
              fieldsHaveErrors || this.state[`${counterpart}FieldsHaveErrors`]
            this.props.handleSelectLocation(addressFormsHaveErrors)
          })
        } else {
          this.setState({ [`${target}FieldsHaveErrors`]: false })
          this.props.handleSelectLocation(this.state[`${counterpart}FieldsHaveErrors`])
          this.props.setNotesIds(nexusIds, target)
          this.scopeNexusOptions(nexusIds, counterpart)
        }

        this.setState({
          truckingOptions: {
            ...this.state.truckingOptions,
            [`${prefix}Carriage`]: truckingAvailable
          }
        })
      }
    )

    addressFromPlace(place, this.props.gMaps, this.state.map, (address) => {
      this.setState({
        [target]: address,
        autoText: { [target]: place.formatted_address }
      })
      this.props.setTargetAddress(target, address)
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
    const { prevRequest, allNexuses } = this.props
    if (!prevRequest.shipment) {
      return ''
    }
    const { shipment } = prevRequest
    const newData = {}
    newData.originHub = shipment.origin_id
      ? allNexuses.origins.filter(o => o.value.id === shipment.origin_id)[0]
      : null
    newData.autoTextOrigin = shipment.origin_user_input ? shipment.origin_user_input : ''
    newData.destinationHub = shipment.destination_id
      ? allNexuses.destinations.filter(o => o.value.id === shipment.destination_id)[0]
      : null
    newData.autoTextDest = shipment.destination_user_input ? shipment.destination_user_input : ''
    if (shipment.origin_id) {
      this.state.map
        ? this.setOriginHub(newData.originHub)
        : setTimeout(() => {
          this.setOriginHub(newData.originHub)
        }, 500)
    }
    if (shipment.destination_id) {
      this.state.map
        ? this.setDestHub(newData.destinationHub)
        : setTimeout(() => {
          this.setDestHub(newData.destinationHub)
        }, 500)
    }
    this.setState({
      autoTextOrigin: newData.autoTextOrigin,
      autoTextDest: newData.autoTextDest,
      autoText: {
        origin: newData.autoTextOrigin,
        destination: newData.autoTextDest
      }
    })

    return ''
  }
  handleSwap () {
    /* eslint-disable camelcase */
    const { has_on_carriage, has_pre_carriage } = this.props

    if (has_pre_carriage || has_on_carriage) {
      // Trucking
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

      // Origin/Destination with trucking
      const { autoText } = this.state

      const origin = { ...this.state.destination }
      const destination = { ...this.state.origin }
      const autoTextOrigin = autoText.destination
      const autoTextDestination = autoText.origin

      autoText.origin = autoTextOrigin || ''
      autoText.destination = autoTextDestination || ''

      this.setState({
        origin,
        destination,
        autoText
      })

      // Address Fields Errors
      const originFieldsHaveErrors = this.state.destinationFieldsHaveErrors
      const destinationFieldsHaveErrors = this.state.originFieldsHaveErrors
      this.setState({ originFieldsHaveErrors, destinationFieldsHaveErrors })
    }

    // Origin/Destination without trucking
    if (!has_on_carriage) {
      this.setOriginHub(this.state.dSelect)
    }
    if (!has_pre_carriage) {
      this.setDestHub(this.state.oSelect)
    }

    /* eslint-enable camelcase */
  }
  render () {
    const {
      allNexuses, shipmentDispatch, scope, shipmentData
    } = this.props

    let originOptions = allNexuses && allNexuses.origins ? allNexuses.origins : []
    let destinationOptions = allNexuses && allNexuses.destinations ? allNexuses.destinations : []

    const {
      originFieldsHaveErrors,
      destinationFieldsHaveErrors,
      availableOrigins,
      availableDestinations,
      truckingOptions
    } = this.state

    if (availableDestinations) destinationOptions = availableDestinations
    if (availableOrigins) originOptions = availableOrigins

    const showOriginError = !this.state.oSelect && this.props.nextStageAttempt
    const originHubSelect = (
      <div style={{ position: 'relative' }} className="flex-100 layout-row layout-wrap">
        <StyledSelect
          name="origin-hub"
          className={styles.select}
          value={this.state.oSelect}
          placeholder="Origin"
          options={originOptions}
          onChange={this.setOriginHub}
          nextStageAttempt={this.props.nextStageAttempt}
        />
        <span className={errorStyles.error_message} style={{ color: 'white' }}>
          {showOriginError ? 'Must not be blank' : ''}
        </span>
      </div>
    )

    const showDestinationError = !this.state.dSelect && this.props.nextStageAttempt
    const destinationHubSelect = (
      <div style={{ position: 'relative' }} className="flex-100 layout-row layout-wrap">
        <StyledSelect
          name="destination-hub"
          className={styles.select}
          value={this.state.dSelect}
          placeholder="Destination"
          options={destinationOptions}
          onChange={this.setDestHub}
          backgroundColor={backgroundColor}
          nextStageAttempt={this.props.nextStageAttempt}
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
            className={`flex-90 ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.props.origin.number}
            placeholder="Number"
          />
          <input
            name="origin-street"
            className={`flex-90 ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.origin.street}
            placeholder="Street"
          />
          <input
            name="origin-zipCode"
            className={`flex-90 ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.origin.zipCode}
            placeholder="Zip Code"
          />
          <input
            name="origin-city"
            className={`flex-90 ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.origin.city}
            placeholder="City"
          />
          <input
            name="origin-country"
            className={`flex-90 ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.origin.country}
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
            className={`flex-90 ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.destination.number}
            placeholder="Number"
          />
          <input
            name="destination-street"
            className={`flex-90 ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.destination.street}
            placeholder="Street"
          />
          <input
            name="destination-zipCode"
            className={`flex-90 ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.destination.zipCode}
            placeholder="Zip Code"
          />
          <input
            name="destination-city"
            className={`flex-90 ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.destination.city}
            placeholder="City"
          />
          <input
            name="destination-country"
            className={`flex-90 ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.destination.country}
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
        return originHubSelect
      }
      if (target === 'destination' && !this.props.has_on_carriage) {
        return destinationHubSelect
      }
      return ''
    }
    const { theme, user } = this.props
    const { shipment } = shipmentData
    const errorClass =
      originFieldsHaveErrors || destinationFieldsHaveErrors ? styles.with_errors : ''
    const routeModal = (
      <Modal
        component={
          <AvailableRoutes
            user={user}
            theme={theme}
            routes={shipmentData.itineraries}
            routeSelected={this.selectedRoute}
            userDispatch={shipmentDispatch}
            initialCompName="UserAccount"
          />
        }
        width="48vw"
        verticalPadding="30px"
        horizontalPadding="15px"
        parentToggle={this.toggleModal}
      />
    )

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
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''
    return (
      <div className="layout-row flex-100 layout-wrap layout-align-center-center">
        <div className="layout-row flex-100 layout-wrap layout-align-center-center">
          <div className={`layout-row flex-none layout-align-start ${defaults.content_width}`}>
            <RoundButton
              text="Show All Routes"
              handleNext={this.toggleModal}
              theme={theme}
              active
            />
          </div>
        </div>
        <div
          className={`layout-row flex-100 layout-wrap layout-align-center-start ${styles.slbox}`}
        >
          <div className={`${styles.map_container} layout-row flex-none layout-align-start-start`}>
            {this.state.showModal ? routeModal : ''}
            <div
              className={`flex-100 layout-row layout-wrap layout-align-center-start ${
                styles.input_box
              } ${errorClass}`}
            >
              <div className="flex-45 layout-row layout-wrap layout-align-start-start mc">
                <div
                  className={
                    'flex-45 layout-row layout-align-start ' +
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
                    Pre-Carriage
                  </label>
                </div>
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
                <div
                  className={
                    'flex-45 layout-row layout-align-start ' +
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
                    On-Carriage
                  </label>
                  <Toggle
                    className="flex-none"
                    id="has_on_carriage"
                    name="has_on_carriage"
                    checked={this.props.has_on_carriage}
                    onChange={this.handleTrucking}
                  />
                </div>
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
  nextStageAttempt: PropTypes.bool,
  handleSelectLocation: PropTypes.func.isRequired,
  gMaps: PropTypes.gMaps.isRequired,
  theme: PropTypes.theme,
  user: PropTypes.user,
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
  shipmentDispatch: PropTypes.shape({
    goTo: PropTypes.func,
    getDashboard: PropTypes.func
  }).isRequired,
  origin: PropTypes.shape({
    number: PropTypes.number
  }),
  routeIds: PropTypes.arrayOf(PropTypes.number),
  prevRequest: PropTypes.shape({
    shipment: PropTypes.shipment
  }),
  scope: PropTypes.scope.isRequired
}

ShipmentLocationBox.defaultProps = {
  nextStageAttempt: false,
  theme: null,
  user: null,
  shipmentData: null,
  setNotesIds: null,
  routeIds: [],
  prevRequest: null,
  origin: null,
  has_on_carriage: true,
  has_pre_carriage: true
}

export default ShipmentLocationBox
