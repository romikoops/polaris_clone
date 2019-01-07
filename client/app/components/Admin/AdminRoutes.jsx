import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import { AdminRoutesIndex, AdminRouteView, AdminRouteForm } from '.'
import { adminActions } from '../../actions'
import { Modal } from '../Modal/Modal'
import GenericError from '../ErrorHandling/Generic'

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
    const {
      adminDispatch, allHubs, loading, match
    } = this.props
    if (allHubs.length < 1 && !loading) {
      adminDispatch.getAllHubs()
    }
    this.props.setCurrentUrl(match.url)
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
      theme,
      allHubs,
      itinerary,
      itineraries,
      hubHash,
      adminDispatch,
      loading,
      tenant,
      user,
      mapData
    } = this.props

    return (
      <GenericError theme={theme}>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          {this.state.newRoute ? (
            <Modal
              component={(
                <AdminRouteForm
                  theme={theme}
                  close={this.closeModal}
                  hubs={allHubs}
                  saveRoute={this.saveNewRoute}
                  adminDispatch={adminDispatch}
                />
              )}
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
                  hubHash={hubHash}
                  itineraries={itineraries}
                  adminDispatch={adminDispatch}
                  {...props}
                  viewItinerary={this.viewItinerary}
                  loading={loading}
                  tenant={tenant}
                  mapData={mapData}
                  user={user}
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
      </GenericError>
    )
  }
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
  const { authentication, app, admin } = state
  const { tenant } = app
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
