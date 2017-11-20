import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Toggle from 'react-toggle';
import 'react-toggle/style.css';
import Select from 'react-select';
import 'react-select/dist/react-select.css';

const mapStyle = {
    width: '400px',
    height: '200px'
};

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
                fullAddress: ''
            },
            destination: {
                street: '',
                zipCode: '',
                city: '',
                fullAddress: ''
            },
            shipment: {
                has_pre_carriage: false,
                has_on_carriage: false
            },
            autocomplete: {
                origin: false,
                destination: false
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
        Object.keys(this.props.allNexuses).forEach(key => {
            if (this.props.allNexuses[key] === route.origin_nexus_id) {
                tmpOrigin = {id: this.props.allNexuses[key], name: key};
            }
            if (this.props.allNexuses[key] === route.destination_nexus_id) {
                tmpDest = {id: this.props.allNexuses[key], name: key};
            }
        });
        this.setState({
            origin: {...this.state.origin, hub_id: tmpOrigin.id, hub_name: tmpOrigin.name},
            destination: {...this.state.destination, hub_id: tmpDest.id, hub_name: tmpDest.name}
        });
        this.props.setTargetAddress('origin', {...this.state.origin, hub_id: tmpOrigin.id, hub_name: tmpOrigin.name});
        this.props.setTargetAddress('destination', {...this.state.destination, hub_id: tmpDest.id, hub_name: tmpDest.name});
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
            styles: [{
                'featureType': 'water',
                'elementType': 'all',
                'stylers': [{
                    'color': '#275b9b'
                }, {
                    'invert_lightness': true
                }]
            }]
        };
        const map1 = new this.props.gMaps.Map(document.getElementById('origin-map'), mapsOptions);
        const map2 = new this.props.gMaps.Map(document.getElementById('destination-map'), mapsOptions);
        this.setState({map1, map2});
        if (this.state.shipment.has_pre_carriage) {
            this.initAutocomplete(map1, 'origin');
        }
        if (this.state.shipment.has_on_carriage) {
            this.initAutocomplete(map2, 'destination');
        }
    }
    initAutocomplete(map, target) {
        const input = document.getElementById(target);
        // map1.controls[this.props.gMaps.ControlPosition.TOP_RIGHT].push(oInput);
        // map2.controls[this.props.gMaps.ControlPosition.TOP_RIGHT].push(dInput);
        const autocomplete = new this.props.gMaps.places.Autocomplete(input);
        autocomplete.bindTo('bounds', map);
        this.autocompleteListener(map, autocomplete, target);
    }
    postToggleAutocomplete(target) {
        const { map1, map2 } = this.state;
        if (target === 'origin') {
            setTimeout(function() { this.initAutocomplete(map1, target);}.bind(this), 1000);
        }
        if (target === 'destination') {
            setTimeout(function() { this.initAutocomplete(map2, target);}.bind(this), 1000);
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
        // User entered the name of a Place that was not suggested and
        // pressed the Enter key, or the Place Details request failed.
                window.alert("No details available for input: '" + place.name + "'");
                return;
            }

      // If the place has a geometry, then present it on a map.
            if (place.geometry.viewport) {
                aMap.fitBounds(place.geometry.viewport);
            } else {
                aMap.setCenter(place.geometry.location);
                aMap.setZoom(17);  // Why 17? Because it looks good.
            }
            marker.setPosition(place.geometry.location);
            marker.setVisible(true);
          //   let address = '';
          //   if (place.address_components) {
          //       address = [
          // (place.address_components[0] && place.address_components[0].short_name || ''),
          // (place.address_components[1] && place.address_components[1].short_name || ''),
          // (place.address_components[2] && place.address_components[2].short_name || '')
          //       ].join(' ');
          //   }
            this.selectLocation(place, target);
        });
    }
    handleTrucking(event) {
        const { name, checked } = event.target;
        this.setState({shipment: {...this.state.shipment, [name]: checked}} );
        if (name === 'has_pre_carriage' && checked) {
            this.postToggleAutocomplete('origin');
            this.props.setCarriage('has_pre_carriage', checked);
        }
        if (name === 'has_on_carriage' && checked) {
            this.postToggleAutocomplete('destination');
            this.props.setCarriage('has_on_carriage', checked);
        }
    }

    handleAddressChange(event) {
        const eventKeys = event.target.name.split('-');
        const key1 = eventKeys[0];
        const key2 = eventKeys[1];
        const val = event.target.value;
        this.setState({
            [key1]: {
                [key2]: val
            }
        });
    }
    setOriginHub(event) {
        console.log(event);
        this.setState({origin: {...this.state.origin, hub_id: event.value, hub_name: event.label}});
    }
    setDestHub(event) {
        console.log(event);
        this.setState({destination: {...this.state.destination, hub_id: event.value, hub_name: event.label}});
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

        this.setState({[target]: tmpAddress});
        this.props.setTargetAddress(target, tmpAddress);
        this.setState({autocomplete: { ...this.state.autocomplete, [target]: true } });
    }
    render() {
        const nexuses = [];
        if (this.props.allNexuses) {
            Object.keys(this.props.allNexuses).forEach(key => {
                nexuses.push({value: this.props.allNexuses[key], label: key});
            });
        }
        const originHubSelect = (
            <Select name="origin-hub" value={this.state.origin.hub_name} options={nexuses} onChange={this.setOriginHub}/>
        );
        const destinationHubSelect = (
            <Select name="destination-hub" value={this.state.destination.hub_name} options={nexuses} onChange={this.setDestHub}/>
        );
        const originFields = (<div className="flex-100 layout-row layout-wrap">
                    <input  name="origin-number" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.number} placeholder="Number"/>
                    <input  name="origin-street" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.street} placeholder="Street"/>
                    <input name="origin-zipCode" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.zipCode} placeholder="Zip Code"/>
                    <input name="origin-city" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.city} placeholder="City"/>
                    <input name="origin-country" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.country} placeholder="Country"/>
                  </div>);
        const originAuto = (<div className="flex-100 layout-row layout-wrap">
                    <input id="origin" name="origin-fullAddress" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.fullAddress} placeholder="Search for address"/>
                  </div>);
        const destFields = (
                <div className="flex-100 layout-row layout-wrap">
                    <input name="destination-number" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.destination.number} placeholder="Number"/>
                    <input name="destination-street" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.destination.street} placeholder="Street"/>
                    <input name="destination-zipCode" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.destination.zipCode} placeholder="Zip Code"/>
                    <input name="destination-city" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.destination.city} placeholder="City"/>
                    <input name="destination-country" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.destination.country} placeholder="Country"/>
                  </div>
        );
        const destAuto = (<div className="flex-100 layout-row layout-wrap">
                    <input id="destination" name="destination-fullAddress" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.destination.fullAddress} placeholder="Search for address"/>
                  </div>);
        const displayLocationOptions = (target) => {
            if (target === 'origin' && !this.state.shipment.has_pre_carriage) {
                return originHubSelect;
            } else if (target === 'origin' && this.state.shipment.has_pre_carriage) {
                return this.state.autocomplete.origin ? originFields : originAuto;
            }
            if (target === 'destination' && !this.state.shipment.has_on_carriage) {
                return destinationHubSelect;
            } else if (target === 'destination' && this.state.shipment.has_on_carriage) {
                return this.state.autocomplete.destination ? destFields : destAuto;
            }
            return '';
        };
        return (
          <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className="layout-row flex-75 layout-align-start-center" >
              <div className="flex-40 layout-row layout-wrap">
                <div className="flex-100 layout-row">
                  <Toggle
                    id="has_pre_carriage"
                    name="has_pre_carriage"
                    defaultChecked={this.state.shipment.has_pre_carriage}
                    onChange={this.handleTrucking} />
                  <label htmlFor="pre-carriage">Pre-Carriage</label>
                </div>
                 <div className="flex-100 layout-row layout-wrap">
                  <p className="flex-100"> Origin Address </p>
                  { displayLocationOptions('origin') }
                 </div>
              </div>
              <div ref="map" id="origin-map" style={mapStyle} />
            </div>
            <div className="layout-row flex-75 layout-align-start-center" >
              <div className="flex-40 layout-row layout-wrap">
                <div className="flex-100 layout-row">
                  <Toggle
                    id="has_on_carriage"
                    name="has_on_carriage"
                    defaultChecked={this.state.shipment.has_on_carriage}
                    onChange={this.handleTrucking} />
                  <label htmlFor="on-carriage">On-Carriage</label>
                </div>
                 <div className="flex-100 layout-row layout-wrap">
                  <p className="flex-100"> Destination Address </p>
                  { displayLocationOptions('destination') }
                 </div>
              </div>
              <div ref="map" id="destination-map" style={mapStyle} />
            </div>
          </div>
        );
    }
}

ShipmentLocationBox.PropTypes = {
    gMaps: PropTypes.object,
    theme: PropTypes.object,
    setTargetAddress: PropTypes.func,
    allNexuses: PropTypes.object,
    selectedRoute: PropTypes.object
};
