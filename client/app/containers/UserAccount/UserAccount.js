import React, { Component } from 'react';
import PropTypes from 'prop-types';
import defs from '../../styles/default_classes.scss';
import { withRouter } from 'react-router-dom';
import { connect } from 'react-redux';
import Header from '../../components/Header/Header';
import { NavSidebar } from '../../components/NavSidebar/NavSidebar';

import {
    UserProfile,
    UserLocations,
    UserEmails,
    UserPassword,
    UserBilling
} from '../../components/UserAccount';

import { userActions } from '../../actions/user.actions';

import './UserAccount.scss';

export class UserAccount extends Component {
    constructor(props) {
        super(props);

        this.state = {
            activeLink: 'profile'
        };

        this.toggleActiveClass = this.toggleActiveClass.bind(this);
        this.getLocations = this.getLocations.bind(this);
        this.destroyLocation = this.destroyLocation.bind(this);
    }

    toggleActiveClass(key) {
        this.setState({ activeLink: key });
    }

    getLocations() {
        const { dispatch, user } = this.props;
        dispatch(userActions.getLocations(user.data.id));
    }

    destroyLocation(locationId) {
        const { dispatch, user } = this.props;
        dispatch(userActions.destroyLocation(user.data.id, locationId));
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
                viewComponent = (
                    <UserLocations
                        locations={this.props.users.items}
                        getLocations={this.getLocations}
                        destroyLocation={this.destroyLocation}
                    />
                );
                break;
            case 'locations':
                viewComponent = <UserLocations />;
                break;
            case 'emails':
                viewComponent = <UserEmails />;
                break;
            case 'password':
                viewComponent = <UserPassword />;
                break;
            case 'billing':
                viewComponent = <UserBilling />;
                break;
            default:
                viewComponent = <UserProfile />;
                break;
        }

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center">
                <Header theme={this.props.theme} />

                <div
                    className={`${defs.content_width} layout-row flex-none ${
                        defs.spacing_md_top
                    } ${defs.spacing_md_bottom}`}
                >
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
    const { authentication, tenant, shipment, users } = state;
    const { user, loggedIn } = authentication;
    return {
        users,
        user,
        tenant,
        loggedIn,
        shipment
    };
}

export default withRouter(connect(mapStateToProps)(UserAccount));
