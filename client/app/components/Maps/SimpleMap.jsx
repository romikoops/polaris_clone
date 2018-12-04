import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './Maps.scss'
import { colorSVG } from '../../helpers'
import { mapStyling } from '../../constants/map.constants'

const mapStyles = mapStyling

export class SimpleMap extends Component {
  constructor (props) {
    super(props)

    this.state = {
      markers: {}
    }
    this.setMarker = this.setMarker.bind(this)
    this.setInitialMarker = this.setInitialMarker.bind(this)
  }

  componentDidMount () {
    this.initMap(this.setInitialMarker)
  }
  componentWillReceiveProps () {
    this.setInitialMarker()
  }
  setInitialMarker () {
    const { address } = this.props
    if (address && address.latitude && address.longitude) {
      this.setMarker({
        lat: address.latitude,
        lng: address.longitude
      }, address.name)
    }
  }

  setMarker (address, name) {
    const { markers, map } = this.state
    const { theme, zoom } = this.props
    const newMarkers = []
    const icon = {
      url: colorSVG('address', theme),
      anchor: new this.props.gMaps.Point(25, 50),
      scaledSize: new this.props.gMaps.Size(36, 36)
    }
    const marker = new this.props.gMaps.Marker({
      position: address,
      map,
      title: name,
      icon
    })
    markers.address = marker
    newMarkers.push(markers.address)
    this.setState({ markers })
    const bounds = new this.props.gMaps.LatLngBounds()
    for (let i = 0; i < newMarkers.length; i++) {
      bounds.extend(newMarkers[i].getPosition())
    }
    if (newMarkers.length > 1) {
      map.fitBounds(bounds)
    } else if (newMarkers.length === 1) {
      map.setCenter(bounds.getCenter())
      map.setZoom(zoom)
    }

    // map.fitBounds(bounds);
  }

  initMap (callback) {
    const { zoom } = this.props
    const mapsOptions = {
      center: {
        lat: 55.675647,
        lng: 12.567848
      },
      zoom,
      mapTypeId: this.props.gMaps.MapTypeId.ROADMAP,
      disableDefaultUI: true,
      styles: mapStyles
    }

    const map = new this.props.gMaps.Map(document.getElementById('map'), mapsOptions)
    this.setState({ map }, () => {
      callback()
    })
  }

  render () {
    const { height } = this.props
    const mapStyle = {
      width: '100%',
      height,
      borderRadius: '3px',
      boxShadow: '1px 1px 2px 2px rgba(0,1,2,0.25)'
    }

    return (
      <div className={`flex-100 layout-row layout-wrap ${styles.map_box}`}>
        <div id="map" className={`flex-100 layout-row ${styles.place_map}`} style={mapStyle} />
      </div>
    )
  }
}

SimpleMap.propTypes = {
  theme: PropTypes.theme,
  gMaps: PropTypes.gMaps.isRequired,
  address: PropTypes.objectOf(PropTypes.any),
  height: PropTypes.string,
  zoom: PropTypes.number
}

SimpleMap.defaultProps = {
  theme: null,
  address: {},
  height: '167px',
  zoom: 12
}

export default SimpleMap
