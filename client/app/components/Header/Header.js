import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { NavDropdown } from '../NavDropdown/NavDropdown';
import styles from './Header.scss';
import accountIcon from '../../assets/images/icons/person-dark.svg';
import defs from '../../styles/default_classes.scss';
import { Redirect } from 'react-router';
import { LoginPage } from '../../containers/LoginPage';
import { Modal } from '../Modal/Modal';


class Header extends Component {
    constructor(props) {
        super(props);
        this.state = {
            redirect: false,
            showLogin: false
        };
        this.goHome = this.goHome.bind(this);
        this.toggleShowLogin = this.toggleShowLogin.bind(this);
    }
    goHome() {
        this.setState({redirect: true});
    }
    toggleShowLogin() {
        this.setState({
            showLogin: !this.state.showLogin
        });
    }
    render() {
        const { user, theme } = this.props;
        const dropDownText = user && user.data ? user.data.first_name + ' ' + user.data.last_name : '';
        const dropDownImage = accountIcon;
        const accountLinks = [
            {
                url: '/account',
                text: 'Settings',
                fontAwesomeIcon: 'fa-cog',
                key: 'settings'
            },
            {
                url: '/signout',
                text: 'Sign out',
                fontAwesomeIcon: 'fa-sign-out',
                key: 'signOut'
            }
        ];
        if (this.state.redirect) {
            return <Redirect push to="/" />;
        }
        const dropDown = (
            <NavDropdown
                dropDownText={dropDownText}
                dropDownImage={dropDownImage}
                linkOptions={accountLinks}
            />
        );
        const loginPrompt = <a className={defs.pointy} onClick={this.toggleShowLogin}>Log in</a>;
        const rightCorner = user ? dropDown : loginPrompt;
        const loginModal = <Modal component={<LoginPage theme={theme}/>} parentToggle={this.toggleShowLogin} />;
        return (
            <div
                className={`${
                    styles.header
                } layout-row flex-100 layout-wrap layout-align-center`}
            >
                <div className={`${defs.content_width} layout-row flex-none`}>
                    <div className="layout-row flex-50 layout-align-start-center">
                        <img
                            src={theme ? theme.logoLarge : ''}
                            className={styles.logo}
                            alt=""
                            onClick={this.goHome}
                        />
                    </div>
                    <div className="layout-row flex-50 layout-align-end-center">
                        {rightCorner}
                    </div>
                </div>
                { this.state.showLogin ? loginModal : '' }
            </div>
        );
    }
}

Header.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    shipment: PropTypes.object,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
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

export default connect(mapStateToProps)(Header);
