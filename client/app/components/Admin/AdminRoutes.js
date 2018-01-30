import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminRoutesIndex, AdminRouteView, AdminRouteForm} from './';
import styles from './Admin.scss';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Switch, Route } from 'react-router-dom';
import { RoundButton } from '../RoundButton/RoundButton';
import { adminActions } from '../../actions';
// import {v4} from 'node-uuid';
// import FileUploader from '../../components/FileUploader/FileUploader';
class AdminRoutes extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedRoute: false,
            currentView: 'open',
            newRoute: false
        };
        this.viewRoute = this.viewRoute.bind(this);
        this.backToIndex = this.backToIndex.bind(this);
        this.toggleNewRoute = this.toggleNewRoute.bind(this);
        this.closeModal = this.closeModal.bind(this);
        this.saveNewRoute = this.saveNewRoute.bind(this);
    }

    viewRoute(route) {
        const { adminDispatch } = this.props;
        adminDispatch.getRoute(route.id, true);
        this.setState({selectedRoute: true});
    }

    toggleNewRoute() {
        this.setState({newRoute: !this.state.newRoute});
    }

    backToIndex() {
        const { dispatch, history } = this.props;
        this.setState({selectedRoute: false});
        dispatch(history.push('/admin/routes'));
    }
    closeModal() {
        this.setState({newRoute: false});
    }
    saveNewRoute(route) {
        const { adminDispatch } = this.props;
        adminDispatch.newRoute(route);
    }

    render() {
        const {selectedRoute} = this.state;
        const {theme, hubs, route, routes, hubHash, adminDispatch, loading} = this.props;
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
        const newButton = (
            <div className="flex-none layout-row">
                <RoundButton
                    theme={theme}
                    size="small"
                    text="New Route"
                    active
                    handleNext={this.toggleNewRoute}
                    iconClass="fa-plus"
                />
            </div>);
        const title = selectedRoute ? 'Route Overview' : 'Routes';
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >{title}</p>
                    {selectedRoute ? backButton : ''}
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-end-center">
                    {newButton}
                </div>
                 { this.state.newRoute ? <AdminRouteForm theme={theme} close={this.closeModal} hubs={hubs} saveRoute={this.saveNewRoute}/> : ''}
                <Switch className="flex">
                    <Route
                        exact
                        path="/admin/routes"
                        render={props => <AdminRoutesIndex theme={theme} hubs={hubs} hubHash={hubHash} routes={routes} adminDispatch={adminDispatch} {...props} viewRoute={this.viewRoute} loading={loading} />}
                    />
                    <Route
                        exact
                        path="/admin/routes/:id"
                        render={props => <AdminRouteView theme={theme} hubs={hubs} hubHash={hubHash} routeData={route} adminActions={adminDispatch} {...props} loading={loading} />}
                    />
                </Switch>
            </div>
        );
    }
}
AdminRoutes.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array
};

function mapStateToProps(state) {
    const {authentication, tenant, admin } = state;
    const { user, loggedIn } = authentication;
    const { clients, hubs, route, routes, loading } = admin;

    return {
        user,
        tenant,
        loggedIn,
        hubs,
        route,
        routes,
        clients,
        loading
    };
}
function mapDispatchToProps(dispatch) {
    return {
        adminDispatch: bindActionCreators(adminActions, dispatch)
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminRoutes);
