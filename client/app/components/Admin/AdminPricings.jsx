import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PropTypes from '../../prop-types'
import {
  AdminPricingsIndex,
  AdminPricingClientView,
  AdminPricingRouteView,
  AdminPricingsClientIndex,
  AdminPricingsRouteIndex
} from './'
import styles from './Admin.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { adminActions } from '../../actions'
import { TextHeading } from '../TextHeading/TextHeading'
// import {v4} from 'node-uuid';
// import FileUploader from '../../components/FileUploader/FileUploader';
class AdminPricings extends Component {
  constructor (props) {
    super(props)
    this.state = {
      selectedPricing: false
    }
    this.viewRoute = this.viewRoute.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
  }
  componentDidMount () {
    const { pricingData, loading, adminDispatch } = this.props
    if (!pricingData && !loading) {
      adminDispatch.getPricings(false)
    }
  }
  viewRoute (route) {
    const { adminDispatch } = this.props
    adminDispatch.getRoute(route.id, true)
    this.setState({ selectedPricing: true })
  }

  backToIndex () {
    const { dispatch, history } = this.props
    this.setState({ selectedPricing: false })
    dispatch(history.push('/admin/routes'))
  }

  render () {
    const { selectedPricing } = this.state
    const {
      theme,
      hubs,
      pricingData,
      itineraries,
      hubHash,
      adminDispatch,
      clients,
      clientPricings,
      itineraryPricings
    } = this.props
    const filteredClients = clients.filter(x => !x.guest)
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
    const title = selectedPricing ? 'Pricing Overview' : 'Pricings'
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <TextHeading theme={theme} size={1} text={title} />
          {selectedPricing ? backButton : ''}
        </div>
        <Switch className="flex">
          <Route
            exact
            path="/admin/pricings"
            render={props => (
              <AdminPricingsIndex
                theme={theme}
                hubs={hubs}
                hubHash={hubHash}
                clients={filteredClients}
                pricingData={pricingData}
                itineraries={itineraries}
                {...props}
                adminTools={adminDispatch}
              />
            )}
          />
          <Route
            exact
            path="/admin/pricings/clients"
            render={props => (
              <AdminPricingsClientIndex
                theme={theme}
                clients={filteredClients}
                adminTools={adminDispatch}
                {...props}
              />
            )}
          />
          <Route
            exact
            path="/admin/pricings/routes"
            render={props => (
              <AdminPricingsRouteIndex
                theme={theme}
                hubs={hubs}
                routes={itineraries || pricingData.itineraries}
                adminTools={adminDispatch}
                {...props}
              />
            )}
          />
          <Route
            exact
            path="/admin/pricings/clients/:id"
            render={props => (
              <AdminPricingClientView
                theme={theme}
                hubs={hubs}
                hubHash={hubHash}
                pricingData={pricingData}
                clientPricings={clientPricings}
                adminActions={adminDispatch}
                {...props}
              />
            )}
          />
          <Route
            exact
            path="/admin/pricings/routes/:id"
            render={props => (
              <AdminPricingRouteView
                theme={theme}
                hubs={hubs}
                hubHash={hubHash}
                pricingData={pricingData}
                clients={filteredClients}
                itineraryPricings={itineraryPricings}
                adminActions={adminDispatch}
                {...props}
              />
            )}
          />
        </Switch>
      </div>
    )
  }
}
AdminPricings.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  dispatch: PropTypes.func.isRequired,
  history: PropTypes.history.isRequired,
  loading: PropTypes.bool,
  adminDispatch: PropTypes.shape({
    getPricings: PropTypes.func,
    getRoute: PropTypes.func
  }).isRequired,
  pricingData: PropTypes.shape({
    routes: PropTypes.array
  }),
  routes: PropTypes.arrayOf(PropTypes.shape({ id: PropTypes.number })),
  hubHash: PropTypes.objectOf(PropTypes.hub),
  clients: PropTypes.arrayOf(PropTypes.client),
  clientPricings: PropTypes.shape({
    client: PropTypes.client,
    userPricings: PropTypes.object
  }).isRequired,
  routePricings: PropTypes.shape({
    route: PropTypes.object,
    routePricingData: PropTypes.object
  }).isRequired,
  itineraryPricings: PropTypes.objectOf(PropTypes.any).isRequired,
  itineraries: PropTypes.objectOf(PropTypes.any).isRequired
}

AdminPricings.defaultProps = {
  theme: null,
  hubs: [],
  loading: false,
  pricingData: null,
  hubHash: {},
  clients: [],
  routes: []
}

function mapStateToProps (state) {
  const { authentication, tenant, admin } = state
  const { user, loggedIn } = authentication
  const {
    clients,
    hubs,
    pricingData,
    routes,
    transportCategories,
    clientPricings,
    routePricings,
    loading
  } = admin

  return {
    user,
    tenant,
    loggedIn,
    hubs,
    pricingData,
    transportCategories,
    clientPricings,
    routes,
    clients,
    routePricings,
    loading
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminPricings)
