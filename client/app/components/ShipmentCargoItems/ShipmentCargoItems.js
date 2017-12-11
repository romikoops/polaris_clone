import React, { Component } from 'react';
import { ValidatedInput } from '../ValidatedInput/ValidatedInput';
import PropTypes from 'prop-types';
import { Checkbox } from '../Checkbox/Checkbox';
import styles from './ShipmentCargoItems.scss';
import defs from '../../styles/default_classes.scss';

export class ShipmentCargoItems extends Component {
    constructor(props) {
        super(props);
        this.handleCargoChange = this.handleCargoChange.bind(this);
        this.addNewCargo = this.addNewCargo.bind(this);
        this.toggleDangerousGoods = this.toggleDangerousGoods.bind(this);
        this.state = {firstRenderInputs: !this.props.nextStageAttempt};
        this.setFirstRenderInputs = this.setFirstRenderInputs.bind(this);
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
        if (cargoItems) {
            cargoItems.forEach((cont, i) => {
                if (i !== 0) {
                    const tmpCont = (
                        <div key={i} className="flex-100 layout-row">
                            <div className="flex-15 layout-row layout-align-center-center">
                                Unit {i}
                            </div>
                            <div className="flex-15 layout-row layout-align-center-center">
                                {cont.payload_in_kg} kg
                            </div>
                            <div className="flex-15 layout-row layout-align-center-center">
                                {cont.dimension_y} cm
                            </div>
                            <div className="flex-15 layout-row layout-align-center-center">
                                {cont.dimension_x} cm
                            </div>
                            <div className="flex-15 layout-row layout-align-center-center">
                                {cont.dimension_z} cm
                            </div>
                            <div className="flex-15 layout-row layout-align-center-center">
                                Dangerous Goods:{' '}
                                {cont.dangerousGoods ? 'Yes' : 'No'}
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
                        <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                            <p className="flex-100"> Gross Weight </p>
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
                        <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                            <p className="flex-100"> Height </p>
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
                        <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                            <p className="flex-100"> Width </p>
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
                        <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                            <p className="flex-100"> Length </p>
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
                        <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                            <p className="flex-100"> Dangerous Goods </p>
                            <Checkbox onChange={this.toggleDangerousGoods} checked={newCargoItem.dangerousGoods} />
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
