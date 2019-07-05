import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { get } from 'lodash'
import { clientsActions } from '../../../../actions'
import styles from './index.scss'
import AdminClientMarginPreviewResult from './Result'
import { moment, getTenantApiUrl } from '../../../../constants'
import NamedAsync from '../../../NamedSelect/NamedAsync'
import { authHeader } from '../../../../helpers'
import NamedSelect from '../../../NamedSelect/NamedSelect'
import CollapsingBar from '../../../CollapsingBar/CollapsingBar'

class AdminClientMarginPreview extends Component {
  static getDerivedStateFromProps (nextProps, prevState) {
    const nextState = {}
    if (nextProps.marginPreview) {
      nextState.filteredTenantVehicles = nextProps.marginPreview.tenantVehicles
      nextState.filteredCargoClasses = nextProps.marginPreview.cargoClasses
    }

    return nextState
  }

  constructor (props) {
    super(props)
    this.state = {
      filteredTenantVehicles: [],
      filteredCargoClasses: [],
      collapsed: get(props, ['collapsed'], true)
    }
    this.toggleCollapsed = this.toggleCollapsed.bind(this)
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

  toggleCollapsed () {
    this.setState(prevState => ({ collapsed: !prevState.collapsed }))
  }

  render () {
    const {
      t, tenant, marginPreview
    } = this.props
    const {
      selectedItinerary,
      selectedTenantVehicle,
      selectedCargoClass,
      filteredTenantVehicles,
      filteredCargoClasses,
      collapsed
    } = this.state
    const getItineraryOptions = (input) => {
      const requestOptions = {
        method: 'GET',
        headers: { ...authHeader() }
      }

      return window
        .fetch(`${getTenantApiUrl()}/admin/margins/form/itineraries?query=${input}`, requestOptions)
        .then(response => response.json())
        .then(json => ({ options: json.data }))
    }
    const previewsToRender = marginPreview.results.filter((mp) => {
      if (selectedTenantVehicle && !selectedCargoClass) {
        return mp[0].tenant_vehicle_id === selectedTenantVehicle.value.id
      }
      if (!selectedTenantVehicle && selectedCargoClass) {
        return mp[0].cargo_class === selectedCargoClass.value
      }
      if (!selectedTenantVehicle && selectedCargoClass) {
        return mp[0].cargo_class === selectedCargoClass.value && mp[0].tenant_vehicle_id === selectedTenantVehicle.value.id
      }

      return !!mp
    })

    return (
      <CollapsingBar
        wrapperClassName="flex-100 layout-row"
        contentClassName="flex-100 layout-row layout-align-center-center layout-wrap greyBg"
        text={t('admin:marginPreview')}
        collapsed={collapsed}
        handleCollapser={this.toggleCollapsed}
        minHeight="450px"
        overflow
        showArrow
      >
        <div className={`flex-100 layout-row layout-align-center-center layout-wrap ${styles.filter_row}`}>
          <div className="flex-25 layout-row layout-align-center-center layout-wrap">
            <h4 className="flex-none">{t('admin:filters')}</h4>
          </div>
          <div className="flex layout-row layout-align-center-center layout-wrap">
            <div className="flex-33 layout-row layout-align-center-center">
              <NamedAsync
                classes="flex-90"
                value={selectedItinerary}
                cacheOptions
                placeholder={t('admin:searchItineraries')}
                name={selectedItinerary}
                autoload={false}
                loadOptions={getItineraryOptions}
                onChange={(n, e) => this.setItinerary(n, e)}
              />
            </div>
            <div className="flex-33 layout-row layout-align-center-center">
              <NamedSelect
                className="flex-90"
                value={selectedTenantVehicle}
                placeholder={t('admin:selectServiceLevel')}
                name="selectedTenantVehicle"
                options={filteredTenantVehicles}
                onChange={(n, e) => this.setFilter(n, e, 'selectedTenantVehicle')}
              />
            </div>
            <div className="flex-33 layout-row layout-align-center-center">
              <NamedSelect
                className="flex-90"
                name="selectedCargoClass"
                placeholder={t('admin:selectCargoClass')}
                value={selectedCargoClass}
                options={filteredCargoClasses}
                onChange={(n, e) => this.setFilter(n, e, 'selectedCargoClass')}
              />
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-center-center layout-wrap">
          {previewsToRender.map(mp => <AdminClientMarginPreviewResult results={mp} tenant={tenant} />)}
        </div>
      </CollapsingBar>
    )
  }
}

AdminClientMarginPreview.defaultProps = {
  compact: false,
  marginPreview: {
    results: []
  },
  collapsed: true
}

function mapStateToProps (state) {
  const { clients, app } = state
  const { marginPreview } = clients
  const { tenant } = app
  const { theme } = tenant

  return {
    marginPreview,
    tenant,
    theme
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientMarginPreview))
