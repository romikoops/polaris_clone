import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminPricingsIndex, AdminPricingClientView, AdminPricingRouteView, AdminPricingsClientIndex, AdminPricingsRouteIndex} from './';
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
            selectedPricing: false,
            currentView: 'open'
        };
        this.viewRoute = this.viewRoute.bind(this);
        this.backToIndex = this.backToIndex.bind(this);
    }
    componentDidMount() {
        const { pricingData, loading, adminDispatch } = this.props;
        if (!pricingData && !loading) {
            adminDispatch.getPricings(false);
        }
    }
    viewRoute(route) {
        const { adminDispatch } = this.props;
        adminDispatch.getRoute(route.id, true);
        this.setState({selectedPricing: true});
    }

    backToIndex() {
        const { dispatch, history } = this.props;
        this.setState({selectedPricing: false});
        dispatch(history.push('/admin/routes'));
    }

    render() {
        const {selectedPricing} = this.state;
        const {theme, hubs, pricingData, itineraries, hubHash, adminDispatch, clients, clientPricings, itineraryPricings } = this.props;
        const filteredClients = clients.filter(x => !x.guest);
        console.log(filteredClients);
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
        const title = selectedPricing ? 'Pricing Overview' : 'Pricings';
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >{title}</p>
                    {selectedPricing ? backButton : ''}
                </div>
                <Switch className="flex">
                    <Route
                        exact
                        path="/admin/pricings"
                        render={props => <AdminPricingsIndex theme={theme} hubs={hubs} hubHash={hubHash} clients={filteredClients} pricingData={pricingData} itineraries={itineraries} {...props} adminTools={adminDispatch}  />}
                    />
                    <Route
                        exact
                        path="/admin/pricings/clients"
                        render={props => <AdminPricingsClientIndex theme={theme} clients={filteredClients} adminTools={adminDispatch} {...props}  />}
                    />
                    <Route
                        exact
                        path="/admin/pricings/routes"
                        render={props => <AdminPricingsRouteIndex theme={theme} hubs={hubs}  routes={itineraries ? itineraries : pricingData.itineraries}  adminTools={adminDispatch} {...props}  />}
                    />
                    <Route
                        exact
                        path="/admin/pricings/clients/:id"
                        render={props => <AdminPricingClientView theme={theme} hubs={hubs} hubHash={hubHash} pricingData={pricingData} clientPricings={clientPricings} adminActions={adminDispatch} {...props} />}
                    />
                    <Route
                        exact
                        path="/admin/pricings/routes/:id"
                        render={props => <AdminPricingRouteView theme={theme} hubs={hubs} hubHash={hubHash} pricingData={pricingData} clients={filteredClients} itineraryPricings={itineraryPricings} adminActions={adminDispatch} {...props} />}
                    />
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
    const { clients, hubs, pricingData, routes, transportCategories, clientPricings, itineraryPricings, loading } = admin;

    return {
        user,
        tenant,
        loggedIn,
        hubs,
        pricingData,
        transportCategories,
        clientPricings,
        routes,
        clients,
        itineraryPricings,
        loading
    };
}
function mapDispatchToProps(dispatch) {
    return {
        adminDispatch: bindActionCreators(adminActions, dispatch)
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminPricings);
