import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { NamedSelect } from '../NamedSelect/NamedSelect';
// import 'react-select/dist/react-select.css';
// import styled from 'styled-components';
import { RoundButton } from '../RoundButton/RoundButton';
import { currencyOptions, cargoOptions, cargoClassOptions, moTOptions } from '../../constants/admin.constants';
import { fclChargeGlossary, lclChargeGlossary, chargeGlossary, rateBasises} from '../../constants';

const fclChargeGloss = fclChargeGlossary;
const lclChargeGloss = lclChargeGlossary;
const chargeGloss = chargeGlossary;
const rateOpts = rateBasises;
// import {v4} from 'node-uuid';
const currencyOpts = currencyOptions;
const cargoOpts = cargoOptions;
const cargoClassOpts = cargoClassOptions;
const moTOpts = moTOptions;
const test = '123';
export class AdminPriceEditor extends Component {
    constructor(props) {
        super(props);
        this.state = {
            pricing: Object.assign({}, this.props.pricing),
            mot: this.selectFromOptions(moTOpts, props.transport.mode_of_transportation),
            cargoClass: this.selectFromOptions(cargoClassOpts, props.transport.cargo_class),
            cargo: this.selectFromOptions(cargoOpts, props.transport.name),
            selectOptions: {},
            options: {}
        };
        this.editPricing = props.pricing;
        this.handleChange = this.handleChange.bind(this);
        this.handleSelect = this.handleSelect.bind(this);
        this.setMOT = this.setMOT.bind(this);
        this.setCargo = this.setCargo.bind(this);
        this.saveEdit = this.saveEdit.bind(this);
        this.setCargoClass = this.setCargoClass.bind(this);
        this.setAllFromOptions = this.setAllFromOptions.bind(this);
    }
    componentWillMount() {
        console.log(test);
        this.setAllFromOptions();
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
    setAllFromOptions() {
        const { pricing } = this.props;
        const newObj = {data: {}};
        const tmpObj = {};

        Object.keys(pricing.data).forEach((key) => {
            if (!newObj.data[key]) {
                newObj.data[key] = {};
            }
            if (!tmpObj[key]) {
                tmpObj[key] = {};
            }
            let opts;
            Object.keys(pricing.data[key]).forEach(chargeKey => {
                if (chargeKey === 'currency') {
                    opts = currencyOpts.slice();
                    // this.getOptions(opts, key, chargeKey);
                } else if (chargeKey === 'rate_basis') {
                    opts = rateOpts.slice();
                    // this.getOptions(opts, key, chargeKey);
                }
                newObj.data[key][chargeKey] = this.selectFromOptions(opts, pricing.data[key][chargeKey]);
            });
        });
        this.setState({selectOptions: newObj, options: tmpObj});
    }
    handleChange(event) {
        const { name, value } = event.target;
        const nameKeys = name.split('-');
        this.setState({
            pricing: {
                ...this.state.pricing,
                data: {
                    ...this.state.pricing.data,
                    [nameKeys[0]]: {
                        ...this.state.pricing.data[nameKeys[0]],
                        [nameKeys[1]]: parseInt(value, 10)
                    }
                }
            }
        });
    }
    handleSelect(selection) {
        console.log(selection);

        console.log(this.state.pricing.data);
        const nameKeys = selection.nameKey.split('-');
        this.setState({
            pricing: {
                ...this.state.pricing,
                data: {
                    ...this.state.pricing.data,
                    [nameKeys[0]]: {
                        ...this.state.pricing.data[nameKeys[0]],
                        [nameKeys[1]]: selection.value
                    }
                }
            },
            selectOptions: {
                ...this.state.selectOptions,
                data: {
                    ...this.state.selectOptions.data,
                    [nameKeys[0]]: {
                        ...this.state.selectOptions.data[nameKeys[0]],
                        [nameKeys[1]]: selection
                    }
                }
            }
        });
        console.log({
            pricing: {
                ...this.state.pricing,
                data: {
                    ...this.state.pricing.data,
                    [nameKeys[0]]: {
                        ...this.state.pricing.data[nameKeys[0]],
                        [nameKeys[1]]: selection.value
                    }
                }
            },
            selectOptions: {
                ...this.state.selectOptions,
                data: {
                    ...this.state.selectOptions.data,
                    [nameKeys[0]]: {
                        ...this.state.selectOptions.data[nameKeys[0]],
                        [nameKeys[1]]: selection
                    }
                }
            }
        });
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
        const req = this.state.pricing;

        this.props.adminTools.updatePricing(this.props.pricing._id, req);
        this.props.closeEdit();
    }
    render() {
        const {theme, hubRoute } = this.props;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const { pricing, selectOptions } = this.state;
        const panel = [];
        let gloss;
        if (pricing._id.includes('lcl')) {
            gloss = lclChargeGloss;
        } else {
            gloss = fclChargeGloss;
        }

        Object.keys(pricing.data).forEach((key) => {
            const cells = [];
            Object.keys(pricing.data[key]).forEach(chargeKey => {
                if (chargeKey !== 'currency' && chargeKey !== 'rate_basis') {
                    cells.push(
                        <div key={chargeKey} className={`flex layout-row layout-align-none-center layout-wrap ${styles.price_cell}`}>
                            <p className="flex-100">{chargeGloss[chargeKey]}</p>
                            <div className={`flex-95 layout-row ${styles.editor_input}`}>
                                <input type="number" value={pricing.data[key][chargeKey]} onChange={this.handleChange} name={`${key}-${chargeKey}`}/>
                            </div>
                        </div>
                    );
                } else if (chargeKey === 'rate_basis') {
                    cells.push( <div className={`flex layout-row layout-align-none-center layout-wrap ${styles.price_cell}`}>
                        <p className="flex-100">{chargeGloss[chargeKey]}</p>
                        <NamedSelect
                            name={`${key}-${chargeKey}`}
                            classes={`${styles.select}`}
                            value={selectOptions ? selectOptions.data[key][chargeKey] : ''}
                            options={rateOpts}
                            onChange={this.handleSelect}
                        />
                    </div>);
                } else if (chargeKey === 'currency') {
                    cells.push( <div key={chargeKey} className={`flex layout-row layout-align-none-center layout-wrap ${styles.price_cell}`}>
                        <p className="flex-100">{chargeGloss[chargeKey]}</p>
                        <div className="flex-95 layout-row">
                            <NamedSelect
                                name={`${key}-currency`}
                                classes={`${styles.select}`}
                                value={selectOptions ? selectOptions.data[key].currency : ''}
                                options={currencyOpts}
                                onChange={this.handleSelect}
                            />
                        </div>
                    </div>);
                }
            });
            panel.push( <div key={key} className="flex-100 layout-row layout-align-none-center layout-wrap">
                <div className={`flex-100 layout-row layout-align-start-center ${styles.price_subheader}`}>
                    <p className="flex-none">{key} - {gloss[key]}</p>
                </div>
                <div className="flex-100 layout-row layout-align-start-center">
                    { cells }
                </div>
            </div>);
        });

        return(
            <div className={` ${styles.editor_backdrop} flex-none layout-row layout-wrap layout-align-center-center`}>
                <div className={` ${styles.editor_box} flex-none layout-row layout-wrap layout-align-center-start`}>
                    <div className="flex-95 layout-row layout-wrap layout-align-center-start">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                            <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Edit Pricing</p>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <div className="flex-60 layout-row layout-align-start-center">
                                <i className="fa fa-map-signs clip" style={textStyle}></i>
                                <p className="flex-none offset-5">{hubRoute.name}</p>
                            </div>
                            {/* <div className="flex-40 layout-row layout-align-center-center" >
                                <StyledSelect
                                    name="hub-filter"
                                    className={`${styles.select}`}
                                    value={currency}
                                    options={currencyOpts}
                                    onChange={this.setCurrency}
                                />
                            </div>*/}
                        </div>
                        <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                            <div className="flex-50 layout-row layout-align-start-center">
                                <p className="flex-none">MoT:</p>
                            </div>
                            <div className="flex-50 layout-row layout-align-end-center">
                                <p className="flex-none">{moTOpts[this.props.transport.mode_of_transport]}</p>
                            </div>
                        </div>
                        <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                            <div className="flex-50 layout-row layout-align-start-center">
                                <p className="flex-none">Cargo Type: </p>
                            </div>
                            <div className="flex-50 layout-row layout-align-end-center">
                                <p className="flex-none">{cargoOpts[this.props.transport.cargo_class]}</p>
                            </div>
                            {/* <p className="flex-none">{transport.name}</p> */}
                        </div>
                        <div className={`flex-95 layout-row layout-align-space-between-center ${styles.edit_row_detail}`}>
                            <div className="flex-50 layout-row layout-align-start-center">
                                <p className="flex-none">Cargo Class:</p>
                            </div>
                            <div className="flex-50 layout-row layout-align-end-center">
                                <p className="flex-none">{cargoClassOpts[this.props.transport.name]}</p>
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
