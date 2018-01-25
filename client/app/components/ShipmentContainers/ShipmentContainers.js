import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Select from 'react-select';
import '../../styles/select-css-custom.css';
import styles from './ShipmentContainers.scss';
import {
    CONTAINER_DESCRIPTIONS,
    CONTAINER_TARE_WEIGHTS
} from '../../constants';
import { Checkbox } from '../Checkbox/Checkbox';
import defs from '../../styles/default_classes.scss';
import { ValidatedInput } from '../ValidatedInput/ValidatedInput';
import styled from 'styled-components';
import { Tooltip } from '../Tooltip/Tooltip';
const containerDescriptions = CONTAINER_DESCRIPTIONS;
const containerTareWeights = CONTAINER_TARE_WEIGHTS;

export class ShipmentContainers extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectors: {
                // sizeClass: {value: 'fcl_20f', label: '20‘ Dry Container', tare_weight: 2370}
            },
            firstRenderInputs: !this.props.nextStageAttempt
        };
        this.handleContainerSelect = this.handleContainerSelect.bind(this);
        this.handleContainerQ = this.handleContainerQ.bind(this);
        this.toggleDangerousGoods = this.toggleDangerousGoods.bind(this);
        this.setFirstRenderInputs = this.setFirstRenderInputs.bind(this);
        this.addContainer = this.addContainer.bind(this);
    }

    handleContainerSelect(val) {
        const ev1 = { target: { name: 'sizeClass', value: val.value } };
        const ev2 = { target: { name: 'tareWeight', value: val.tare_weight } };
        this.setState({selectors: {sizeClass: val.value}});
        this.props.handleDelta(ev1);
        this.props.handleDelta(ev2);
    }

    handleContainerQ(ev) {
        const ev1 = { target: { name: 'quantity', value: ev } };
        this.props.handleDelta(ev1);
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
        const { containers, handleDelta, theme } = this.props;
        const { selectors } = this.state;
        const newContainer = containers[0];
        const containerOptions = [];
        Object.keys(containerDescriptions).forEach(key => {
            if (key !== 'lcl') {
                containerOptions.push({
                    value: key,
                    label: containerDescriptions[key],
                    tare_weight: containerTareWeights[key]
                });
            }
        });
        if (!selectors.sizeClass) {
            this.handleContainerSelect(containerOptions[0]);
        }
        const numbers = [];
        for (let i = 1; i <= 20; i++) {
            numbers.push({label: i, value: i});
        }
        const grossWeight =
            parseInt(newContainer.payload_in_kg, 10) +
            parseInt(newContainer.tareWeight, 10);
        const containersAdded = [];
        if (this.props.containers) {
            this.props.containers.forEach((cont, i) => {
                if (i !== 0) {
                    const tmpCont = (
                        <div className={`flex-100 layout-row ${styles.container_row}`}>
                            <div className="flex-20 layout-row layout-align-start-center layout-wrap">
                                <p className={`flex-100 ${styles.cell_header}`}> Container Size</p>
                                <p className="flex-100">{containerDescriptions[cont.sizeClass]}</p>
                            </div>
                            <div className="flex-20 layout-row layout-align-start-center layout-wrap">
                                <p className={`flex-100 ${styles.cell_header}`}>Net Weight</p>
                                <p className="flex-100">{cont.payload_in_kg} kg</p>
                            </div>
                            <div className="flex-20 layout-row layout-align-start-center layout-wrap">
                                <p className={`flex-100 ${styles.cell_header}`}> Gross Weight</p>
                                <p className="flex-100">{parseInt(cont.payload_in_kg, 10) + parseInt(cont.tareWeight, 10)}{' '} kg</p>

                            </div>
                            <div className="flex-20 layout-row layout-align-start-center layout-wrap">
                                <p className={`flex-100 ${styles.cell_header}`}>No. of Containers:{' '}</p>

                                <p className="flex-100">{cont.quantity}</p>
                            </div>
                            <div className="flex-10 layout-row layout-align-start-center layout-wrap">
                                <p className={`flex-100 ${styles.cell_header}`}>Dangerous Goods:{' '}</p>

                                <p className="flex-100">{cont.dangerousGoods ? 'Yes' : 'No'}</p>
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
                            <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                                <p className="flex-none letter_1"> Container Size </p>
                                <Tooltip theme={theme} icon="fa-info-circle" text="size_class" />
                            </div>
                            <StyledSelect
                                placeholder={newContainer.sizeClass}
                                className={styles.select}
                                name="container-size"
                                value={selectors.sizeClass}
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
                            <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                                <p className="flex-none letter_1"> Gross Weight </p>
                                <Tooltip theme={theme} icon="fa-info-circle" text="gross_weight" />
                            </div>
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
                        <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                            <p className="flex-100"> No. of Containers </p>
                            <StyledSelect
                                placeholder={newContainer.quantity}
                                className={styles.select}
                                name="container-quantity"
                                value={newContainer.quantity}
                                options={numbers}
                                simpleValue
                                onChange={this.handleContainerQ}
                            />
                        </div>
                        <div className="layout-row flex-20 layout-wrap layout-align-start-center">
                            <p className="flex-100"> Dangerous Goods </p>
                            <Checkbox
                                onChange={this.toggleDangerousGoods}
                                checked={newContainer.dangerousGoods}
                                theme={this.props.theme}
                            />
                             <Tooltip theme={theme} icon="fa-info-circle" text="dangerous_goods" />
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
