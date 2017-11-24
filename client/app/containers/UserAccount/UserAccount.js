import React, { Component } from 'react';
import PropTypes from 'prop-types';

import { connect } from 'react-redux';
// import { Route } from 'react-router';
import { withRouter } from 'react-router-dom';

import './UserAccount.scss';

class UserAccount extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }

    render() {
        return (
            <div className="layout-row flex-100 layout-wrap">
                <h1>HALLO!</h1>
            </div>
        );
    }
}

UserAccount.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    shipment: PropTypes.object,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};

UserAccount.defaultProps = {
    stageTracker: {
        stage: 0,
        shipmentType: ''
    }
};

function mapStateToProps(state) {
    const { authentication, tenant, shipment } = state;
    const { user, loggedIn } = authentication;
    return {
        user,
        tenant,
        loggedIn,
        shipment
    };
}

export default withRouter(connect(mapStateToProps)(UserAccount));
