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
import { SignOut } from '../../components/SignOut/SignOut';
import { Loading } from '../../components/Loading/Loading';
import { fetchTenantIfNeeded } from '../../actions/tenant';

class App extends Component {
    constructor(props) {
        super(props);
    }
    componentDidMount() {
        const { dispatch, selectedSubdomain } = this.props;
        dispatch(fetchTenantIfNeeded(selectedSubdomain));
    }
    componentDidUpdate(prevProps) {
        if (this.props.selectedSubdomain !== prevProps.selectedSubdomain) {
            const { dispatch, selectedSubdomain } = this.props;
            dispatch(fetchTenantIfNeeded(selectedSubdomain));
        }
    }
    render() {
        const { tenant, isFetching } = this.props;
        const theme = tenant.data.theme;
        // const tenant = this.state.tenant;
        console.log(tenant);

        return (
            <div className="layout-fill layout-column scroll">
                {isFetching && <Loading theme={theme} text="loading..." />}
                <Switch className="flex">
                    <Route
                        exact
                        path="/"
                        render={props => <Landing theme={theme} {...props} />}
                    />
                    <Route
                        path="/booking"
                        render={props => <Shop theme={theme} {...props} />}
                    />
                    <Route
                        path="/signout"
                        render={props => <SignOut theme={theme} {...props} />}
                    />
                    {theme ? (
                        <Route
                            path="/account"
                            render={props => (
                                <UserAccount theme={theme} {...props} />
                            )}
                        />
                    ) : (
                        ''
                    )}
                </Switch>
                <Footer />
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
