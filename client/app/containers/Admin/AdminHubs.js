import React, { Component } from 'react';
import PropTypes from 'prop-types';
export class AdminHubs extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        // const {theme} = this.props;
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <h1>Dashboard</h1>
            </div>
        );
    }
}
AdminHubs.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array
};
