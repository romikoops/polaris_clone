import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import Select from 'react-select';
import 'react-select/dist/react-select.css';
import styled from 'styled-components';
import { RoundButton } from '../RoundButton/RoundButton';
import { currencyOptions, cargoOptions, cargoClassOptions, moTOptions } from '../../constants/admin.constants';
import {v4} from 'node-uuid';
const currencyOpts = currencyOptions;
const cargoOpts = cargoOptions;
const cargoClassOpts = cargoClassOptions;
const moTOpts = moTOptions;
export class AdminPriceEditor extends Component {
    constructor(props) {
        super(props);
        this.state = {
            currency: props.currency ? props.currency : 'EUR',
            mot: props.transport.mode_of_transportation ? this.selectFromOptions(moTOpts, props.transport.mode_of_transportation) : moTOpts[0],
            cargoClass: props.transport.cargo_class ? this.selectFromOptions(cargoClassOpts, props.transport.cargo_class) : cargoClassOpts[0],
            cargo: props.transport.name ? this.selectFromOptions(cargoOpts, props.transport.name) : cargoOpts[0],
            wmRate: props.pricing.wm.rate ? props.pricing.wm.rate : 0,
            wmMin: props.pricing.wm.min ? props.pricing.wm.min : 0,
            heavyWmMin: props.pricing.heavy_wm && props.pricing.heavy_wm.heavy_weight ? props.pricing.heavy_wm.heavy_weight : 0,
            heavyWmRate: props.pricing.heavy_wm && props.pricing.heavy_wm.heavy_wm_min ? props.pricing.heavy_wm.heavy_wm_min : 0,
            heavyKg: props.pricing.heavy_kg && props.pricing.heavy_kg.heavy_weight ? props.pricing.heavy_kg.heavy_weight : 0,
            heavyKgMin: props.pricing.heavy_kg && props.pricing.heavy_kg.heavy_kg_min ? props.pricing.heavy_kg.heavy_kg_min : 0
        };
        this.handleChange = this.handleChange.bind(this);
        this.setCurrency = this.setCurrency.bind(this);
        this.setMOT = this.setMOT.bind(this);
        this.setCargo = this.setCargo.bind(this);
        this.saveEdit = this.saveEdit.bind(this);
        this.setCargoClass = this.setCargoClass.bind(this);
    }
    selectFromOptions(options, value) {
        let result;
        console.log(options);
        options.forEach(op => {
            if (op.value === value) {
                result = op;
            }
        });
        return result ? result : options[0];
    }
    handleChange(event) {
        const { name, value } = event.target;
        this.setState({[name]: value});
    }
    setCurrency(value) {
        this.setState({currency: value});
    }
    setMOT(value) {
        this.setState({mot: value});
    }
    setCargo(value) {
        this.setState({cargo: value});
    }
    setCargoClass(value) {
        this.setState({cargoClass: value});
    }
    saveEdit() {
        const { currency, cargoClass, wmRate, wmMin, heavyWmMin, heavyWmRate, heavyKg, heavyKgMin } = this.state;
        const req = {};

        if (cargoClass.value === 'lcl') {
            req.wm = {
                rate: wmRate,
                min: wmMin,
                currency
            };
            req.heavy_wm = {
                currency,
                heavy_weight: heavyWmRate,
                heavy_wm_min: heavyWmMin
            };
        } else {
            req.wm = {
                rate: wmRate,
                currency
            };
            req.heavy_kg = {
                currency,
                heavy_weight: heavyKg,
                heavy_kg_min: heavyKgMin
            };
        }
        this.props.adminTools.updatePricing(this.props.pricing._id, req);
        this.props.closeEdit();
    }
    render() {
        const {theme, hubRoute } = this.props;
        // const { selectedPricing } = this.state;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
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
        const { currency, mot, cargoClass, cargo, wmRate, wmMin, heavyWmMin, heavyWmRate, heavyKg, heavyKgMin } = this.state;
        const panel = cargoClass.value === 'lcl' ?
            (<div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.price_row}`}>
                <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                    <div className="flex-50 layout-row layout-align-start-center">
                        <p className="flex-none">Rate per WM</p>
                    </div>
                    <div className={`flex-50 layout-row layout-align-end-center ${styles.editor_input}`}>
                        <input type="number" name="wmRate" value={wmRate} onChange={this.handleChange}/>
                    </div>
                </div>
                <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                    <div className="flex-50 layout-row layout-align-start-center">
                        <p className="flex-none">Minimum WM: </p>
                    </div>
                    <div className={`flex-50 layout-row layout-align-end-center ${styles.editor_input}`}>
                        <input type="number" name="wmMin" value={wmMin} onChange={this.handleChange}/>
                    </div>
                </div>
                <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                    <div className="flex-50 layout-row layout-align-start-center">
                        <p className="flex-none"> Heavy Weight Surcharge</p>
                    </div>
                    <div className={`flex-50 layout-row layout-align-end-center ${styles.editor_input}`}>
                        <input type="number" name="heavyWmRate" value={heavyWmRate} onChange={this.handleChange}/>
                    </div>
                </div>
                <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                    <div className="flex-50 layout-row layout-align-start-center">
                        <p className="flex-none">Minimum Heavy WM</p>
                    </div>
                    <div className={`flex-50 layout-row layout-align-end-center ${styles.editor_input}`}>
                        <input type="number" name="heavyWmMin" value={heavyWmMin} onChange={this.handleChange}/>
                    </div>
                </div>
            </div>) :
            (<div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.price_row}`}>
                <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                    <div className="flex-50 layout-row layout-align-start-center">
                        <p className="flex-none">Rate per Container</p>
                    </div>
                    <div className={`flex-50 layout-row layout-align-end-center ${styles.editor_input}`}>
                        <input type="number" name="wmRate" value={wmRate} onChange={this.handleChange}/>
                    </div>
                </div>
                <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                    <div className="flex-50 layout-row layout-align-start-center">
                        <p className="flex-none">Surcharge per Heavy Container</p>
                    </div>
                    <div className={`flex-50 layout-row layout-align-end-center ${styles.editor_input}`}>
                        <input type="number" name="heavyKg" value={heavyKg} onChange={this.handleChange}/>
                    </div>
                </div>
                <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                    <div className="flex-50 layout-row layout-align-start-center">
                        <p className="flex-none">Minimum Heavy Weight</p>
                    </div>
                    <div className={`flex-50 layout-row layout-align-end-center ${styles.editor_input}`}>
                        <input type="number" name="heavyKgMin" value={heavyKgMin} onChange={this.handleChange}/>
                    </div>
                </div>
            </div>);


        return(
            <div className={` ${styles.editor_backdrop} flex-none layout-row layout-wrap layout-align-center-center`}>
                <div className={` ${styles.editor_box} flex-none layout-row layout-wrap layout-align-center-center`}>
                    <div key={v4()} className="flex-80 layout-row layout-wrap layout-align-center-start">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                            <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Edit Pricing</p>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <div className="flex-60 layout-row layout-align-start-center">
                                <i className="fa fa-map-signs clip" style={textStyle}></i>
                                <p className="flex-none offset-5">{hubRoute.name}</p>
                            </div>
                            <div className="flex-40 layout-row layout-align-center-center" >
                                <StyledSelect
                                    name="hub-filter"
                                    className={`${styles.select}`}
                                    value={currency}
                                    options={currencyOpts}
                                    onChange={this.setCurrency}
                                />
                            </div>
                        </div>
                        <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                            <div className="flex-50 layout-row layout-align-start-center">
                                <p className="flex-none">MoT:</p>
                            </div>
                            <div className="flex-50 layout-row layout-align-end-center">
                                <StyledSelect
                                    name="hub-filter"
                                    className={`${styles.select}`}
                                    value={mot}
                                    options={moTOpts}
                                    onChange={this.setMOT}
                                />
                            </div>
                        </div>
                        <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                            <div className="flex-50 layout-row layout-align-start-center">
                                <p className="flex-none">Cargo Type: </p>
                            </div>
                            <div className="flex-50 layout-row layout-align-end-center">
                                <StyledSelect
                                    name="hub-filter"
                                    className={`${styles.select}`}
                                    value={cargo}
                                    options={cargoOpts}
                                    onChange={this.setCargo}
                                />
                            </div>
                            {/* <p className="flex-none">{transport.name}</p> */}
                        </div>
                        <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                            <div className="flex-50 layout-row layout-align-start-center">
                                <p className="flex-none">Cargo Class:</p>
                            </div>
                            <div className="flex-50 layout-row layout-align-end-center">
                                <StyledSelect
                                    name="hub-filter"
                                    className={`${styles.select}`}
                                    value={cargoClass}
                                    options={cargoClassOpts}
                                    onChange={this.setCargoClass}
                                />
                            </div>
                        </div>
                        {panel}
                        <div className="flex-100 layout-align-end-center layout-row" style={{margin: '15px'}}>
                            <RoundButton
                                theme={theme}
                                size="small"
                                text="Save"
                                active
                                handleNext={this.saveEdit}
                                iconClass="fa-floppy-o"
                            />
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}
AdminPriceEditor.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    pricing: PropTypes.object,
    isNew: PropTypes.bool,
    userId: PropTypes.number
};
