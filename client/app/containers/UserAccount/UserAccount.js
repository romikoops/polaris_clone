import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import { Route } from 'react-router';
import { withRouter } from 'react-router-dom';
import { connect } from 'react-redux';
import Header from '../../components/Header/Header';
import { NavSidebar } from '../../components/NavSidebar/NavSidebar';

import './UserAccount.scss';

class UserAccount extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const navHeadlineInfo = 'Account Settings';
        const navLinkInfo = [
            { key: 'profile', text: 'Profile' },
            { key: 'locations', text: 'Locations' },
            { key: 'emails', text: 'Emails' },
            { key: 'password', text: 'Password' },
            { key: 'billing', text: 'Billing' }
        ];

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center">
                <Header theme={this.props.theme} />

                <div className="content-width layout-row flex-none spacing-md-top spacing-md-bottom">
                    <div className="layout-row flex-20">
                        <NavSidebar
                            theme={this.props.theme}
                            navHeadlineInfo={navHeadlineInfo}
                            navLinkInfo={navLinkInfo}
                        />
                    </div>

                    <div className="layout-row flex-80">
                        Lorem ipsum dolor sit amet, consectetur adipisicing
                        elit. In ducimus velit quibusdam alias perferendis!
                        Reprehenderit nisi natus reiciendis ipsam maiores
                        commodi iure, corrupti! Odio, ratione consequatur.
                        Adipisci placeat, in dolores?
                    </div>
                </div>
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
