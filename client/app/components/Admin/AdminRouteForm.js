import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import Select from 'react-select';
import '../../styles/select-css-custom.css';
import { RoundButton } from '../RoundButton/RoundButton';
import styled from 'styled-components';
export class AdminRouteForm extends Component {
    constructor(props) {
        super(props);
        this.state = {
            location: {},
            route: {
                name: '',
                startHub: '',
                endHub: ''
            }
        };
        this.handlePlaceChange = this.handlePlaceChange.bind(this);
        this.handleAddressChange = this.handleAddressChange.bind(this);
        this.resetAuto = this.resetAuto.bind(this);
        this.saveNewHub = this.saveNewHub.bind(this);
        this.handleTruckingType = this.handleTruckingType.bind(this);
        this.handleHubType = this.handleHubType.bind(this);
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
        const  { theme, close, hubs } = this.props;
        const { route, location } = this.state;
        const StyledSelect = styled(NamedSelect)`
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
                    <div className="flex-100 layout-row layout-wrap layout-align-end-center">
                        <h2 className="flex-none clip letter_3" style={textStyle}>Add a New Route</h2>
                    </div>
                    <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.form_padding}`}>
                      <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.form_row}`}>
                        <div className="flex-100 flex-gt-sm-50 layout-align-start-center">
                          <p className="flex-none">Origin</p>
                        </div>
                        <div className="flex-100 flex-gt-sm-50 layout-align-end-center">
                          <StyledSelect
                              placeholder="Origin"
                              className={styles.select}
                              name="origin"
                              value={route.startHub}
                              options={originHubs}
                              onChange={this.handleHubChange}
                          />
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

AdminRouteForm.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    shipment: PropTypes.object,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};

