import React, { Component } from 'react';
import PropTypes from 'prop-types';
export class AdminDashboard extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        // const {theme} = this.props;
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <h1>Dashboard</h1>
            </div>
        );
    }
}
AdminDashboard.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};
