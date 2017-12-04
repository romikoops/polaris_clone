import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Header from '../../components/Header/Header';
import { connect } from 'react-redux';
import { withRouter } from 'react-router-dom';
import { Switch, Route } from 'react-router-dom';
import { AdminNav } from './AdminNav';
import { AdminDashboard } from './AdminDashboard';
import defs from '../../styles/default_classes.scss';
class Admin extends Component {
    constructor(props) {
        super(props);
        this.setUrl = this.setUrl.bind(this);
    }
    setUrl(url) {
        console.log(url);
        const {history} = this.props;
        history.push(url);
    }
    render() {
        const {theme} = this.props;
        return (
            <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                <Header theme={theme} />
                <div className={`flex-none ${defs.content_width} layout-row layout-wrap layout-align-start-center `}>
                    <div className="flex-20 layout-row layout-wrap layout-align-start-center">
                        <AdminNav navLink={this.setUrl} theme={theme}/>
                    </div>
                    <div className="flex-80 layout-row layout-wrap layout-align-start-center">
                        <Switch className="flex">
                            <Route
                                exact
                                path="/dashboard"
                                render={props => <AdminDashboard theme={theme} {...props} />}
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
    match: PropTypes.object
};

Admin.defaultProps = {
};

function mapStateToProps(state) {
    const { users, authentication, tenant } = state;
    const { user, loggedIn } = authentication;
    return {
        user,
        users,
        tenant,
        loggedIn
    };
}

export default withRouter(connect(mapStateToProps)(Admin));
