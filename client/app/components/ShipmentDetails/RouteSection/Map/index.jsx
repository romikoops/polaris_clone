import React from 'react'
import { has } from 'lodash'
import GmapsLoader from '../../../../hocs/GmapsLoader'
import { mapStyling } from '../../../../constants/map.constants'
import styles from './index.scss'
import { colorSVG } from '../../../../helpers'
import removeTabIndex from './removeTabIndex'

class RouteSectionMapContent extends React.PureComponent {
  constructor (props) {
    super(props)

    this.mapStyle = {
      width: '100%',
      height: '600px',
      borderRadius: '3px',
      boxShadow: '1px 1px 2px 2px rgba(0,1,2,0.25)'
    }

    this.state = { markers: { origin: null, destination: null } }

    this.getIcon = this.getIcon.bind(this)
    this.setMarker = this.setMarker.bind(this)
    this.initMap = this.initMap.bind(this)
    this.adjustMapBounds = this.adjustMapBounds.bind(this)
  }

  componentDidMount () {
    this.initMap()
  }

  getIcon (target) {
    const { theme, gMaps } = this.props

    if (target === 'origin') {
      return {
        url: colorSVG('address', theme),
        anchor: new gMaps.Point(18, 36),
        scaledSize: new gMaps.Size(36, 36)
      }
    }

    if (target === 'destination') {
      return {
        url: colorSVG('flag', theme),
        anchor: new gMaps.Point(10, 25),
        scaledSize: new gMaps.Size(36, 36)
      }
    }

    return null
  }

  getMarker (target, address) {
    if (!address) return null

    const { gMaps } = this.props

    return new gMaps.Marker({
      position: address,
      map: this.map,
      title: target,
      icon: this.getIcon(target),
      optimized: false,
      keyboard: false
    })
  }

  setMarker (target, address) {
    const { markers } = this.state
    const { withDrivingDirections } = this.props

    // Clear previous marker from map
    if (has(markers, [target, 'title'])) {
      markers[target].setMap(null)
    }

    this.setState(
      prevState => ({
        markers: {
          ...prevState.markers,
          [target]: this.getMarker(target, address)
        }
      }),
      () => {
        this.adjustMapBounds()

        if (withDrivingDirections) this.setDrivingDirections()
      }
    )
  }

  setDrivingDirections () {
    const { markers } = this.state

    if (Object.values(markers).some(marker => marker == null)) return

    this.directionsDisplay.setMap(this.map)
    const request = {
      origin: markers.origin.getPosition(),
      destination: markers.destination.getPosition(),
      travelMode: 'DRIVING'
    }
    this.directionsService.route(request, (result, status) => {
      if (status === 'OK') this.directionsDisplay.setDirections(result)
    })
  }

  initMap () {
    const { gMaps, origin, destination, withDrivingDirections } = this.props

    const mapsOptions = {
      center: {
        lat: 55.675647,
        lng: 12.567848
      },
      zoom: 5,
      mapTypeId: gMaps.MapTypeId.ROADMAP,
      disableDefaultUI: true,
      styles: mapStyling,
      keyboard: false,
      gestureHandling: 'none',
      zoomControl: false
    }

    this.map = new gMaps.Map(this.mapDiv, mapsOptions)
    removeTabIndex(this.map, gMaps)

    this.directionsDisplay = false
    this.directionsService = false
    if (withDrivingDirections) {
      this.directionsService = new gMaps.DirectionsService()
      this.directionsDisplay = new gMaps.DirectionsRenderer({ suppressMarkers: true })
    }

    // set initial markers
    if (origin.latitude && origin.longitude) {
      this.setMarker('origin', { lat: origin.latitude, lng: origin.longitude })
    }
    if (destination.latitude && destination.longitude) {
      this.setMarker('destination', { lat: destination.latitude, lng: destination.longitude })
    }

    this.forceUpdate()
  }

  adjustMapBounds () {
    const { markers } = this.state
    const { gMaps } = this.props

    const bounds = new gMaps.LatLngBounds()
    Object.values(markers).forEach(marker => marker && bounds.extend(marker.getPosition()))

    if (Object.values(markers).every(marker => marker == null)) {
      this.map.setCenter({
        lat: 55.675647,
        lng: 12.567848
      })
      this.map.setZoom(5)
    } else if (Object.values(markers).every(marker => marker)) {
      this.map.fitBounds(bounds, { top: 100, bottom: 20 })
    } else {
      this.map.setCenter(bounds.getCenter())
      this.map.setZoom(13)
    }
  }

  render () {
    const { children, gMaps } = this.props

    return (
      <div className={`flex-100 ${styles.route_section_map}`}>
        <div ref={(div) => { this.mapDiv = div }} id="map" style={this.mapStyle} />
        <div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.children_wrapper}`}>
          { this.map && children({ gMaps, map: this.map, setMarker: this.setMarker }) }
        </div>
      </div>
    )
  }
}

function RouteSectionMap (props) {
  return <GmapsLoader {...props} component={RouteSectionMapContent} />
}

export default RouteSectionMap
