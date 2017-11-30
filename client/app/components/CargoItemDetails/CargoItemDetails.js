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
            <div className={`${styles.info} layout-row flex-100 layout-wrap layout-align-center`}>
                <div className="flex-100">
                    <h4>Unit {index + 1}</h4>
                </div>
                <hr/>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Gross Weight</p>
                    <p>{item.payload_in_kg} kg</p>
                </div>
                <hr className="flex-100"/>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Length</p>
                    <p>{item.dimension_y} cm</p>
                </div>
                <hr className="flex-100"/>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Width</p>
                    <p>{item.dimension_x} cm</p>
                </div>
                <hr className="flex-100"/>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Height</p>
                    <p>{item.dimension_z} cm</p>
                </div>
                <hr className="flex-100"/>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Volume</p>
                    <p>{(item.dimension_y * item.dimension_x * item.dimension_y) / 1000000} m<sup>3</sup></p>
                </div>
                <hr className="flex-100"/>
            </div>
        );
    }
}
CargoItemDetails.PropTypes = {
    item: PropTypes.object,
    index: PropTypes.number
};
