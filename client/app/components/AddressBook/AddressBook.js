import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './AddressBook.scss';
import { v4 } from 'node-uuid';
import { RoundButton } from '../RoundButton/RoundButton';
import { ContactCard } from '../ContactCard/ContactCard';
import defs from '../../styles/default_classes.scss';
import { Tooltip } from '../Tooltip/Tooltip';
import { capitalize } from '../../helpers/stringTools';
import { ShipmentContactBox } from '../ShipmentContactBox/ShipmentContactBox';

export class AddressBook extends Component {
    constructor(props) {
        super(props);

        this.state = {
            contactType: 'shipper',
            contact: {},
            setShipper: true,
            setConsignee: false,
            setNotifyees: false,
            notifyees: []
        };
        this.contactTypes = ['shipper', 'consignee', 'notifyee'];
        this.setContact = this.setContact.bind(this);
        this.toggleNotifyees = this.toggleNotifyees.bind(this);
    }

    toggleNotifyees(id) {
        this.setState({
            selectedNotifyees: {
                ...this.state.selectedNotifyees,
                [id]: !this.state.selectedNotifyees[id]
            }
        });
    }

    setContact(type, val) {
        this.props.setDetails(type, val);
        let newState;
        switch (type) {
            case 'shipper':
                newState = {
                    setShipper: false,
                    contact: val,
                    setConsignee: true,
                };
                break;
            case 'consignee':
                newState = {
                    setShipper: false,
                    contact: val,
                    setConsignee: false,
                    setNotifyees: true
                };
                break;
            case 'notifyee':
                const notifyees = this.state.notifyees;
                notifyees.push(val);
                newState = {
                    setShipper: false,
                    notifyees: notifyees,
                    setConsignee: false,
                    setNotifyees: true
                };
                break;
            default:
                break;
        }
        const contactTypeIndex = Math.min(
            this.contactTypes.indexOf(type) + 1,
            this.contactTypes.length - 1
        );
        newState.contactType = this.contactTypes[contactTypeIndex];
        this.setState(newState);
    }

    availableContacts(contacts) {
        return contacts.filter(
            c =>
                this.state.shipper !== c &&
                this.state.consignee !== c &&
                this.state.notifyees.indexOf(c) === -1
        );
    }

    render() {
        const { contacts, userLocations, theme } = this.props;
        const { notifyees, contact, contactType } = this.state;
        const shipperOptions = [...userLocations, ...contacts];
        const contactsArray = [];
        const shipperArray = [];
        const notifyeeArray = [];
        const noteArr = [];

        if (contacts) {
            this.availableContacts(contacts).forEach(c => {
                contactsArray.push(
                    <ContactCard
                        contactData={c}
                        theme={theme}
                        select={this.setContact}
                        key={v4()}
                        target="consignee"
                    />
                );
                notifyeeArray.push(
                    <ContactCard
                        contactData={c}
                        theme={theme}
                        key={v4()}
                        target="notifyee"
                        select={this.setContact}
                    />
                );
            });
        }

        if (shipperOptions) {
            shipperOptions.forEach(c => {
                shipperArray.push(
                    <ContactCard
                        contactData={c}
                        theme={theme}
                        select={this.setContact}
                        key={v4()}
                        target="shipper"
                    />
                );
            });
        }

        if (notifyees.length > 0) {
            notifyees.forEach((nt, i) => {
                noteArr.push(
                    <div
                        key={v4()}
                        className={`${styles.n_arr_elem} flex-45 ${
                            i % 2 !== 0 ? 'offset-10' : ''
                        }`}
                    >
                        <div
                            className={`${
                                styles.result_content
                            } flex-100 layout-row`}
                        >
                            <p className="flex-50">{nt.contact.first_name} </p>
                            <p className="flex-50">{nt.contact.last_name} </p>
                        </div>
                    </div>
                );
            });
        }
        if (notifyees.length < 2) {
            for (let i = notifyees.length; i < 2; i++) {
                noteArr.push(
                    <div
                        key={v4()}
                        className={`${styles.n_arr_elem} flex-45 ${
                            i % 2 !== 0 ? 'offset-10' : ''
                        }`}
                    >
                        <div
                            className={`${
                                styles.result_content
                            } flex-100 layout-row`}
                        >
                            <p className="flex-50"> </p>
                            <p className="flex-50"> </p>
                        </div>
                    </div>
                );
            }
        }

        return (
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div
                    className={`flex-none ${defs.content_width} layout-row layout-wrap`}
                >
                    <div className="flex-100 layout-row layout-align-center-center">
                        <h1> Set {capitalize(contactType)} Details</h1>
                        <Tooltip theme={theme} icon="fa-info-circle" text={contactType} />
                    </div>
                    <div className="flex-50">
                        <ShipmentContactBox
                            contact={contact}
                            theme={theme}
                        />
                    </div>

                    <div
                        className={`${
                            styles.contact_scroll
                        } flex-50 layout-row layout-wrap layout-align-center-start`}
                    >
                        {this.state.setShipper ? shipperArray : ''}
                        {this.state.setConsignee ? contactsArray : ''}
                        {this.state.setNotifyees ? notifyeeArray : ''}
                    </div>

                    <div className="flex-100 layout-row layout-align-center-center">
                        <div
                            className={`${
                                defs.content_width
                            } layout-row layout-align-end-center ${
                                defs.button_padding
                            }`}
                        >
                            <RoundButton
                                active
                                handleNext={this.props.closeAddressBook}
                                theme={theme}
                                text="Done"
                            />
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

AddressBook.propTypes = {
    contacts: PropTypes.array,
    userLocations: PropTypes.array,
    theme: PropTypes.object,
    setDetails: PropTypes.func,
    closeAddressBook: PropTypes.func
};
