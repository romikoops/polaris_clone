import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import { Route } from 'react-router';
import { withRouter } from 'react-router-dom';
import { connect } from 'react-redux';
import Style from 'style-it';
import styles from './UserAccount.scss';
import Header from '../../components/Header/Header';

import './UserAccount.scss';

class UserAccount extends Component {
    constructor(props) {
        super(props);

        this.state = {
            whoIsActive: 'profile'
        };

        this.toggleActiveClass = this.toggleActiveClass.bind(this);
    }

    toggleActiveClass(key) {
        this.setState({ whoIsActive: key });
    }

    render() {
        const navLinks = [
            { profile: 'Profile' },
            { locations: 'Locations' },
            { emails: 'Emails' },
            { password: 'Password' },
            { billing: 'Billing' }
        ].map(op => {
            const navLinkKey = Object.keys(op)[0];

            return (
                <div
                    className={[
                        styles['menu-item'],
                        navLinkKey === this.state.whoIsActive ? 'active' : null
                    ].join(' ')}
                    onClick={() => this.toggleActiveClass(navLinkKey)}
                >
                    {op[navLinkKey]}
                </div>
            );
        });

        return (
            <div>
                <Style>
                    {`
                        .active::before {
                            position: absolute;
                            top: 0;
                            bottom: 0;
                            left: 0;
                            width: 2px;
                            content: '';
                            background-color: ${
                                this.props.theme.colors.primary
                            };
                         }
                    `}
                </Style>

                <div className="layout-row flex-100 layout-wrap layout-align-center">
                    <Header theme={this.props.theme} />

                    <div className="content-width layout-row flex-none">
                        <div className="layout-row flex-20 layout-align-start">
                            <nav className={styles.menu}>
                                <h3 className={styles['menu-heading']}>
                                    Account Settings
                                </h3>
                                {navLinks}
                            </nav>
                        </div>
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
