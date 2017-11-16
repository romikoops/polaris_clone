import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Toggle from 'react-toggle';
import 'react-toggle/style.css';

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
                has_pre_carriage: true,
                has_on_carriage: true
            },
            autocomplete: {
                origin: false,
                destination: false
            }
        };
        this.handleAddressChange = this.handleAddressChange.bind(this);
        this.selectLocation = this.selectLocation.bind(this);
    }
    componentDidMount() {
        this.initMap();
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
        this.initAutocomplete(map1, map2);
    }
    initAutocomplete(map1, map2) {
        const oInput = document.getElementById('origin');
        const dInput = document.getElementById('destination');
        // map1.controls[this.props.gMaps.ControlPosition.TOP_RIGHT].push(oInput);
        // map2.controls[this.props.gMaps.ControlPosition.TOP_RIGHT].push(dInput);
        const autocomplete1 = new this.props.gMaps.places.Autocomplete(oInput);
        const autocomplete2 = new this.props.gMaps.places.Autocomplete(dInput);
        autocomplete1.bindTo('bounds', map1);
        autocomplete2.bindTo('bounds', map2);

        this.autocompleteListener(map1, autocomplete1, 'origin');
        this.autocompleteListener(map2, autocomplete2, 'destination');
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
        this.setState({autocomplete: {
            [target]: true}}
        );
    }
    render() {
        const originFields = (<div className="flex-100 layout-row layout-wrap">
                    <input  name="origin-number" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.number} placeholder="Number"/>
                    <input  name="origin-street" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.street} placeholder="Street"/>
                    <input name="origin-zipCode" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.zipCode} placeholder="Zip Code"/>
                    <input name="origin-city" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.city} placeholder="City"/>
                    <input name="origin-country" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.country} placeholder="Country"/>
                  </div>);
        const originAuto = (<div className="flex-100 layout-row layout-wrap">
                    <input id="origin" name="origin-street" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.origin.fullAddress} placeholder="Search for address"/>
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
                    <input id="destination" name="origin-street" className="flex-100" type="string" onChange={this.handleAddressChange} value={this.state.destination.fullAddress} placeholder="Search for address"/>
                  </div>);
        return (
          <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className="layout-row flex-75 layout-align-start-center" >
              <div className="flex-40 layout-row layout-wrap">
                <div className="flex-100 layout-row">
                  <Toggle
                    id="pre-carriage"
                    defaultChecked={this.state.shipment.has_pre_carriage}
                    onChange={this.handlePreCarriage} />
                  <label htmlFor="pre-carriage">Pre-Carriage</label>
                </div>
                 <div className="flex-100 layout-row layout-wrap">
                  <p className="flex-100"> Origin Address </p>
                  { this.state.autocomplete.origin ? originFields : originAuto }
                 </div>
              </div>
              <div ref="map" id="origin-map" style={mapStyle} />
            </div>
            <div className="layout-row flex-75 layout-align-start-center" >
              <div className="flex-40 layout-row layout-wrap">
                <div className="flex-100 layout-row">
                  <Toggle
                    id="on-carriage"
                    defaultChecked={this.state.shipment.has_on_carriage}
                    onChange={this.handleOnCarriage} />
                  <label htmlFor="on-carriage">On-Carriage</label>
                </div>
                 <div className="flex-100 layout-row layout-wrap">
                  <p className="flex-100"> Destination Address </p>
                  { this.state.autocomplete.destination ? destFields : destAuto }
                 </div>
              </div>
              <div ref="map" id="destination-map" style={mapStyle} />
            </div>
          </div>
        );
    }
}

ShipmentLocationBox.PropTypes = {
    gMaps: PropTypes.func,
    theme: PropTypes.object
};
