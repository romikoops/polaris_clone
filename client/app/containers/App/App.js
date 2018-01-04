import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withRouter } from 'react-router-dom';
import { Switch, Route } from 'react-router-dom';
import { connect } from 'react-redux';
import './App.scss';
import Landing from '../Landing/Landing';
import Shop from '../Shop/Shop';
import { Footer } from '../../components/Footer/Footer';
import UserAccount from '../UserAccount/UserAccount';
import Admin from '../Admin/Admin';
import AdminShipmentAction from '../../components/Redirects/AdminShipmentAction';
import { SignOut } from '../../components/SignOut/SignOut';
import { Loading } from '../../components/Loading/Loading';
import { fetchTenantIfNeeded } from '../../actions/tenant';
import { PrivateRoute, AdminPrivateRoute } from '../../routes/index';
import {getSubdomain} from '../../helpers';
class App extends Component {
    constructor(props) {
        super(props);
    }
    componentDidMount() {
        const { dispatch } = this.props;
        const subdomain = getSubdomain();
        dispatch(fetchTenantIfNeeded(subdomain));
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
        const { tenant, isFetching, user, loggedIn } = this.props;
        const theme = tenant.data.theme;
        return (
            <div className="layout-fill layout-column scroll">
                {isFetching ? <Loading theme={theme} text="loading..." /> : ''}
                <Switch className="flex">
                    <Route
                        exact
                        path="/"
                        render={props => <Landing theme={theme} {...props} />}
                    />
                    {/* <Route
                        path="/booking"
                        render={props => <Shop theme={theme} {...props} />}
                    /> */}
                    <PrivateRoute
                        path="/booking"
                        component={Shop}
                        user={user}
                        loggedIn={loggedIn}
                        theme={theme}
                    />
                    {/* <Route
                        path="/admin"
                        render={props => <Admin theme={theme} {...props} />}
                    /> */}
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
        );
    }
}

App.propTypes = {
    selectedSubdomain: PropTypes.string.isRequired,
    isFetching: PropTypes.bool.isRequired,
    dispatch: PropTypes.func.isRequired,
    tenant: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool
};

function mapStateToProps(state) {
    const { selectedSubdomain, tenant, authentication } = state;
    const { user, loggedIn } = authentication;
    const { isFetching } = tenant || {
        isFetching: true
    };
    return {
        selectedSubdomain,
        tenant,
        user,
        loggedIn,
        isFetching
    };
}

export default withRouter(connect(mapStateToProps)(App));
