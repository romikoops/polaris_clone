import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { Switch, Route } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../prop-types'
import { AdminShipmentsIndex } from './'
import AdminShipmentView from './AdminShipmentView/AdminShipmentView'
import { adminActions, remarkActions } from '../../actions'
import AdminShipmentsGroup from './Shipments/Group'
import GenericError from '../../components/ErrorHandling/Generic'

class AdminShipments extends Component {
  constructor (props) {
    super(props)
    this.state = {
      // selectedShipment: false
    }
    this.viewShipment = this.viewShipment.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
    this.handleShipmentAction = this.handleShipmentAction.bind(this)
  }
  componentDidMount () {
    const {
      shipments, loading, adminDispatch, match
    } = this.props
    if (!shipments && !loading) {
      adminDispatch.getShipments(false)
    }
    window.scrollTo(0, 0)
    this.props.setCurrentUrl(match.url)
  }
  viewShipment (shipment) {
    const { adminDispatch } = this.props
    adminDispatch.getShipment(shipment.id, true)
  }

  backToIndex () {
    const { dispatch, history } = this.props
    dispatch(history.push('/admin/shipments'))
  }
  handleShipmentAction (id, action) {
    const { adminDispatch } = this.props
    adminDispatch.confirmShipment(id, action)
  }

  render () {
    const {
      t,
      theme,
      hubs,
      shipments,
      clients,
      shipment,
      loading,
      adminDispatch,
      hubHash,
      tenant,
      user,
      remarkDispatch
    } = this.props
    // ;
    if (!shipments || !hubs || !clients) {
      return <h1>{t('admin:noShipmentData')}</h1>
    }

    return (
      <GenericError theme={theme}>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start extra_padding">
          <Switch className="flex">
            <Route
              exact
              path="/admin/shipments"
              render={props => (
                <AdminShipmentsIndex
                  theme={theme}
                  handleShipmentAction={this.handleShipmentAction}
                  clients={clients}
                  hubs={hubs}
                  adminDispatch={adminDispatch}
                  hubHash={hubHash}
                  shipments={shipments}
                  user={user}
                  viewShipment={this.viewShipment}
                  {...props}
                />
              )}
            />
            <Route
              exact
              path="/admin/shipments/view/:id"
              render={props => (
                <AdminShipmentView
                  theme={theme}
                  adminDispatch={adminDispatch}
                  loading={loading}
                  hubs={hubs}
                  scope={tenant.scope}
                  handleShipmentAction={this.handleShipmentAction}
                  shipmentData={shipment}
                  clients={clients}
                  user={user}
                  tenant={tenant}
                  remarkDispatch={remarkDispatch}
                  {...props}
                />
              )}
            />
            <Route
              exact
              path="/admin/shipments/requested"
              render={props => (
                <AdminShipmentsGroup
                  theme={theme}
                  title={t('shipment:requested')}
                  target="requested"
                  adminDispatch={adminDispatch}
                  loading={loading}
                  hubs={hubs}
                  handleShipmentAction={this.handleShipmentAction}
                  shipments={shipments}
                  hubHash={hubHash}
                  clients={clients}
                  viewShipment={this.viewShipment}
                  {...props}
                />
              )}
            />
            <Route
              exact
              path="/admin/shipments/open"
              render={props => (
                <AdminShipmentsGroup
                  theme={theme}
                  title={t('common:open')}
                  target="open"
                  adminDispatch={adminDispatch}
                  loading={loading}
                  hubs={hubs}
                  handleShipmentAction={this.handleShipmentAction}
                  shipments={shipments}
                  hubHash={hubHash}
                  clients={clients}
                  viewShipment={this.viewShipment}
                  {...props}
                />
              )}
            />
            <Route
              exact
              path="/admin/shipments/finished"
              render={props => (
                <AdminShipmentsGroup
                  theme={theme}
                  title={t('common:finished')}
                  target="finished"
                  adminDispatch={adminDispatch}
                  loading={loading}
                  hubs={hubs}
                  handleShipmentAction={this.handleShipmentAction}
                  shipments={shipments}
                  hubHash={hubHash}
                  clients={clients}
                  viewShipment={this.viewShipment}
                  {...props}
                />
              )}
            />
            <Route
              exact
              path="/admin/shipments/rejected"
              render={props => (
                <AdminShipmentsGroup
                  theme={theme}
                  title={t('shpment:rejected')}
                  target="rejected"
                  adminDispatch={adminDispatch}
                  loading={loading}
                  hubs={hubs}
                  handleShipmentAction={this.handleShipmentAction}
                  shipments={shipments}
                  hubHash={hubHash}
                  clients={clients}
                  viewShipment={this.viewShipment}
                  {...props}
                />
              )}
            />
            <Route
              exact
              path="/admin/shipments/archived"
              render={props => (
                <AdminShipmentsGroup
                  theme={theme}
                  title={t('shipment:archived')}
                  target="archived"
                  adminDispatch={adminDispatch}
                  loading={loading}
                  hubs={hubs}
                  handleShipmentAction={this.handleShipmentAction}
                  shipments={shipments}
                  hubHash={hubHash}
                  clients={clients}
                  viewShipment={this.viewShipment}
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
AdminShipments.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  shipments: PropTypes.arrayOf(PropTypes.shipment),
  shipment: PropTypes.shipment,
  clients: PropTypes.arrayOf(PropTypes.client),
  hubHash: PropTypes.objectOf(PropTypes.hub),
  loading: PropTypes.bool,
  adminDispatch: PropTypes.shape({
    getShipments: PropTypes.func
  }).isRequired,
  dispatch: PropTypes.func.isRequired,
  setCurrentUrl: PropTypes.func.isRequired,
  tenant: PropTypes.tenant,
  history: PropTypes.history.isRequired,
  user: PropTypes.user
}

AdminShipments.defaultProps = {
  theme: null,
  hubs: null,
  shipments: [],
  shipment: null,
  clients: [],
  loading: false,
  tenant: {},
  hubHash: null,
  user: {}
}

function mapStateToProps (state) {
  const { authentication, app, admin } = state
  const { tenant } = app
  const { user, loggedIn } = authentication
  const {
    clients, shipment, shipments, hubs, loading
  } = admin

  return {
    user,
    tenant,
    loggedIn,
    clients,
    shipments,
    shipment,
    hubs,
    loading
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    remarkDispatch: bindActionCreators(remarkActions, dispatch)
  }
}

export default withNamespaces(['common', 'shipment'])(connect(mapStateToProps, mapDispatchToProps)(AdminShipments))
