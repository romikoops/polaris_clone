import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PropTypes from '../../prop-types'
import { AdminRoutesIndex, AdminRouteView, AdminRouteForm } from './'
import styles from './Admin.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { adminActions } from '../../actions'
import { TextHeading } from '../TextHeading/TextHeading'
// import {v4} from 'node-uuid';
// import FileUploader from '../../components/FileUploader/FileUploader';
class AdminRoutes extends Component {
  constructor (props) {
    super(props)
    this.state = {
      selectedRoute: false,
      newRoute: false
    }
    this.viewItinerary = this.viewItinerary.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
    this.toggleNewRoute = this.toggleNewRoute.bind(this)
    this.closeModal = this.closeModal.bind(this)
    this.saveNewRoute = this.saveNewRoute.bind(this)
  }

  viewItinerary (itinerary) {
    const { adminDispatch } = this.props
    adminDispatch.getItinerary(itinerary.id, true)
    this.setState({ selectedRoute: true })
  }

  toggleNewRoute () {
    this.setState({ newRoute: !this.state.newRoute })
  }

  backToIndex () {
    const { adminDispatch } = this.props
    this.setState({ selectedRoute: false })
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
    const { selectedRoute } = this.state
    const {
      theme, hubs, itinerary, itineraries, hubHash, adminDispatch, loading
    } = this.props
    const backButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="Back"
          handleNext={this.backToIndex}
          iconClass="fa-chevron-left"
        />
      </div>
    )
    const newButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="New Route"
          active
          handleNext={this.toggleNewRoute}
          iconClass="fa-plus"
        />
      </div>
    )
    const title = selectedRoute ? 'Route Overview' : 'Routes'
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <TextHeading theme={theme} size={1} text={title} />
          {selectedRoute ? backButton : ''}
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-end-center">{newButton}</div>
        {this.state.newRoute ? (
          <AdminRouteForm
            theme={theme}
            close={this.closeModal}
            hubs={hubs}
            saveRoute={this.saveNewRoute}
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
                hubs={hubs}
                hubHash={hubHash}
                itineraries={itineraries}
                adminDispatch={adminDispatch}
                {...props}
                viewItinerary={this.viewItinerary}
                loading={loading}
              />
            )}
          />
          <Route
            exact
            path="/admin/routes/:id"
            render={props => (
              <AdminRouteView
                theme={theme}
                hubs={hubs}
                hubHash={hubHash}
                itineraryData={itinerary}
                adminActions={adminDispatch}
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
  hubs: PropTypes.arrayOf(PropTypes.hub),
  adminDispatch: PropTypes.shape({
    getRoute: PropTypes.func,
    newRoute: PropTypes.func
  }).isRequired,
  dispatch: PropTypes.func.isRequired,
  history: PropTypes.history.isRequired,
  route: PropTypes.route.isRequired,
  routes: PropTypes.arrayOf(PropTypes.route).isRequired,
  hubHash: PropTypes.objectOf(PropTypes.hub),
  loading: PropTypes.bool,
  itinerary: PropTypes.objectOf(PropTypes.any).isRequired,
  itineraries: PropTypes.objectOf(PropTypes.any).isRequired
}

AdminRoutes.defaultProps = {
  theme: null,
  hubs: [],
  hubHash: {},
  loading: false
}

function mapStateToProps (state) {
  const { authentication, tenant, admin } = state
  const { user, loggedIn } = authentication
  const {
    clients, hubs, route, routes, loading
  } = admin

  return {
    user,
    tenant,
    loggedIn,
    hubs,
    route,
    routes,
    clients,
    loading
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminRoutes)
