import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { get } from 'lodash'
import GmapsWrapper from '../../../../hocs/GmapsWrapper'
import { clientsActions } from '../../../../actions'
import styles from './index.scss'
import AdminMarginPreviewResult from './Result'
import { cargoClassOptions } from '../../../../constants'
import NamedAsync from '../../../NamedSelect/NamedAsync'
import { getHubOptions, isEmpty } from '../../../../helpers'
import NamedSelect from '../../../NamedSelect/NamedSelect'
import PlaceSearch from '../../../Maps/PlaceSearch'
import CarriageToggle from '../../../ShipmentDetails/RouteSection/CarriageToggle'
import SquareButton from '../../../SquareButton/index'
import LoadingSpinner from '../../../LoadingSpinner/LoadingSpinner'

class AdminClientMarginPreview extends Component {
  static targetKeys (target) {
    return target.includes('Origin') ? ['selectedDestinationTrucking', 'selectedDestinationHub'] : ['selectedOriginTrucking', 'selectedOriginHub']
  }

  constructor (props) {
    super(props)
    this.state = {
      stage: 0,
      filteredTenantVehicles: [],
      filteredCargoClasses: cargoClassOptions,
      selectedOriginHub: {},
      selectedDestinationHub: {},
      selectedOriginTrucking: {},
      selectedDestinationTrucking: {},
      originTrucking: false,
      destinationTrucking: false
    }
    this.testMargins = this.testMargins.bind(this)
  }

  componentWillUnmount () {
    const { clientsDispatch } = this.props
    clientsDispatch.clearMarginPreview()
  }

  setItinerary (n, e) {
    this.setState({ selectedItinerary: e })
    const { clientsDispatch, targetType, targetId } = this.props
    clientsDispatch.testMargins({
      itineraryId: get(e, ['value', 'id'], null),
      targetType,
      targetId
    })
  }

  setFilter (e) {
    const { name, label, value } = e
    this.setState({ [name]: { value, label } })
  }

  selectHub (name, e) {
    const target = name === 'pre' ? 'selectedOriginHub' : 'selectedDestinationHub'
    this.setState({ [target]: e }, () => {
      if (AdminClientMarginPreview.targetKeys(target).some(key => !!isEmpty(this.state[key]))) {
        this.setState({ stage: 3 })
      }
    })
  }

  selectCargoClass (e) {
    this.setState(prevState => ({ selectedCargoClass: e, stage: 1 }))
  }

  handleTruckingToggle (target) {
    this.setState(prevState => ({ [`${target}Trucking`]: !prevState[`${target}Trucking`] }))
  }

  selectTruckingLocation (place, target) {
    const latLngObj = { lat: place.geometry.location.lat(), lng: place.geometry.location.lng() }
    this.setState(({ [target]: latLngObj }), () => {
      if (AdminClientMarginPreview.targetKeys(target).some(key => !!isEmpty(this.state[key]))) {
        this.setState({ stage: 3 })
      }
    })
  }

  testMargins () {
    const { clientsDispatch, targetType, targetId } = this.props
    const {
      selectedOriginTrucking,
      selectedOriginHub,
      selectedDestinationTrucking,
      selectedDestinationHub,
      selectedCargoClass
    } = this.state
    clientsDispatch.testMargins({
      selectedOriginTrucking,
      selectedOriginHub: get(selectedOriginHub, ['value', 'id']),
      selectedDestinationTrucking,
      selectedCargoClass: get(selectedCargoClass, 'value'),
      selectedDestinationHub: get(selectedDestinationHub, ['value', 'id']),
      targetType,
      targetId
    })
  }

  render () {
    const {
      t, tenant, marginPreview, theme, loading
    } = this.props
    const {
      selectedOriginHub,
      selectedDestinationHub,
      selectedCargoClass,
      filteredCargoClasses,
      originTrucking,
      destinationTrucking,
      stage
    } = this.state
    const previewsToRender = get(marginPreview, 'results', [])

    return (
      <div className="flex-100 layout-row layout-align-center-center layout-wrap ">
        <div className={`flex-100 layout-row layout-align-start-center layout-wrap greyBg ${styles.preview_header}`}>
          <h3 className="flex-none">{t('admin:marginPreview')}</h3>
        </div>
        <div className={`flex-100 layout-row layout-align-center-center layout-wrap ${styles.filter_row}`}>
          <div className="flex-100 layout-row layout-align-center-center layout-wrap">
            <div className="flex-20 layout-row layout-align-center-center">
              <NamedSelect
                className="flex-90"
                name="selectedCargoClass"
                placeholder={t('admin:selectCargoClass')}
                value={selectedCargoClass}
                options={filteredCargoClasses}
                onChange={e => this.selectCargoClass(e)}
              />

            </div>
            <div className="flex layout-row layout-align-center-center layout-wrap relative">
              <div className={`flex-gt-sm-50 flex-100 layout-row layout-align-center-center ${styles.route_inputs}`}>
                <div className={`flex layout-row layout-align-center-center ${styles.route_toggle}`}>
                  <CarriageToggle
                    carriage="pre"
                    theme={theme}
                    checked={!originTrucking}
                    onChange={e => this.handleTruckingToggle('origin')}
                  />
                </div>
                { originTrucking ? (
                  <NamedAsync
                    classes="flex"
                    value={selectedOriginHub}
                    placeholder={t('admin:hub')}
                    cacheOptions
                    name="pre"
                    autoload={false}
                    loadOptions={getHubOptions}
                    onChange={(n, e) => this.selectHub(n, e)}
                  />
                ) : (
                  <GmapsWrapper
                    component={PlaceSearch}
                    hideMap
                    wrapperFlex="flex"
                    theme={theme}
                    target="pre"
                    handlePlaceChange={e => this.selectTruckingLocation(e, 'selectedOriginTrucking')}
                  />
                ) }
              </div>
              <div className={`flex-gt-sm-50 flex-100 layout-row layout-align-center-center ${styles.route_inputs}`}>
                <div className={`flex layout-row layout-align-center-center ${styles.route_toggle}`}>
                  <CarriageToggle
                    carriage="on"
                    theme={theme}
                    checked={!destinationTrucking}
                    onChange={e => this.handleTruckingToggle('destination')}
                  />

                </div>
                { destinationTrucking ? (
                  <NamedAsync
                    classes="flex"
                    value={selectedDestinationHub}
                    placeholder={t('admin:hub')}
                    cacheOptions
                    name="on"
                    autoload={false}
                    loadOptions={getHubOptions}
                    onChange={(n, e) => this.selectHub(n, e)}
                  />
                ) : (
                  <GmapsWrapper
                    wrapperFlex="flex"
                    component={PlaceSearch}
                    hideMap
                    theme={theme}
                    handlePlaceChange={e => this.selectTruckingLocation(e, 'selectedDestinationTrucking')}
                  />
                ) }
              </div>
            </div>
            <div className="flex-15 layout-row layout-align-center-center relative">
              <SquareButton
                handleNext={() => this.testMargins()}
                text={t('rates:fetchRates')}
                theme={theme}
                size="small"
                inverse
                disabled={stage < 2}
              />
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-center-center layout-wrap">
          { loading ? <LoadingSpinner size="large" /> : previewsToRender.map(mp => <AdminMarginPreviewResult result={mp} tenant={tenant} />)}
        </div>
      </div>
    )
  }
}

AdminClientMarginPreview.defaultProps = {
  compact: false,
  marginPreview: {
    results: []
  },
  collapsed: true,
  laoding: false
}

function mapStateToProps (state) {
  const { clients, app } = state
  const { marginPreview, loading } = clients
  const { tenant } = app
  const { theme } = tenant

  return {
    marginPreview,
    tenant,
    theme,
    loading
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export const translatedMarginPreview = withNamespaces(['common', 'admin'])(AdminClientMarginPreview)
export default connect(mapStateToProps, mapDispatchToProps)(translatedMarginPreview)
