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
                    <h4>Unit {index + 1 }</h4>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Gross Weight</p>
                    <p>{item.payload_in_kg} kg</p>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Container Class</p>
                    <p>{cDesc[item.size_class]} </p>
                </div>
            </div>
        );
    }
}
ContainerDetails.propTypes = {
    item: PropTypes.object,
    index: PropTypes.number
};
