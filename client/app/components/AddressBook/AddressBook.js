import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './AddressBook.scss';
import { v4 } from 'node-uuid';
import { ContactCard } from '../ContactCard/ContactCard';

export class AddressBook extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const { theme, contacts, autofillContact } = this.props;

        const contactCards = contacts && contacts.map(contact => (
            <ContactCard
                contactData={contact}
                theme={theme}
                select={autofillContact}
                key={v4()}
                target={''}
            />
        ));

        return (
            <div className={`
                ${styles.contact_scroll} flex-100 layout-row layout-wrap layout-align-center-start
            `}>
                {contactCards}
            </div>
        );
    }
}

AddressBook.propTypes = {
    contacts: PropTypes.array,
    userLocations: PropTypes.array,
    theme: PropTypes.object,
    availableContacts: PropTypes.func
};
