import React, { Component } from 'react';
import { CONTAINER_DESCRIPTIONS } from '../../constants';
import styles from './ContainerDetails.scss';
import PropTypes from 'prop-types';

export class ContainerDetails extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        const cDesc = CONTAINER_DESCRIPTIONS;
        const { index, item } = this.props;
        return (
            <div className={` ${styles.info} layout-row flex-100 layout-wrap layout-align-center`}>
                <div className="flex-100 layout-row">
                    <h4 className="flex-none">Unit {index + 1 }</h4>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p className="flex-none">Gross Weight</p>
                    <p className="flex-none">{item.payload_in_kg} kg</p>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p className="flex-none">Container Class</p>
                    <p className="flex-none">{cDesc[item.size_class]} </p>
                </div>
            </div>
        );
    }
}
ContainerDetails.PropTypes = {
    item: PropTypes.object,
    index: PropTypes.number
};
