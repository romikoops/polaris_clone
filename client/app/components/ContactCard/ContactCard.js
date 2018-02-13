import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ContactCard.scss';
import { v4 } from 'node-uuid';
import Truncate from 'react-truncate';
import { gradientTextGenerator } from '../../helpers';
export class ContactCard extends Component {
    constructor(props) {
        super(props);
        this.selectContact = this.selectContact.bind(this);
    }
    selectContact() {
        this.props.select(this.props.contactData, this.props.contactType);
    }
    render() {
        const { contactData, theme, removeFunc, popOutHover } = this.props;
        const { contact, location } = contactData;
        const iconStyle = {
            ...gradientTextGenerator(theme.colors.primary, theme.colors.secondary),
            width: '28px',
            padding: '3px 0'
        };

        const removeIcon = typeof removeFunc === 'function' ? (
            <i className={`${styles.remove_icon} fa fa-times`} onClick={removeFunc}></i>
        ) : '';
        return (
            <div
                key={v4()}
                className={`flex-100 layout-row ${styles.contact_card} ${popOutHover ? styles.pop_out_hover : ''}`}
                onClick={this.selectContact}
            >
                {removeIcon}
                <div className="flex layout-row layout-wrap">
                    <div className="flex-100 layout-row layout-align-space-between-center">
                        <div className="flex-60 layout-row layout-align-start-start layout-wrap">
                            <div className="flex-100 layout-row alyout-align-start-center">
                                <i
                                    className="fa fa-user-circle-o flex-none"
                                    style={iconStyle}
                                />
                                <p className={`flex ${styles.contact_header}`}>
                                    {contact.firstName} {contact.lastName}
                                </p>
                            </div>
                        </div>
                        <div
                            className={`flex-40 layout-row layout-wrap layout-align-start-center ${
                                styles.contact_details
                            }`}
                        >
                            <div className="flex-100 layout-row layout-align-start-center">
                                <i
                                    className="fa fa-envelope flex-none"
                                    style={iconStyle}
                                />
                                <p className="flex-none"> {contact.email} </p>
                            </div>
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-align-space-between-center">
                        <div className="flex-60 layout-row layout-align-start-start layout-wrap">
                            <div className="flex-100 layout-row alyout-align-start-center">
                                <i
                                    className="fa fa-building-o flex-none"
                                    style={iconStyle}
                                />
                                <p className={`flex ${styles.contact_header}`}>
                                    <Truncate lines={1} >{contact.companyName} </Truncate>
                                </p>
                            </div>
                        </div>
                        <div
                            className={`flex-40 layout-row layout-wrap layout-align-start-center ${
                                styles.contact_details
                            }`}
                        >
                             <div className="flex-100 layout-row layout-align-start-center">
                                <i
                                    className="fa fa-phone flex-none"
                                    style={iconStyle}
                                />
                                <p className="flex-none"> {contact.phone} </p>
                            </div>
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-center">
                        <i
                            className="fa fa-globe flex-none"
                            style={iconStyle}
                        />
                        <p className="flex-100">
                            { location && location.geocodedAddress || location.fullAddress}
                        </p>
                    </div>
                </div>
            </div>
        );
    }
}

ContactCard.propTypes = {
    contactData: PropTypes.object,
    theme: PropTypes.object,
    select: PropTypes.func,
    contactType: PropTypes.string,
    removeFunc: PropTypes.func,
    popOutHover: PropTypes.bool
};

ContactCard.defaultProps = {
    contactType: '',
    removeFunc: null,
    popOutHover: false
};
