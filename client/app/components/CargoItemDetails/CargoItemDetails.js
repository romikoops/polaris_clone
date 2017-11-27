import React, { Component } from 'react';
import styles from './CargoItemDetails.scss';
import PropTypes from 'prop-types';

export class CargoItemDetails extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        const { index, item } = this.props;
        return (
            <div className={` ${styles.info} layout-row flex-100 layout-wrap layout-align-center`}>
                <div className="flex-100 layout-row">
                    <h4 className="flex-none">Unit {index + 1}</h4>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p className="flex-none">Gross Weight</p>
                    <p className="flex-none">{item.payload_in_kg} kg</p>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p className="flex-none">Length</p>
                    <p className="flex-none">{item.dimension_y} cm</p>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p className="flex-none">Width</p>
                    <p className="flex-none">{item.dimension_x} cm</p>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p className="flex-none">Height</p>
                    <p className="flex-none">{item.dimension_z} cm</p>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p className="flex-none">Volume</p>
                    <p className="flex-none">{(item.dimension_y * item.dimension_x * item.dimension_y) / 1000000} m<sup>3</sup></p>
                </div>
            </div>
        );
    }
}
CargoItemDetails.PropTypes = {
    item: PropTypes.object,
    index: PropTypes.number
};
