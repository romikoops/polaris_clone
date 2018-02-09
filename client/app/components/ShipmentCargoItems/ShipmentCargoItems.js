import React, { Component } from 'react';
import { ValidatedInput } from '../ValidatedInput/ValidatedInput';
import PropTypes from 'prop-types';
import { Checkbox } from '../Checkbox/Checkbox';
import styles from './ShipmentCargoItems.scss';
import defs from '../../styles/default_classes.scss';
import { NamedSelect } from '../NamedSelect/NamedSelect';
import '../../styles/select-css-custom.css';
import { v4 } from 'node-uuid';
import { Tooltip } from '../Tooltip/Tooltip';
import ReactTooltip from 'react-tooltip';
import { TextHeading } from '../TextHeading/TextHeading';

export class ShipmentCargoItems extends Component {
    constructor(props) {
        super(props);
        this.state = {
            cargoItemTypes: [],
            firstRenderInputs: !this.props.nextStageAttempt
        };
        this.handleCargoChange = this.handleCargoChange.bind(this);
        this.addNewCargo = this.addNewCargo.bind(this);
        this.toggleDangerousGoods = this.toggleDangerousGoods.bind(this);
        this.setFirstRenderInputs = this.setFirstRenderInputs.bind(this);
        this.handleCargoItemQ = this.handleCargoItemQ.bind(this);
        this.handleCargoItemType = this.handleCargoItemType.bind(this);
    }

    handleCargoChange(event) {
        const { name, value } = event.target;
        this.setState({
            newCargoItem: { ...this.state.newCargoItem, [name]: value }
        });
    }

    setFirstRenderInputs(bool) {
        this.setState({firstRenderInputs: bool});
    }

    addNewCargo() {
        this.props.addCargoItem();
        this.setState({firstRenderInputs: true});
    }
    handleCargoItemQ(event) {
        const modifiedEvent = { target: event };
        this.props.handleDelta(modifiedEvent);
    }
    handleCargoItemType(event) {
        const index = event.name.split('-')[0];
        const modifiedEvent = {
            target: { name: event.name, value: event.key }
        };
        const newCargoItemTypes = this.state.cargoItemTypes;
        newCargoItemTypes[index] = event;
        this.setState({cargoItemTypes: newCargoItemTypes});
        this.props.handleDelta(modifiedEvent);

        console.log('event');
        console.log(event);
        if (!event.dimension_x) return;

        const modifiedEventDimentionX = {
            target: { name: index + '-dimension_x', value: event.dimension_x }
        };
        const modifiedEventDimentionY = {
            target: { name: index + '-dimension_y', value: event.dimension_y }
        };
        this.props.handleDelta(modifiedEventDimentionX);
        this.props.handleDelta(modifiedEventDimentionY);
    }
    toggleDangerousGoods(i) {
        const event = {
            target: {
                name: i + '-dangerousGoods',
                value: !this.props.cargoItems[i].dangerousGoods
            }
        };
        this.props.handleDelta(event);
    }
    deleteCargo(index) {
        const { cargoItemTypes } = this.state;
        cargoItemTypes.splice(index, 1);
        this.setState({ cargoItemTypes });

        this.props.deleteItem('cargoItems', index);
    }
    render() {
        const { cargoItems, handleDelta, theme, scope } = this.props;
        const { cargoItemTypes } = this.state;
        const cargosAdded = [];
        const availableCargoItemTypes = this.props.availableCargoItemTypes ? (
            this.props.availableCargoItemTypes.map(cargoItemType => (
                {
                    label: cargoItemType.description,
                    key: cargoItemType.id,
                    dimension_x: cargoItemType.dimension_x,
                    dimension_y: cargoItemType.dimension_y
                }
            ))
        ) : [];
        const numberOptions = [];
        for (let i = 1; i <= 20; i++) {
            numberOptions.push({label: i, value: i});
        }
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const placeholderInput = (
            <input
                className="flex-80"
                type="number"
            />
        );
        const generateSeparator = () => (
            <div key={v4()} className={`${styles.separator} flex-100`}>
                <hr/>
            </div>
        );
        const generateCargoItem = (cargoItem, i) => (
            <div
                key={i}
                className="layout-row flex-100 layout-wrap layout-align-start-center"
                style={{ position: 'relative' }}
            >
                <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                    <div className="layout-row flex-50 layout-wrap layout-align-start-center" >
                        <div style={{ width: '97.75%' }}>
                            <p className={`${styles.input_label} flex-100`}> Colli Type </p>
                            <NamedSelect
                                placeholder=""
                                className={styles.select_100}
                                name={`${i}-colliType`}
                                value={cargoItemTypes[i]}
                                options={availableCargoItemTypes}
                                onChange={this.handleCargoItemType}
                            />
                        </div>
                    </div>
                    <div className="layout-row flex layout-wrap layout-align-start-center" >
                        <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                            <p className={`${styles.input_label} flex-none`}> Gross Weight </p>
                            <Tooltip theme={theme} icon="fa-info-circle" text="payload_in_kg" />
                        </div>
                        <div className={`flex-95 layout-row ${styles.input_box}`}>
                            {
                                cargoItem ? (
                                    <ValidatedInput
                                        className="flex-80"
                                        name={`${i}-payload_in_kg`}
                                        value={cargoItem.payload_in_kg}
                                        type="number"
                                        onChange={handleDelta}
                                        firstRenderInputs={this.state.firstRenderInputs}
                                        setFirstRenderInputs={this.setFirstRenderInputs}
                                        nextStageAttempt={this.props.nextStageAttempt}
                                        validations={{ nonNegative: (values, value) => value > 0 }}
                                        validationErrors={{
                                            nonNegative: 'Must be greater than 0',
                                            isDefaultRequiredValue: 'Must not be blank'
                                        }}
                                        required
                                    />
                                ) : placeholderInput
                            }
                            <div className="flex-20 layout-row layout-align-center-center">
                                kg
                            </div>
                        </div>
                    </div>
                    <div className="layout-row flex layout-wrap layout-align-start-center" >
                        <p className={`${styles.input_label} flex-100`}> Height </p>
                        <div className={`flex-95 layout-row ${styles.input_box}`}>
                            {
                                cargoItem ? (
                                    <ValidatedInput
                                        className="flex-80"
                                        name={`${i}-dimension_z`}
                                        value={cargoItem.dimension_z}
                                        type="number"
                                        min="0"
                                        step="any"
                                        onChange={handleDelta}
                                        firstRenderInputs={this.state.firstRenderInputs}
                                        setFirstRenderInputs={this.setFirstRenderInputs}
                                        nextStageAttempt={this.props.nextStageAttempt}
                                        validations={{ nonNegative: (values, value) => value > 0 }}
                                        validationErrors={{
                                            nonNegative: 'Must be greater than 0',
                                            isDefaultRequiredValue: 'Must not be blank'
                                        }}
                                        required
                                    />
                                ) : placeholderInput
                            }
                            <div className="flex-20 layout-row layout-align-center-center">
                                cm
                            </div>
                        </div>
                    </div>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                    <div className="layout-row flex layout-wrap layout-align-start-center" >
                        <p className={`${styles.input_label} flex-100`}> Length </p>
                        <ReactTooltip />
                        <div
                            className={`flex-95 layout-row ${styles.input_box}`}
                            data-tip={
                                cargoItem && !!cargoItemTypes[i].dimension_x ? (
                                    'Length is automatically set by \'Collie Type\''
                                ) : ''
                            }
                        >
                            {
                                cargoItem ? (
                                    <ValidatedInput
                                        className="flex-80"
                                        name={`${i}-dimension_x`}
                                        value={cargoItem.dimension_x}
                                        type="number"
                                        min="0"
                                        step="any"
                                        onChange={handleDelta}
                                        firstRenderInputs={this.state.firstRenderInputs}
                                        setFirstRenderInputs={this.setFirstRenderInputs}
                                        nextStageAttempt={this.props.nextStageAttempt}
                                        validations={{ nonNegative: (values, value) => value > 0 }}
                                        validationErrors={{
                                            nonNegative: 'Must be greater than 0',
                                            isDefaultRequiredValue: 'Must not be blank'
                                        }}
                                        required
                                        disabled={!!cargoItemTypes[i].dimension_x}
                                    />
                                ) : placeholderInput
                            }
                            <div className="flex-20 layout-row layout-align-center-center">
                                cm
                            </div>
                        </div>
                    </div>
                    <div className="layout-row flex layout-wrap layout-align-start-center" >
                        <p className={`${styles.input_label} flex-100`}> Width </p>
                        <ReactTooltip />
                        <div
                            className={`flex-95 layout-row ${styles.input_box}`}
                            data-tip={
                                cargoItem && !!cargoItemTypes[i].dimension_y ? (
                                    'Width is automatically set by \'Collie Type\''
                                ) : ''
                            }
                        >
                            {
                                cargoItem ? (
                                    <ValidatedInput
                                        className="flex-80"
                                        name={`${i}-dimension_y`}
                                        value={cargoItem.dimension_y}
                                        type="number"
                                        min="0"
                                        step="any"
                                        onChange={handleDelta}
                                        firstRenderInputs={this.state.firstRenderInputs}
                                        setFirstRenderInputs={this.setFirstRenderInputs}
                                        nextStageAttempt={this.props.nextStageAttempt}
                                        validations={{ nonNegative: (values, value) => value > 0 }}
                                        validationErrors={{
                                            nonNegative: 'Must be greater than 0',
                                            isDefaultRequiredValue: 'Must not be blank'
                                        }}
                                        disabled={!!cargoItemTypes[i].dimension_y}
                                        required
                                    />
                                ) : placeholderInput
                            }
                            <div className="flex-20 layout-row layout-align-center-center">
                                cm
                            </div>
                        </div>
                    </div>
                    <div className="layout-row flex layout-wrap layout-align-start-center" >
                        <p className={`${styles.input_label} flex-100`}> No. of Cargo Items </p>
                        <NamedSelect
                            placeholder={cargoItem ? cargoItem.quantity : ''}
                            className={`${styles.select} flex-95`}
                            name={`${i}-quantity`}
                            value={cargoItem ? cargoItem.quantity : ''}
                            options={cargoItem ? numberOptions : ''}
                            onChange={this.handleCargoItemQ}
                        />
                    </div>
                    <div
                        className="layout-row flex layout-wrap layout-align-start-center"
                    >
                        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                            <p className={`${styles.input_label} flex-none`}> Dangerous Goods </p>
                            <Tooltip theme={theme} icon="fa-info-circle" text="dangerous_goods" />
                        </div>
                        <Checkbox
                            name={`${i}-dangerous_goods`}
                            onChange={() => this.toggleDangerousGoods(i)}
                            checked={cargoItem ? cargoItem.dangerousGoods : false}
                            theme={theme}
                            size="34px"
                            disabled={!scope.dangerous_goods}
                            onClick={scope.dangerous_goods ? '' : this.props.showAlertModal}
                        />
                    </div>
                </div>

                {
                    cargoItem ? (
                        <i
                            className={`fa fa-trash ${styles.delete_icon}`}
                            onClick={() => this.deleteCargo(i)}
                        ></i>
                    ) : ''
                }
            </div>
        );

        if (cargoItems) {
            cargoItems.forEach((cargoItem, i) => {
                if (i > 0) cargosAdded.push(generateSeparator());
                if (!cargoItemTypes[i]) {
                    this.handleCargoItemType(
                        Object.assign(
                            { name: i + '-colliType'},
                            availableCargoItemTypes[1]
                        )
                    );
                }
                cargosAdded.push(generateCargoItem(cargoItem, i));
            });
        }

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
                <div
                    className={`layout-row flex-none ${defs.content_width} layout-wrap layout-align-center-center section_padding`}
                    style={{ margin: '0 0 70px 0' }}
                >
                    <TextHeading theme={theme} text="Cargo Units" size={3}/>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                        { cargosAdded }
                    </div>

                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`${styles.add_unit_wrapper} content_width`}>
                            <div className={`layout-row flex-none ${styles.add_unit} layout-wrap layout-align-center-center`} onClick={this.addNewCargo}>
                                <p> Add unit</p>
                                <i className="fa fa-plus-square-o clip" style={textStyle}/>
                            </div>
                        </div>
                        <div className={`flex-100 ${styles.new_container_placeholder}`} >
                            { generateSeparator(null, -1) }
                            { generateCargoItem(null, -1) }
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

ShipmentCargoItems.propTypes = {
    theme: PropTypes.object,
    deleteItem: PropTypes.func,
    cargoItems: PropTypes.array,
    addCargoItem: PropTypes.func,
    handleDelta: PropTypes.func
};
