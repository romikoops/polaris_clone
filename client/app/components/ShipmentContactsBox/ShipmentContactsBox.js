import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ShipmentContactsBox.scss';
import { v4 } from 'node-uuid';
// import { RoundButton } from '../RoundButton/RoundButton';
import defs from '../../styles/default_classes.scss';
import { ContactCard } from '../ContactCard/ContactCard';
import { capitalize } from '../../helpers/stringTools';


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
        const textStyle = {
            background:
                theme && theme.colors
                    ? '-webkit-linear-gradient(left, ' +
                      theme.colors.primary +
                      ',' +
                      theme.colors.secondary +
                      ')'
                    : 'black'
        };
        const placeholderCard = (type, i) => (
            <div
                className={`
                    layout-column flex-align-center-center ${styles.placeholder_card}
                    ${finishBookingAttempted && type !== 'notifyee' ? styles.with_errors : ''}
                `}
                onClick={() => this.setContactForEdit(Object.assign({}, this.newContactData), type, i)}
            >
                <h1>{ type === 'notifyee' ? 'Add' : 'Set' } { capitalize(type) }</h1>
            </div>
        );
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
