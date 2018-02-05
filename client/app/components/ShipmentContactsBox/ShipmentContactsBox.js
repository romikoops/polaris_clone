import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ShipmentContactsBox.scss';
// import {v4} from 'node-uuid';
// import { RoundButton } from '../RoundButton/RoundButton';
import defs from '../../styles/default_classes.scss';
import GmapsWrapper from '../../hocs/GmapsWrapper';
import { PlaceSearch } from '../Maps/PlaceSearch';

export class ShipmentContactsBox extends Component {
    constructor(props) {
        super(props);
        this.state = {
            location: {
                number: '',
                street: '',
                zipCode: '',
                city: '',
                country: '',
                fullAddress: ''
            }
        };
        this.handleFormChange = this.handleFormChange.bind(this);
        this.handleNotifyeeChange = this.handleNotifyeeChange.bind(this);
        this.addNotifyee = this.addNotifyee.bind(this);
        this.removeNotifyee = this.removeNotifyee.bind(this);
        this.handlePlaceChange = this.handlePlaceChange.bind(this);
    }

    handleFormChange(event) {
        this.props.handleChange(event);
    }
    handleNotifyeeChange(event) {
        this.props.handleNotifyeeChange(event);
    }
    addNotifyee() {
        this.props.addNotifyee();
    }
    removeNotifyee(not) {
        this.props.removeNotifyee(not);
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
        // ;
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
        this.setState({ location: tmpAddress });
        this.setState({
            autocomplete: { ...this.state.autocomplete, location: true }
        });
    }
    render() {
        const { consignee, shipper, notifyees, theme } = this.props;
        let notifyeesArray;
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
        const addressBtn = (
            <div className={`flex-none layout-row layout-align-center-center ${styles.icon_btn}`} onClick={this.props.toggleAddressBook}>
                <i className="flex-none fa fa-address-book clip" style={textStyle}></i>
            </div>
        );
        if (notifyees) {
            // debugger;
            notifyeesArray = notifyees.map((n, i) => {
                return (
                    <div
                        key={'notifyee' + i}
                        className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-start-start"
                    >
                        <div className={` ${styles.contact_header} flex-100 layout-row layout-align-space-between-center`}>
                            <div className="flex-75 layout-row layout-align-start-center">
                                <p className="flex-none">Notifyee {i + 1}</p>
                            </div>
                            <div className="flex-25 layout-row layout-align-center-center">
                                { addressBtn }
                            </div>
                        </div>
                        <input
                            className={styles.input_100}
                            type="text"
                            value={n.companyName}
                            name={'notifyees-' + i + '-companyName'}
                            placeholder="Company Name"
                            onChange={(ev) => this.handleNotifyeeChange(ev)}
                        />
                        <input
                            className={styles.input_50}
                            type="text"
                            value={n.firstName}
                            name={'notifyees-' + i + '-firstName'}
                            placeholder="First Name"
                            onChange={(ev) => this.handleNotifyeeChange(ev)}
                        />
                        <input
                            className={styles.input_50}
                            type="text"
                            value={n.lastName}
                            name={'notifyees-' + i + '-lastName'}
                            placeholder="Last Name"
                            onChange={(ev) => this.handleNotifyeeChange(ev)}
                        />
                        <input
                            className={styles.input_50}
                            type="text"
                            value={n.email}
                            name={'notifyees-' + i + '-email'}
                            placeholder="Email"
                            onChange={(ev) => this.handleNotifyeeChange(ev)}
                        />
                        <div className="flex-50 layout-row layout-align-end-center" onClick={() => this.removeNotifyee(n)}>
                            <p className="flex-none">Remove</p>
                            <div className="flex-5"></div>
                            <i className="flex-none fa fa-trash clip" style={textStyle}></i>
                        </div>
                    </div>
                );
            });
        }
        const { location } = this.state;
        console.log('location');
        console.log(location);
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
                    <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-start-start">
                        <div className={` ${styles.contact_header} flex-100 layout-row layout-align-start-center`}>
                            <div className="flex-75 layout-row layout-align-start-center">
                                <i className="fa fa-user flex-none" style={textStyle}></i>
                                <p className="flex-none">Shipper</p>
                            </div>
                            <div className="flex-25 layout-row layout-align-center-center">
                                { addressBtn }
                            </div>
                        </div>
                        <GmapsWrapper
                            theme={theme}
                            component={PlaceSearch}
                            handlePlaceChange={this.handlePlaceChange}
                            hideMap={true}
                        />
                        <input className={styles.input_100} type="text" value={shipper.companyName} name={'shipper-companyName'} placeholder="Company Name" onChange={this.handleFormChange} />
                        <input className={styles.input_50} type="text" value={shipper.firstName} name="shipper-firstName" placeholder="First Name" onChange={this.handleFormChange} />
                        <input className={styles.input_50} type="text" value={shipper.lastName} name="shipper-lastName" placeholder="Last Name" onChange={this.handleFormChange} />
                        <input className={styles.input_50} type="text" value={shipper.email} name="shipper-email" placeholder="Email" onChange={this.handleFormChange} />
                        <input className={styles.input_50} type="text" value={shipper.phone} name="shipper-phone" placeholder="Phone" onChange={this.handleFormChange} />
                        <input className={styles.input_street} type="text" value={location.street} name="shipper-street" placeholder="Street" onChange={this.handleFormChange} />
                        <input className={styles.input_no} type="text" value={location.number} name="shipper-number" placeholder="Number" onChange={this.handleFormChange} />
                        <input className={styles.input_zip} type="text" value={location.zipCode} name="shipper-zipCode" placeholder="Postal Code" onChange={this.handleFormChange} />
                        <input className={styles.input_cc} type="text" value={location.city} name="shipper-city" placeholder="City" onChange={this.handleFormChange} />
                        <input className={styles.input_cc} type="text" value={location.country} name="shipper-country" placeholder="Country" onChange={this.handleFormChange} />
                    </div>


                    <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-start-start">
                        <div
                            className={` ${
                                styles.contact_header
                            } flex-100 layout-row layout-align-space-between-center`}
                        >
                            <div className="flex-75 layout-row layout-align-start-center">
                                <i
                                    className="fa fa-envelope-open-o flex-none"
                                    style={textStyle}
                                />
                                <p className="flex-none"> Consignee</p>
                            </div>
                            <div className="flex-25 layout-row layout-align-center-center">
                                { addressBtn }
                            </div>
                        </div>
                        <input
                            className={styles.input_100}
                            type="text"
                            value={consignee.companyName}
                            name={'consignee-companyName'}
                            placeholder="Company Name"
                            onChange={this.handleFormChange}
                        />
                        <input
                            className={styles.input_50}
                            type="text"
                            value={consignee.firstName}
                            name="consignee-firstName"
                            placeholder="First Name"
                            onChange={this.handleFormChange}
                        />
                        <input
                            className={styles.input_50}
                            type="text"
                            value={consignee.lastName}
                            name="consignee-lastName"
                            placeholder="Last Name"
                            onChange={this.handleFormChange}
                        />
                        <input
                            className={styles.input_50}
                            type="text"
                            value={consignee.email}
                            name="consignee-email"
                            placeholder="Email"
                            onChange={this.handleFormChange}
                        />
                        <input
                            className={styles.input_50}
                            type="text"
                            value={consignee.phone}
                            name="consignee-phone"
                            placeholder="Phone"
                            onChange={this.handleFormChange}
                        />
                        <input
                            className={styles.input_street}
                            type="text"
                            value={consignee.street}
                            name="consignee-street"
                            placeholder="Street"
                            onChange={this.handleFormChange}
                        />
                        <input
                            className={styles.input_no}
                            type="text"
                            value={consignee.number}
                            name="consignee-number"
                            placeholder="Number"
                            onChange={this.handleFormChange}
                        />
                        <input
                            className={styles.input_zip}
                            type="text"
                            value={consignee.zipCode}
                            name="consignee-zipCode"
                            placeholder="Postal Code"
                            onChange={this.handleFormChange}
                        />
                        <input
                            className={styles.input_cc}
                            type="text"
                            value={consignee.city}
                            name="consignee-city"
                            placeholder="City"
                            onChange={this.handleFormChange}
                        />
                        <input
                            className={styles.input_cc}
                            type="text"
                            value={consignee.country}
                            name="consignee-country"
                            placeholder="Country"
                            onChange={this.handleFormChange}
                        />
                    </div>
                    <div className="flex-100 layout-row layout-wrap">
                        <div className="flex-100 layout-row layout-align-start-center">
                            <div
                                className={` ${
                                    styles.contact_header
                                } flex-50 layout-row layout-align-start-center`}
                            >
                                <i
                                    className="fa fa-users flex-none"
                                    style={textStyle}
                                />
                                <p className="flex-none"> Notifyees</p>
                            </div>
                            <div className="flex-50 layout-row layout-align-start-center">
                                <div
                                    className="flex-50 layout-row layout-align-start-center"
                                    onClick={this.addNotifyee}
                                >
                                    <i className="fa fa-plus flex-none" />
                                    <p className="flex-none">Add Notifyees</p>
                                </div>
                            </div>
                        </div>
                        {notifyeesArray}
                    </div>
                </div>
            </div>
        );
    }
}
ShipmentContactsBox.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    user: PropTypes.object,
    handleChange: PropTypes.func,
    handleNotifyeeChange: PropTypes.func,
    addNotifyee: PropTypes.func,
    toggleAddressBook: PropTypes.func
};
