import React, { PureComponent } from 'react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { mapStyling } from '../../../../constants/map.constants'
import { mapActions } from '../../../../actions'
import styles from './index.scss'

class TruckingCoverage extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      geoJsons: [],
      map: null,
      targetId: false
    }
    this.initMap = this.initMap.bind(this)
    this.setMapData = this.setMapData.bind(this)
    this.setMapCoverage = this.setMapCoverage.bind(this)
  }

  componentDidMount () {
    const { location, mapDispatch, geojsons } = this.props
    mapDispatch.getMapData(location.id)
    this.initMap(this.setMapCoverage)
  }

  componentWillReceiveProps (nextProps, prevState) {
    const { coverage, geojsons, geojson, targetId } = nextProps
    if ((targetId !== this.props.targetId) && !!targetId) {
      this.fetchActiveGeoJson(nextProps)
    }
    if (geojson !== prevState.geoJson) {
      this.setActiveGeoJson(nextProps)
    }
  }

  fetchActiveGeoJson (props) {
    const { mapDispatch, targetId } = props
    mapDispatch.getGeoJson(targetId)
  }

  setMapData (props) {
    const { map } = this.state
    const { geojsons, onMapClick } = props || this.props

    if (geojsons) {
      geojsons.forEach((data) => {
        if (data.geojson) {
          const features = map.data.addGeoJson(data.geojson)
          features[0].setProperty('rateId', data.trucking_rate_id)
        }
      })
      map.data.setStyle((feature) => {
        let color = 'gray'
        if (feature.getProperty('isSelected')) {
          color = 'green'
        }

        return ({
          fillColor: color,
          strokeColor: color,
          strokeWeight: 2
        })
      })
      map.data.addListener('click', (event) => {
        const id = event.feature.getProperty('rateId')
        event.feature.setProperty('isSelected', true)
        onMapClick(id)
      })
    }

    map.panTo(map.center)
  }
  setMapCoverage (props) {
    const { map } = this.state
    const { coverage, onMapClick } = props || this.props

    if (coverage) {
 
      const features = map.data.addGeoJson(coverage)
        
      map.data.setStyle((feature) => {
        let color = 'gray'

        return ({
          fillColor: color,
          strokeColor: color,
          strokeWeight: 2
        })
      })
    }

    map.panTo(map.center)
  }
  setActiveGeoJson (props) {
    const { map, activeGeoJsons } = this.state
    const { geojson, location, gMaps } = props || this.props
    let bounds
    if ((!geojson || !geojson.geojson) && (!activeGeoJsons || activeGeoJsons.length === 0)) {
      return
    }
    if (activeGeoJsons) {
      activeGeoJsons.forEach(activeGeoJson => {
        if (activeGeoJson.setMap) {
          activeGeoJson.setMap(null)
        } else {
          map.data.remove(activeGeoJson)
        }
      })
    }
    if (geojson && !geojson.distance) {
 
      const features = map.data.addGeoJson(geojson.geojson)
        
      map.data.setStyle((feature) => {
        let color = 'green'

        return ({
          fillColor: color,
          strokeColor: color,
          strokeWeight: 2
        })
      })
      
      bounds = new gMaps.LatLngBounds()
      features.forEach((feature) => {
        feature.getGeometry().forEachLatLng((latlng) => {
          bounds.extend(latlng)
        })
      })
      this.setState({ geoJson: geojson, activeGeoJsons: features  })
    }
    if (geojson && geojson.distance) {
      const circle = new google.maps.Circle({
        strokeColor: 'green',
        strokeOpacity: 0.8,
        strokeWeight: 2,
        fillColor: 'green',
        fillOpacity: 0.35,
        map: map,
        center: {
          lat: location.latitude,
          lng: location.longitude
        },
        radius: geojson.distance * 1000
      })    

      bounds = circle.getBounds()
      this.setState({ geoJson: geojson, activeGeoJsons: [circle]  })
    }
    
    map.fitBounds(bounds)
  }

  initMap (callback) {
    const { zoom, location, gMaps } = this.props
    const mapsOptions = {
      center: {
        lat: location.latitude || 55.675647,
        lng: location.longitude || 12.567848
      },
      zoom: zoom || 5,
      mapTypeId: gMaps.MapTypeId.ROADMAP,
      disableDefaultUI: true,
      styles: mapStyling
    }

    const map = new gMaps.Map(document.getElementById('map'), mapsOptions)
    this.setState({ map }, () => {
      callback()
    })
  }

  render () {
    return (
      <div className={`flex-100 layout-row layout-wrap ${styles.map_box}`}>
        <div id="map" className={`flex-100 layout-row ${styles.place_map}`} />
      </div>
    )
  }
}
function mapStateToProps (state) {
  const { map } = state
  const { geojsons, geojson } = map

  return {
    geojsons,
    geojson
  }
}
function mapDispatchToProps (dispatch) {
  return {
    mapDispatch: bindActionCreators(mapActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(TruckingCoverage)
