import React, { Component } from 'react';
import { ValidatedInput } from '../ValidatedInput/ValidatedInput';
import PropTypes from 'prop-types';
import { Checkbox } from '../Checkbox/Checkbox';
import styles from './ShipmentCargoItems.scss';
import defs from '../../styles/default_classes.scss';
// import Select from 'react-select';
import { NamedSelect } from '../NamedSelect/NamedSelect';
import '../../styles/select-css-custom.css';
import { v4 } from 'node-uuid';

export class ShipmentCargoItems extends Component {
    constructor(props) {
        super(props);
        this.state = {
            cargoItemTypes: [{}],
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
    }
    toggleDangerousGoods() {
        const event = {
            target: {
                name: 'dangerousGoods',
                value: !this.props.cargoItems[0].dangerousGoods
            }
        };
        // this.setState({ newCargoItem: { ...this.state.newCargoItem, dangerousGoods: !this.state.newCargoItem.dangerousGoods } });
        this.props.handleDelta(event);
    }
    deleteCargo(index) {
        this.props.deleteItem('cargoItems', index);
    }

    render() {
        const { cargoItems, handleDelta, theme } = this.props;
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
        const generateSeparator = () => (
            <div key={v4()} className={`${styles.separator} flex-100`}>
                <hr/>
            </div>
        );
        if (cargoItems) {
            cargoItems.forEach((cont, i) => {
                if (i > 0) cargosAdded.push(generateSeparator());
                const tmpCont = (
                    <div
                        key={i}
                        className="layout-row flex-100 layout-wrap layout-align-start-center"
                    >
                        <div className="layout-row flex-90 layout-wrap layout-align-start-center" >
                            <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                                <div className="layout-row flex layout-wrap layout-align-start-center" >
                                    <p className={`${styles.input_label} flex-100`}> Gross Weight </p>
                                    <div className={`flex-95 layout-row ${styles.input_box}`}>
                                        <ValidatedInput
                                            className="flex-80"
                                            name={`${i}-payload_in_kg`}
                                            value={cont.payload_in_kg}
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
                                <div className="layout-row flex layout-wrap layout-align-start-center" >
                                    <p className={`${styles.input_label} flex-100`}> Height </p>
                                    <div className={`flex-95 layout-row ${styles.input_box}`}>
                                        <ValidatedInput
                                            className="flex-80"
                                            name={`${i}-dimension_z`}
                                            value={cont.dimension_z}
                                            type="number"
                                            min="0"
                                            step="any"
                                            onChange={handleDelta}
                                            firstRenderInputs={this.state.firstRenderInputs}
                                            setFirstRenderInputs={this.setFirstRenderInputs}
                                            nextStageAttempt={this.props.nextStageAttempt}
                                            validations={ {matchRegexp: /[^0]/} }
                                            validationErrors={ {matchRegexp: 'Must not be 0', isDefaultRequiredValue: 'Must not be blank'} }
                                            required
                                        />
                                        <div className="flex-20 layout-row layout-align-center-center">
                                            cm
                                        </div>
                                    </div>
                                </div>
                                <div className="layout-row flex-50 layout-wrap layout-align-start-center" >
                                    <p className={`${styles.input_label} flex-100`}> Colli Type </p>
                                    <NamedSelect
                                        placeholder="Colli Type"
                                        className={styles.select_100}
                                        name={`${i}-colliType`}
                                        value={cargoItemTypes[i]}
                                        options={availableCargoItemTypes}
                                        onChange={this.handleCargoItemType}
                                    />
                                </div>
                            </div>
                            <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                                <div className="layout-row flex layout-wrap layout-align-start-center" >
                                    <p className={`${styles.input_label} flex-100`}> Length </p>
                                    <div className={`flex-95 layout-row ${styles.input_box}`}>
                                        <ValidatedInput
                                            className="flex-80"
                                            name={`${i}-dimension_x`}
                                            value={cont.dimension_x}
                                            type="number"
                                            min="0"
                                            step="any"
                                            onChange={handleDelta}
                                            firstRenderInputs={this.state.firstRenderInputs}
                                            setFirstRenderInputs={this.setFirstRenderInputs}
                                            nextStageAttempt={this.props.nextStageAttempt}
                                            validations={ {matchRegexp: /[^0]/} }
                                            validationErrors={ {matchRegexp: 'Must not be 0', isDefaultRequiredValue: 'Must not be blank'} }
                                            required
                                        />
                                        <div className="flex-20 layout-row layout-align-center-center">
                                            cm
                                        </div>
                                    </div>
                                </div>
                                <div className="layout-row flex layout-wrap layout-align-start-center" >
                                    <p className={`${styles.input_label} flex-100`}> Width </p>
                                    <div className={`flex-95 layout-row ${styles.input_box}`}>
                                        <ValidatedInput
                                            className="flex-80"
                                            name={`${i}-dimension_y`}
                                            value={cont.dimension_y}
                                            type="number"
                                            min="0"
                                            step="any"
                                            onChange={handleDelta}
                                            firstRenderInputs={this.state.firstRenderInputs}
                                            setFirstRenderInputs={this.setFirstRenderInputs}
                                            nextStageAttempt={this.props.nextStageAttempt}
                                            validations={ {matchRegexp: /[^0]/} }
                                            validationErrors={ {matchRegexp: 'Must not be 0', isDefaultRequiredValue: 'Must not be blank'} }
                                            required
                                        />
                                        <div className="flex-20 layout-row layout-align-center-center">
                                            cm
                                        </div>
                                    </div>
                                </div>
                                <div className="layout-row flex layout-wrap layout-align-start-center" >
                                    <p className={`${styles.input_label} flex-100`}> No. of Cargo Items </p>
                                    <NamedSelect
                                        placeholder={cont.quantity}
                                        className={styles.select}
                                        name={`${i}-quantity`}
                                        value={cont.quantity}
                                        options={numberOptions}
                                        onChange={this.handleCargoItemQ}
                                    />
                                </div>
                                <div className="layout-row flex layout-wrap layout-align-start-center" >
                                    <p className={`${styles.input_label} flex-100`}> Dangerous Goods </p>
                                    <Checkbox
                                        onChange={this.toggleDangerousGoods}
                                        checked={cont.dangerousGoods}
                                        theme={this.props.theme}
                                        size="34px"
                                    />
                                </div>
                            </div>
                        </div>
                        <div className="flex-10 layout-row layout-align-center-center">
                            <i className="fa fa-trash flex-none" onClick={() => this.deleteCargo(i)}></i>
                        </div>
                    </div>
                );
                cargosAdded.push(tmpCont);
            });
        }

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
                <div className={`layout-row flex-none ${defs.content_width} layout-wrap layout-align-center-center section_padding`} >
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                        { cargosAdded }
                        <div className="layout-row layout-align-start-center flex-100" >
                            <div className={`layout-row flex-none ${styles.add_unit} layout-wrap layout-align-center-center`} onClick={this.addNewCargo}>
                                <i className="fa fa-plus-square-o clip" style={textStyle}/>
                                <p> Add another </p>
                            </div>
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
