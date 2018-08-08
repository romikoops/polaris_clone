import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import { Switch, Route, withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import FloatingMenu from '../../components/FloatingMenu/FloatingMenu'
import { adminActions } from '../../actions'
import { Footer } from '../../components/Footer/Footer'
import { AdminDashboardNew, AdminServiceCharges, SuperAdmin } from '../../components/Admin'
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
import AdminSchedulesRoute from '../../components/Admin/Schedules/Route'
import SuperAdminTenantCreator from '../SuperAdmin/Tenant/Creator'
import { SuperAdminPrivateRoute } from '../../routes/index'
// eslint-disable-next-line import/no-named-as-default
import AdminCurrencyCenter from '../../components/Admin/Currency/Center'
import { adminHubs as hubsTip } from '../../constants'

class Admin extends Component {
  constructor (props) {
    super(props)
    this.setUrl = this.setUrl.bind(this)
  }
  componentDidMount () {
    const { adminDispatch } = this.props
    adminDispatch.getClients(false)
    adminDispatch.getHubs(false)
    adminDispatch.getShipments(false)
  }
  setUrl (target) {
    const { adminDispatch } = this.props
    switch (target) {
      case 'hubs':
        adminDispatch.getHubs(true)
        break
      case 'serviceCharges':
        adminDispatch.getServiceCharges(true)
        break
      case 'pricing':
        adminDispatch.getPricings(true)
        break
      case 'schedules':
        adminDispatch.getSchedules(true)
        break
      case 'trucking':
        adminDispatch.getTrucking(true)
        break
      case 'shipments':
        adminDispatch.getShipments(true)
        break
      case 'clients':
        adminDispatch.getClients(true)
        break
      case 'dashboard':
        adminDispatch.getDashboard(true)
        break
      case 'routes':
        adminDispatch.getItineraries(true)
        break
      case 'wizard':
        adminDispatch.goTo('/admin/wizard')
        break
      case 'super_admin':
        adminDispatch.goTo('/admin/super_admin/upload')
        break
      default:
        break
    }
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
    const menu = <FloatingMenu Comp={SideNav} theme={theme} user={user} />
    const minHeightForFooter = window.innerHeight - 350
    const footerStyle = {
      minHeight: `${minHeightForFooter}px`,
      position: 'relative',
      paddingBottom: '230px'
    }

    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap hundred">
        {loadingScreen}
        {menu}
        <Header theme={theme} scrollable />
        <div
          className="flex layout-row layout-align-center-start layout-wrap"
          style={footerStyle}
        >
          <NavBar className={`${styles.top_margin}`} />
          <div
            className=" flex-100 layout-row
             layout-wrap layout-align-start-start hundred"
          >
            <div className="flex-100 layout-row layout-wrap layout-align-center-center">
              <Switch className="flex ">
                <Route
                  exact
                  path="/admin/dashboard"
                  render={props => (
                    <AdminDashboardNew
                      user={user}
                      theme={theme}
                      {...props}
                      clients={clients}
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
                    <AdminPricings theme={theme} {...props} hubs={hubs} pricingData={pricingData} />
                  )}
                />
                <Route
                  path="/admin/currencies"
                  render={props => (
                    <AdminCurrencyCenter theme={theme} />
                  )}
                />
                <SuperAdminPrivateRoute
                  path="/admin/superadmin"
                  component={SuperAdminTenantCreator}
                  user={user}
                  theme={theme}
                />
                <Route
                  exact
                  path="/admin/schedules"
                  render={props => (
                    <AdminSchedules
                      theme={theme}
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
                    clients={clients}
                    {...props}
                    hubs={hubs}
                    hubHash={hubHash}
                  />)}
                />
                <Route
                  path="/admin/routes"
                  render={props => (
                    <AdminRoutes theme={theme} {...props} hubHash={hubHash} clients={clients} allHubs={allHubs} loading={loading} />
                  )}
                />
                <Route
                  path="/admin/wizard"
                  render={props => <AdminWizard theme={theme} {...props} hubHash={hubHash} />}
                />
                <Route
                  path="/admin/trucking"
                  render={props => <AdminTrucking theme={theme} {...props} hubHash={hubHash} />}
                />
                <Route
                  path="/admin/super_admin/upload"
                  render={props => <SuperAdmin theme={theme} {...props} />}
                />
              </Switch>
            </div>
          </div>
          <Footer theme={theme} tenant={tenant.data} isShop />
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
