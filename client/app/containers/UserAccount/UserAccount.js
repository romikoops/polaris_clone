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

        this.state = {
            activeLink: 'profile'
        };

        this.toggleActiveClass = this.toggleActiveClass.bind(this);
    }

    toggleActiveClass(key) {
        this.setState({ activeLink: key });
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

        let viewComponent;
        switch (this.state.activeLink) {
            case 'profile':
                viewComponent = <h1>pro</h1>;
                break;
            case 'locations':
                viewComponent = <h1>locations</h1>;
                break;
            case 'emails':
                viewComponent = <h1>emails</h1>;
                break;
            case 'password':
                viewComponent = <h1>password</h1>;
                break;
            case 'billing':
                viewComponent = <h1>billing</h1>;
                break;
            default:
                viewComponent = <h1>pro</h1>;
                break;
        }

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center">
                <Header theme={this.props.theme} />

                <div className="content-width layout-row flex-none spacing-md-top spacing-md-bottom">
                    <div className="layout-row flex-20">
                        <NavSidebar
                            theme={this.props.theme}
                            navHeadlineInfo={navHeadlineInfo}
                            navLinkInfo={navLinkInfo}
                            toggleActiveClass={this.toggleActiveClass}
                            activeLink={this.state.activeLink}
                        />
                    </div>

                    <div className="layout-row flex-80">{viewComponent}</div>
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
