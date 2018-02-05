import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withRouter } from 'react-router-dom';
import { Switch, Route, Redirect } from 'react-router-dom';
import { connect } from 'react-redux';
import './App.scss';
import Landing from '../Landing/Landing';
import Shop from '../Shop/Shop';
import { Footer } from '../../components/Footer/Footer';
import UserAccount from '../UserAccount/UserAccount';
import Admin from '../Admin/Admin';
import AdminShipmentAction from '../../components/Redirects/AdminShipmentAction';
import { SignOut } from '../../components/SignOut/SignOut';
import Loading from '../../components/Loading/Loading';
import { fetchTenantIfNeeded } from '../../actions/tenant';
import { appActions } from '../../actions';
import { bindActionCreators } from 'redux';
import { PrivateRoute, AdminPrivateRoute } from '../../routes/index';
import {getSubdomain} from '../../helpers';
import MessageCenter from '../../containers/MessageCenter/MessageCenter';
// import SideNav from '../../components/SideNav/SideNav';
class App extends Component {
    constructor(props) {
        super(props);
    }
    componentDidMount() {
        const { appDispatch } = this.props;
        const subdomain = getSubdomain();
        appDispatch.fetchTenantIfNeeded(subdomain);
        appDispatch.fetchCurrencies();
        // dispatch(anonymousLogin());
    }
    componentDidUpdate(prevProps) {
        if (this.props.selectedSubdomain !== prevProps.selectedSubdomain) {
        // const subdomain = getSubdomain();
            const { dispatch, selectedSubdomain } = this.props;
            dispatch(fetchTenantIfNeeded(selectedSubdomain));
        }
    }
    render() {
        const { tenant, isFetching, user, loggedIn, showMessages, sending } = this.props;
        const theme = tenant.data.theme;
        return (
            <div className="layout-fill layout-column layout-align-end hundred">
                <div className="flex-100 layout-row height_100">
                    {/* <SideNav/>*/}
                    <div className="flex layout-column scroll layout-align-end hundred">
                        { showMessages || sending ? <MessageCenter /> : '' }
                        {isFetching ? <Loading theme={theme} text="loading..." /> : ''}
                        { user && user.id && tenant && tenant.data && user.tenant_id !== tenant.data.id ? <Redirect to="/signout" /> : '' }
                        <Switch className="flex">
                            <Route
                                exact
                                path="/"
                                render={props => <Landing theme={theme} {...props} />}
                            />
                            <PrivateRoute
                                path="/booking"
                                component={Shop}
                                user={user}
                                loggedIn={loggedIn}
                                theme={theme}
                            />
                            <AdminPrivateRoute
                                path="/admin"
                                component={Admin}
                                user={user}
                                loggedIn={loggedIn}
                                theme={theme}
                            />
                            <Route
                                path="/signout"
                                render={props => <SignOut theme={theme} {...props} />}
                            />
                             <Route
                                path="/redirects/shipment/:uuid"
                                render={props => <AdminShipmentAction theme={theme} {...props} />}
                            />
                            <PrivateRoute
                                path="/account"
                                component={UserAccount}
                                user={user}
                                loggedIn={loggedIn}
                                theme={theme}
                            />

                        </Switch>
                        <Footer theme={theme} tenant={tenant.data}/>
                    </div>
                </div>
            </div>
        );
    }
}

App.propTypes = {
    selectedSubdomain: PropTypes.string.isRequired,
    isFetching: PropTypes.bool.isRequired,
    tenant: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool
};

function mapStateToProps(state) {
    const { selectedSubdomain, tenant, authentication, messaging } = state;
    const { showMessages, sending } = messaging;
    const { user, loggedIn } = authentication;
    // const { currencies } = app;
    const { isFetching } = tenant || {
        isFetching: true
    };
    return {
        selectedSubdomain,
        tenant,
        user,
        loggedIn,
        isFetching,
        showMessages,
        sending
        // currencies
    };
}
function mapDispatchToProps(dispatch) {
    return {
        appDispatch: bindActionCreators(appActions, dispatch)
    };
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(App));
