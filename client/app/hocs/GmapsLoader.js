import React, { Component } from 'react';
import ReactGoogleMapLoader from 'react-google-maps-loader';
import { API_KEY } from '../constants';
import PropTypes from 'prop-types';

export default class GmapsLoader extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        const apiKey = API_KEY;
        console.log(apiKey);
        const params = {
            key: apiKey, // Define your api key here
            libraries: 'places' // To request multiple libraries, separate them with a comma
        };
        const ParamComponent = this.props.component;
        return (
            <ReactGoogleMapLoader
                params={params}
                render={googleMaps =>
                    googleMaps && (
                        <ParamComponent
                            allNexuses={this.props.allNexuses}
                            setTargetAddress={this.props.selectLocation}
                            theme={this.props.theme}
                            gMaps={googleMaps}
                            selectedRoute={this.props.selectedRoute}
                            setCarriage={this.props.toggleCarriage}
                        />
                    )
                }
            />
        );
    }
}
GmapsLoader.propTypes = {
    theme: PropTypes.object,
    selectLocation: PropTypes.func,
    component: PropTypes.func,
    allNexuses: PropTypes.object,
    toggleCarraige: PropTypes.func
};
