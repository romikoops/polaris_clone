import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Toggle from 'react-toggle';
import '../../styles/react-toggle.scss';
import Select from 'react-select';
import '../../styles/select-css-custom.css';
import styles from './ShipmentLocationBox.scss';
import defaults from '../../styles/default_classes.scss';
import { isEmpty } from '../../helpers/isEmpty';
import { colorSVG } from '../../helpers/svgColourer';
import {mapStyling} from '../../constants/map.constants';
import styled from 'styled-components';
const mapStyle = {
    width: '100%',
    height: '400px',
    borderRadius: '3px',
    boxShadow: '1px 1px 2px 2px rgba(0,1,2,0.25)'
};
const isObjectEmpty = isEmpty;
const colourSVG = colorSVG;
const mapStyles = mapStyling;
export class ShipmentLocationBox extends Component {
    constructor(props) {
        super(props);
        console.log(this.props);
        this.state = {
            origin: {
                street: '',
                zipCode: '',
                city: '',
                country: '',
                fullAddress: '',
                hub_id: '',
                hub_name: ''
            },
            destination: {
                street: '',
                zipCode: '',
                city: '',
                fullAddress: '',
                hub_id: '',
                hub_name: ''
            },
            autoTextOrigin: '',
            autoTextDest: '',
            // origin: this.props.origin,
            // destination: this.props.destination,
            shipment: {
                has_pre_carriage: false,
                has_on_carriage: false
            },
            autocomplete: {
                origin: false,
                destination: false
            },
            markers: {
                origin: {},
                destination: {}
            }
        };

        this.handleAddressChange = this.handleAddressChange.bind(this);
        this.selectLocation = this.selectLocation.bind(this);
        this.handleTrucking = this.handleTrucking.bind(this);
        this.setOriginHub = this.setOriginHub.bind(this);
        this.setDestHub = this.setDestHub.bind(this);
        this.postToggleAutocomplete = this.postToggleAutocomplete.bind(this);
        this.initAutocomplete = this.initAutocomplete.bind(this);
        this.setHubsFromRoute = this.setHubsFromRoute.bind(this);
        this.resetAuto = this.resetAuto.bind(this);
        this.setMarker = this.setMarker.bind(this);
        this.handleAuto = this.handleAuto.bind(this);
    }

    componentDidMount() {
        this.initMap();
        if (this.props.selectedRoute) {
            this.setHubsFromRoute(this.props.selectedRoute);
        }
    }

    setHubsFromRoute(route) {
        let tmpOrigin = {};
        let tmpDest = {};
        this.props.allNexuses.forEach(nx => {
            if (nx.id === route.origin_nexus_id) {
                tmpOrigin = nx;
            }

            if (nx.id === route.destination_nexus_id) {
                tmpDest = nx;
            }
        });

        this.setState({
            oSelect: {value: tmpOrigin, label: tmpOrigin.name},
            dSelect: {value: tmpDest, label: tmpDest.name},
            origin: {
                ...this.state.origin,
                hub_id: tmpOrigin.id,
                hub_name: tmpOrigin.name,
                lat: tmpOrigin.latitude,
                lng: tmpOrigin.longitude
            },
            destination: {
                ...this.state.destination,
                hub_id: tmpDest.id,
                hub_name: tmpDest.name,
                lat: tmpDest.latitude,
                lng: tmpDest.longitude
            }
        });

        this.props.setTargetAddress('origin', {
            ...this.state.origin,
            hub_id: tmpOrigin.id,
            hub_name: tmpOrigin.name,
            lat: tmpOrigin.latitude,
            lng: tmpOrigin.longitude
        });

        this.props.setTargetAddress('destination', {
            ...this.state.destination,
            hub_id: tmpDest.id,
            hub_name: tmpDest.name,
            lat: tmpDest.latitude,
            lng: tmpDest.longitude
        });

        if (this.state.map) {
            this.setMarker(
                { lat: tmpOrigin.latitude, lng: tmpOrigin.longitude },
                tmpOrigin.name, 'origin'
            );
            this.setMarker(
                { lat: tmpDest.latitude, lng: tmpDest.longitude },
                tmpDest.name, 'destination'
            );
        } else {
            setTimeout(
                function() {
                    this.setMarker(
                        { lat: tmpOrigin.latitude, lng: tmpOrigin.longitude },
                        tmpOrigin.name, 'origin'
                    );
                }.bind(this),
                750
            );
            setTimeout(
                function() {
                    this.setMarker(
                        { lat: tmpDest.latitude, lng: tmpDest.longitude },
                        tmpDest.name, 'destination'
                    );
                }.bind(this),
                750
            );
        }
    }

    initMap() {
        const mapsOptions = {
            center: {
                lat: 55.675647,
                lng: 12.567848
            },
            zoom: 5,
            mapTypeId: this.props.gMaps.MapTypeId.ROADMAP,
            disableDefaultUI: true,
            styles: mapStyles
            // [
            //     {
            //         featureType: 'water',
            //         elementType: 'all',
            //         stylers: [
            //             {
            //                 color: '#275b9b'
            //             },
            //             {
            //                 invert_lightness: true
            //             }
            //         ]
            //     }
            // ]
        };

        const map = new this.props.gMaps.Map(
            document.getElementById('map'),
            mapsOptions
        );
        this.setState({ map });

        if (this.state.shipment.has_pre_carriage) {
            this.initAutocomplete(map, 'origin');
        }

        if (this.state.shipment.has_on_carriage) {
            this.initAutocomplete(map, 'destination');
        }
    }

    initAutocomplete(map, target) {
        // const targetId = target + '-gmac';
        const input = document.getElementById(target);
        const autocomplete = new this.props.gMaps.places.Autocomplete(input);
        autocomplete.bindTo('bounds', map);
        this.setState({autoListener: {...this.state.autoListener, [target]: autocomplete }});
        this.autocompleteListener(map, autocomplete, target);
    }

    postToggleAutocomplete(target) {
        const { map } = this.state;

        if (target === 'origin') {
            setTimeout(
                function() {
                    this.initAutocomplete(map, target);
                }.bind(this),
                1000
            );
        }

        if (target === 'destination') {
            setTimeout(
                function() {
                    this.initAutocomplete(map, target);
                }.bind(this),
                1000
            );
        }
    }

    autocompleteListener(aMap, autocomplete, target) {
        const infowindow = new this.props.gMaps.InfoWindow();
        const infowindowContent = document.getElementById('infowindow-content');
        infowindow.setContent(infowindowContent);

        const marker = new this.props.gMaps.Marker({
            map: aMap,
            anchorPoint: new this.props.gMaps.Point(0, -29)
        });

        autocomplete.addListener('place_changed', () => {
            infowindow.close();
            marker.setVisible(false);
            const place = autocomplete.getPlace();
            if (!place.geometry) {
                window.alert(
                    "No details available for input: '" + place.name + "'"
                );
                return;
            }

            this.setMarker(
                {
                    lat: place.geometry.location.lat(),
                    lng: place.geometry.location.lng()
                },
                place.name, target
            );

            this.selectLocation(place, target);
        });
    }

    setMarker(location, name, target) {
        const { markers, map } = this.state;
        const {theme} = this.props;
        const newMarkers = [];
        if (!isObjectEmpty(markers[target])) {
            markers[target].setMap(null);
        }
        let icon;
        if (target === 'origin') {
            icon = {
                url: colourSVG('location', theme),
                anchor: new this.props.gMaps.Point(25, 50),
                scaledSize: new this.props.gMaps.Size(36, 36)
            };
        } else {
            icon = {
                url: colourSVG('flag', theme),
                anchor: new this.props.gMaps.Point(25, 50),
                scaledSize: new this.props.gMaps.Size(36, 36)
            };
        }
        const marker = new this.props.gMaps.Marker({
            position: location,
            map: map,
            title: name,
            icon
        });
        markers[target] = marker;
        if (!isObjectEmpty(markers.origin)) {
            newMarkers.push(markers.origin);
        }
        if (!isObjectEmpty(markers.destination)) {
            newMarkers.push(markers.destination);
        }
        this.setState({ markers: markers});
        const bounds = new this.props.gMaps.LatLngBounds();
        for (let i = 0; i < newMarkers.length; i++) {
            bounds.extend(newMarkers[i].getPosition());
        }

        map.fitBounds(bounds);
    }

    handleTrucking(event) {
        const { name, checked } = event.target;
        console.log(name, checked);
        this.setState({
            shipment: { ...this.state.shipment, [name]: checked }
        });

        if (name === 'has_pre_carriage') {
            if (checked) {
                this.postToggleAutocomplete('origin');
            }
            this.props.setCarriage('has_pre_carriage', checked);
        }

        if (name === 'has_on_carriage') {
            if (checked) {
                this.postToggleAutocomplete('destination');
            }
            this.props.setCarriage('has_on_carriage', checked);
        }
    }

    handleAddressChange(event) {
        this.props.handleAddressChange(event);
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
    setOriginHub(event) {
        if (event) {
            this.setState({
                oSelect: event,
                origin: {
                    ...this.state.origin,
                    hub_id: event.value.id,
                    hub_name: event.label,
                    lat: event.value.latitude,
                    lng: event.value.longitude
                }
            });

            this.props.setTargetAddress('origin', {
                ...this.state.origin,
                hub_id: event.value.id,
                hub_name: event.value.name,
                lat: event.value.latitude,
                lng: event.value.longitude
            });

            this.setMarker(
                { lat: event.value.latitude, lng: event.value.longitude },
                event.value.name, 'origin'
            );
        } else {
            this.setState({
                oSelect: '',
                origin: {}
            });

            this.props.setTargetAddress('origin', {});
        }
    }
    handleAuto(event) {
        console.log(event.target);
        const {name, value} = event.target;
        this.setState({autoText: {[name]: value}});
    }

    setDestHub(event) {
        if (event) {
            this.setState({
                dSelect: event,
                destination: {
                    ...this.state.destination,
                    hub_id: event.value.id,
                    hub_name: event.label,
                    lat: event.value.latitude,
                    lng: event.value.longitude
                }
            });

            this.props.setTargetAddress('destination', {
                ...this.state.destination,
                hub_id: event.value.id,
                hub_name: event.value.name,
                lat: event.value.latitude,
                lng: event.value.longitude
            });

            this.setMarker(
                { lat: event.value.latitude, lng: event.value.longitude },
                event.value.name, 'destination'
            );
        } else {
            this.setState({
                dSelect: '',
                destination: {}
            });

            this.props.setTargetAddress('destination', {});
        }
    }

    selectLocation(place, target) {
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

            if (ac.types.includes('route')) {
                tmpAddress.street = ac.long_name;
            }

            if (ac.types.includes('administrative_area_level_1')) {
                tmpAddress.city = ac.long_name;
            }

            if (ac.types.includes('postal_code')) {
                tmpAddress.zipCode = ac.long_name;
            }

            if (ac.types.includes('country')) {
                tmpAddress.country = ac.long_name;
            }
        });
        tmpAddress.fullAddress = place.formatted_address;

        this.setState({ [target]: tmpAddress });
        this.props.setTargetAddress(target, tmpAddress);
        this.setState({
            autocomplete: { ...this.state.autocomplete, [target]: true }
        });
    }
    resetAuto(target) {
        // this.state.autoListener[target].clearListeners();
        this.setState({
            autocomplete: { ...this.state.autocomplete, [target]: false }
        });
    }

    render() {
        const nexuses = [];

        if (this.props.allNexuses) {
            this.props.allNexuses.forEach(nex => {
                nexuses.push({ value: nex, label: nex.name });
            });
        }
        const StyledSelect = styled(Select)`
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
        const autoHide = {
            height: '0px',
            display: 'none'
        };
        const originHubSelect = (
            <StyledSelect
                name="origin-hub"
                className={`${styles.select}`}
                value={this.state.oSelect}
                options={nexuses}
                onChange={this.setOriginHub}
            />
        );

        const destinationHubSelect = (
            <StyledSelect
                name="destination-hub"
                className={`${styles.select}`}
                value={this.state.dSelect}
                options={nexuses}
                onChange={this.setDestHub}
            />
        );

        const originFields = (
            <div className="flex-100 layout-row layout-wrap">
                <input
                    id="not-auto"
                    name="origin-number"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAddressChange}
                    value={this.props.origin.number}
                    placeholder="Number"
                />
                <input
                    name="origin-street"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAddressChange}
                    value={this.state.origin.street}
                    placeholder="Street"
                />
                <input
                    name="origin-zipCode"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAddressChange}
                    value={this.state.origin.zipCode}
                    placeholder="Zip Code"
                />
                <input
                    name="origin-city"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAddressChange}
                    value={this.state.origin.city}
                    placeholder="City"
                />
                <input
                    name="origin-country"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAddressChange}
                    value={this.state.origin.country}
                    placeholder="Country"
                />
                <div className="flex-100 layout-row layout-align-end-center">
                    <div className="flex-none layout-row layout-align-end-center" onClick={() => this.resetAuto('origin')}>
                        <i className="fa fa-times flex-none"></i>
                        <p className="offset-5 flex-none" style={{paddingRight: '10px'}} >Clear</p>
                    </div>
                </div>
            </div>
        );

        const originAuto = (
            <div className="flex-100 layout-row layout-wrap" style={this.state.autocomplete.origin ? autoHide : {}}>
                <input
                    id="origin"
                    name="origin-fullAddress"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAddressChange}
                    value={this.state.origin.fullAddress}
                    placeholder="Search for address"
                />
            </div>
        );

        const destFields = (
            <div className="flex-100 layout-row layout-wrap">
                <input
                    name="destination-number"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAddressChange}
                    value={this.state.destination.number}
                    placeholder="Number"
                />
                <input
                    name="destination-street"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAddressChange}
                    value={this.state.destination.street}
                    placeholder="Street"
                />
                <input
                    name="destination-zipCode"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAddressChange}
                    value={this.state.destination.zipCode}
                    placeholder="Zip Code"
                />
                <input
                    name="destination-city"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAddressChange}
                    value={this.state.destination.city}
                    placeholder="City"
                />
                <input
                    name="destination-country"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAddressChange}
                    value={this.state.destination.country}
                    placeholder="Country"
                />
                <div className="flex-100 layout-row layout-align-end-center">
                    <div className="flex-none layout-row layout-align-end-center" onClick={() => this.resetAuto('destination')}>
                        <i className="fa fa-times flex-none"></i>
                        <p className="flex-none offset-5" style={{paddingRight: '10px'}}>Clear</p>
                    </div>
                </div>
            </div>
        );

        const destAuto = (
            <div className="flex-100 layout-row layout-wrap" style={this.state.autocomplete.destination ? autoHide : {}}>
                <input
                    id="destination"
                    name="destination"
                    className={`flex-none ${styles.input}`}
                    type="string"
                    onChange={this.handleAuto}
                    value={this.state.autoText}
                    placeholder="Search for address"
                />
            </div>
        );
        const displayLocationOptions = target => {
            if (target === 'origin' && !this.state.shipment.has_pre_carriage) {
                return originHubSelect;
            } else if (
                target === 'origin' &&
                this.state.shipment.has_pre_carriage
            ) {
                return this.state.autocomplete.origin
                    ? originFields
                    : '';
            }

            if (
                target === 'destination' &&
                !this.state.shipment.has_on_carriage
            ) {
                return destinationHubSelect;
            } else if (
                target === 'destination' &&
                this.state.shipment.has_on_carriage
            ) {
                return this.state.autocomplete.destination
                    ? destFields
                    : '';
            }
            return '';
        };
        const { theme } = this.props;

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center-start" >
                <div className={defaults.content_width + ' layout-row flex-none layout-align-start-start'} >
                    <div className={`flex-30 layout-row layout-wrap ${styles.input_box}`}>
                        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                            <div className={'flex-100 layout-row ' + defaults.mc}>
                                <Toggle
                                    className="flex-none"
                                    id="has_pre_carriage"
                                    name="has_pre_carriage"
                                    value={String(this.state.shipment.has_pre_carriage)}
                                    defaultChecked={this.state.shipment.has_pre_carriage}
                                    onChange={this.handleTrucking}
                                />
                                <label htmlFor="pre-carriage">Pre-Carriage</label>
                            </div>
                            <div className="flex-100 layout-row layout-wrap">
                                <p className="flex-100"> Origin Address </p>
                                { this.state.shipment.has_pre_carriage ? originAuto : '' }
                                { displayLocationOptions('origin') }
                            </div>
                        </div>
                        {/* <div ref="map" id="map" style={mapStyle} />*/}
                        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                            <div className={'flex-100 layout-row ' + defaults.mc}>
                                <Toggle
                                    className="flex-none"
                                    id="has_on_carriage"
                                    name="has_on_carriage"
                                    value={String(this.state.shipment.has_on_carriage)}
                                    defaultChecked={this.state.shipment.has_on_carriage}
                                    onChange={this.handleTrucking}
                                />
                                <label htmlFor="on-carriage">On-Carriage</label>
                            </div>
                            <div className="flex-100 layout-row layout-wrap">
                                <p className="flex-100">
                                    {' '}
                                    Destination Address{' '}
                                </p>
                                { this.state.shipment.has_on_carriage ? destAuto : '' }
                                {displayLocationOptions('destination')}
                            </div>
                        </div>
                    </div>
                    <div className="flex-70 layout-row layout-wrap layout-align-center-start">
                        <div ref="map" id="map" style={mapStyle} />
                    </div>
                </div>
                <style dangerouslySetInnerHTML={{__html: `
                    .react-toggle--checked .react-toggle-track {
                        background: linear-gradient(90deg, ${theme.colors.brightPrimary} 0%, ${theme.colors.brightSecondary} 100%);
                    }
                `}} />
            </div>
        );
    }
}

ShipmentLocationBox.propTypes = {
    gMaps: PropTypes.object,
    theme: PropTypes.object,
    setTargetAddress: PropTypes.func,
    handleAddressChange: PropTypes.func,
    setCarriage: PropTypes.func,
    allNexuses: PropTypes.array,
    selectedRoute: PropTypes.object,
    origin: PropTypes.object,
    destination: PropTypes.object
};
