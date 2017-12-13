import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminPricingsIndex} from './';
import styles from './Admin.scss';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Switch, Route } from 'react-router-dom';
import { RoundButton } from '../RoundButton/RoundButton';
import { adminActions } from '../../actions';
// import {v4} from 'node-uuid';
// import FileUploader from '../../components/FileUploader/FileUploader';
class AdminPricings extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedRoute: false,
            currentView: 'open'
        };
        this.viewRoute = this.viewRoute.bind(this);
        this.backToIndex = this.backToIndex.bind(this);
    }
    viewRoute(route) {
        const { adminDispatch } = this.props;
        adminDispatch.getRoute(route.id, true);
        this.setState({selectedRoute: true});
    }

    backToIndex() {
        const { dispatch, history } = this.props;
        this.setState({selectedHub: false});
        dispatch(history.push('/admin/routes'));
    }

    render() {
        const {selectedRoute} = this.state;
        const {theme, hubs, pricingData, routes, hubHash, adminDispatch} = this.props;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const backButton = (
            <div className="flex-none layout-row">
                <RoundButton
                    theme={theme}
                    size="small"
                    text="Back"
                    handleNext={this.backToIndex}
                    iconClass="fa-chevron-left"
                />
            </div>);
        const title = selectedHub ? 'Pricing Overview' : 'Pricings';
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >{title}</p>
                    {selectedRoute ? backButton : ''}
                </div>
                <Switch className="flex">
                    <Route
                        exact
                        path="/admin/pricings"
                        render={props => <AdminPricingsIndex theme={theme} hubs={hubs} hubHash={hubHash} clients={clients} pricingData={pricingData} routes={routes} {...props} viewRoute={this.viewRoute} />}
                    />
                    {/* <Route
                        exact
                        path="/admin/pricings/clients"
                        render={props => <AdminPricingsClientsIndex theme={theme} hubs={hubs} hubHash={hubHash} routes={routes} {...props} viewRoute={this.viewRoute} />}
                    />
                    <Route
                        exact
                        path="/admin/pricings/routes"
                        render={props => <AdminPricingsRoutesIndex theme={theme} hubs={hubs} hubHash={hubHash} routes={routes} {...props} viewRoute={this.viewRoute} />}
                    />
                    <Route
                        exact
                        path="/admin/pricings/clients/:id"
                        render={props => <AdminPricingClientView theme={theme} hubs={hubs} hubHash={hubHash} routeData={route} adminActions={adminDispatch} {...props} />}
                    />
                    <Route
                        exact
                        path="/admin/pricings/routes/:id"
                        render={props => <AdminPricingRouteView theme={theme} hubs={hubs} hubHash={hubHash} routeData={route} adminActions={adminDispatch} {...props} />}
                    /> */}
                </Switch>
            </div>
        );
    }
}
AdminPricings.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array
};

function mapStateToProps(state) {
    const {authentication, tenant, admin } = state;
    const { user, loggedIn } = authentication;
    const { clients, hubs, pricingData, routes } = admin;

    return {
        user,
        tenant,
        loggedIn,
        hubs,
        pricingData,
        routes,
        clients
    };
}
function mapDispatchToProps(dispatch) {
    return {
        adminDispatch: bindActionCreators(adminActions, dispatch)
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminPricings);
