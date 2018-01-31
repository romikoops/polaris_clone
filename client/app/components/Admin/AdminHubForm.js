import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import GmapsWrapper from '../../hocs/GmapsWrapper';
import { PlaceSearch } from '../Maps/PlaceSearch';
import Select from 'react-select';
import '../../styles/select-css-custom.css';
import { RoundButton } from '../RoundButton/RoundButton';
import styled from 'styled-components';
export class AdminHubForm extends Component {
    constructor(props) {
        super(props);
        this.state = {
            location: {},
            hub: {
                name: '',
                hubType: '',
                truckingType: ''
            }
        };
        this.handlePlaceChange = this.handlePlaceChange.bind(this);
        this.handleAddressChange = this.handleAddressChange.bind(this);
        this.resetAuto = this.resetAuto.bind(this);
        this.saveNewHub = this.saveNewHub.bind(this);
        this.handleTruckingType = this.handleTruckingType.bind(this);
        this.handleHubType = this.handleHubType.bind(this);
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
    handleAddressChange(event) {
        const eventKeys = event.target.name.split('-');
        const key1 = eventKeys[0];
        const key2 = eventKeys[1];
        const val = event.target.value;

        this.setState({
            [key1]: {
                ...this.state[key1],
                [key2]: val
            }
        });
        // console.log(this.state[key1]);
    }
    resetAuto() {
        // this.state.autoListener[target].clearListeners();
        this.setState({
            autocomplete: { ...this.state.autocomplete, location: false }
        });
    }
    handleTruckingType(ev) {
        this.setState({hub: {
            ...this.state.hub,
            truckingType: ev.value
        }});
    }
    handleHubType(ev) {
        this.setState({hub: {
            ...this.state.hub,
            hubType: ev.value
        }});
    }
    saveNewHub() {
        const { hub, location } = this.state;
        const preppedLocation = {};
        const preppedHub = {};
        preppedLocation.street_number = location.number;
        preppedLocation.street = location.street;
        preppedLocation.zip_code = location.zipCode;
        preppedLocation.city = location.city;
        preppedLocation.country = location.country;
        preppedLocation.latitude = location.latitude;
        preppedLocation.longitude = location.longitude;
        preppedLocation.geocoded_address = location.geocoded_address;

        preppedHub.name = hub.name;
        preppedHub.hub_type = hub.hubType;
        preppedHub.trucking_type = hub.truckingType;
        preppedHub.latitude = location.latitude;
        preppedHub.longitude = location.longitude;
        this.props.saveHub(preppedHub, preppedLocation);
        this.props.close();
    }

    render() {
        const  { theme, close } = this.props;
        const { hub, location } = this.state;
        const hubTypes = [
            {value: 'ocean', label: 'Port'},
            {value: 'air', label: 'Airport'},
            {value: 'rail', label: 'Railyard'},
            {value: 'trucking', label: 'Trucking Depot'}
        ];
        const truckingTypes = [
            {value: 'city', label: 'Cities'},
            {value: 'zip_code', label: 'Zip Codes'}
        ];
        const StyledSelect = styled(Select)`
            width: 100%;
            .Select-control {
                background-color: #F9F9F9;
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2 !important;
            }
            .Select-menu-outer {
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2;
            }
            .Select-value {
                background-color: #F9F9F9;
                border: 1px solid #F2F2F2;
            }
            .Select-option {
                background-color: #F9F9F9;
            }
        `;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return (
            <div className={`flex-none layout-align-center-center layout-row ${styles.editor_backdrop}`}>
                <div className={`flex-none ${styles.editor_fade}`} onClick={() => close()}></div>
                <div
                    className={`${
                        styles.hub_form
                    } layout-row flex-none layout-wrap layout-align-center`}
                >
                    <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                        <div className="flex-5"></div>
                        <h2 className="flex-none clip letter_3" style={textStyle}>Add a New Hub</h2>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-center">
                        <GmapsWrapper theme={theme} component={PlaceSearch} handlePlaceChange={this.handlePlaceChange}/>
                    </div>
                    <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.form_padding}`}>
                        <div className="flex-50 layout-row layout-wrap layout-align-start-start height_100">
                            <div className="flex-80 layout-row layout-align-center-center input_box_full margin_1">
                                <input
                                    name="hub-name"
                                    className={`flex-none ${styles.input}`}
                                    type="string"
                                    onChange={this.handleAddressChange}
                                    value={hub.name}
                                    placeholder="Name"
                                />
                            </div>
                            <div className="flex-80 layout-row layout-align-center-center margin_1">
                                <StyledSelect
                                    placeholder="Hub Type"
                                    className={styles.select}
                                    name="hub-type"
                                    value={hub.hubType}
                                    options={hubTypes}
                                    onChange={this.handleHubType}
                                />
                            </div>
                            <div className="flex-80 layout-row layout-align-center-center margin_1">
                                <StyledSelect
                                    placeholder="Trucking Type"
                                    className={styles.select}
                                    name="hub-trucking"
                                    value={hub.truckingType}
                                    options={truckingTypes}
                                    onChange={this.handleTruckingType}
                                />
                            </div>

                        </div>
                        <div className="flex-50 layout-row layout-wrap layout-align-end-space-around">
                            <div className="flex-80 layout-row layout-align-center-center input_box_full margin_1">
                                <input
                                    id="not-auto"
                                    name="location-number"
                                    className={`flex-none ${styles.input}`}
                                    type="string"
                                    onChange={this.handleAddressChange}
                                    value={location.number}
                                    placeholder="Number"
                                />
                            </div>
                            <div className="flex-80 layout-row layout-align-center-center input_box_full margin_1">
                                <input
                                    name="location-street"
                                    className={`flex-none ${styles.input}`}
                                    type="string"
                                    onChange={this.handleAddressChange}
                                    value={location.street}
                                    placeholder="Street"
                                />
                            </div>
                            <div className="flex-80 layout-row layout-align-center-center input_box_full margin_1">
                                <input
                                    name="location-zipCode"
                                    className={`flex-none ${styles.input}`}
                                    type="string"
                                    onChange={this.handleAddressChange}
                                    value={location.zipCode}
                                    placeholder="Zip Code"
                                />
                            </div>
                            <div className="flex-80 layout-row layout-align-center-center input_box_full margin_1">
                                <input
                                    name="location-city"
                                    className={`flex-none ${styles.input}`}
                                    type="string"
                                    onChange={this.handleAddressChange}
                                    value={location.city}
                                    placeholder="City"
                                />
                            </div>
                            <div className="flex-80 layout-row layout-align-center-center input_box_full margin_1">
                                <input
                                    name="location-country"
                                    className={`flex-none ${styles.input}`}
                                    type="string"
                                    onChange={this.handleAddressChange}
                                    value={location.country}
                                    placeholder="Country"
                                />
                            </div>
                            <div className="flex-100 layout-row layout-align-end-center">
                                <div className="flex-none layout-row layout-align-end-center" onClick={() => this.resetAuto('location')}>
                                    <i className="fa fa-times flex-none"></i>
                                    <p className="offset-5 flex-none" style={{paddingRight: '10px'}} >Clear</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-end-center">
                        <div className="flex-none layout-row">
                            <RoundButton
                                theme={theme}
                                size="small"
                                text="Save Hub"
                                active
                                handleNext={this.saveNewHub}
                                iconClass="fa-floppy"
                            />
                        </div>
                        <div className="flex-5"></div>
                    </div>
                </div>
            </div>
        );
    }
}

AdminHubForm.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    shipment: PropTypes.object,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};

