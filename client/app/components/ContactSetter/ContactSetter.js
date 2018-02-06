import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ContactSetter.scss';
import { RoundButton } from '../RoundButton/RoundButton';
import defs from '../../styles/default_classes.scss';
import { Tooltip } from '../Tooltip/Tooltip';
import { capitalize } from '../../helpers/stringTools';
import { ShipmentContactBox } from '../ShipmentContactBox/ShipmentContactBox';
import { AddressBook } from '../AddressBook/AddressBook';

export class ContactSetter extends Component {
  constructor(props) {
    super(props);

    this.newContactData = {
      type: 'shipper',
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
        country: ''
      }
    };

    this.state = {
    	contactData: this.newContactData,
      shipper: {},
      consignee: {},
      notifyees: []
    };
    this.contactTypes = ['shipper', 'consignee', 'notifyee'];
    this.autofillContact = this.autofillContact.bind(this);
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
  autofillContact(contactData) {
  	this.setState({
  		contactData: {
	  		...this.state.contactData,
	  		...contactData
  		}
  	});
  }

  setContact(contactData) {
  	const type = this.state.contactData.type;
    // this.props.setDetails(type, val);

    const newState = {
      contactData: Object.assign({}, this.newContactData)
    };

		if (type === 'notifyee') {
      const notifyees = this.state.notifyees;
      notifyees.push(contactData);
      newState.notifyees = notifyees;
		} else {
      newState[type] = contactData;
		}

    const contactTypeIndex = Math.min(
        this.contactTypes.indexOf(type) + 1,
        this.contactTypes.length - 1
    );
    newState.contactData.type = this.contactTypes[contactTypeIndex];

    this.setState(newState);
  }

  availableContacts() {
  	const { shipper, consignee, notifyees, contactData } = this.state;

  	const { userLocations } = this.props;
  	let { contacts } = this.props;
  	if (contactData.type === 'shipper') contacts = [...userLocations, ...contacts];

    return contacts.filter(contactData => (
      shipper !== contactData &&
      consignee !== contactData &&
      notifyees.indexOf(contactData) === -1
    ));
  }

  render() {
    const { theme } = this.props;
    const { contactData } = this.state;

    return (
      <div className={`
      	${styles.contact_setter} flex-100 layout-row layout-wrap layout-align-center-start
      `}>
        <div className={`
        	flex-none ${defs.content_width} layout-row layout-wrap
        `}>
          <div className="flex-100 layout-row layout-align-center-center">
            <h1> Set {capitalize(contactData.type)} Details</h1>
            <Tooltip theme={theme} icon="fa-info-circle" text={contactData.type} />
          </div>
          <div className="flex-50">
            <ShipmentContactBox
              contactData={contactData}
              theme={theme}
              setContact={this.setContact}
            />
          </div>

          <div className="flex-50">
						<AddressBook
							contacts={this.availableContacts()}
							autofillContact={this.autofillContact}
							theme={theme}
						/>
          </div>

          <div className="flex-100 layout-row layout-align-center-center">
            <div className={`
              ${defs.content_width} layout-row layout-align-end-center ${defs.button_padding}
           	`}>
              <RoundButton
                active
                handlxtSetter={this.props.SetCloseAddressBook}
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

ContactSetter.propTypes = {
    contacts: PropTypes.array,
    userLocations: PropTypes.array,
    theme: PropTypes.object,
    setDetails: PropTypes.func,
    SetCloseAddressBook: PropTypes.func
};
