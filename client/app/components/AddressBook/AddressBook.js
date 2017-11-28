import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './AddressBook.scss';
import { v4 } from 'node-uuid';
// import { Checkbox } from '../Checkbox/Checkbox';
import { RoundButton } from '../RoundButton/RoundButton';
import { ContactCard } from '../ContactCard/ContactCard';

export class AddressBook extends Component {
    constructor(props) {
        super(props);

        this.state = {
            setShipper: true,
            setConsignee: false,
            setNotifyees: false,
            selectedNotifyees: {}
        };
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
        switch (type) {
            case 'shipper':
                this.setState({
                    setShipper: false,
                    shipper: val,
                    setConsignee: true
                });
                break;
            case 'consignee':
                this.setState({
                    setShipper: false,
                    consignee: val,
                    setConsignee: false,
                    setNotifyees: true
                });
                break;
            default:
                break;
        }
    }

    render() {
        const { contacts, userLocations, theme } = this.props;
        const shipperOptions = [...userLocations, ...contacts];
        const contactsArray = [];
        const shipperArray = [];
        const notifyeeArray = [];
        if (contacts) {
            contacts.forEach(c => {
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
                        toggleSelect={this.toggleNotifyees}
                        list
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
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div className="flex-none content-width layout-row layout-wrap">
                    <div className="flex-50 layout-row layout-wrap layout-align-start-start">
                        <div
                            className={` ${
                                styles.prompt
                            } flex-100 layout-row layout-align-start-center`}
                        >
                            {this.state.setShipper ? (
                                <h1> Set Shipper Details</h1>
                            ) : (
                                ''
                            )}
                            {this.state.setConsignee ? (
                                <h1> Set Consignee Details</h1>
                            ) : (
                                ''
                            )}
                            {this.state.setNotifyees ? (
                                <h1> Set Notifyees Details</h1>
                            ) : (
                                ''
                            )}
                        </div>
                        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                            <div className="flex-80 layout-row">
                                {this.state.shipper ? (
                                    <ContactCard
                                        contactData={this.state.shipper}
                                        theme={theme}
                                        key={v4()}
                                    />
                                ) : (
                                    ''
                                )}
                            </div>
                            <div className="flex-80 layout-row">
                                {this.state.consignee ? (
                                    <ContactCard
                                        contactData={this.state.consignee}
                                        theme={theme}
                                        key={v4()}
                                    />
                                ) : (
                                    ''
                                )}
                            </div>
                        </div>
                    </div>
                    <div
                        className={`${
                            styles.contact_scroll
                        } flex-50 layout-row layout-wrap`}
                    >
                        {this.state.setShipper ? shipperArray : ''}
                        {this.state.setConsignee ? contactsArray : ''}
                        {this.state.setNotifyees ? notifyeeArray : ''}
                    </div>
                    <div className="flex-100 layout-row layout-align-center-center">
                        <div className="content-width layout-row layout-align-end-center button_padding">
                            <RoundButton
                                active
                                handleNext={this.closeAddressBook}
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

AddressBook.PropTypes = {
    contacts: PropTypes.array,
    userLocations: PropTypes.array,
    theme: PropTypes.object,
    setDetails: PropTypes.func,
    closeAddressBook: PropTypes.func
};
