import React, {Component} from 'react';
// import { Link } from 'react-router-dom';
import { Footer } from '../Footer/Footer';
// import Routes from '../../routes';
import './App.scss';
import { Switch } from 'react-router-dom';
import Landing from '../../containers/Landing/Landing';
// import PropsRoute from '../../routes/PropsRoute'; // <PropsRoute path="/landing" component={Landing} />
import { Route } from 'react-router-dom';
import PropTypes from 'prop-types';
import { fetchTenantIfNeeded } from '../../actions/tenant';
import { connect } from 'react-redux';
// debugger;
class App extends Component {
    constructor(props) {
        super(props);
        this.state = {
            tenant: {}
        };
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
                <Route  render={props => (<Landing tenant={tenant} {...props} />)}/>
              </Switch>
            <Footer/>
          </div>
        );
    }
}

App.propTypes = {
    selectedSubdomain: PropTypes.string.isRequired,
    tenants: PropTypes.object.isRequired,
    isFetching: PropTypes.bool.isRequired,
    dispatch: PropTypes.func.isRequired,
    tenant: PropTypes.object
};

App.defaultProps = {
    tenant: {
        theme: {}
    }
};

function mapStateToProps(state) {
    const { selectedSubdomain, tenantBySubdomain } = state;
    const {
    isFetching,
    lastUpdated,
    data: tenant
  } = tenantBySubdomain[selectedSubdomain] || {
      isFetching: true,
      data: {}
  };

    return {
        selectedSubdomain,
        tenant,
        isFetching,
        lastUpdated
    };
}

export default connect(mapStateToProps)(App);

