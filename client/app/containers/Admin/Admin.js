import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Header from '../../components/Header/Header';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import { Switch, Route } from 'react-router-dom';
import { AdminNav, AdminDashboard, AdminSchedules, AdminServiceCharges } from '../../components/Admin';
import AdminShipments from '../../components/Admin/AdminShipments';
import AdminClients from '../../components/Admin/AdminClients';
import AdminHubs from '../../components/Admin/AdminHubs';
import AdminRoutes from '../../components/Admin/AdminRoutes';
import AdminPricings from '../../components/Admin/AdminPricings';
import defs from '../../styles/default_classes.scss';
import { adminActions } from '../../actions';
class Admin extends Component {
    constructor(props) {
        super(props);
        this.setUrl = this.setUrl.bind(this);
    }
    componentDidMount() {
        const {dispatch} = this.props;
        dispatch(adminActions.getClients(false));
        dispatch(adminActions.getHubs(false));
    }
    setUrl(target) {
        console.log(target);
        const {dispatch} = this.props;
        switch(target) {
            case 'hubs':
                dispatch(adminActions.getHubs(true));
                break;
            case 'serviceCharges':
                dispatch(adminActions.getServiceCharges(true));
                break;
            case 'pricing':
                dispatch(adminActions.getPricings(true));
                break;
            case 'schedules':
                dispatch(adminActions.getSchedules(true));
                break;
            case 'trucking':
                dispatch(adminActions.getTrucking(true));
                break;
            case 'shipments':
                dispatch(adminActions.getShipments(true));
                break;
             case 'clients':
                dispatch(adminActions.getClients(true));
                break;
            case 'dashboard':
                dispatch(adminActions.getDashboard(true));
                break;
            case 'routes':
                dispatch(adminActions.getRoutes(true));
                break;
            default:
                break;
        }
    }
    render() {
        const {theme, adminData} = this.props;
        const {hubs, serviceCharges, pricingData, schedules, shipments, clients, dashboard, routes} = adminData;
        const hubHash = {};
        if (hubs) {
          hubs.forEach((hub) => {
              hubHash[hub.data.id] = hub;
          });
        }
        // debugger;
        return (
            <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                <Header theme={theme} />
                <div className={`flex-none ${defs.content_width} layout-row layout-wrap layout-align-start-start `}>
                    <div className="flex-20 layout-row layout-wrap layout-align-start-center">
                        <AdminNav navLink={this.setUrl} theme={theme}/>
                    </div>
                    <div className="flex-80 layout-row layout-wrap layout-align-start-start">
                        <Switch className="flex">
                            <Route

                                path="/admin/dashboard"
                                render={props => <AdminDashboard theme={theme} {...props} clients={clients} dashData={dashboard}/>}
                            />
                            <Route

                                path="/admin/hubs"
                                render={props => <AdminHubs theme={theme} {...props} hubHash={hubHash} hubs={hubs}/>}
                            />
                            <Route

                                path="/admin/pricings"
                                render={props => <AdminPricings theme={theme} {...props} hubs={hubs} pricingData={pricingData} />}
                            />
                            <Route

                                path="/admin/schedules"
                                render={props => <AdminSchedules theme={theme} {...props} hubs={hubHash} scheduleData={schedules} />}
                            />
                             <Route

                                path="/admin/service_charges"
                                render={props => <AdminServiceCharges theme={theme} {...props} hubs={hubs} charges={serviceCharges} />}
                            />
                            <Route

                                path="/admin/shipments"
                                render={props => <AdminShipments theme={theme} {...props} hubs={hubs} shipments={shipments} clients={clients}/>}
                            />
                            <Route

                                path="/admin/clients"
                                render={props => <AdminClients theme={theme} {...props} hubs={hubHash} clients={clients}/>}
                            />
                             <Route

                                path="/admin/routes"
                                render={props => <AdminRoutes theme={theme} {...props} hubHash={hubHash} routes={routes} clients={clients}/>}
                            />
                        </Switch>
                    </div>
                </div>


            </div>
        );
    }
}
Admin.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object,
    adminData: PropTypes.object
};

Admin.defaultProps = {
};

function mapStateToProps(state) {
    const { users, authentication, tenant, admin } = state;
    const { user, loggedIn } = authentication;
    return {
        user,
        users,
        tenant,
        loggedIn,
        adminData: admin
    };
}

export default withRouter(connect(mapStateToProps)(Admin));
