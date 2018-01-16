import React, { Component } from 'react';
import styles from './Footer.scss';
import defs from '../../styles/default_classes.scss';
import PropTypes from 'prop-types';
export class Footer extends Component {
    render() {
        const { theme, tenant } = this.props;
        const primaryColor = {
            color: theme && theme.colors ? theme.colors.primary : 'black'
        };
        let logo = theme && theme.logoLarge ? theme.logoLarge : '';
        if (!logo && theme && theme.logoSmall) logo = theme.logoSmall;
        const supportNumber = tenant && tenant.phones ? tenant.phones.support : '';
        const supportEmail = tenant && tenant.emails ? tenant.emails.support : '';
        const tenantName = tenant ? tenant.name : '';
        return (
            <div>
                <div className={`${styles.contact_bar} flex-100 layout-row layout-align-center-center`}>
                    <div className={`flex-none ${defs.content_width} layout-row`}>
                        <div className="flex-50 layout-row layout-align-start-center">
                            <img src={logo} />
                        </div>
                        <div className="flex-50 layout-row layout-align-end-end">
                            <a className={`flex-none layout-row layout-align-center-center pointy ${styles.contact_elem}`} href={`mailto:${supportEmail}`}>
                                <i className="fa fa-envelope" aria-hidden="true" style={primaryColor}></i>
                                {supportEmail}
                            </a>
                            <div className={`flex-none layout-row layout-align-center-end ${styles.contact_elem}`}>
                                <i className="fa fa-phone" aria-hidden="true" style={primaryColor}></i>
                                {supportNumber}
                            </div>
                        </div>
                    </div>
                </div>
                <div className={`${styles.footer} layout-row flex-100 layout-wrap`}>
                    <div className={`flex-100 ${styles.button_row} layout-row layout-align-end-center`}>
                        <div className={`flex-50 ${styles.buttons} layout-row layout-align-end-center`}>
                            <div className="flex-25 layout-row layout-align-center-center">
                                <a target="_blank" href="https://www.itsmycargo.com/en/ourstory">About Us</a>
                            </div>
                            <div className="flex-25 layout-row layout-align-center-center">
                                <a target="_blank" href="https://www.itsmycargo.com/en/privacy">Privacy Policy</a>
                            </div>
                            <div className="flex-25 layout-row layout-align-center-center">
                                <a target="_blank" href="https://www.itsmycargo.com/en/terms">Terms and Conditions</a>
                            </div>
                            <div className="flex-25 layout-row layout-align-center-center">
                                <a target="_blank" href="https://www.itsmycargo.com/en/contact">Impressum</a>
                            </div>
                        </div>
                        <div className="flex-20" />
                    </div>
                    <div className={`flex-100 layout-row ${styles.copyright}`}>
                        <div className="flex-80 layout-row layout-align-end-center">
                            <p className="flex-none">
                            Copyright © 2017 {tenantName}
                            </p>
                        </div>
                        <div className="flex-20" />
                    </div>
                </div>
            </div>
        );
    }
}
Footer.propTypes = {
    theme: PropTypes.object,
    tenant: PropTypes.object
};
