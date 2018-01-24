import React, { Component } from 'react';
import PropTypes from 'prop-types';
import '../../styles/select-css-custom.css';
import styles from './ShipmentContainers.scss';
import {
    CONTAINER_DESCRIPTIONS,
    CONTAINER_TARE_WEIGHTS
} from '../../constants';
import { Checkbox } from '../Checkbox/Checkbox';
import defs from '../../styles/default_classes.scss';
import { ValidatedInput } from '../ValidatedInput/ValidatedInput';
import { NamedSelect } from '../NamedSelect/NamedSelect';
import { v4 } from 'node-uuid';

const containerDescriptions = CONTAINER_DESCRIPTIONS;
const containerTareWeights = CONTAINER_TARE_WEIGHTS;

export class ShipmentContainers extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectors: [{}],
            firstRenderInputs: !this.props.nextStageAttempt
        };
        this.handleContainerSelect = this.handleContainerSelect.bind(this);
        this.handleContainerQ = this.handleContainerQ.bind(this);
        this.toggleDangerousGoods = this.toggleDangerousGoods.bind(this);
        this.setFirstRenderInputs = this.setFirstRenderInputs.bind(this);
        this.addContainer = this.addContainer.bind(this);
    }

    handleContainerSelect(optionSelected) {
        const index = optionSelected.index;
        const modifiedEventSizeClass = {
            target: { name: `${index}-sizeClass`, value: optionSelected.value }
        };
        const modifiedEventTareWeight = {
            target: { name: `${index}-tareWeight`, value: optionSelected.tare_weight }
        };
        const { selectors } = this.state;
        selectors[index] = { sizeClass: optionSelected.value };
        this.setState({ selectors });
        this.props.handleDelta(modifiedEventSizeClass);
        this.props.handleDelta(modifiedEventTareWeight);
    }

    handleContainerQ(event) {
        const modifiedEvent = { target: event };
        this.props.handleDelta(modifiedEvent);
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

    addContainer() {
        this.props.addContainer();

        const selectors = this.state.selectors;
        selectors.push({});

        this.setState({selectors, firstRenderInputs: true});
    }

    render() {
        const { containers, handleDelta } = this.props;
        const { selectors } = this.state;
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
        const numberOptions = [];
        for (let i = 1; i <= 20; i++) {
            numberOptions.push({label: i, value: i});
        }

        const optionsWithIndex = (options, index) => {
            return options.map(option => {
                const optionCopy = Object.assign([], option);
                optionCopy.index = index;
                return optionCopy;
            });
        };
        const generateSeparator = () => (
            <div key={v4()} className={`${styles.separator} flex-100`}>
                <hr/>
            </div>
        );
        const generateContainer = (container, i) => {
            const grossWeight = container ? (
                parseInt(container.payload_in_kg, 10) +
                parseInt(container.tareWeight, 10)
            ) : '';
            return (
                <div
                    key={i}
                    className="layout-row flex-100 layout-wrap layout-align-start-center"
                    style={{ position: 'relative' }}
                >
                    <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                        <p className={`${styles.input_label} flex-100`}> Container Size </p>
                        <NamedSelect
                            placeholder={container ? container.sizeClass : ''}
                            className="flex-95"
                            name={`${i}-container_size`}
                            value={container ? selectors[i].sizeClass : ''}
                            options={container ? optionsWithIndex(containerOptions, i) : []}
                            onChange={this.handleContainerSelect}
                        />
                    </div>
                    <div className="layout-row flex-20 layout-wrap layout-align-start-center">
                        <p className={`${styles.input_label} flex-100`}> Net Weight </p>
                        <div
                            className={`flex-95 layout-row ${styles.input_box}`}
                        >
                            {
                                container ? (
                                    <ValidatedInput
                                        className="flex-80"
                                        name={`${i}-payload_in_kg`}
                                        value={container ? container.payload_in_kg : ''}
                                        type="number"
                                        onChange={handleDelta}
                                        firstRenderInputs={this.state.firstRenderInputs}
                                        setFirstRenderInputs={this.setFirstRenderInputs}
                                        nextStageAttempt={this.props.nextStageAttempt}
                                        validations={ {matchRegexp: /[^0]/} }
                                        validationErrors={ {matchRegexp: 'Must not be 0', isDefaultRequiredValue: 'Must not be blank'} }
                                        required={!!container}
                                    />
                                ) : (
                                    <input
                                        className="flex-80"
                                        type="number"
                                    />
                                )
                            }
                            <div className="flex-20 layout-row layout-align-center-center">
                                kg
                            </div>
                        </div>
                    </div>
                    <div className="layout-row flex-20 layout-wrap layout-align-start-center">
                        <p className={`${styles.input_label} flex-100`}> Gross Weight </p>
                        <div
                            className={`flex-95 layout-row ${styles.input_box}`}
                        >
                            <input
                                className="flex-80"
                                name={`${i}-payload_in_kg`}
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
                        <p className={`${styles.input_label} flex-100`}> No. of Containers </p>
                        <NamedSelect
                            placeholder={container ? container.quantity : ''}
                            className="flex-95"
                            name={`${i}-quantity`}
                            value={container ? container.quantity : ''}
                            options={numberOptions}
                            onChange={this.handleContainerQ}
                        />
                    </div>
                    <div className="layout-row flex-20 layout-wrap layout-align-start-center">
                        <p className={`${styles.input_label} flex-100`}> Dangerous Goods </p>
                        <Checkbox
                            onChange={this.toggleDangerousGoods}
                            checked={container ? container.dangerousGoods : false}
                            theme={this.props.theme}
                            size="34px"
                        />
                    </div>

                    {
                        container ? (
                            <i
                                className={`fa fa-trash ${styles.delete_icon}`}
                                onClick={() => this.deleteCargo(i)}
                            ></i>
                        ) : ''
                    }
                </div>
            );
        };
        const containersAdded = [];
        if (containers) {
            containers.forEach((container, i) => {
                if (i > 0) containersAdded.push(generateSeparator());
                if (!selectors[i].sizeClass) {
                    this.handleContainerSelect(optionsWithIndex(containerOptions, i)[0]);
                }
                containersAdded.push(generateContainer(container, i));
            });
        }
        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center-start" >
                <div
                    className={`layout-row flex-none ${defs.content_width} layout-wrap layout-align-start-center`}
                    style={{ margin: '30px 0 70px 0' }}
                >
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        {containersAdded}
                    </div>

                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`layout-row flex-none ${styles.add_unit} layout-align-start-center`} onClick={this.addContainer}>
                            <p> Add unit </p>
                            <i className="fa fa-plus-square-o" />
                        </div>
                        <div
                            className={styles.new_container_placeholder}
                        >
                            { generateSeparator(null, -1) }
                            { generateContainer(null, -1) }
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
