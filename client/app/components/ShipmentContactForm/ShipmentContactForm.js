import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ShipmentContactForm.scss';
// import {v4} from 'node-uuid';
import { RoundButton } from '../RoundButton/RoundButton';
import defs from '../../styles/default_classes.scss';
import GmapsWrapper from '../../hocs/GmapsWrapper';
import { PlaceSearch } from '../Maps/PlaceSearch';
import Formsy from 'formsy-react';
import FormsyInput from '../FormsyInput/FormsyInput';

export class ShipmentContactForm extends Component {
    constructor(props) {
        super(props);
        this.state = {
            contactData: props.contactData
        };
        this.handleFormChange = this.handleFormChange.bind(this);
        this.handlePlaceChange = this.handlePlaceChange.bind(this);
        this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    componentWillReceiveProps(nextProps) {
        this.setState({
            contactData: nextProps.contactData
        });
    }

    handleFormChange(event) {
        this.props.handleChange(event);
    }
    handlePlaceChange(place) {
        const newLocation = {
            streetNumber: '',
            street: '',
            zipCode: '',
            city: '',
            country: '',
            fullAddress: ''
        };
        place.address_components.forEach(ac => {
            if (ac.types.includes('street_number')) {
                newLocation.streetNumber = ac.long_name;
            }

            if (ac.types.includes('route') || ac.types.includes('premise')) {
                newLocation.street = ac.long_name;
            }

            if (ac.types.includes('administrative_area_level_1') || ac.types.includes('locality')) {
                newLocation.city = ac.long_name;
            }

            if (ac.types.includes('postal_code')) {
                newLocation.zipCode = ac.long_name;
            }

            if (ac.types.includes('country')) {
                newLocation.country = ac.long_name;
            }
        });
        newLocation.latitude = place.geometry.location.lat();
        newLocation.longitude = place.geometry.location.lng();
        newLocation.fullAddress = place.formatted_address;
        newLocation.geocoded_address = place.formatted_address;
        this.setState({
            contactData: { ...this.state.contactData, location: newLocation }
        });
        this.setState({
            autocomplete: { ...this.state.autocomplete, location: true }
        });
    }
    handleSubmit(contactData) {
        this.props.setContact(contactData);
        this.refs.contactForm.reset();
    }
    handleInvalidSubmit() {
        console.log('invalid');
    }
    mapInputs(inputs) {
        const location = {};
        const contact = {};

        for(const k of Object.keys(inputs)) {
            if (k.split('-')[0] === 'location') {
                location[k.split('-')[1]] = inputs[k];
            } else {
                contact[k] = inputs[k];
            }
        }

        return { location, contact };
    }
    render() {
        const { theme } = this.props;
        const { contactData } = this.state;

        return (
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
                    <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-start-start">
                        <Formsy
                            className={styles.login_form}
                            name="form"
                            onValidSubmit={this.handleSubmit}
                            onInvalidSubmit={this.handleInvalidSubmit}
                            mapping={this.mapInputs}
                            ref="contactForm"
                        >
                            <GmapsWrapper
                                theme={theme}
                                component={PlaceSearch}
                                handlePlaceChange={this.handlePlaceChange}
                                hideMap={true}
                            />
                            <FormsyInput className={styles.input_100}
                                type="text"
                                value={contactData.contact.companyName}
                                name="companyName"
                                placeholder="Company Name"
                            />
                            <FormsyInput
                                className={styles.input_50}
                                type="text"
                                value={contactData.contact.firstName}
                                name="firstName"
                                placeholder="First Name"
                            />
                            <FormsyInput
                                className={styles.input_50}
                                type="text"
                                value={contactData.contact.lastName}
                                name="lastName"
                                placeholder="Last Name"
                            />
                            <FormsyInput
                                className={styles.input_50}
                                type="text"
                                value={contactData.contact.email}
                                name="email"
                                placeholder="Email"
                            />
                            <FormsyInput
                                className={styles.input_50}
                                type="text"
                                value={contactData.contact.phone}
                                name="phone"
                                placeholder="Phone"
                            />
                            <FormsyInput
                                className={styles.input_street}
                                type="text"
                                value={contactData.location.street}
                                name="location-street"
                                placeholder="Street"
                            />
                            <FormsyInput
                                className={styles.input_no}
                                type="text"
                                value={contactData.location.streetNumber}
                                name="location-streetNumber"
                                placeholder="Number"
                            />
                            <FormsyInput
                                className={styles.input_zip}
                                type="text"
                                value={contactData.location.zipCode}
                                name="location-zipCode"
                                placeholder="Postal Code"
                            />
                            <FormsyInput
                                className={styles.input_cc}
                                type="text"
                                value={contactData.location.city}
                                name="location-city"
                                placeholder="City"
                            />
                            <FormsyInput
                                className={styles.input_cc}
                                type="text"
                                value={contactData.location.country}
                                name="location-country"
                                placeholder="Country"
                            />
                            <RoundButton
                                text={`Set ${contactData.type}`}
                                theme={theme}
                                size="small"
                                active
                            />
                        </Formsy>
                    </div>
                </div>
            </div>
        );
    }
}
ShipmentContactForm.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    user: PropTypes.object,
    handleChange: PropTypes.func,
    toggleAddressBook: PropTypes.func
};
