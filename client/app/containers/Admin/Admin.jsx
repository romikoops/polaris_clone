import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import { Switch, Route, withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import FloatingMenu from '../../components/FloatingMenu/FloatingMenu'
import { adminActions } from '../../actions'
import Footer from '../../components/Footer/Footer'
import { AdminDashboard, AdminServiceCharges, SuperAdmin } from '../../components/Admin'
import AdminShipments from '../../components/Admin/AdminShipments'
import AdminClients from '../../components/Admin/AdminClients'
import AdminHubs from '../../components/Admin/Hubs/AdminHubs'
import AdminRoutes from '../../components/Admin/AdminRoutes'
import AdminSchedules from '../../components/Admin/AdminSchedules'
import AdminPricings from '../../components/Admin/AdminPricings'
import AdminTrucking from '../../components/Admin/AdminTrucking'
import AdminWizard from '../../components/Admin/AdminWizard/AdminWizard'
import Loading from '../../components/Loading/Loading'
import Header from '../../components/Header/Header'
import SideNav from '../../components/SideNav/SideNav'
import styles from './Admin.scss'
import NavBar from '../Nav'
import GenericError from '../../components/ErrorHandling/Generic'
import AdminSchedulesRoute from '../../components/Admin/Schedules/Route'
import SuperAdminTenantCreator from '../SuperAdmin/Tenant/Creator'
import { SuperAdminPrivateRoute } from '../../routes/index'
import AdminCurrencyCenter from '../../components/Admin/Currency/Center'
import { adminHubs as hubsTip } from '../../constants'

class Admin extends Component {
  constructor (props) {
    super(props)
    this.state = { currentUrl: '/admin' }
    this.setCurrentUrl = this.setCurrentUrl.bind(this)
  }
  componentDidMount () {
    const { adminDispatch } = this.props
    adminDispatch.getClients(false)
    adminDispatch.getHubs(false)
  }
  setCurrentUrl (url) {
    this.setState({ currentUrl: url })
  }
  render () {
    const {
      theme, adminData, adminDispatch, user, documentLoading, tenant
    } = this.props

    const {
      hubs,
      serviceCharges,
      pricingData,
      schedules,
      shipments,
      clients,
      dashboard,
      confirmShipmentData,
      loading,
      itinerarySchedules,
      allHubs
    } = adminData

    const hubHash = {}
    if (hubs) {
      hubs.forEach((hub) => {
        hubHash[hub.data.id] = hub
      })
    }
    const loadingScreen = loading || documentLoading ? <Loading theme={theme} /> : ''
    const menu = <FloatingMenu Comp={SideNav} theme={theme} user={user} currentUrl={this.state.currentUrl} />
    const minHeightForFooter = window.innerHeight - 350
    const footerStyle = {
      minHeight: `${minHeightForFooter}px`,
      position: 'relative',
      paddingBottom: '230px'
    }
    const footerWidth = this.pageWindow ? this.pageWindow.offsetWidth : false

    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap hundred">
        {loadingScreen}
        <GenericError theme={theme}>
          {menu}
        </GenericError>
        <GenericError theme={theme}>
          <Header theme={theme} scrollable />
        </GenericError>
        <div
          className="flex layout-row layout-align-center-start layout-wrap"
          style={footerStyle}
          ref={(ref) => { this.pageWindow = ref }}
        >
          <GenericError theme={theme}>
            <NavBar className={`${styles.top_margin}`} />
          </GenericError>
          <div
            className=" flex-100 layout-row
             layout-wrap layout-align-start-start hundred"
          >
            <div className="flex-100 layout-row layout-wrap layout-align-center-center">
              <Switch className="flex">
                <Route
                  exact
                  path="/admin/dashboard"
                  render={props => (
                    <AdminDashboard
                      user={user}
                      tenant={tenant}
                      theme={theme}
                      setCurrentUrl={this.setCurrentUrl}
                      {...props}
                      scope={tenant.data.scope}
                      clients={clients}
                      confirmShipmentData={confirmShipmentData}
                      shipments={shipments}
                      hubs={hubs}
                      hubHash={hubHash}
                      dashData={dashboard}
                      adminDispatch={adminDispatch}
                    />
                  )}
                />

                <Route
                  path="/admin/hubs"
                  render={props => (
                    <AdminHubs
                      setCurrentUrl={this.setCurrentUrl}
                      theme={theme}
                      {...props}
                      hubHash={hubHash}
                      hubs={hubs}
                      icon="fa-info-circle"
                      tooltip={hubsTip.manage}
                    />
                  )}
                />

                <Route
                  path="/admin/pricings"
                  render={props => (
                    <AdminPricings
                      setCurrentUrl={this.setCurrentUrl}
                      theme={theme}
                      {...props}
                      hubs={hubs}
                      pricingData={pricingData}
                    />
                  )}
                />

                <Route
                  path="/admin/currencies"
                  render={props => (
                    <AdminCurrencyCenter theme={theme} setCurrentUrl={this.setCurrentUrl} />
                  )}
                />

                <SuperAdminPrivateRoute
                  path="/admin/superadmin"
                  component={SuperAdminTenantCreator}
                  setCurrentUrl={this.setCurrentUrl}
                  user={user}
                  theme={theme}
                />

                <Route
                  exact
                  path="/admin/schedules"
                  render={props => (
                    <AdminSchedules
                      theme={theme}
                      setCurrentUrl={this.setCurrentUrl}
                      {...props}
                      hubs={hubHash}
                      scope={tenant.data.scope}
                      adminDispatch={adminDispatch}
                      scheduleData={schedules}
                    />
                  )}
                />

                <Route
                  exact
                  path="/admin/schedules/:id"
                  render={props => (
                    <AdminSchedulesRoute
                      theme={theme}
                      {...props}
                      hubs={hubHash}
                      setCurrentUrl={this.setCurrentUrl}
                      adminDispatch={adminDispatch}
                      scheduleData={itinerarySchedules}
                    />
                  )}
                />

                <Route
                  path="/admin/service_charges"
                  render={props => (
                    <AdminServiceCharges
                      theme={theme}
                      {...props}
                      hubs={hubs}
                      setCurrentUrl={this.setCurrentUrl}
                      charges={serviceCharges}
                      adminTools={adminDispatch}
                    />
                  )}
                />

                <Route
                  path="/admin/shipments"
                  render={props => (
                    <AdminShipments
                      theme={theme}
                      {...props}
                      hubs={hubs}
                      setCurrentUrl={this.setCurrentUrl}
                      hubHash={hubHash}
                      shipments={shipments}
                      clients={clients}
                    />
                  )}
                />

                <Route
                  path="/admin/clients"
                  render={props => (<AdminClients
                    theme={theme}
                    setCurrentUrl={this.setCurrentUrl}
                    clients={clients}
                    {...props}
                    hubs={hubs}
                    hubHash={hubHash}
                  />)}
                />

                <Route
                  path="/admin/routes"
                  render={props => (
                    <AdminRoutes
                      theme={theme}
                      {...props}
                      setCurrentUrl={this.setCurrentUrl}
                      hubHash={hubHash}
                      clients={clients}
                      allHubs={allHubs}
                      loading={loading}
                    />
                  )}
                />

                <Route
                  path="/admin/wizard"
                  render={props => (<AdminWizard
                    theme={theme}
                    setCurrentUrl={this.setCurrentUrl}
                    {...props}
                    hubHash={hubHash}
                  />)}
                />

                <Route
                  path="/admin/trucking"
                  render={props => (<AdminTrucking
                    theme={theme}
                    setCurrentUrl={this.setCurrentUrl}
                    {...props}
                    hubHash={hubHash}
                  />)}
                />
                <GenericError theme={theme}>
                  <Route
                    path="/admin/super_admin/upload"
                    render={props => (<SuperAdmin
                      theme={theme}
                      setCurrentUrl={this.setCurrentUrl}
                      {...props}
                    />)}
                  />
                </GenericError>
              </Switch>
            </div>
          </div>
          <GenericError theme={theme}>
            <Footer width={footerWidth} theme={theme} tenant={tenant} />
          </GenericError>
        </div>
      </div>
    )
  }
}
Admin.propTypes = {
  theme: PropTypes.theme,
  // eslint-disable-next-line react/forbid-prop-types
  user: PropTypes.any,
  loggedIn: PropTypes.bool,
  documentLoading: PropTypes.bool,
  adminData: PropTypes.shape({
    hubs: PropTypes.array,
    serviceCharges: PropTypes.any,
    pricingData: PropTypes.any,
    schedules: PropTypes.any,
    shipments: PropTypes.any,
    clients: PropTypes.any,
    dashboard: PropTypes.any,
    loading: PropTypes.bool
  }).isRequired,
  tenant: PropTypes.tenant,
  adminDispatch: PropTypes.shape({
    getHubs: PropTypes.func,
    getServiceCharges: PropTypes.func,
    getPricings: PropTypes.func,
    getSchedules: PropTypes.func,
    getTrucking: PropTypes.func,
    getShipments: PropTypes.func,
    getClients: PropTypes.func,
    getDashboard: PropTypes.func,
    getRoutes: PropTypes.func,
    goTo: PropTypes.func
  }).isRequired
}

Admin.defaultProps = {
  theme: {},
  user: {},
  tenant: {},
  documentLoading: false,
  loggedIn: false
}

function mapStateToProps (state) {
  const {
    users, authentication, tenant, admin, document
  } = state
  const { user, loggedIn } = authentication
  const documentLoading = document.loading

  return {
    user,
    users,
    tenant,
    documentLoading,
    theme: tenant.data.theme,
    loggedIn,
    adminData: admin
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Admin))
