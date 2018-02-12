import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './ContactSetter.scss';
import defs from '../../styles/default_classes.scss';
import { ShipmentContactForm } from '../ShipmentContactForm/ShipmentContactForm';
import { AddressBook } from '../AddressBook/AddressBook';
import { ShipmentContactsBox } from '../ShipmentContactsBox/ShipmentContactsBox';
import { StageTimeline } from '../StageTimeline/StageTimeline';


export class ContactSetter extends Component {
  constructor(props) {
    super(props);

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

    this.state = {
    	contactData: {
      	type: 'shipper',
    		...this.newContactData
    	}
    };
    this.contactTypes = ['shipper', 'consignee', 'notifyee'];
    this.stages = ['shipper', 'consignee', 'notifyees'];
    this.autofillContact = this.autofillContact.bind(this);
    this.setContact = this.setContact.bind(this);
    this.setStage = this.setStage.bind(this);
    this.setContactForEdit = this.setContactForEdit.bind(this);
  }

  setContactForEdit(contactData) {
  	this.setState({ contactData });
  }

  autofillContact(contactData) {
  	this.setState({
  		contactData: {
        ...this.state.contactData,
	  		contact: contactData.contact,
	  		location: contactData.location
  		}
  	});
  }

  setContact(contactData) {
  	const { type, index } = this.state.contactData;

    const newState = {
      contactData: Object.assign({}, this.newContactData)
    };

    let contactTypeIndex = this.contactTypes.indexOf(type) + 1;

    if (contactTypeIndex === 2) {
      newState.contactData.index = 0;
    } else if (contactTypeIndex > 2) {
      contactTypeIndex = 2;
      newState.contactData.index = index + 1;
    }

    this.props.setContact(contactData, type, index);

    newState.contactData.type = this.contactTypes[contactTypeIndex];
    this.setState(newState);
  }

  setStage(i) {
  	const contactType = this.contactTypes[i];
  	if (contactType === 'notifyee') {
			this.setState({
	  		contactData: {
          index: 0,
	  			type: this.contactTypes[i],
	  			...(this.props.notifyees[0] || Object.assign({}, this.newContactData))
	  		}
			});
  	} else {
			this.setState({
	  		contactData: {
	  			type: this.contactTypes[i],
	  			...this.props[this.contactTypes[i]]
	  		}
			});
  	}
  }

  availableContacts() {
  	const { contactData } = this.state;

  	const { userLocations, shipper, consignee, notifyees } = this.props;
  	let { contacts } = this.props;
  	if (contactData.type === 'shipper') contacts = [...userLocations, ...contacts];

    return contacts.filter(contactData => (
      shipper !== contactData &&
      consignee !== contactData &&
      notifyees.indexOf(contactData) === -1
    ));
  }

  render() {
    const { theme, shipper, consignee, notifyees } = this.props;
    const { contactData } = this.state;
    const stageIndex = this.contactTypes.indexOf(contactData.type);
    console.log('!!', contactData);
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        <div className={`
        	flex-none ${defs.content_width} layout-row layout-wrap
        `}>
	        <div className="flex-100 layout-row layout-align-center-center">
	          <h1> Set Contact Details</h1>
	        </div>

          <div className="flex-100 layout-row layout-align-center-center">
	          <StageTimeline
              theme={theme}
              currentStageIndex={stageIndex}
              stages={this.stages}
              setStage={this.setStage}
	          />
          </div>
          <div
          	className="flex-100 layout-row layout-align-center-center"
          	style={{ marginBottom: '50px', height: '493px', boxShadow: 'rgba(0, 0, 0, 0.05) 2px 2px 1px' }}
          >
	          <div className="flex-50" style={{height: '100%'}}>
	            <ShipmentContactForm
	              contactData={contactData}
	              theme={theme}
	              setContact={this.setContact}
	            />
	          </div>

	          <div className="flex-50" style={{ height: '100%' }}>
							<AddressBook
								contacts={this.availableContacts()}
								autofillContact={this.autofillContact}
								theme={theme}
							/>
	          </div>
          </div>
          <div className="flex-100 layout-row layout-align-center-center">
	          <ShipmentContactsBox
              consignee={consignee}
              shipper={shipper}
              notifyees={notifyees}
              theme={theme}
              removeNotifyee={this.props.removeNotifyee}
              setContactForEdit={this.setContactForEdit}
	          />
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
};
