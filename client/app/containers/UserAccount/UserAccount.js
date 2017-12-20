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
        const { user, theme, users } = this.props;
        const navHeadlineInfo = 'Account Settings';
        const navLinkInfo = [
            { key: 'profile', text: 'Profile' },
            { key: 'locations', text: 'Locations' },
            { key: 'emails', text: 'Emails' },
            { key: 'password', text: 'Password' },
            { key: 'billing', text: 'Billing' }
        ];

        // let viewComponent;
        // switch(this.state.activeLink) {
        //     case 'profile':
        //         viewComponent = (
        //             <UserLocations
        //                 theme={theme}
        //                 locations={users.items}
        //                 getLocations={this.getLocations}
        //                 destroyLocation={this.destroyLocation}
        //                 makePrimary={this.makePrimary}
        //             />
        //         );
        //         break;
        //     case 'locations':
        //         viewComponent = <UserLocations />;
        //         break;
        //     case 'emails':
        //         viewComponent = <UserEmails />;
        //         break;
        //     case 'password':
        //         viewComponent = <UserPassword />;
        //         break;
        //     case 'billing':
        //         viewComponent = <UserBilling />;
        //         break;
        //     default:
        //         viewComponent = <UserProfile />;
        //         break;
        // }

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
                            {/* <Route

                                path="/account/dashboard"
                                render={props => <UserDashboard theme={theme} {...props} clients={clients} dashData={dashboard}/>}
                            /> */}
                            <Route

                                path="/account/locations"
                                render={props => <UserLocations theme={theme} {...props} locations={users.items}
                                    getLocations={this.getLocations}
                                    destroyLocation={this.destroyLocation}
                                    makePrimary={this.makePrimary} />}
                            />
                            <Route
                                exact
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
