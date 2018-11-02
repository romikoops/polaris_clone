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
import { RoundButton } from '../RoundButton/RoundButton'
import { adminActions, documentActions } from '../../actions'
import { AdminUploadsSuccess } from './Uploads/Success'
import { AdminTruckingView } from './AdminTruckingView'
import GenericError from '../../components/ErrorHandling/Generic'

class AdminPricings extends Component {
  constructor (props) {
    super(props)
    this.state = {
      selectedPricing: false
    }
    this.viewRoute = this.viewRoute.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
    this.closeSuccessDialog = this.closeSuccessDialog.bind(this)
  }
  componentDidMount () {
    const {
      pricingData, loading, adminDispatch, match
    } = this.props
    if (!pricingData && !loading) {
      adminDispatch.getPricings(false)
    }
    this.props.setCurrentUrl(match.url)
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
  closeSuccessDialog () {
    const { documentDispatch } = this.props
    documentDispatch.closeViewer()
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
      itineraryPricings,
      documentDispatch,
      document,
      tenant,
      loading,
      trucking,
      truckingDetail
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
    const uploadStatus = document.viewer ? (
      <AdminUploadsSuccess
        theme={theme}
        data={document.results}
        closeDialog={this.closeSuccessDialog}
      />
    ) : (
      ''
    )
    const { nexuses } = trucking

    return (
      <GenericError theme={theme}>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          {uploadStatus}
          {selectedPricing ? backButton : ''}

          <Switch className="flex">
            <Route
              exact
              path="/admin/pricings"
              render={props => (
                <AdminPricingsIndex
                  theme={theme}
                  scope={tenant.data.scope}
                  hubs={hubs}
                  hubHash={hubHash}
                  clients={filteredClients}
                  pricingData={pricingData}
                  itineraries={itineraries}
                  {...props}
                  adminDispatch={adminDispatch}
                  documentDispatch={documentDispatch}
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
                  itineraries={itineraries || pricingData.itineraries}
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
              path="/admin/pricings/trucking/:id"
              render={props => (
                <AdminTruckingView
                  theme={theme}
                  nexuses={nexuses}
                  truckingDetail={truckingDetail}
                  loading={loading}
                  adminDispatch={adminDispatch}
                  {...props}
                />
              )}
            />
            <Route
              exact
              path="/admin/pricings/routes/:id"
              render={props => (
                <AdminPricingRouteView
                  clientPricings={clientPricings}
                  theme={theme}
                  hubs={hubs}
                  scope={tenant.data.scope}
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
      </GenericError>
    )
  }
}
AdminPricings.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  dispatch: PropTypes.func.isRequired,
  setCurrentUrl: PropTypes.func.isRequired,
  history: PropTypes.history.isRequired,
  loading: PropTypes.bool,
  adminDispatch: PropTypes.shape({
    getPricings: PropTypes.func,
    getRoute: PropTypes.func
  }).isRequired,
  documentDispatch: PropTypes.shape({
    uploadPricings: PropTypes.func
  }).isRequired,
  pricingData: PropTypes.shape({
    itineraries: PropTypes.array
  }),
  itineraries: PropTypes.arrayOf(PropTypes.shape({ id: PropTypes.number })),
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
  document: PropTypes.objectOf(PropTypes.any).isRequired,
  itineraryPricings: PropTypes.objectOf(PropTypes.any).isRequired,
  tenant: PropTypes.tenant,
  trucking: PropTypes.shape({
    truckingHubs: PropTypes.array,
    truckingPrices: PropTypes.array
  }).isRequired,
  truckingDetail: PropTypes.shape({ truckingHub: PropTypes.object, pricing: PropTypes.object })
}

AdminPricings.defaultProps = {
  theme: null,
  hubs: [],
  loading: false,
  pricingData: null,
  hubHash: {},
  clients: [],
  itineraries: [],
  tenant: null,
  truckingDetail: null
}

function mapStateToProps (state) {
  const {
    authentication, tenant, admin, document
  } = state
  const { user, loggedIn } = authentication
  const {
    clients,
    hubs,
    pricingData,
    itineraries,
    transportCategories,
    clientPricings,
    itineraryPricings,
    loading,
    trucking,
    truckingDetail
  } = admin

  return {
    user,
    tenant,
    loggedIn,
    hubs,
    pricingData,
    transportCategories,
    clientPricings,
    itineraries,
    clients,
    itineraryPricings,
    loading,
    document,
    trucking,
    truckingDetail
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    documentDispatch: bindActionCreators(documentActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminPricings)
