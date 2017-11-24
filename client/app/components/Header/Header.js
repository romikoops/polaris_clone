import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { NavDropdown } from '../NavDropdown/NavDropdown';
import styles from './Header.scss';
import accountIcon from '../../assets/images/icons/person-dark.svg';

class Header extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const { user } = this.props;
        const dropDownText = user.data.first_name + ' ' + user.data.last_name;
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

        return (
            <div
                className={`${
                    styles.header
                } layout-row flex-100 layout-wrap layout-align-center`}
            >
                <div className="content-width layout-row flex-none">
                    <div className="layout-row flex-50 layout-align-start-center">
                        <img src={this.props.theme.logoLarge} className={styles.logo} alt="" />
                    </div>
                    <div className="layout-row flex-50 layout-align-end-center">
                        <NavDropdown
                            dropDownText={dropDownText}
                            dropDownImage={dropDownImage}
                            linkOptions={accountLinks}
                        />
                    </div>
                </div>
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
