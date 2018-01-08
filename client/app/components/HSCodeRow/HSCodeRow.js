import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import Select from 'react-select';
import { Async } from 'react-select';
import '../../styles/select-css-custom.css';
import styles from './HSCodeRow.scss';
import {
    CONTAINER_DESCRIPTIONS,
    // CONTAINER_TARE_WEIGHTS,
    BASE_URL
} from '../../constants';
// import { Checkbox } from '../Checkbox/Checkbox';
import defs from '../../styles/default_classes.scss';
// import { ValidatedInput } from '../ValidatedInput/ValidatedInput';
import styled from 'styled-components';
const containerDescriptions = CONTAINER_DESCRIPTIONS;
// const containerTareWeights = CONTAINER_TARE_WEIGHTS;

export class HSCodeRow extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }

    render() {
        const { containers, cargoItems } = this.props;
        const containersAdded = [];
        const cargoItemsAdded = [];
        const StyledSelect = styled(Async)`
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
        const getOptions = (input) => {
            return fetch(`${BASE_URL}/search/hscodes/${input}`)
                .then((response) => {
                    return response.json();
                }).then((json) => {
                    return { options: json };
                });
        };
        if (containers) {
            containers.forEach((cont, i) => {
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
                            <div className="flex-100 layout-row layout-align-start-center">
                                <StyledSelect
                                    name="form-field-name"
                                    value=""
                                    loadOptions={getOptions}
                                />
                            </div>
                        </div>
                    );
                    containersAdded.push(tmpCont);
                }
            });
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

                            <div className="flex-100 layout-row layout-align-start-center">
                                <StyledSelect
                                    name="form-field-name"
                                    value=""
                                    loadOptions={getOptions}
                                />
                            </div>
                        </div>
                    );
                    cargoItemsAdded.push(tmpCont);
                }
            });
        }

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
                <div className={`layout-row flex-none ${defs.content_width} layout-wrap layout-align-start-center`} >
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className="layout-row flex-100 layout-wrap">
                            {containersAdded}
                            {cargoItemsAdded}
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

HSCodeRow.propTypes = {
    theme: PropTypes.object,
    addContainer: PropTypes.func,
    containers: PropTypes.array,
    cargoItems: PropTypes.array,
    deleteCargo: PropTypes.func
};
