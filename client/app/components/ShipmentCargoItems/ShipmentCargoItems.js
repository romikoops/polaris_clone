import React, { Component } from 'react';
import { ValidatedInput } from '../ValidatedInput/ValidatedInput';
import PropTypes from 'prop-types';
import { Checkbox } from '../Checkbox/Checkbox';
import styles from './ShipmentCargoItems.scss';
import defs from '../../styles/default_classes.scss';
// import Select from 'react-select';
import { NamedSelect } from '../NamedSelect/NamedSelect';
import '../../styles/select-css-custom.css';
import styled from 'styled-components';

export class ShipmentCargoItems extends Component {
    constructor(props) {
        super(props);
        this.state = {
            cargoItemType: [{}],
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
    handleCargoItemQ(ev) {
        const nameKeys = ev.nameKey.split('-');
        const ev1 = { target: { name: nameKeys[0] + 'quantity', value: ev.label } };
        this.props.handleDelta(ev1);
    }
    handleCargoItemType(ev) {
        const nameKeys = ev.nameKey.split('-');
        if (ev.dimension_x) {
            const evX = { target: { name: nameKeys[0] + 'dimension_x', value: ev.dimension_x } };
            const evY = { target: { name: nameKeys[0] + 'dimension_y', value: ev.dimension_y } };
            this.props.handleDelta(evX);
            this.props.handleDelta(evY);
        }
        const ev1 = { target: { name: nameKeys[0] + 'cargo_item_type_id', value: ev.key } };
        const cargoItemTypes = this.state.cargoItemTypes;
        cargoItemTypes[parseInt(nameKeys[0], 10)] = ev;
        this.setState({cargoItemType: cargoItemTypes});
        this.props.handleDelta(ev1);
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
        const { cargoItems, handleDelta, theme, cargoItemTypes } = this.props;
        const { cargoItemType } = this.state;
        const cargosAdded = [];
        // const newCargoItem = cargoItems[0];
        const StyledSelect = styled(NamedSelect)`
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
        const colliTypes = cargoItemTypes ? cargoItemTypes.map((ct) => {
            return {label: ct.description, key: ct.id, dimension_x: ct.dimension_x, dimension_y: ct.dimension_y};
        }) : [];
        const numbers = [];
        for (let i = 1; i <= 20; i++) {
            numbers.push({label: i, value: i});
        }
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        if (cargoItems) {
            cargoItems.forEach((cont, i) => {
                    const tmpCont = (
                        <div key={i} className="layout-row flex-100 layout-wrap layout-align-start-center" >
                            <div className="layout-row flex-90 layout-wrap layout-align-start-center" >
                                <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                                    <div className="layout-row flex layout-wrap layout-align-start-center" >
                                        <p className="flex-100 letter_1"> Gross Weight </p>
                                        <div className={`flex-95 layout-row ${styles.input_box}`}>
                                            <ValidatedInput
                                                className="flex-80"
                                                name={`${i}-payload_in_kg`}
                                                value={cont.payload_in_kg}
                                                type="number"
                                                onChange={() => handleDelta}
                                                firstRenderInputs={() => this.state.firstRenderInputs}
                                                setFirstRenderInputs={() => this.setFirstRenderInputs}
                                                nextStageAttempt={() => this.props.nextStageAttempt}
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
                                        <p className="flex-100 letter_1"> Height </p>
                                        <div className={`flex-95 layout-row ${styles.input_box}`}>
                                            <ValidatedInput
                                                className="flex-80"
                                                name={`${i}-dimension_z`}
                                                value={cont.dimension_z}
                                                type="number"
                                                min="0"
                                                step="any"
                                                onChange={() => handleDelta}
                                                firstRenderInputs={() => this.state.firstRenderInputs}
                                                setFirstRenderInputs={() => this.setFirstRenderInputs}
                                                nextStageAttempt={() => this.props.nextStageAttempt}
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
                                        <p className="flex-100 letter_1"> Length </p>
                                        <div className={`flex-95 layout-row ${styles.input_box}`}>
                                            <ValidatedInput
                                                className="flex-80"
                                                name={`${i}-dimension_x`}
                                                value={cont.dimension_x}
                                                type="number"
                                                min="0"
                                                step="any"
                                                onChange={() => handleDelta}
                                                firstRenderInputs={() => this.state.firstRenderInputs}
                                                setFirstRenderInputs={() => this.setFirstRenderInputs}
                                                nextStageAttempt={() => this.props.nextStageAttempt}
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
                                        <p className="flex-100 letter_1"> Width </p>
                                        <div className={`flex-95 layout-row ${styles.input_box}`}>
                                            <ValidatedInput
                                                className="flex-80"
                                                name={`${i}-dimension_y`}
                                                value={cont.dimension_y}
                                                type="number"
                                                min="0"
                                                step="any"
                                                onChange={() => handleDelta}
                                                firstRenderInputs={() => this.state.firstRenderInputs}
                                                setFirstRenderInputs={() => this.setFirstRenderInputs}
                                                nextStageAttempt={() => this.props.nextStageAttempt}
                                                validations={ {matchRegexp: /[^0]/} }
                                                validationErrors={ {matchRegexp: 'Must not be 0', isDefaultRequiredValue: 'Must not be blank'} }
                                                required
                                            />
                                            <div className="flex-20 layout-row layout-align-center-center">
                                                cm
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                                    <div className="layout-row flex layout-wrap layout-align-start-center" >
                                        <p className="flex-100 letter_1"> No. of Cargo Items </p>
                                        <StyledSelect
                                            placeholder={cont.quantity}
                                            classes={styles.select}
                                            name={`${i}-cargo_item_quantity`}
                                            value={cont.quantity}
                                            options={numbers}
                                            onChange={() => this.handleCargoItemQ}
                                        />
                                    </div>
                                    <div className="layout-row flex layout-wrap layout-align-start-center" >
                                        <p className="flex-100 letter_1"> Dangerous Goods </p>
                                        <Checkbox
                                            onChange={() => this.toggleDangerousGoods}
                                            checked={cont.dangerousGoods}
                                            theme={() => this.props.theme}
                                        />
                                    </div>
                                    <div className="layout-row flex-50 layout-wrap layout-align-start-center" >
                                        <p className="flex-100 letter_1"> Colli Type </p>
                                        <StyledSelect
                                            placeholder="Colli Type"
                                            classes={styles.select_100}
                                            name={`${i}-cargo_item_quantity`}
                                            value={cargoItemType[i]}
                                            options={colliTypes}
                                            onChange={() => this.handleCargoItemType}
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
                                <p classNme="flex-100"> Add another </p>
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
