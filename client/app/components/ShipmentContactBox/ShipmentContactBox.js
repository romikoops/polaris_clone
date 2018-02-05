import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ShipmentContactBox.scss';
// import {v4} from 'node-uuid';
// import { RoundButton } from '../RoundButton/RoundButton';
import defs from '../../styles/default_classes.scss';
import GmapsWrapper from '../../hocs/GmapsWrapper';
import { PlaceSearch } from '../Maps/PlaceSearch';
import Formsy from 'formsy-react';
import FormsyInput from '../FormsyInput/FormsyInput';

export class ShipmentContactBox extends Component {
    constructor(props) {
        super(props);
        this.state = {
            contact: {
                location: {
                    number: '',
                    street: '',
                    zipCode: '',
                    city: '',
                    country: '',
                    fullAddress: ''
                }
            }
        };
        this.handleFormChange = this.handleFormChange.bind(this);
        this.handlePlaceChange = this.handlePlaceChange.bind(this);
    }

    handleFormChange(event) {
        this.props.handleChange(event);
    }
    handlePlaceChange(place) {
        const tmpAddress = {
            number: '',
            street: '',
            zipCode: '',
            city: '',
            country: '',
            fullAddress: ''
        };
        place.address_components.forEach(ac => {
            if (ac.types.includes('street_number')) {
                tmpAddress.number = ac.long_name;
            }

            if (ac.types.includes('route') || ac.types.includes('premise')) {
                tmpAddress.street = ac.long_name;
            }

            if (ac.types.includes('administrative_area_level_1') || ac.types.includes('locality')) {
                tmpAddress.city = ac.long_name;
            }

            if (ac.types.includes('postal_code')) {
                tmpAddress.zipCode = ac.long_name;
            }

            if (ac.types.includes('country')) {
                tmpAddress.country = ac.long_name;
            }
        });
        tmpAddress.latitude = place.geometry.location.lat();
        tmpAddress.longitude = place.geometry.location.lng();
        tmpAddress.fullAddress = place.formatted_address;
        tmpAddress.geocoded_address = place.formatted_address;
        this.setState({ contact: {
            location: tmpAddress
        }});
        this.setState({
            autocomplete: { ...this.state.autocomplete, location: true }
        });
    }
    render() {
        const { theme } = this.props;
        const { contact } = this.state;

        const { location } = this.state;
        console.log('location');
        console.log(location);
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
                    <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-start-start">
                        <Formsy
                            className={styles.login_form}
                            name="form"
                            onValidSubmit={this.handleSubmit}
                            onInvalidSubmit={this.handleInvalidSubmit}
                        >
                            <GmapsWrapper
                                theme={theme}
                                component={PlaceSearch}
                                handlePlaceChange={this.handlePlaceChange}
                                hideMap={true}
                            />
                            <FormsyInput className={styles.input_100}
                                type="text"
                                value={contact.companyName}
                                name="companyName"
                                placeholder="Company Name"
                                onChange={this.handleFormChange}
                            />
                            <FormsyInput
                                className={styles.input_50}
                                type="text"
                                value={contact.firstName}
                                name="firstName"
                                placeholder="First Name"
                                onChange={this.handleFormChange}
                            />
                            <FormsyInput
                                className={styles.input_50}
                                type="text"
                                value={contact.lastName}
                                name="lastName"
                                placeholder="Last Name"
                                onChange={this.handleFormChange}
                            />
                            <FormsyInput
                                className={styles.input_50}
                                type="text"
                                value={contact.email}
                                name="email"
                                placeholder="Email"
                                onChange={this.handleFormChange}
                            />
                            <FormsyInput
                                className={styles.input_50}
                                type="text"
                                value={contact.phone}
                                name="phone"
                                placeholder="Phone"
                                onChange={this.handleFormChange}
                            />
                            <FormsyInput
                                className={styles.input_street}
                                type="text"
                                value={contact.location.street}
                                name="street"
                                placeholder="Street"
                                onChange={this.handleFormChange}
                            />
                            <FormsyInput
                                className={styles.input_no}
                                type="text"
                                value={contact.location.number}
                                name="number"
                                placeholder="Number"
                                onChange={this.handleFormChange}
                            />
                            <FormsyInput
                                className={styles.input_zip}
                                type="text"
                                value={contact.location.zipCode}
                                name="zipCode"
                                placeholder="Postal Code"
                                onChange={this.handleFormChange}
                            />
                            <FormsyInput
                                className={styles.input_cc}
                                type="text"
                                value={contact.location.city}
                                name="city"
                                placeholder="City"
                                onChange={this.handleFormChange}
                            />
                            <FormsyInput
                                className={styles.input_cc}
                                type="text"
                                value={contact.location.country}
                                name="country"
                                placeholder="Country"
                                onChange={this.handleFormChange}
                            />
                        </Formsy>
                    </div>
                </div>
            </div>
        );
    }
}
ShipmentContactBox.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    user: PropTypes.object,
    handleChange: PropTypes.func,
    toggleAddressBook: PropTypes.func
};
