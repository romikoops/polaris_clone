import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Select from 'react-select';
import 'react-select/dist/react-select.css';
import styles from './ShipmentContainers.scss';
import {
    CONTAINER_DESCRIPTIONS,
    CONTAINER_TARE_WEIGHTS
} from '../../constants';
import { Checkbox } from '../Checkbox/Checkbox';
import defs from '../../styles/default_classes.scss';
import { ValidatedInput } from '../ValidatedInput/ValidatedInput';
import styled from 'styled-components';

const containerDescriptions = CONTAINER_DESCRIPTIONS;
const containerTareWeights = CONTAINER_TARE_WEIGHTS;

export class ShipmentContainers extends Component {
    constructor(props) {
        super(props);
        this.handleContainerSelect = this.handleContainerSelect.bind(this);
        this.toggleDangerousGoods = this.toggleDangerousGoods.bind(this);
        this.state = {firstRenderInputs: !this.props.nextStageAttempt};
        this.setFirstRenderInputs = this.setFirstRenderInputs.bind(this);
        this.addContainer = this.addContainer.bind(this);
    }

    handleContainerSelect(val) {
        const ev1 = { target: { name: 'sizeClass', value: val.value } };
        const ev2 = { target: { name: 'tareWeight', value: val.tare_weight } };
        this.props.handleDelta(ev1);
        this.props.handleDelta(ev2);
    }

    setFirstRenderInputs(bool) {
        this.setState({firstRenderInputs: bool});
    }

    toggleDangerousGoods() {
        const event = {
            target: {
                name: 'dangerousGoods',
                value: !this.props.containers[0].dangerousGoods
            }
        };
        this.props.handleDelta(event);
    }
    deleteCargo(index) {
        this.props.deleteItem('containers', index);
    }
    addContainer(event) {
        this.setState({firstRenderInputs: true});
        this.props.addContainer(event);
    }

    render() {
        const { containers, handleDelta } = this.props;
        const newContainer = containers[0];
        const containerOptions = [];
        Object.keys(containerDescriptions).forEach(key => {
            containerOptions.push({
                value: key,
                label: containerDescriptions[key],
                tare_weight: containerTareWeights[key]
            });
        });
        const grossWeight =
            parseInt(newContainer.payload_in_kg, 10) +
            parseInt(newContainer.tareWeight, 10);
        const containersAdded = [];
        if (this.props.containers) {
            this.props.containers.forEach((cont, i) => {
                if (i !== 0) {
                    const tmpCont = (
                        <div className="flex-100 layout-row">
                            <div className="flex-20 layout-row layout-align-center-center">
                                {containerDescriptions[cont.sizeClass]}
                            </div>
                            <div className="flex-20 layout-row layout-align-center-center">
                                {cont.payload_in_kg} kg
                            </div>
                            <div className="flex-20 layout-row layout-align-center-center">
                                {parseInt(cont.payload_in_kg, 10) +
                                    parseInt(cont.tareWeight, 10)}{' '}
                                kg
                            </div>
                            <div className="flex-20 layout-row layout-align-center-center">
                                Dangerous Goods:{' '}
                                {cont.dangerousGoods ? 'Yes' : 'No'}
                            </div>
                            <div className="flex-10 layout-row layout-align-center-center">
                                <i className="fa fa-trash flex-none" onClick={() => this.deleteCargo(i)}></i>
                            </div>
                        </div>
                    );
                    containersAdded.push(tmpCont);
                }
            });
        }
        const StyledSelect = styled(Select)`
            .Select-control {
                background-color: #F9F9F9;
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2 !important;
            }
            .Select-menu-outer {
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2;
            }
            .Select-value {
                background-color: #F9F9F9;
                border: 1px solid #F2F2F2;
            }
            .Select-option {
                background-color: #F9F9F9;
            }
        `;
        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
                <div className={`layout-row flex-none ${defs.content_width} layout-wrap layout-align-start-center`} >
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                        <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                            <p className="flex-100"> Container Size </p>
                            <StyledSelect
                                placeholder={newContainer.sizeClass}
                                className={styles.select}
                                name="container-size"
                                value={newContainer.type}
                                options={containerOptions}
                                onChange={this.handleContainerSelect}
                            />
                        </div>
                        <div className="layout-row flex-20 layout-wrap layout-align-start-center">
                            <p className="flex-100"> Net Weight </p>
                            <div
                                className={`flex-95 layout-row ${
                                    styles.input_box
                                }`}
                            >
                                <ValidatedInput
                                    className="flex-80"
                                    name="payload_in_kg"
                                    value={newContainer.payload_in_kg}
                                    type="number"
                                    onChange={handleDelta}
                                    firstRenderInputs={this.state.firstRenderInputs}
                                    setFirstRenderInputs={this.setFirstRenderInputs}
                                    nextStageAttempt={this.props.nextStageAttempt}
                                    validations={ {matchRegexp: /[^0]/} }
                                    validationErrors={ {matchRegexp: 'Must not be 0', isDefaultRequiredValue: 'Must not be blank'} }
                                    required
                                />
                                <div className="flex-20 layout-row layout-align-center-center">
                                    kg
                                </div>
                            </div>
                        </div>
                        <div className="layout-row flex-20 layout-wrap layout-align-start-center">
                            <p className="flex-100"> Gross Weight </p>
                            <div
                                className={`flex-95 layout-row ${
                                    styles.input_box
                                }`}
                            >
                                <input
                                    className="flex-80"
                                    name="payload_in_kg"
                                    value={grossWeight}
                                    type="number"
                                    disabled
                                />
                                <div className="flex-20 layout-row layout-align-center-center">
                                    kg
                                </div>
                            </div>
                        </div>

                        <div className="layout-row flex-20 layout-wrap layout-align-start-center">
                            <p className="flex-100"> Dangerous Goods </p>
                            <Checkbox
                                onChange={this.toggleDangerousGoods}
                                checked={newContainer.dangerousGoods}
                                theme={this.props.theme}
                            />
                        </div>
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`layout-row flex-none ${styles.add_unit} layout-align-start-center`} onClick={this.addContainer}>
                            <i className="fa fa-plus-square-o" />
                            <p> Add unit </p>
                        </div>
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className="layout-row flex-100 layout-wrap">
                            {containersAdded}
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

ShipmentContainers.propTypes = {
    theme: PropTypes.object,
    addContainer: PropTypes.func,
    containers: PropTypes.array,
    handleDelta: PropTypes.func,
    deleteCargo: PropTypes.func
};
