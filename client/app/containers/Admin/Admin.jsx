import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import { Switch, Route, withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import { FloatingMenu } from '../../components/FloatingMenu/FloatingMenu'
import { adminActions } from '../../actions'
import { Footer } from '../../components/Footer/Footer'
import { AdminDashboard, AdminSchedules, AdminServiceCharges, SuperAdmin } from '../../components/Admin'
import AdminShipments from '../../components/Admin/AdminShipments'
import AdminClients from '../../components/Admin/AdminClients'
import AdminHubs from '../../components/Admin/AdminHubs'
import AdminRoutes from '../../components/Admin/AdminRoutes'
import AdminPricings from '../../components/Admin/AdminPricings'
import AdminTrucking from '../../components/Admin/AdminTrucking'
import AdminWizard from '../../components/Admin/AdminWizard/AdminWizard'
import Loading from '../../components/Loading/Loading'
import defs from '../../styles/default_classes.scss'
import Header from '../../components/Header/Header'
import SideNav from '../../components/SideNav/SideNav'

class Admin extends Component {
  constructor (props) {
    super(props)
    this.setUrl = this.setUrl.bind(this)
  }
  componentDidMount () {
    const { adminDispatch } = this.props
    adminDispatch.getClients(false)
    adminDispatch.getHubs(false)
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
        adminDispatch.getRoutes(true)
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
      theme, adminData, adminDispatch, user
    } = this.props

    const {
      hubs, serviceCharges, pricingData, schedules, shipments, clients, dashboard, loading
    } = adminData

    const hubHash = {}
    if (hubs) {
      hubs.forEach((hub) => {
        hubHash[hub.data.id] = hub
      })
    }
    const loadingScreen = loading ? <Loading theme={theme} /> : ''
    const nav = (<SideNav theme={theme} user={user} />)
    const menu = <FloatingMenu Comp={nav} theme={theme} />
    // ;
    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap hundred">

        <Header theme={theme} menu={menu} showMenu scrollable />
        {loadingScreen}
        <div className={`flex-none ${defs.content_width} layout-row layout-wrap layout-align-start-start hundred`}>
          <div className="flex-100 layout-row layout-wrap layout-align-center-center">
            <Switch className="flex">
              <Route
                path="/admin/dashboard"
                render={props => (<AdminDashboard
                  theme={theme}
                  {...props}
                  clients={clients}
                  hubs={hubs}
                  hubHash={hubHash}
                  dashData={dashboard}
                  adminDispatch={adminDispatch}
                />)}
              />
              <Route
                path="/admin/hubs"
                render={props => (<AdminHubs
                  theme={theme}
                  {...props}
                  hubHash={hubHash}
                  hubs={hubs}
                />)}
              />
              <Route

                path="/admin/pricings"
                render={props => (<AdminPricings
                  theme={theme}
                  {...props}
                  hubs={hubs}
                  pricingData={pricingData}
                />)}
              />
              <Route

                path="/admin/schedules"
                render={props => (<AdminSchedules
                  theme={theme}
                  {...props}
                  hubs={hubHash}
                  scheduleData={schedules}
                />)}
              />
              <Route

                path="/admin/service_charges"
                render={props => (<AdminServiceCharges
                  theme={theme}
                  {...props}
                  hubs={hubs}
                  charges={serviceCharges}
                  adminTools={adminDispatch}
                />)}
              />
              <Route

                path="/admin/shipments"
                render={props => (<AdminShipments
                  theme={theme}
                  {...props}
                  hubs={hubs}
                  hubHash={hubHash}
                  shipments={shipments}
                  clients={clients}
                />)}
              />
              <Route

                path="/admin/clients"
                render={props => (<AdminClients
                  theme={theme}
                  {...props}
                  hubs={hubHash}
                />)}
              />
              <Route
                path="/admin/routes"
                render={props => (<AdminRoutes
                  theme={theme}
                  {...props}
                  hubHash={hubHash}
                  clients={clients}
                />)}
              />
              <Route
                path="/admin/wizard"
                render={props => (<AdminWizard
                  theme={theme}
                  {...props}
                  hubHash={hubHash}
                />)}
              />
              <Route
                path="/admin/trucking"
                render={props => (<AdminTrucking
                  theme={theme}
                  {...props}
                  hubHash={hubHash}
                />)}
              />
              <Route
                path="/admin/super_admin/upload"
                render={props => (<SuperAdmin
                  theme={theme}
                  {...props}
                />)}
              />
            </Switch>
          </div>
        </div>
        <Footer />
      </div>
    )
  }
}
Admin.propTypes = {
  theme: PropTypes.theme,
  // eslint-disable-next-line react/forbid-prop-types
  user: PropTypes.any,
  loggedIn: PropTypes.bool,
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
  loggedIn: false
}

function mapStateToProps (state) {
  const {
    users, authentication, tenant, admin
  } = state
  const { user, loggedIn } = authentication
  return {
    user,
    users,
    tenant,
    theme: tenant.data.theme,
    loggedIn,
    adminData: admin
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    user: null,
    loggedIn: false
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Admin))
