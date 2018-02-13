import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ShipmentContactsBox.scss';
import { v4 } from 'node-uuid';
// import { RoundButton } from '../RoundButton/RoundButton';
import defs from '../../styles/default_classes.scss';
import errors from '../../styles/errors.scss';
import { ContactCard } from '../ContactCard/ContactCard';
import { capitalize } from '../../helpers/stringTools';
import { gradientTextGenerator } from '../../helpers';

export class ShipmentContactsBox extends Component {
    constructor(props) {
        super(props);
        this.state = {};
        this.newContactData = {
            contact: {
                companyName: '',
                firstName: '',
                lastName: '',
                email: '',
                phone: ''
            },
            location: {
                street: '',
                number: '',
                zipCode: '',
                city: '',
                country: '',
                gecodedAddress: ''
            }
        };
        this.setContactForEdit = this.setContactForEdit.bind(this);
    }

    setContactForEdit(contactData, contactType, contactIndex) {
        this.props.setContactForEdit({
            ...contactData,
            type: contactType,
            index: contactIndex
        });
    }
    render() {
        const { shipper, consignee, notifyees, theme, finishBookingAttempted } = this.props;
        const textStyle = theme ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : {color: 'black'};
        const placeholderCard = (type, i) => {
            const errorMessage = (
                <span
                    className={errors.error_message}
                    style={{ left: '15px', top: '14px', fontSize: '17px' }}
                >
                    * Required
                </span>
            );
            const showError = finishBookingAttempted && type !== 'notifyee';
            return (
                <div
                    className={`
                        layout-column flex-align-center-center ${styles.placeholder_card}
                        ${showError ? styles.with_errors : ''}
                    `}
                    onClick={() => this.setContactForEdit(Object.assign({}, this.newContactData), type, i)}
                >
                    <div className="flex-100 layout-row layout-align-center-center">
                        <i
                            className={`fa fa-${type === 'notifyee' ? 'plus' : 'mouse-pointer'}`}
                            style={{ fontSize: '30px' }}
                        ></i>
                    </div>
                    <h3>{ type === 'notifyee' ? 'Add' : 'Set' } { capitalize(type) }</h3>
                    { showError ? errorMessage : '' }
                </div>
            );
        };
        const notifyeeContacts = notifyees && notifyees.map((notifyee, i) => (
            <div className="flex-50">
                <div className={styles.contact_wrapper}>
                    <ContactCard
                        contactData={notifyee}
                        theme={theme}
                        select={() => this.setContactForEdit(notifyee, 'notifyee', i)}
                        key={v4()}
                        contactType="notifyee"
                        removeFunc={() => this.props.removeNotifyee(i)}
                    />
                </div>
            </div>
        ));
        notifyeeContacts.push(
            <div className="flex-50">
                <div className={styles.contact_wrapper}>
                    {placeholderCard('notifyee', notifyeeContacts.length)}
                </div>
            </div>
        );
        const shipperContact = shipper.contact ? (
            <ContactCard
                contactData={shipper}
                theme={theme}
                select={this.setContactForEdit}
                key={v4()}
                contactType="shipper"
            />
        ) : placeholderCard('shipper');
        const consigneeContact = consignee.contact ? (
            <ContactCard
                contactData={consignee}
                theme={theme}
                select={this.setContactForEdit}
                key={v4()}
                contactType="consignee"
            />
        ) : placeholderCard('consignee');
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
                    <div
                        className="flex-100 layout-row layout-wrap"
                        style={{ height: '185px' }}
                    >
                        <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-start-start">
                            <div className={`${styles.contact_header} flex-100 layout-row layout-align-start-center`}>
                                <div className="flex-75 layout-row layout-align-start-center">
                                    <i className="fa fa-user flex-none" style={textStyle}></i>
                                    <p className="flex-none">Shipper</p>
                                </div>
                            </div>
                            <div className={styles.contact_wrapper}>
                                {shipperContact}
                            </div>
                        </div>
                        <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-start-start">
                            <div className={`${styles.contact_header} flex-100 layout-row layout-align-start-center`}>
                                <div className="flex-75 layout-row layout-align-start-center">
                                    <i className="fa fa-user flex-none" style={textStyle}></i>
                                    <p className="flex-none">Consignee</p>
                                </div>
                            </div>
                            <div className={styles.contact_wrapper}>
                                {consigneeContact}
                            </div>
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-wrap">
                        <div className="flex-100 layout-row layout-align-start-center">
                            <div className={`
                                ${styles.contact_header} flex-50
                                layout-row layout-align-start-center
                            `}>
                                <i
                                    className="fa fa-users flex-none"
                                    style={textStyle}
                                />
                                <p className="flex-none"> Notifyees</p>
                            </div>
                        </div>
                        {notifyeeContacts}
                    </div>
                </div>
            </div>
        );
    }
}

ShipmentContactsBox.propTypes = {
    theme: PropTypes.object,
    shipper: PropTypes.object,
    consignee: PropTypes.object,
    notifyees: PropTypes.object,
    finishBookingAttempted: PropTypes.bool
};
