import React, { Component } from 'react';
// import styles from './CargoItemDetails.scss';
import PropTypes from 'prop-types';

export class ContainerDetails extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        const { index, item } = this.props;
        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center">
                <div className="flex-100 layout-row">
                    <h4 className="flex-none">Unit {index + 1 }</h4>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p className="flex-none">Gross Weight</p>
                    <p className="flex-none">{item.payload_in_kg} kg</p>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p className="flex-none">Container Class</p>
                    <p className="flex-none">{item.size_class} cm</p>
                </div>
            </div>
        );
    }
}
ContainerDetails.PropTypes = {
    item: PropTypes.object,
    index: PropTypes.number
};
