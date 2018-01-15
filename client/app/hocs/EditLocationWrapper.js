import React, { Component } from 'react';
import ReactGoogleMapLoader from 'react-google-maps-loader';
import { API_KEY } from '../constants';
import PropTypes from 'prop-types';

export default class EditLocationWrapper extends Component {
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
                            theme={this.props.theme}
                            gMaps={googleMaps}
                            handleAddressChange={this.props.handleAddressChange}
                            saveLocation={this.props.saveLocation}
                        />
                    )
                }
            />
        );
    }
}
EditLocationWrapper.propTypes = {
    theme: PropTypes.object,
    selectLocation: PropTypes.func,
    component: PropTypes.func,
};
