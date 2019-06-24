import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import GenericError from '../ErrorHandling/Generic'
import {
  AdminPricingsIndex,
  AdminPricingClientView,
  AdminPricingRouteView
} from '.'
import { RoundButton } from '../RoundButton/RoundButton'
import { adminActions, documentActions, clientsActions } from '../../actions'
import AdminUploadsSuccess from './Uploads/Success'
import AdminTruckingView from './Trucking/AdminTruckingView'

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
      t,
      theme,
      hubs,
      pricingData,
      itineraries,
      hubHash,
      adminDispatch,
      clientPricings,
      pricings,
      documentDispatch,
      document,
      tenant,
      loading,
      trucking,
      truckingDetail,
      user,
      clientsDispatch
    } = this.props
    const backButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text={t('common:basicBack')}
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
                  scope={tenant.scope}
                  hubs={hubs}
                  user={user}
                  hubHash={hubHash}
                  
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
                  scope={tenant.scope}
                  hubHash={hubHash}
                  pricingData={pricingData}
                  pricings={pricings.show}
                  adminActions={adminDispatch}
                  clientsDispatch={clientsDispatch}
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

function mapStateToProps (state) {
  const {
    authentication, app, admin, document
  } = state
  const { tenant } = app
  const { user, loggedIn } = authentication
  const {
    clients,
    hubs,
    pricingData,
    itineraries,
    transportCategories,
    clientPricings,
    pricings,
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
    pricings,
    loading,
    document,
    trucking,
    truckingDetail
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    clientsDispatch: bindActionCreators(clientsActions, dispatch),
    documentDispatch: bindActionCreators(documentActions, dispatch)
  }
}

export default withNamespaces('common')(connect(mapStateToProps, mapDispatchToProps)(AdminPricings))
