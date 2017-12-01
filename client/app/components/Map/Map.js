import React, { Component } from 'react';
import PropTypes from 'prop-types';

const mapStyle = {
    width: '400px',
    height: '200px'
};


export class MapContainer extends Component {
    constructor(props) {
        super(props);
        this.initAutocomplete = this.initAutocomplete.bind(this);
        this.initMap = this.initMap.bind(this);
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
        const mapKey = this.props.target + '_map';
        const map = new this.props.gMaps.Map(document.getElementById(mapKey), mapsOptions);
        this.initAutocomplete(map);
    }
    initAutocomplete(map) {
        const inputKey = this.props.target + '-input';
        const input = document.getElementById(inputKey);
        map.controls[this.props.gMaps.ControlPosition.TOP_RIGHT].push(input);
        const autocomplete = new this.props.gMaps.places.Autocomplete(input);
        autocomplete.bindTo('bounds', map);
        const infowindow = new this.props.gMaps.InfoWindow();
        const infowindowContent = document.getElementById('infowindow-content');
        infowindow.setContent(infowindowContent);
        const marker = new this.props.gMaps.Marker({
            map: map,
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
                map.fitBounds(place.geometry.viewport);
            } else {
                map.setCenter(place.geometry.location);
                map.setZoom(17);  // Why 17? Because it looks good.
            }
            marker.setPosition(place.geometry.location);
            marker.setVisible(true);
            debugger;
            let address = '';
            if (place.address_components) {
                address = [
          (place.address_components[0] && place.address_components[0].short_name || ''),
          (place.address_components[1] && place.address_components[1].short_name || ''),
          (place.address_components[2] && place.address_components[2].short_name || '')
                ].join(' ');
            }

            infowindowContent.children['place-icon'].src = place.icon;
            infowindowContent.children['place-name'].textContent = place.name;
            infowindowContent.children['place-address'].textContent = address;
            infowindow.open(map, marker);
            this.props.selectLocation(place.formatted_address);
        });
    }

    render() {
        const mapKey = this.props.target + '_map';
        const inputKey = this.props.target + '-input';
        return (
            <div className="flex-100 layout-row">
                <div ref="map" id={mapKey} style={mapStyle} />
                <div className="pac-card" id="pac-card">
                    <div id="pac-container">
                        <input id={inputKey} type="text"
                            placeholder="Enter a location"/>
                    </div>
                </div>
            </div>
          );
    }
}

MapContainer.propTypes = {
    theme: PropTypes.object,
    gMaps: PropTypes.object,
    target: PropTypes.string,
    selectLocation: PropTypes.func
};
