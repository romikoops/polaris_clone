import React, { Component } from 'react';
import { ValidatedInput } from '../ValidatedInput/ValidatedInput';
import PropTypes from 'prop-types';
import { Checkbox } from '../Checkbox/Checkbox';
import styles from './ShipmentCargoItems.scss';
import defs from '../../styles/default_classes.scss';
import Select from 'react-select';
import '../../styles/select-css-custom.css';
import styled from 'styled-components';

export class ShipmentCargoItems extends Component {
    constructor(props) {
        super(props);
        this.handleCargoChange = this.handleCargoChange.bind(this);
        this.addNewCargo = this.addNewCargo.bind(this);
        this.toggleDangerousGoods = this.toggleDangerousGoods.bind(this);
        this.state = {firstRenderInputs: !this.props.nextStageAttempt};
        this.setFirstRenderInputs = this.setFirstRenderInputs.bind(this);
        this.handleCargoItemQ = this.handleCargoItemQ.bind(this);
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
        const ev1 = { target: { name: 'quantity', value: ev } };
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
        const { cargoItems, handleDelta } = this.props;
        const cargosAdded = [];
        const newCargoItem = cargoItems[0];
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
        const numbers = [];
        for (let i = 1; i <= 20; i++) {
            numbers.push({label: i, value: i});
        }
        if (cargoItems) {
            cargoItems.forEach((cont, i) => {
                if (i !== 0) {
                    const tmpCont = (
                        <div key={i} className={`flex-100 layout-row ${styles.container_row}`}>
                            <div className="flex-15 layout-row layout-align-center-center">
                                <p className={`flex-100 ${styles.cell_header}`}>Unit</p>
                                <p className="flex-100">{i}</p>
                            </div>
                            <div className="flex-15 layout-row layout-align-center-center">
                                <p className={`flex-100 ${styles.cell_header}`}>Payload</p>
                                <p className="flex-100">{cont.payload_in_kg} kg</p>
                            </div>
                            <div className="flex-15 layout-row layout-align-center-center">
                                <p className={`flex-100 ${styles.cell_header}`}>Depth</p>
                                <p className="flex-100">{cont.dimension_y} cm</p>
                            </div>
                            <div className="flex-15 layout-row layout-align-center-center">
                                <p className={`flex-100 ${styles.cell_header}`}>Width</p>
                                <p className="flex-100">{cont.dimension_x} cm</p>
                            </div>
                            <div className="flex-15 layout-row layout-align-center-center">
                                <p className={`flex-100 ${styles.cell_header}`}>Height</p>
                                <p className="flex-100">{cont.dimension_z} cm</p>
                            </div>
                            <div className="flex-15 layout-row layout-align-center-center">
                                <p className={`flex-100 ${styles.cell_header}`}>Dangerous Goods:{' '}</p>
                                <p className="flex-100">{cont.dangerousGoods ? 'Yes' : 'No'}</p>
                            </div>
                            <div className="flex-10 layout-row layout-align-center-center">
                                <i className="fa fa-trash flex-none" onClick={() => this.deleteCargo(i)}></i>
                            </div>
                        </div>
                    );
                    cargosAdded.push(tmpCont);
                }
            });
        }

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
                <div className={`layout-row flex-none ${defs.content_width} layout-wrap layout-align-center-center`} >
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                        <div className="layout-row flex-15 layout-wrap layout-align-start-center" >
                            <p className="flex-100 letter_1"> Gross Weight </p>
                            <div className={`flex-95 layout-row ${styles.input_box}`}>
                                <ValidatedInput
                                    className="flex-80"
                                    name="payload_in_kg"
                                    value={newCargoItem.payload_in_kg}
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
                        <div className="layout-row flex-15 layout-wrap layout-align-start-center" >
                            <p className="flex-100 letter_1"> Height </p>
                            <div className={`flex-95 layout-row ${styles.input_box}`}>
                                <ValidatedInput
                                    className="flex-80"
                                    name="dimension_z"
                                    value={newCargoItem.dimension_z}
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
                                    cm
                                </div>
                            </div>
                        </div>
                        <div className="layout-row flex-15 layout-wrap layout-align-start-center" >
                            <p className="flex-100 letter_1"> Width </p>
                            <div className={`flex-95 layout-row ${styles.input_box}`}>
                                <ValidatedInput
                                    className="flex-80"
                                    name="dimension_y"
                                    value={newCargoItem.dimension_y}
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
                                    cm
                                </div>
                            </div>
                        </div>
                        <div className="layout-row flex-15 layout-wrap layout-align-start-center" >
                            <p className="flex-100 letter_1"> Length </p>
                            <div className={`flex-95 layout-row ${styles.input_box}`}>
                                <ValidatedInput
                                    className="flex-80"
                                    name="dimension_x"
                                    value={newCargoItem.dimension_x}
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
                                    cm
                                </div>
                            </div>
                        </div>
                        <div className="layout-row flex-15 layout-wrap layout-align-start-center" >
                            <p className="flex-100 letter_1"> No. of Cargo Items </p>
                            <StyledSelect
                                placeholder={newCargoItem.quantity}
                                className={styles.select}
                                name="cargo-item-quantity"
                                value={newCargoItem.quantity}
                                options={numbers}
                                simpleValue
                                onChange={this.handleCargoItemQ}
                            />
                        </div>
                        <div className="layout-row flex-15 layout-wrap layout-align-start-center" >
                            <p className="flex-100 letter_1"> Dangerous Goods </p>
                            <Checkbox
                                onChange={this.toggleDangerousGoods}
                                checked={newCargoItem.dangerousGoods}
                                theme={this.props.theme}
                            />
                        </div>

                        <div className="layout-row layout-align-start-center" >
                            <div className={`layout-row flex-none ${styles.add_unit} layout-align-start-center`} onClick={this.addNewCargo}>
                                <i className="fa fa-plus-square-o" />
                                <p> Add unit </p>
                            </div>
                        </div>
                        <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                            <div className={`layout-row flex-none ${defs.content_width} layout-wrap`} >
                                { cargosAdded }
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
