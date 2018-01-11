import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Header from '../../components/Header/Header';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import { Switch, Route } from 'react-router-dom';
import { bindActionCreators } from 'redux';
import { AdminNav, AdminDashboard, AdminSchedules, AdminServiceCharges } from '../../components/Admin';
import AdminShipments from '../../components/Admin/AdminShipments';
import AdminClients from '../../components/Admin/AdminClients';
import AdminHubs from '../../components/Admin/AdminHubs';
import AdminRoutes from '../../components/Admin/AdminRoutes';
import AdminPricings from '../../components/Admin/AdminPricings';
import AdminTrucking from '../../components/Admin/AdminTrucking';
import AdminWizard from '../../components/Admin/AdminWizard/AdminWizard';
import { FloatingMenu } from '../../components/FloatingMenu/FloatingMenu';
import { Loading } from '../../components/Loading/Loading';
import defs from '../../styles/default_classes.scss';
import { adminActions } from '../../actions';
class Admin extends Component {
    constructor(props) {
        super(props);
        this.setUrl = this.setUrl.bind(this);
    }
    componentDidMount() {
        const {adminDispatch} = this.props;
        adminDispatch.getClients(false);
        adminDispatch.getHubs(false);
    }
    setUrl(target) {
        console.log(target);
        const {adminDispatch} = this.props;
        switch(target) {
            case 'hubs':
                adminDispatch.getHubs(true);
                break;
            case 'serviceCharges':
                adminDispatch.getServiceCharges(true);
                break;
            case 'pricing':
                adminDispatch.getPricings(true);
                break;
            case 'schedules':
                adminDispatch.getSchedules(true);
                break;
            case 'trucking':
                adminDispatch.getTrucking(true);
                break;
            case 'shipments':
                adminDispatch.getShipments(true);
                break;
            case 'clients':
                adminDispatch.getClients(true);
                break;
            case 'dashboard':
                adminDispatch.getDashboard(true);
                break;
            case 'routes':
                adminDispatch.getRoutes(true);
                break;
            case 'wizard':
                adminDispatch.goTo('/admin/wizard');
                break;
            default:
                break;
        }
    }
    render() {
        console.log(this.props);
        const {theme, adminData, adminDispatch} = this.props;
        const {hubs, serviceCharges, pricingData, schedules, shipments, clients, dashboard, routes, loading} = adminData;
        const hubHash = {};
        if (hubs) {
            hubs.forEach((hub) => {
                hubHash[hub.data.id] = hub;
            });
        }
        const loadingScreen = loading ? <Loading theme={theme} /> : '';
        const nav = (<AdminNav navLink={this.setUrl} theme={theme}/>);
        // ;
        return (
            <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                <Header theme={theme} />
                {loadingScreen}
                <div className={`flex-none ${defs.content_width} layout-row layout-wrap layout-align-start-start `}>
                    <FloatingMenu Comp={nav} theme={theme}/>
                    <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                        <Switch className="flex">
                            <Route

                                path="/admin/dashboard"
                                render={props => <AdminDashboard theme={theme} {...props} clients={clients} hubs={hubs} hubHash={hubHash} dashData={dashboard} adminDispatch={adminDispatch}/>}
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
                                render={props => <AdminServiceCharges theme={theme} {...props} hubs={hubs} charges={serviceCharges} adminTools={adminDispatch}/>}
                            />
                            <Route

                                path="/admin/shipments"
                                render={props => <AdminShipments theme={theme} {...props} hubs={hubs} hubHash={hubHash} shipments={shipments} clients={clients}/>}
                            />
                            <Route

                                path="/admin/clients"
                                render={props => <AdminClients theme={theme} {...props} hubs={hubHash} clients={clients} adminDispatch={adminDispatch}/>}
                            />
                            <Route

                                path="/admin/routes"
                                render={props => <AdminRoutes theme={theme} {...props} hubHash={hubHash} routes={routes} clients={clients}/>}
                            />
                            <Route

                                path="/admin/wizard"
                                render={props => <AdminWizard theme={theme} {...props} hubHash={hubHash} />}
                            />
                            <Route

                                path="/admin/trucking"
                                render={props => <AdminTrucking theme={theme} {...props} hubHash={hubHash} />}
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
        theme: tenant.data.theme,
        loggedIn,
        adminData: admin
    };
}
function mapDispatchToProps(dispatch) {
    return {
        adminDispatch: bindActionCreators(adminActions, dispatch)
    };
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Admin));
