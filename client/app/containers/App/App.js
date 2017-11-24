import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withRouter } from 'react-router-dom';
import { Switch, Route } from 'react-router-dom';
import { connect } from 'react-redux';
import './App.scss';
import Landing from '../Landing/Landing';
import OpenShop from '../OpenShop/OpenShop';
import { Footer } from '../../components/Footer/Footer';
import UserAccount from '../UserAccount/UserAccount';
// import PropsRoute from '../../routes/PropsRoute'; // <PropsRoute path="/landing" component={Landing} />
import { fetchTenantIfNeeded } from '../../actions/tenant';
// import { tenantDefaults } from '../../constants';
// debugger;
class App extends Component {
    constructor(props) {
        super(props);
        // this.state = {
        //     tenant: {}
        // };
        console.log(this.props);
    }

    componentDidMount() {
        const { dispatch, selectedSubdomain } = this.props;
        dispatch(fetchTenantIfNeeded(selectedSubdomain));
        // const tenantId = 'greencarrier';
        // fetch('http://localhost:3000/tenants/' + tenantId)
        // .then(results => {
        //     return results.json();
        // }).then(data => {
        //     // console.log(data);
        //     // this.setTenant(data);
        //     this.setState({tenant: data});
        // });
    }
    componentDidUpdate(prevProps) {
        if (this.props.selectedSubdomain !== prevProps.selectedSubdomain) {
            const { dispatch, selectedSubdomain } = this.props;
            dispatch(fetchTenantIfNeeded(selectedSubdomain));
        }
    }
    // setTenant(tenant) {
    //     boundSetTenant({tenant: tenant});
    // }

    render() {
        const { tenant, isFetching } = this.props;
        // const tenant = this.state.tenant;
        console.log(tenant);
        return (
            <div className="layout-fill layout-column scroll">
                {isFetching && <h2>Loading...</h2>}
                <Switch className="flex">
                    <Route
                        exact
                        path="/"
                        render={props => (
                            <Landing theme={tenant.data.theme} {...props} />
                        )}
                    />
                    <Route
                        path="/open"
                        render={props => (
                            <OpenShop theme={tenant.data.theme} {...props} />
                        )}
                    />
                    <Route
                        path="/account"
                        render={props => (
                            <UserAccount theme={tenant.data.theme} {...props} />
                        )}
                    />
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
