import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { get } from 'lodash'
import { mapStyling } from '../../../../constants/map.constants'
import { mapActions } from '../../../../actions'
import styles from './index.scss'
import { debounce } from '../../../../helpers'
import NamedSelect from '../../../NamedSelect/NamedSelect'
import LoadingSpinner from '../../../LoadingSpinner/LoadingSpinner'

class TruckingCoverageEditor extends Component {
  constructor (props) {
    super(props)
    this.state = {
      geoJsons: [],
      map: null,
      targetId: false,
      bounds: {
        north: 0,
        south: 0,
        east: 0,
        west: 0
      },
      selectedAreas: [],
      setFeatures: [],
      adminLevel: {}
    }
    this.initMap = this.initMap.bind(this)
    this.setMapData = this.setMapData.bind(this)
    this.updateMapData = this.updateMapData.bind(this)
  }

  componentDidMount () {
    this.initMap()
  }

  componentWillReceiveProps (nextProps, prevState) {
    const {
      center, gMaps, orignalLocation, current_admin_level
    } = nextProps
    const { map } = this.state
    if (this.state.selectedAreas.length === 0 && orignalLocation) {
      this.setState({ selectedAreas: [orignalLocation] })
    }
    if (prevState.center !== center) {
      this.setState({ center })
      map.panTo(new gMaps.LatLng(center))
      this.setMapData(nextProps)
    }

    if (current_admin_level) {
      this.setState({ adminLevel: { label: current_admin_level, value: current_admin_level } })
    }
  }

  handleListChange (area) {
    this.setState((prevState) => {
      const { selectedAreas } = prevState
      if (selectedAreas.some(a => a.id === area.id)) {
        return { selectedAreas: selectedAreas.filter(x => x.id !== area.id) }
      }

      return { selectedAreas: [...selectedAreas, area] }
    })
  }

  setMapData (props) {
    const { map, selectedAreas, setFeatures } = this.state
    const { data, orignalLocation } = props || this.props
    if (setFeatures) {
      setFeatures.forEach((feature) => {
        map.data.remove(feature[0])
      })
    }
    const newSetFeatures = []
    if (data) {
      data.forEach((datum) => {
        if (datum.geojson) {
          const features = map.data.addGeoJson(datum.geojson)
          features[0].setProperty('locationData', datum)
          if (selectedAreas.some(x => x.id === datum.id)) {
            features[0].setProperty('isSelected', true)
          }
          newSetFeatures.push(features)
        }
      })
      map.data.setStyle((feature) => {
        let color = 'gray'
        const isAreaSelected = feature.getProperty('isSelected')
        const datum = feature.getProperty('locationData')
        const originalLocationId = get(orignalLocation, ['id'], false)
        const datumId = get(datum, ['id'], false)
        if (isAreaSelected && datumId !== originalLocationId) {
          color = 'green'
        } else if (isAreaSelected && datumId === originalLocationId) {
          color = 'blue'
        } else if (!isAreaSelected && datumId === originalLocationId) {
          color = 'red'
        }

        return ({
          fillColor: color,
          strokeColor: color,
          strokeWeight: 2
        })
      })
      map.data.addListener('click', (event) => {
        const datum = event.feature.getProperty('locationData')
        event.feature.setProperty('isSelected', true)
        this.handleListChange(datum)
      })
    }
    this.setState({ setFeatures: newSetFeatures })
    map.panTo(map.center)
  }

  fetchActiveGeoJson (props) {
    const { mapDispatch, targetId } = props || this.props
    mapDispatch.getGeoJson(targetId)
  }

  handleAdminLevel (e) {
    this.setState({ adminLevel: e }, () => {
      this.updateMapData()
    })
  }

  updateMapData (newBounds) {
    const { bounds, adminLevel } = this.state
    const { targetId, mapDispatch } = this.props
    if (!newBounds) {
      const args = {
        id: targetId,
        ...bounds
      }
      if (adminLevel.value) {
        args.admin_level = adminLevel.value
      }
      debounce(mapDispatch.getEditorMapData(args), 1000)
    } else {
      const jsonBounds = newBounds.toJSON()
      const newArea = (jsonBounds.north - jsonBounds.south) * (jsonBounds.east - jsonBounds.west)
      const oldArea = (bounds.north - bounds.south) * (bounds.east - bounds.west)

      if (newArea > oldArea) {
        const args = {
          id: targetId,
          ...jsonBounds
        }
        if (adminLevel.value) {
          args.admin_level = adminLevel.value
        }
        this.setState({ bounds: jsonBounds })
        debounce(mapDispatch.getEditorMapData(args), 1000)
      }
    }
  }

  initMap (callback) {
    const { zoom, location, gMaps } = this.props
    const mapsOptions = {
      center: {
        lat: location.latitude || 55.675647,
        lng: location.longitude || 12.567848
      },
      zoom: zoom || 7,
      mapTypeId: gMaps.MapTypeId.ROADMAP,
      disableDefaultUI: true,
      styles: mapStyling
    }

    const map = new gMaps.Map(document.getElementById('map'), mapsOptions)
    gMaps.event.addListener(map, 'bounds_changed', () => {
      this.updateMapData(map.getBounds())
    })
    this.setState({ map }, () => {
      if (callback) {
        callback()
      }
    })
  }

  render () {
    const { t, orignalLocation, fetching } = this.props
    const { selectedAreas, adminLevel } = this.state
    const adminLevelOptions = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13].map(i => ({ label: i, value: i }))

    return (
      <div className={`flex-100 layout-row layout-wrap ${styles.wrapper}`}>
        { fetching ? (
          <div className={`flex-none layout-row layout-align-center-center ${styles.loading}`}>
            <LoadingSpinner size="medium" />
          </div>
        ) : '' }
        <div className={`flex-80 layout-row layout-wrap ${styles.map_box}`}>
          <div id="map" className={`flex-100 layout-row ${styles.place_map}`} />
        </div>
        <div className={`flex-20 layout-row layout-wrap layout-align-start-start ${styles.editor_box}`}>
          <div className={`flex-100 layout-row layout-align-center-start layout-wrap ${styles.editor_section}`}>
            <div className="flex-100 layout-row">
              <h3 className="flex ">{t('admin:selectAdminLevel')}</h3>
            </div>
            <div className="flex-100 layout-row">
              <NamedSelect
                className="flex-100"
                options={adminLevelOptions}
                value={adminLevel}
                onChange={e => this.handleAdminLevel(e)}
              />
            </div>
          </div>
          <div className={`flex-100 layout-row layout-align-center-start layout-wrap ${styles.editor_section}`}>
            <div className="flex-100 layout-row">
              <h3 className="flex ">{t('admin:originalArea')}</h3>
            </div>
            <div className="flex-100 layout-row">
              <p className="flex ">{get(orignalLocation, ['name'])}</p>
            </div>
          </div>

          <div className={`flex-100 layout-row layout-align-center-start layout-wrap ${styles.editor_section}`}>
            <div className="flex-100 layout-row">
              <h3 className="flex ">{t('admin:selectedAreas')}</h3>
            </div>
            <ul className="flex-100">
              {
                selectedAreas.map(area => (
                  <li className="flex-100 layout-row">
                    <p className="flex ">{area.name}</p>
                    <p className="flex-10 ">{area.admin_level}</p>
                    <p className="flex-10 pointy" onClick={() => this.handleListChange(area)}>
                      <i className="fa fa-trash red" />
                    </p>
                  </li>
                ))
              }
            </ul>

          </div>
        </div>
      </div>
    )
  }
}
function mapStateToProps (state) {
  const { map } = state
  const { editor, fetching } = map
  const {
    data,
    geojson,
    center,
    original_location,
    current_admin_level
  } = editor || {}

  return {
    data,
    geojson,
    center,
    orignalLocation: original_location,
    current_admin_level,
    fetching
  }
}
function mapDispatchToProps (dispatch) {
  return {
    mapDispatch: bindActionCreators(mapActions, dispatch)
  }
}

export default withNamespaces(['common', 'shipment', 'trucking'])(connect(mapStateToProps, mapDispatchToProps)(TruckingCoverageEditor))
