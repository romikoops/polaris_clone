import React, { Component } from 'react';
import PropTypes from 'prop-types';
import defs from '../../styles/default_classes.scss';
import { withRouter } from 'react-router-dom';
import { connect } from 'react-redux';
import Header from '../../components/Header/Header';
import { NavSidebar } from '../../components/NavSidebar/NavSidebar';
import { FloatingMenu } from '../../components/FloatingMenu/FloatingMenu';
import { bindActionCreators } from 'redux';
import { Switch, Route } from 'react-router-dom';
import {
    UserProfile,
    UserDashboard,
    UserShipments,
    UserShipmentView,
    UserLocations,
    UserBilling
} from '../../components/UserAccount';
import UserContacts from '../../components/UserAccount/UserContacts';
import { userActions, authenticationActions } from '../../actions';
import { Modal } from '../../components/Modal/Modal';
import { AvailableRoutes } from '../../components/AvailableRoutes/AvailableRoutes';

// import styles from '../../components/UserAccount/UserAccount.scss';
import { Loading } from '../../components/Loading/Loading';


export class UserAccount extends Component {
    constructor(props) {
        super(props);

        this.state = {
            activeLink: 'profile',
            showModal: false
        };

        this.toggleActiveClass = this.toggleActiveClass.bind(this);
        this.getLocations = this.getLocations.bind(this);
        this.destroyLocation = this.destroyLocation.bind(this);
        this.makePrimary = this.makePrimary.bind(this);
        this.setUrl = this.setUrl.bind(this);
        this.setNavLink = this.setNavLink.bind(this);
        this.toggleModal = this.toggleModal.bind(this);
    }
    componentDidMount() {
        const {userDispatch, users, user} = this.props;
        if (user && user.data && users && !users.loading && !users.dashboard) {
            userDispatch.getDashboard(user.data.id, false);
        }
        if (user && user.data && users && !users.loading && !users.hubs) {
            userDispatch.getHubs(user.data.id);
        }
    }
    setNavLink(target) {
        const {userDispatch, users, user} = this.props;
        this.setState({activeLink: target});
        if (user && user.data && users && !users.loading && !users.dashboard) {
            userDispatch.getDashboard(user.data.id, false);
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

    toggleModal() {
        this.setState({ showModal: !this.state.showModal });
    }

    setUrl(target) {
        const {userDispatch, user} = this.props;
        switch(target) {
            case 'pricing':
                this.setState({activeLink: target});
                userDispatch.getPricings(user.data.id, true);
                break;
            case 'chooseRoutes':
                this.toggleModal();
                break;
            case 'shipments':
                this.setState({activeLink: target});
                userDispatch.getShipments(true);
                break;
            case 'contacts':
                this.setState({activeLink: target});
                userDispatch.goTo('/account/contacts');
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
        const { user, theme, users, userDispatch, authDispatch } = this.props;
        if (!users || !user) {
            return '';
        }
        const { shipments, hubs, shipment, dashboard, loading } = users;
        if (!dashboard) {
            return '';
        }
        const loadingScreen =  loading ? <Loading theme={theme} /> : '';
        const navHeadlineInfo = 'Account Settings';
        const navLinkInfo = [

            {
                icon: 'fa-tachometer',
                text: 'Dashboard',
                url: '/account/dashboard',
                target: 'dashboard'
            },
            {
                icon: 'fa-ship',
                text: 'Avail. Routes',
                url: '/chooseroute/chooseroute',
                target: 'chooseRoutes'
            },
            {
                icon: 'fa-ship',
                text: 'Shipments',
                url: '/account/shipments',
                target: 'shipments'
            },
            {
                icon: 'fa-user',
                text: 'Profile',
                url: '/account/profile',
                target: 'profile'
            },
            {
                icon: 'fa-address-card',
                text: 'Contacts',
                url: '/account/contacts',
                target: 'contacts'
            }
        ];

        const hubHash = {};
        if (hubs) {
            hubs.forEach((hub) => {
                hubHash[hub.data.id] = hub;
            });
        }
        const nav = (
            <NavSidebar
                theme={theme}
                navHeadlineInfo={navHeadlineInfo}
                navLinkInfo={navLinkInfo}
                toggleActiveClass={this.setUrl}
                activeLink={this.state.activeLink}
            />
        );

        const routeModal = (
            <Modal
                component={
                    <AvailableRoutes
                        user={ user }
                        theme={ theme }
                        routes={ dashboard.routes }
                        initialCompName="UserAccount"
                    />
                }
                width="48vw"
                verticalPadding="30px"
                horizontalPadding="15px"
                parentToggle={this.toggleModal}
            />
        );
        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center">
                <Header theme={theme} />
                {loadingScreen}
                {this.state.showModal ? routeModal : ''}
                <div
                    className={`${defs.content_width} layout-row flex-none ${
                        defs.spacing_md_top
                    } ${defs.spacing_md_bottom}`}
                >
                    <FloatingMenu Comp={nav} theme={theme}/>

                    <div className="layout-row flex-100 ">

                        <Switch className="flex">
                            <Route
                                exact
                                path="/account"
                                render={props => <UserDashboard setNav={this.setNavLink} theme={theme} {...props} user={user.data} hubs={hubHash} navFn={this.setUrl} userDispatch={userDispatch} dashboard={dashboard}/>}
                            />
                            <Route
                                path="/account/routesavailable"
                                render={props => <UserLocations setNav={this.setNavLink} theme={theme} {...props} locations={users.dashboard.locations}
                                    getLocations={this.getLocations}
                                    destroyLocation={this.destroyLocation}
                                    makePrimary={this.makePrimary} />}
                            />
                            <Route
                                path="/account/locations"
                                render={props => <UserLocations setNav={this.setNavLink} theme={theme} {...props} locations={users.dashboard.locations}
                                    getLocations={this.getLocations}
                                    destroyLocation={this.destroyLocation}
                                    makePrimary={this.makePrimary} />}
                            />
                            <Route
                                path="/account/profile"
                                render={props => <UserProfile setNav={this.setNavLink} theme={theme} user={user.data} aliases={dashboard.aliases} {...props} locations={dashboard.locations} userDispatch={userDispatch} authDispatch={authDispatch}/>}
                            />
                            <Route
                                path="/account/contacts"
                                render={props => <UserContacts setNav={this.setNavLink} theme={theme} user={user.data} aliases={dashboard.aliases} {...props} locations={dashboard.locations} userDispatch={userDispatch} authDispatch={authDispatch}/>}
                            />
                            <Route
                                path="/account/billing"
                                render={props => <UserBilling setNav={this.setNavLink} theme={theme} user={user} {...props} />}
                            />
                            <Route
                                exact
                                path="/account/shipments"
                                render={props => <UserShipments setNav={this.setNavLink} theme={theme} hubs={hubHash} user={user} {...props} shipments={shipments} userDispatch={userDispatch}/>}
                            />
                            <Route
                                path="/account/shipments/:id"
                                render={props => <UserShipmentView setNav={this.setNavLink} theme={theme} hubs={hubs} user={user} loading={loading} {...props} shipmentData={shipment} userDispatch={userDispatch}/>}
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
        userDispatch: bindActionCreators(userActions, dispatch),
        authDispatch: bindActionCreators(authenticationActions, dispatch)
    };
}
export default withRouter(connect(mapStateToProps, mapDispatchToProps)(UserAccount));
