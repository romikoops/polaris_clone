import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Header from '../../components/Header/Header';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import { Switch, Route } from 'react-router-dom';
import { AdminNav, AdminDashboard, AdminHubs, AdminPricings, AdminSchedules, AdminServiceCharges } from '../../components/Admin';
import defs from '../../styles/default_classes.scss';
import { adminActions } from '../../actions';
class Admin extends Component {
    constructor(props) {
        super(props);
        this.setUrl = this.setUrl.bind(this);
    }
    setUrl(target) {
        console.log(target);
        const {dispatch} = this.props;
        switch(target) {
            case 'hubs':
                dispatch(adminActions.getHubs());
                break;
            case 'serviceCharges':
                dispatch(adminActions.getServiceCharges());
                break;
            case 'pricing':
                dispatch(adminActions.getPricings());
                break;
            case 'schedules':
                dispatch(adminActions.getSchedules());
                break;
            case 'trucking':
                dispatch(adminActions.getTrucking());
                break;
            default:
                break;
        }
    }
    render() {
        const {theme, adminData} = this.props;
        const {hubs, serviceCharges, pricingData, schedules} = adminData;
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
                                render={props => <AdminDashboard theme={theme} {...props} />}
                            />
                            <Route

                                path="/admin/hubs"
                                render={props => <AdminHubs theme={theme} {...props} hubs={hubs} />}
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
