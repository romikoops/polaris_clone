import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PropTypes from 'prop-types'

import { AdminRoutesIndex, AdminRouteView, AdminRouteForm } from './'
// import styles from './Admin.scss'

import { adminActions } from '../../actions'
import { Modal } from '../Modal/Modal'
// import { TextHeading } from '../TextHeading/TextHeading'

class AdminRoutes extends Component {
  constructor (props) {
    super(props)
    this.state = {
      newRoute: false
    }
    this.viewItinerary = this.viewItinerary.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
    this.toggleNewRoute = this.toggleNewRoute.bind(this)
    this.closeModal = this.closeModal.bind(this)
    this.saveNewRoute = this.saveNewRoute.bind(this)
  }
  componentDidMount () {
    const { adminDispatch, allHubs, loading } = this.props
    if (allHubs.length < 1 && !loading) {
      adminDispatch.getAllHubs()
    }
  }

  viewItinerary (itinerary) {
    const { adminDispatch } = this.props
    adminDispatch.getItinerary(itinerary.id, true)
  }

  toggleNewRoute () {
    this.setState({ newRoute: !this.state.newRoute })
  }

  backToIndex () {
    const { adminDispatch } = this.props
    adminDispatch.goTo('/admin/routes')
  }
  closeModal () {
    this.setState({ newRoute: false })
  }
  saveNewRoute (route) {
    const { adminDispatch } = this.props
    adminDispatch.newRoute(route)
  }

  render () {
    const {
      theme, allHubs, itinerary, itineraries, hubHash, adminDispatch, loading, tenant, mapData
    } = this.props

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start header_buffer">
        {this.state.newRoute ? (
          <Modal
            component={
              <AdminRouteForm
                theme={theme}
                close={this.closeModal}
                hubs={allHubs}
                saveRoute={this.saveNewRoute}
                adminDispatch={adminDispatch}
              />
            }
            verticalPadding="30px"
            horizontalPadding="40px"
            parentToggle={this.closeModal}
          />

        ) : (
          ''
        )}
        <Switch className="flex">
          <Route
            exact
            path="/admin/routes"
            render={props => (
              <AdminRoutesIndex
                theme={theme}
                // hubs={hubs}
                hubHash={hubHash}
                itineraries={itineraries}
                adminDispatch={adminDispatch}
                {...props}
                viewItinerary={this.viewItinerary}
                loading={loading}
                tenant={tenant}
                mapData={mapData}
                toggleNewRoute={this.toggleNewRoute}
              />
            )}
          />
          <Route
            exact
            path="/admin/routes/:id"
            render={props => (
              <AdminRouteView
                theme={theme}
                // hubs={hubs}
                hubHash={hubHash}
                itineraryData={itinerary}
                adminDispatch={adminDispatch}
                {...props}
                loading={loading}
              />
            )}
          />
        </Switch>
      </div>
    )
  }
}
AdminRoutes.propTypes = {
  theme: PropTypes.theme,
  allHubs: PropTypes.arrayOf(PropTypes.hub),
  adminDispatch: PropTypes.shape({
    getRoute: PropTypes.func,
    newRoute: PropTypes.func
  }).isRequired,
  dispatch: PropTypes.func.isRequired,
  history: PropTypes.history.isRequired,
  route: PropTypes.route.isRequired,
  routes: PropTypes.arrayOf(PropTypes.route).isRequired,
  mapData: PropTypes.arrayOf(PropTypes.object),
  hubHash: PropTypes.objectOf(PropTypes.hub),
  loading: PropTypes.bool,
  itinerary: PropTypes.objectOf(PropTypes.any).isRequired,
  itineraries: PropTypes.objectOf(PropTypes.any).isRequired,
  tenant: PropTypes.tenant
}

AdminRoutes.defaultProps = {
  theme: null,
  allHubs: [],
  mapData: [],
  hubHash: {},
  loading: false,
  tenant: { data: {} }
}

function mapStateToProps (state) {
  const { authentication, tenant, admin } = state
  const { user, loggedIn } = authentication
  const {
    clients, hubs, itinerary, itineraries, loading, mapData
  } = admin

  return {
    user,
    tenant,
    loggedIn,
    hubs,
    itinerary,
    itineraries,
    clients,
    loading,
    mapData
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminRoutes)
