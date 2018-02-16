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
import { isEmpty } from '../../helpers/isEmpty'
import { colorSVG, authHeader } from '../../helpers'
import { mapStyling } from '../../constants/map.constants'
import { Modal } from '../Modal/Modal'
import { AvailableRoutes } from '../AvailableRoutes/AvailableRoutes'
import { RoundButton } from '../RoundButton/RoundButton'
import { capitalize } from '../../helpers/stringTools'
import { BASE_URL } from '../../constants'

const { fetch } = window
const mapStyle = {
  width: '100%',
  height: '600px',
  borderRadius: '3px',
  boxShadow: '1px 1px 2px 2px rgba(0,1,2,0.25)'
}
const isObjectEmpty = isEmpty
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
      shipment: {
        has_pre_carriage: false,
        has_on_carriage: false
      },
      autocomplete: {
        origin: false,
        destination: false
      },
      markers: {
        origin: {},
        destination: {}
      },
      showModal: false,
      locationFromModal: false
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
    this.scopeNexusOptions = this.scopeNexusOptions.bind(this)
  }

  componentDidMount () {
    this.initMap()
    if (this.props.selectedRoute) {
      this.setHubsFromRoute(this.props.selectedRoute)
    }
    if (this.props.prevRequest && this.props.prevRequest.shipment) {
      this.loadPrevReq()
    }
  }

  setHubsFromRoute (route) {
    let tmpOrigin = {}
    let tmpDest = {}
    // TO DO: AllNexuses changed to object with origin and dest arrays
    this.props.allNexuses.origins.forEach((nx) => {
      if (nx.value.id === route.origin_nexus_id) {
        tmpOrigin = nx.value
      }
    })
    this.props.allNexuses.destinations.forEach((nx) => {
      if (nx.value.id === route.destination_nexus_id) {
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
      setTimeout(
        () => {
          this.setMarker(
            { lat: tmpOrigin.latitude, lng: tmpOrigin.longitude },
            tmpOrigin.name,
            'origin'
          )
        },
        750
      )
      setTimeout(
        () => {
          this.setMarker(
            { lat: tmpDest.latitude, lng: tmpDest.longitude },
            tmpDest.name,
            'destination'
          )
        },
        750
      )
    }
  }

  setMarker (location, name, target) {
    const { markers, map } = this.state
    const { theme } = this.props
    const newMarkers = []
    if (!isObjectEmpty(markers[target])) {
      markers[target].setMap(null)
    }
    let icon
    if (target === 'origin') {
      icon = {
        url: colourSVG('location', theme),
        anchor: new this.props.gMaps.Point(25, 50),
        scaledSize: new this.props.gMaps.Size(36, 36)
      }
    } else {
      icon = {
        url: colourSVG('flag', theme),
        anchor: new this.props.gMaps.Point(25, 50),
        scaledSize: new this.props.gMaps.Size(36, 36)
      }
    }
    const marker = new this.props.gMaps.Marker({
      position: location,
      map,
      title: name,
      icon
    })
    markers[target] = marker
    if (!isObjectEmpty(markers.origin)) {
      newMarkers.push(markers.origin)
    }
    if (!isObjectEmpty(markers.destination)) {
      newMarkers.push(markers.destination)
    }
    this.setState({ markers })
    const bounds = new this.props.gMaps.LatLngBounds()
    for (let i = 0; i < newMarkers.length; i++) {
      bounds.extend(newMarkers[i].getPosition())
    }

    if (newMarkers.length > 1) {
      map.fitBounds(bounds)
    } else if (newMarkers.length === 1) {
      map.setCenter(bounds.getCenter())
      map.setZoom(14)
    }
  }
  
  toggleModal () {
    this.setState({ showModal: !this.state.showModal })
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

    if (this.state.shipment.has_pre_carriage) {
      this.initAutocomplete(map, 'origin')
    }

    if (this.state.shipment.has_on_carriage) {
      this.initAutocomplete(map, 'destination')
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

    if (target === 'origin') {
      setTimeout(
        () => {
          this.initAutocomplete(map, target)
        },
        1000
      )
    }

    if (target === 'destination') {
      setTimeout(
        () => {
          this.initAutocomplete(map, target)
        },
        1000
      )
    }
  }

  changeAddressFormVisibility (target, visibility) {
    const key = `show${capitalize(target)}Fields`
    const value = visibility || !this.state[key]
    this.setState({ [key]: value })
  }

  autocompleteListener (aMap, autocomplete, target) {
    const infowindow = new this.props.gMaps.InfoWindow()
    const infowindowContent = document.getElementById('infowindow-content')
    infowindow.setContent(infowindowContent)

    const marker = new this.props.gMaps.Marker({
      map: aMap,
      anchorPoint: new this.props.gMaps.Point(0, -29)
    })

    autocomplete.addListener('place_changed', () => {
      this.changeAddressFormVisibility(target, true)

      infowindow.close()
      marker.setVisible(false)
      const place = autocomplete.getPlace()
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
    })
  }

  handleTrucking (event) {
    const { name, checked } = event.target
    this.setState({
      shipment: { ...this.state.shipment, [name]: checked }
    })

    if (name === 'has_pre_carriage') {
      if (checked) {
        this.postToggleAutocomplete('origin')
      }
      this.props.setCarriage('has_pre_carriage', checked)
    }

    if (name === 'has_on_carriage') {
      if (checked) {
        this.postToggleAutocomplete('destination')
      }
      this.props.setCarriage('has_on_carriage', checked)
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
  scopeNexusOptions (userInput, target) {
    fetch(
      `${BASE_URL}/nexuses?` +
        `itinerary_ids=${this.props.routeIds}&` +
        `target=${target}&` +
        `user_input=${userInput}`,
      {
        method: 'GET',
        headers: authHeader()
      }
    ).then((promise) => {
      promise.json().then((response) => {
        this.setState(response.data)
      })
    })
  }
  setOriginHub (event) {
    this.scopeNexusOptions(event ? event.label : '', 'destination')
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
    } else {
      this.setState({
        oSelect: '',
        origin: {}
      })
      this.state.markers.origin.setMap(null)
      this.props.setTargetAddress('origin', {})
    }
  }
  handleAuto (event) {
    const { name, value } = event.target
    this.setState({ autoText: { [name]: value } })
  }

  setDestHub (event) {
    this.scopeNexusOptions(event ? event.label : '', 'origin')
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

      this.props.setTargetAddress('destination', destination)
      this.setMarker({ lat, lng }, destination.hub_name, 'destination')
      this.setState({ dSelect, destination })
    } else {
      this.setState({
        dSelect: '',
        destination: {}
      })

      this.state.markers.destination.setMap(null)
      this.props.setTargetAddress('destination', {})
    }
  }

  selectLocation (place, target) {
    const tmpAddress = {
      number: '',
      street: '',
      zipCode: '',
      city: '',
      country: '',
      fullAddress: ''
    }
    // ;
    place.address_components.forEach((ac) => {
      if (ac.types.includes('street_number')) {
        tmpAddress.number = ac.long_name
      }

      if (ac.types.includes('route') || ac.types.includes('premise')) {
        tmpAddress.street = ac.long_name
      }

      if (ac.types.includes('administrative_area_level_1')) {
        tmpAddress.city = ac.long_name
      }

      if (ac.types.includes('postal_code')) {
        tmpAddress.zipCode = ac.long_name
      }

      if (ac.types.includes('country')) {
        tmpAddress.country = ac.long_name
      }
    })
    tmpAddress.fullAddress = place.formatted_address
    setTimeout(() => {
      this.changeAddressFormVisibility(target, this.isOnFocus[target])
    }, 6000)

    const { allNexuses } = this.props
    const lat = place.geometry.location.lat()
    const lng = place.geometry.location.lng()
    if (target === 'origin') {
      fetch(`${BASE_URL}/find_nexus?lat=${lat}&lng=${lng}`, {
        method: 'GET',
        headers: authHeader()
      }).then((promise) => {
        promise.json().then((response) => {
          const nexus = response.data.nexus
          const nexusName = nexus ? nexus.name : ''

          let originOptions = allNexuses && allNexuses.origins ? allNexuses.origins : []
          if (this.state.availableOrigins) originOptions = this.state.availableOrigins
          const originOptionNames = originOptions.map(originOption => originOption.label)

          this.setState({
            originFieldsHaveErrors: !originOptionNames.includes(nexusName)
          })
          this.props.handleSelectLocation(!originOptionNames.includes(nexusName) || this.state.destinationFieldsHaveErrors)
        })
      })
    } else if (target === 'destination') {
      fetch(`${BASE_URL}/find_nexus?lat=${lat}&lng=${lng}`, {
        method: 'GET',
        headers: authHeader()
      }).then((promise) => {
        promise.json().then((response) => {
          const nexus = response.data.nexus
          const nexusName = nexus ? nexus.name : ''

          let destinationOptions =
            allNexuses && allNexuses.destinations ? allNexuses.destinations : []
          if (this.state.availableDestinations) { destinationOptions = this.state.availableDestinations }
          const destinationOptionNames = destinationOptions.map(destinationOption => destinationOption.label)

          this.setState({
            destinationFieldsHaveErrors: !destinationOptionNames.includes(nexusName)
          })
          this.props.handleSelectLocation(this.state.originFieldsHaveErrors || !destinationOptionNames.includes(nexusName))
        })
      })
    }

    this.setState({ [target]: tmpAddress })
    this.props.setTargetAddress(target, tmpAddress)
    this.setState({
      autoText: { [target]: place.name }
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
  getCoordinates (hub, hubName) {
    const { allNexuses } = this.props
    let tmpCoord = {}
    switch (hub) {
      case 'origins':
        allNexuses.origins.forEach((nx) => {
          nx.label === hubName ? (tmpCoord = { lat: nx.value.latitude, lng: nx.longitude }) : ''
        })
        break
      case 'destinations':
        allNexuses.destinations.forEach((nx) => {
          nx.label === hubName ? (tmpCoord = { lat: nx.value.latitude, lng: nx.longitude }) : ''
        })
        break
      default:
        break
    }
    return tmpCoord
  }
  loadPrevReq() {
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
    if (shipment.origin_id) {
      this.state.map
        ? this.setDestHub(newData.destinationHub)
        : setTimeout(() => {
          this.setDestHub(newData.destinationHub)
        }, 500)
    }
    this.setState({
      autoTextOrigin: newData.autoTextOrigin,
      autoTextDest: newData.autoTextDest
    })
    return ''
  }
  handleSwap () {
    const origin = { ...this.state.destination }
    const destination = { ...this.state.origin }
    const autoText = { ...this.state.autoText }
    const pre = this.state.shipment.has_pre_carriage
    const on = this.state.shipment.has_on_carriage
    let autoTextDest = this.state.autoTextDest ? this.state.autoTextDest : ''
    let autoTextOrigin = this.state.autoTextOrigin ? this.state.autoTextOrigin : ''
    if ((pre && !on) || (!pre && on)) {
      () => this.changeAddressFormVisibility('origin');
      () => this.changeAddressFormVisibility('destination')
    }
    autoText.destination = destination.hub_name
    autoTextDest = this.state.autoTextOrigin

    autoText.origin = origin.hub_name
    autoTextOrigin = this.state.autoTextDest

    this.setState({
      origin, destination, autoText, autoTextOrigin, autoTextDest
    })
    this.setDestHub(this.state.oSelect)
    this.setOriginHub(this.state.dSelect)
  }
  render () {
    const { allNexuses } = this.props

    let originOptions = allNexuses && allNexuses.origins ? allNexuses.origins : []
    let destinationOptions = allNexuses && allNexuses.destinations ? allNexuses.destinations : []

    const {
      originFieldsHaveErrors,
      destinationFieldsHaveErrors,
      availableOrigins,
      availableDestinations
    } = this.state

    if (availableDestinations) destinationOptions = availableDestinations
    if (availableOrigins) originOptions = availableOrigins

    const showOriginError = !this.state.oSelect && this.props.nextStageAttempt
    const originHubSelect = (
      <div style={{ position: 'relative', margin: 'auto' }}>
        <StyledSelect
          name="origin-hub"
          className={`${styles.select}`}
          value={this.state.oSelect}
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
      <div style={{ position: 'relative', margin: 'auto' }}>
        <StyledSelect
          name="destination-hub"
          className={`${styles.select}`}
          value={this.state.dSelect}
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
      this.state.shipment.has_pre_carriage && this.state.showOriginFields ? styles.visible : ''
    const originFields = (
      <div className={`${styles.address_form_wrapper} ${toggleLogic}`}>
        <div
          className={`${styles.btn_address_form} ${
            this.state.shipment.has_pre_carriage ? '' : styles.hidden
          }`}
          onClick={() => this.changeAddressFormVisibility('origin')}
        >
          <i className={`${styles.down} fa fa-angle-double-down`} />
          <i className={`${styles.up} fa fa-angle-double-up`} />
        </div>
        <div className={`${styles.address_form} flex-100 layout-row layout-wrap`}>
          <div
            className={`${styles.address_form_title} flex-100 layout-row layout-align-start-center`}
          >
            <p className="flex-none">Enter Pickup Address</p>
          </div>
          <input
            id="not-auto"
            name="origin-number"
            className={`flex-none ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.props.origin.number}
            placeholder="Number"
          />
          <input
            name="origin-street"
            className={`flex-none ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.origin.street}
            placeholder="Street"
          />
          <input
            name="origin-zipCode"
            className={`flex-none ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.origin.zipCode}
            placeholder="Zip Code"
          />
          <input
            name="origin-city"
            className={`flex-none ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.origin.city}
            placeholder="City"
          />
          <input
            name="origin-country"
            className={`flex-none ${styles.input}`}
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
      this.state.shipment.has_on_carriage && this.state.showDestinationFields ? styles.visible : ''
    const destFields = (
      <div className={`${styles.address_form_wrapper} ${toggleLogic}`}>
        <div
          className={`${styles.btn_address_form} ${
            this.state.shipment.has_on_carriage ? '' : styles.hidden
          }`}
          onClick={() => this.changeAddressFormVisibility('destination')}
        >
          <i className={`${styles.down} fa fa-angle-double-down`} />
          <i className={`${styles.up} fa fa-angle-double-up`} />
        </div>
        <div className={`${styles.address_form} ${toggleLogic} flex-100 layout-row layout-wrap`}>
          <div
            className={`${styles.address_form_title} flex-100 layout-row layout-align-start-center`}
          >
            <p className="flex-none">Enter Delivery Address</p>
          </div>
          <input
            name="destination-number"
            className={`flex-none ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.destination.number}
            placeholder="Number"
          />
          <input
            name="destination-street"
            className={`flex-none ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.destination.street}
            placeholder="Street"
          />
          <input
            name="destination-zipCode"
            className={`flex-none ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.destination.zipCode}
            placeholder="Zip Code"
          />
          <input
            name="destination-city"
            className={`flex-none ${styles.input}`}
            type="string"
            onChange={this.handleAddressChange}
            onFocus={this.handleAddressFormFocus}
            onBlur={this.handleAddressFormFocus}
            value={this.state.destination.city}
            placeholder="City"
          />
          <input
            name="destination-country"
            className={`flex-none ${styles.input}`}
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
            className={`flex-none ${styles.input} ${
              destinationFieldsHaveErrors ? styles.with_errors : ''
            }`}
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
      if (target === 'origin' && !this.state.shipment.has_pre_carriage) {
        return originHubSelect
      }
      if (target === 'destination' && !this.state.shipment.has_on_carriage) {
        return destinationHubSelect
      }
      return ''
    }
    const { theme, user, shipment } = this.props
    const errorClass =
      originFieldsHaveErrors || destinationFieldsHaveErrors ? styles.with_errors : ''
    const routeModal = (
      <Modal
        component={
          <AvailableRoutes
            user={user}
            theme={theme}
            routes={shipment.itineraries}
            routeSelected={this.selectedRoute}
            initialCompName="UserAccount"
          />
        }
        width="48vw"
        verticalPadding="30px"
        horizontalPadding="15px"
        parentToggle={this.toggleModal}
      />
    )

    return (
      <div className="layout-row flex-100 layout-wrap layout-align-center-center">
        <div className="layout-row flex-100 layout-wrap layout-align-center-center">
          <div className="layout-row flex-none layout-align-start content_width">
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
          <div
            className={
              `${defaults.content_width
              } layout-row flex-none layout-align-start-start ${
                styles.map_container}`
            }
          >
            {this.state.showModal ? routeModal : ''}
            <div className={`flex-none layout-row layout-wrap ${styles.input_box} ${errorClass}`}>
              <div className="flex-45 layout-row layout-wrap layout-align-start-start mc">
                <div
                  className={`flex-40 layout-row layout-align-center-center ${styles.toggle_box}`}
                >
                  <Toggle
                    className="flex-none"
                    id="has_pre_carriage"
                    name="has_pre_carriage"
                    value={String(this.state.shipment.has_pre_carriage)}
                    defaultChecked={this.state.shipment.has_pre_carriage}
                    onChange={this.handleTrucking}
                  />
                  <label htmlFor="pre-carriage">Pre-Carriage</label>
                </div>
                <div className={`flex-50 layout-row layout-wrap ${styles.search_box}`}>
                  {this.state.shipment.has_pre_carriage ? originAuto : ''}
                  {displayLocationOptions('origin')}
                  {originFields}
                </div>
              </div>
              <div
                className="flex-10 layout-row layout-align-center-center "
                onClick={this.handleSwap}
              >
                <i className={`${styles.fa_exchange_style} fa fa-exchange `} />
              </div>
              <div className="flex-45 layout-row layout-wrap layout-align-end-start">
                <div
                  className={`flex-40 layout-row layout-align-center-center ${styles.toggle_box}`}
                >
                  <Toggle
                    className="flex-none"
                    id="has_on_carriage"
                    name="has_on_carriage"
                    value={String(this.state.shipment.has_on_carriage)}
                    defaultChecked={this.state.shipment.has_on_carriage}
                    onChange={this.handleTrucking}
                  />
                  <label htmlFor="on-carriage">On-Carriage</label>
                </div>
                <div className={`flex-50 layout-row layout-wrap ${styles.search_box}`}>
                  {this.state.shipment.has_on_carriage ? destAuto : ''}
                  {displayLocationOptions('destination')}
                  {destFields}
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <div id="map" style={mapStyle} />
            </div>
          </div>
          {theme ? (
            <style
              dangerouslySetInnerHTML={{
                __html: `
                            .react-toggle--checked .react-toggle-track {
                                background: linear-gradient(90deg, ${
            theme.colors.brightPrimary
            } 0%, ${theme.colors.brightSecondary} 100%);
                                border: 0.5px solid rgba(0, 0, 0, 0);
                            }
                    `
              }}
            />
          ) : (
            ''
          )}
        </div>
      </div>
    )
  }
}

ShipmentLocationBox.propTypes = {
  nextStageAttempt: PropTypes.bool,
  handleSelectLocation: PropTypes.func.isRequired,
  availableDestinations: PropTypes.arrayOf(PropTypes.object),
  gMaps: PropTypes.gMaps.isRequired,
  theme: PropTypes.theme,
  user: PropTypes.user,
  shipment: PropTypes.shipment,
  setTargetAddress: PropTypes.func.isRequired,
  handleAddressChange: PropTypes.func.isRequired,
  setCarriage: PropTypes.func.isRequired,
  allNexuses: PropTypes.shape({
    origins: PropTypes.array,
    destinations: PropTypes.array
  }).isRequired,
  selectedRoute: PropTypes.route,
  origin: PropTypes.shape({
    number: PropTypes.number
  }),
  nexusDispatch: PropTypes.shape({
    getAvailableDestinations: PropTypes.func
  }).isRequired,
  routeIds: PropTypes.arrayOf(PropTypes.number),
  prevRequest: PropTypes.shape({
    shipment: PropTypes.shipment
  })
}

ShipmentLocationBox.defaultProps = {
  nextStageAttempt: false,
  theme: null,
  user: null,
  shipment: null,
  routeIds: [],
  prevRequest: null,
  availableDestinations: [],
  selectedRoute: null,
  origin: null
}

export default ShipmentLocationBox
