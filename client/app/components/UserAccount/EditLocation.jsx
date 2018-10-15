import React, { Component } from 'react'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './UserAccount.scss'
// import defaults from '../../styles/default_classes.scss';
import { RoundButton } from '../RoundButton/RoundButton'
import { colorSVG } from '../../helpers'
import { mapStyling } from '../../constants/map.constants'

const colourSVG = colorSVG
const mapStyles = mapStyling
const mapStyle = {
  width: '100%',
  height: '400px',
  borderRadius: '3px',
  boxShadow: '1px 1px 2px 2px rgba(0,1,2,0.25)'
}

class EditLocation extends Component {
  constructor (props) {
    super(props)

    this.state = {
      geocodedAddress: this.props.geocodedAddress,
      location: {
        street: this.props.location ? this.props.location.street : '',
        number: this.props.location ? this.props.location.street_number : '',
        zipCode: this.props.location ? this.props.location.zip_code : '',
        city: this.props.location ? this.props.location.city : '',
        country: this.props.location ? this.props.location.country : '',
        fullAddress: this.props.location ? this.props.location.geocoded_address : ''
      },
      autoText: {
        location: ''
      },
      autocomplete: {
        location: ''
      },
      markers: {}
    }
    this.handleAddressChange = this.handleAddressChange.bind(this)
    this.selectLocation = this.selectLocation.bind(this)
    this.resetAuto = this.resetAuto.bind(this)
    this.setMarker = this.setMarker.bind(this)
    this.handleAuto = this.handleAuto.bind(this)
    this.saveLocation = this.saveLocation.bind(this)
    this.handleInputChange = this.handleInputChange.bind(this)
  }
  componentDidMount () {
    this.initMap()
  }
  componentWillReceiveProps () {
    if (!this.state.location.street && this.props.location) {
      this.setState({
        location: {
          street: this.props.location.street,
          number: this.props.location.street_number,
          zipCode: this.props.location.zip_code,
          city: this.props.location.city,
          country: this.props.location.country,
          fullAddress: this.props.location.geocoded_address
        }
      })
    }
  }
  setMarker (location, name) {
    const { markers, map } = this.state
    const { theme } = this.props
    const newMarkers = []
    const icon = {
      url: colourSVG('location', theme),
      anchor: new this.props.gMaps.Point(25, 50),
      scaledSize: new this.props.gMaps.Size(36, 36)
    }
    const marker = new this.props.gMaps.Marker({
      position: location,
      map,
      title: name,
      icon
    })
    markers.location = marker
    newMarkers.push(markers.location)
    this.setState({ markers })
    const bounds = new this.props.gMaps.LatLngBounds()
    for (let i = 0; i < newMarkers.length; i++) {
      bounds.extend(newMarkers[i].getPosition())
    }

    map.fitBounds(bounds)
  }
  handleInputChange (event) {
    const val = event.target.value

    this.setState({
      geocodedAddress: val
    })
  }
  handleAuto (event) {
    const { name, value } = event.target
    this.setState({ autoText: { [name]: value } })
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
    this.initAutocomplete(map)
  }

  initAutocomplete (map) {
    // const targetId = target + '-gmac';
    const input = document.getElementById('location')
    const autocomplete = new this.props.gMaps.places.Autocomplete(input)
    autocomplete.bindTo('bounds', map)
    this.setState({ autoListener: { ...this.state.autoListener, location: autocomplete } })
    this.autocompleteListener(map, autocomplete)
  }
  autocompleteListener (aMap, autocomplete, t) {
    const infowindow = new this.props.gMaps.InfoWindow()
    const infowindowContent = document.getElementById('infowindow-content')
    infowindow.setContent(infowindowContent)

    const marker = new this.props.gMaps.Marker({
      map: aMap,
      anchorPoint: new this.props.gMaps.Point(0, -29)
    })

    autocomplete.addListener('place_changed', () => {
      infowindow.close()
      marker.setVisible(false)
      const place = autocomplete.getPlace()
      if (!place.geometry) {
        window.alert(t('nav:noDetailsAvailable', { placeName: place.name }))

        return
      }

      this.setMarker(
        {
          lat: place.geometry.location.lat(),
          lng: place.geometry.location.lng()
        },
        place.name
      )

      this.selectLocation(place)
    })
  }
  handleAddressChange (event) {
    const eventKeys = event.target.name.split('-')
    const key1 = eventKeys[0]
    const key2 = eventKeys[1]
    const val = event.target.value

    this.setState({
      [key1]: {
        ...this.state[key1],
        [key2]: val
      }
    })
    // console.log(this.state[key1]);
  }
  selectLocation (place) {
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

    this.setState({ location: tmpAddress })
    this.setState({
      autocomplete: { ...this.state.autocomplete, location: true }
    })
  }
  resetAuto () {
    // this.state.autoListener[target].clearListeners();
    this.setState({
      autocomplete: { ...this.state.autocomplete, location: false }
    })
  }
  saveLocation () {
    const { location } = this.state
    const preppedLocation = {}
    preppedLocation.id = this.props.location.id
    preppedLocation.street_number = location.number
    preppedLocation.street = location.street
    preppedLocation.zip_code = location.zipCode
    preppedLocation.city = location.city
    preppedLocation.country = location.country
    this.props.saveLocation(preppedLocation)
  }

  render () {
    const { t } = this.props
    const originFields = (
      <div className="flex-80 layout-row layout-wrap layout-align-end-space-around">
        <input
          id="not-auto"
          name="location-number"
          className={`flex-none ${styles.input}`}
          type="string"
          onChange={this.handleAddressChange}
          value={this.state.location.number}
          placeholder={t('user:streetNumber')}
        />
        <input
          name="location-street"
          className={`flex-none ${styles.input}`}
          type="string"
          onChange={this.handleAddressChange}
          value={this.state.location.street}
          placeholder={t('user:street')}
        />
        <input
          name="location-zipCode"
          className={`flex-none ${styles.input}`}
          type="string"
          onChange={this.handleAddressChange}
          value={this.state.location.zipCode}
          placeholder={t('user:postalCode')}
        />
        <input
          name="location-city"
          className={`flex-none ${styles.input}`}
          type="string"
          onChange={this.handleAddressChange}
          value={this.state.location.city}
          placeholder={t('user:city')}
        />
        <input
          name="location-country"
          className={`flex-none ${styles.input}`}
          type="string"
          onChange={this.handleAddressChange}
          value={this.state.location.country}
          placeholder={t('user:country')}
        />
        <div className="flex-100 layout-row layout-align-start-center">
          <div
            className="flex-none layout-row layout-align-end-center"
            onClick={() => this.resetAuto('location')}
          >
            <i className="fa fa-times flex-none" />
            <p className="offset-5 flex-none" style={{ paddingRight: '10px' }}>
              Clear
            </p>
          </div>
        </div>
      </div>
    )
    const autoHide = {
      height: '0px',
      display: 'none'
    }
    const autoInput = (
      <div
        className={`flex-100 layout-row layout-wrap ${styles.overlay_auto}`}
        style={this.state.autocomplete.location ? autoHide : {}}
      >
        <input
          id="location"
          name="location"
          className={`flex-none ${styles.input}`}
          type="string"
          onChange={this.handleAuto}
          value={this.state.autoText.location}
          placeholder={t('nav:searchAddress')}
        />
      </div>
    )

    return (
      <div className="layout-row flex-100 layout-wrap">
        <h1
          className="layout-row flex-100"
          onClick={() => this.props.toggleActiveView('allLocations')}
        />
        <div className="flex-100 layout-row layout-align-end-center">
          <div
            className="flex-none layout-row layout-align-center-center"
            onClick={() => this.props.toggleActiveView('allLocations')}
          >
            <i className="flex-none fa fa-checvron-left" />
            <p className="flex-none">{t('common:basicBack')}</p>
          </div>
        </div>
        <div
          className={`flex-65 layout-row layout-wrap layout-align-center-start ${styles.map_box}`}
        >
          {autoInput}
          <div id="map" className={styles.loc_map} style={mapStyle} />
        </div>
        <div className="flex-30 offset-5 layout-row layout-wrap layout-align-center-end">
          {originFields}
          <RoundButton
            active
            text={t('common:save')}
            theme={this.props.theme}
            size="small"
            handleNext={this.saveLocation}
            iconClass="fa-check"
          />
        </div>
      </div>
    )
  }
}

EditLocation.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  toggleActiveView: PropTypes.func.isRequired,
  saveLocation: PropTypes.func.isRequired,
  gMaps: PropTypes.gMaps.isRequired,
  geocodedAddress: PropTypes.string,
  location: PropTypes.objectOf(PropTypes.string)
}

EditLocation.defaultProps = {
  theme: null,
  geocodedAddress: '',
  location: {}
}

export default translate(['user', 'common', 'nav'])(EditLocation)
