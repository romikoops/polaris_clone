import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './Maps.scss'
import { colorSVG } from '../../helpers'
import { mapStyling } from '../../constants/map.constants'

const colourSVG = colorSVG
const mapStyles = mapStyling
const baseMapStyle = {
  width: '100%',
  height: '300px',
  borderRadius: '3px',
  boxShadow: '1px 1px 2px 2px rgba(0,1,2,0.25)'
}
export class PlaceSearch extends Component {
  constructor (props) {
    super(props)

    this.state = {
      autoText: {
        location: ''
      },
      markers: {}
    }
    this.selectLocation = this.selectLocation.bind(this)
    this.setMarker = this.setMarker.bind(this)
    this.handleAuto = this.handleAuto.bind(this)
  }

  componentDidMount () {
    this.initMap()
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
    if (newMarkers.length > 1) {
      map.fitBounds(bounds)
    } else if (newMarkers.length === 1) {
      map.setCenter(bounds.getCenter())
      map.setZoom(14)
    }

    // map.fitBounds(bounds);
  }

  handleAuto (event) {
    console.log(event.target)
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
  autocompleteListener (aMap, autocomplete) {
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
        window.alert(`No details available for input: '${place.name}'`)
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
  selectLocation (place) {
    this.props.handlePlaceChange(place)
  }

  render () {
    const autoInputStyles = {}
    const mapStyle = Object.assign({}, baseMapStyle)
    if (this.props.hideMap) {
      Object.assign(mapStyle, {
        display: 'none'
      })
    } else {
      Object.assign(autoInputStyles, {
        position: 'absolute',
        zIndex: '25',
        top: '50px',
        left: '40px',
        boxShadow: '1px 2px 1px rgba(0,1,2,0.5)'
      })
    }
    const autoInput = (
      <div className="flex-100 layout-row layout-wrap" style={autoInputStyles}>
        <input
          id="location"
          name="location"
          className={`flex-none ${styles.input}`}
          type="string"
          onChange={this.handleAuto}
          value={this.state.autoText.location}
          placeholder="Search for address"
          style={this.props.inputStyles}
        />
      </div>
    )
    return (
      <div className={`flex-100 layout-row layout-wrap ${styles.map_box}`}>
        <div id="map" className={`flex-100 layout-row ${styles.place_map}`} style={mapStyle} />
        {autoInput}
      </div>
    )
  }
}

PlaceSearch.propTypes = {
  theme: PropTypes.theme,
  handlePlaceChange: PropTypes.func.isRequired,
  gMaps: PropTypes.gMaps.isRequired,
  hideMap: PropTypes.bool,
  inputStyles: PropTypes.objectOf(PropTypes.string)
}

PlaceSearch.defaultProps = {
  theme: null,
  hideMap: false,
  inputStyles: {}
}

export default PlaceSearch
