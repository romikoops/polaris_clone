import React, { Component } from 'react';
import PropTypes from 'prop-types';
import defs from '../../styles/default_classes.scss';
import { withRouter } from 'react-router-dom';
import { connect } from 'react-redux';
import Header from '../../components/Header/Header';
import { NavSidebar } from '../../components/NavSidebar/NavSidebar';
import { bindActionCreators } from 'redux';
import { Switch, Route } from 'react-router-dom';
import {
    UserProfile,
    UserDashboard,
    UserShipments,
    UserShipmentView,
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
        this.makePrimary = this.makePrimary.bind(this);
        this.setUrl = this.setUrl.bind(this);
    }
    componentDidUpdate() {
        const {userDispatch, users, user} = this.props;
        if (user && user.data && users && !users.loading && !users.hubs) {
            userDispatch.getHubs(user.data.id);
        }
        if (user && user.data && users && !users.loading && !users.shipments) {
            userDispatch.getShipments(user.data.id);
        }
    }

    toggleActiveClass(key) {
        this.setState({ activeLink: key });
    }

    getLocations() {
        const { userDispatch, user } = this.props;
        userDispatch.getLocations(user.data.id);
    }

    destroyLocation(locationId) {
        const { userDispatch, user } = this.props;
        userDispatch.destroyLocation(user.data.id, locationId);
    }

    makePrimary(locationId) {
        const { userDispatch, user } = this.props;
        userDispatch.makePrimary(user.data.id, locationId);
    }
    setUrl(target) {
        console.log(target);
        const {userDispatch, user} = this.props;
        switch(target) {
            case 'pricing':
                this.setState({activeLink: target});
                userDispatch.getPricings(user.data.id, true);
                break;
            case 'shipments':
                this.setState({activeLink: target});
                userDispatch.getShipments(user.data.id, true);
                break;
            case 'clients':
                this.setState({activeLink: target});
                userDispatch.getClients(user.data.id, true);
                break;
            case 'dashboard':
                this.setState({activeLink: target});
                userDispatch.getDashboard(user.data.id, true);
                break;
            case 'locations':
                this.setState({activeLink: target});
                userDispatch.getLocations(user.data.id, true);
                break;
            case 'profile':
                this.setState({activeLink: target});
                userDispatch.goTo('/account/profile');
                break;
            default:
                break;
        }
    }

    render() {
        const { user, theme, users, userDispatch } = this.props;
        const { shipments, hubs, shipment } = users;
        const navHeadlineInfo = 'Account Settings';
        const navLinkInfo = [
            { key: 'dashboard', text: 'Dashboard' },
            { key: 'profile', text: 'Profile' },
            { key: 'locations', text: 'Locations' },
            { key: 'emails', text: 'Emails' },
            { key: 'password', text: 'Password' },
            { key: 'billing', text: 'Billing' },
            { key: 'shipments', text: 'Shipments' }
        ];
        const hubHash = {};
        if (hubs) {
            hubs.forEach((hub) => {
                hubHash[hub.data.id] = hub;
            });
        }

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center">
                <Header theme={theme} />

                <div
                    className={`${defs.content_width} layout-row flex-none ${
                        defs.spacing_md_top
                    } ${defs.spacing_md_bottom}`}
                >
                    <div className="layout-row flex-20">
                        <NavSidebar
                            theme={theme}
                            navHeadlineInfo={navHeadlineInfo}
                            navLinkInfo={navLinkInfo}
                            toggleActiveClass={this.setUrl}
                            activeLink={this.state.activeLink}
                        />
                    </div>

                    <div className="layout-row flex-80">
                        <Switch className="flex">
                            <Route
                                exact
                                path="/account"
                                render={props => <UserDashboard theme={theme} {...props} user={user.data} hubs={hubHash} userDispatch={userDispatch} shipments={shipments}/>}
                            />
                            <Route

                                path="/account/locations"
                                render={props => <UserLocations theme={theme} {...props} locations={users.items}
                                    getLocations={this.getLocations}
                                    destroyLocation={this.destroyLocation}
                                    makePrimary={this.makePrimary} />}
                            />
                            <Route

                                path="/account/profile"
                                render={props => <UserProfile theme={theme} {...props} locations={users.items} />}
                            />
                            <Route
                                path="/account/emails"
                                render={props => <UserEmails theme={theme} user={user} {...props} />}
                            />
                            <Route

                                path="/account/password"
                                render={props => <UserPassword theme={theme} user={user} {...props} />}
                            />
                            <Route

                                path="/account/billing"
                                render={props => <UserBilling theme={theme} user={user} {...props} />}
                            />
                            <Route
                                exact
                                path="/account/shipments"
                                render={props => <UserShipments theme={theme} hubs={hubHash} user={user} {...props} shipments={shipments} userDispatch={userDispatch}/>}
                            />
                            <Route

                                path="/account/shipments/:id"
                                render={props => <UserShipmentView theme={theme} hubs={hubs} user={user} {...props} shipmentData={shipment} userDispatch={userDispatch}/>}
                            />

                        </Switch>
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
    shipments: PropTypes.array,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};


function mapStateToProps(state) {
    const { authentication, tenant, shipments, users } = state;
    const { user, loggedIn } = authentication;
    return {
        users,
        user,
        tenant,
        loggedIn,
        shipments
    };
}

function mapDispatchToProps(dispatch) {
    return {
        userDispatch: bindActionCreators(userActions, dispatch)
    };
}
export default withRouter(connect(mapStateToProps, mapDispatchToProps)(UserAccount));
