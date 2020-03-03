import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Switch, Route, withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import FloatingMenu from '../../components/FloatingMenu/FloatingMenu'
import { adminActions, tenantActions, remarkActions } from '../../actions'
import { AdminDashboard, AdminServiceCharges, SuperAdmin } from '../../components/Admin'
import AdminShipments from '../../components/Admin/AdminShipments'
import AdminClients from '../../components/Admin/AdminClients'
import AdminHubs from '../../components/Admin/Hubs/AdminHubs'
import AdminRoutes from '../../components/Admin/Routes/AdminRoutes'
import AdminSchedules from '../../components/Admin/AdminSchedules'
import AdminPricings from '../../components/Admin/AdminPricings'
import AdminTrucking from '../../components/Admin/AdminTrucking'
import AdminWizard from '../../components/Admin/AdminWizard/AdminWizard'
import AdminSettings from '../../components/Admin/AdminSettings/AdminSettings'
import Loading from '../../components/Loading/Loading'
import Header from '../../components/Header/Header'
import SideNav from '../../components/SideNav/SideNav'
import styles from './Admin.scss'
import NavBar from '../Nav'
import GenericError from '../../components/ErrorHandling/Generic'
import AdminSchedulesRoute from '../../components/Admin/Schedules/Route'
import SuperAdminTenantCreator from '../SuperAdmin/Tenant/Creator'
import { SuperAdminPrivateRoute } from '../../routes/index'
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
  }

  setCurrentUrl (url) {
    this.setState({ currentUrl: url })
  }

  render () {
    const {
      theme, adminData, adminDispatch, tenantDispatch, remarkDispatch, user, documentLoading, tenant
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

    const loadingScreen = loading || documentLoading ? <Loading tenant={tenant} /> : ''
    const menu = (
      <FloatingMenu
        Comp={SideNav}
        theme={theme}
        user={user}
        currentUrl={this.state.currentUrl}
        tenant={tenant}
      />
    )

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
                      scope={tenant.scope}
                      clients={clients}
                      confirmShipmentData={confirmShipmentData}
                      shipments={shipments}
                      hubs={hubs}
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
                  path="/admin/settings"
                  render={props => (
                    <AdminSettings
                      theme={theme}
                      setCurrentUrl={this.setCurrentUrl}
                      {...props}
                      clients={clients}
                      tenant={tenant}
                      loading={loading}
                      tenantDispatch={tenantDispatch}
                      remarkDispatch={remarkDispatch}
                    />
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

                      scope={tenant.scope}
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
                      shipments={shipments}
                      clients={clients}
                    />
                  )}
                />

                <Route
                  path="/admin/clients"
                  render={props => (
                    <AdminClients
                      theme={theme}
                      setCurrentUrl={this.setCurrentUrl}
                      clients={clients}
                      {...props}
                      hubs={hubs}
                    />
                  )}
                />

                <Route
                  path="/admin/routes"
                  render={props => (
                    <AdminRoutes
                      theme={theme}
                      {...props}
                      setCurrentUrl={this.setCurrentUrl}
                      clients={clients}
                      allHubs={allHubs}
                      loading={loading}
                    />
                  )}
                />

                <Route
                  path="/admin/wizard"
                  render={props => (
                    <AdminWizard
                      theme={theme}
                      setCurrentUrl={this.setCurrentUrl}
                      {...props}
                    />
                  )}
                />

                <Route
                  path="/admin/trucking"
                  render={props => (
                    <AdminTrucking
                      theme={theme}
                      setCurrentUrl={this.setCurrentUrl}
                      {...props}
                    />
                  )}
                />
                <GenericError theme={theme}>
                  <Route
                    path="/admin/super_admin/upload"
                    render={props => (
                      <SuperAdmin
                        theme={theme}
                        setCurrentUrl={this.setCurrentUrl}
                        {...props}
                      />
                    )}
                  />
                </GenericError>
              </Switch>
            </div>
          </div>
        </div>
      </div>
    )
  }
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
    users, authentication, app, admin, document, remark
  } = state
  const { tenant } = app
  const { user, loggedIn } = authentication
  const documentLoading = document.loading

  return {
    user,
    users,
    tenant,
    remark,
    documentLoading,
    theme: tenant.theme,
    loggedIn,
    adminData: admin
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    tenantDispatch: bindActionCreators(tenantActions, dispatch),
    remarkDispatch: bindActionCreators(remarkActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Admin))
