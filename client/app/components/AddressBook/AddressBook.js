import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './AddressBook.scss';
import { v4 } from 'node-uuid';
import { RoundButton } from '../RoundButton/RoundButton';
import { ContactCard } from '../ContactCard/ContactCard';
import defs from '../../styles/default_classes.scss';

export class AddressBook extends Component {
    constructor(props) {
        super(props);

        this.state = {
            setShipper: true,
            setConsignee: false,
            setNotifyees: false,
            notifyees: []
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
            case 'notifyee':
                const notifyees = this.state.notifyees;
                notifyees.push(val);
                this.setState({
                    setShipper: false,
                    notifyees: notifyees,
                    setConsignee: false,
                    setNotifyees: true
                });
                break;
            default:
                break;
        }
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
        const { notifyees, shipper, consignee } = this.state;
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
                    className={`flex-none ${
                        defs.content_width
                    } layout-row layout-wrap`}
                >
                    <div className="flex-50">
                        <div
                            className={`${
                                styles.summary
                            } flex-90 layout-row layout-wrap layout-align-start-start`}
                        >
                            <div
                                className={`${
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
                                {shipper ? (
                                    <div
                                        className={`${
                                            styles.results
                                        } flex-100 layout-row layout-wrap`}
                                    >
                                        <div className="flex-100">
                                            <h4 className="title">
                                                {' '}
                                                Shipping from:
                                            </h4>
                                        </div>
                                        <div
                                            className={`${
                                                styles.result_content
                                            } flex-100 layout-row`}
                                        >
                                            <p className="flex-60 offset-5">
                                                {' '}
                                                {
                                                    shipper.contact.first_name
                                                }{' '}
                                                {shipper.contact.last_name}{' '}
                                            </p>
                                            <p className="flex-100 ">
                                                {' '}
                                                {
                                                    shipper.location
                                                        .geocoded_address
                                                }{' '}
                                            </p>
                                        </div>
                                    </div>
                                ) : (
                                    <div
                                        className={`${
                                            styles.results
                                        } flex-100 layout-row layout-wrap`}
                                    >
                                        <div className="flex-100">
                                            <h4 className="title">
                                                {' '}
                                                Shipping from:
                                            </h4>
                                        </div>
                                        <div
                                            className={`${
                                                styles.result_content
                                            } flex-100 layout-row`}
                                        >
                                            <p className="flex-60 offset-5">
                                                {' '}
                                            </p>
                                            <p className="flex-100 "> </p>
                                        </div>
                                    </div>
                                )}
                                {consignee ? (
                                    <div
                                        className={`${
                                            styles.results
                                        } flex-100 layout-row layout-wrap`}
                                    >
                                        <div className="flex-100">
                                            <h4 className="title">
                                                {' '}
                                                Consigned by:
                                            </h4>
                                        </div>
                                        <div
                                            className={`${
                                                styles.result_content
                                            } flex-100 layout-row`}
                                        >
                                            <p className="flex-60 offset-5">
                                                {' '}
                                                {
                                                    consignee.contact.first_name
                                                }{' '}
                                                {consignee.contact.last_name}{' '}
                                            </p>
                                            <p className="flex-100 ">
                                                {' '}
                                                {
                                                    consignee.location
                                                        .geocoded_address
                                                }{' '}
                                            </p>
                                        </div>
                                    </div>
                                ) : (
                                    <div
                                        className={`${
                                            styles.results
                                        } flex-100 layout-row layout-wrap`}
                                    >
                                        <div className="flex-100">
                                            <h4 className="title">
                                                {' '}
                                                Consigned by:
                                            </h4>
                                        </div>
                                        <div
                                            className={`${
                                                styles.result_content
                                            } flex-100 layout-row`}
                                        >
                                            <p className="flex-60 offset-5">
                                                {' '}
                                            </p>
                                            <p className="flex-100 "> </p>
                                        </div>
                                    </div>
                                )}
                                {
                                    <div
                                        className={`${
                                            styles.results
                                        } flex-100 layout-row layout-wrap`}
                                    >
                                        <div className="flex-100">
                                            <h4 className="title">
                                                {' '}
                                                Notifying:
                                            </h4>
                                        </div>
                                        {noteArr}
                                    </div>
                                }
                            </div>
                        </div>
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
