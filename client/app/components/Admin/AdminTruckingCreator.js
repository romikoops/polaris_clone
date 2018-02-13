import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { NamedSelect } from '../NamedSelect/NamedSelect';
import { RoundButton } from '../RoundButton/RoundButton';
import { gradientTextGenerator } from '../../helpers';
import { currencyOptions, rateBasises } from '../../constants/admin.constants';

export class AdminTruckingCreator extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectOptions: {},
            options: {},
            nexus: false,
            rateBasis: false,
            truckingBasis: false,
            currency: false,
            cells: [],
            newCell: {
                table: []
            },
            newStep: {},
            weightSteps: [],
            steps: {
                nexus: false,
                rateBasis: false,
                currency: false,
                truckingBasis: false,
                weightSteps: false
            }
        };
        this.handleStepChange = this.handleStepChange.bind(this);
        this.handleRateChange = this.handleRateChange.bind(this);
        this.handleMinimumChange = this.handleMinimumChange.bind(this);
        this.handleChange = this.handleChange.bind(this);
        this.saveEdit = this.saveEdit.bind(this);
        this.handleTopLevelSelect = this.handleTopLevelSelect.bind(this);
        this.addWeightStep = this.addWeightStep.bind(this);
        this.saveWeightSteps = this.saveWeightSteps.bind(this);
        this.addNewCell = this.addNewCell.bind(this);
    }

    handleChange(event) {
        const { name, value } = event.target;
        this.setState({
            newCell: {
                ...this.state.newCell,
                [name]: parseInt(value, 10)
            }
        });
    }
    addNewCell() {
        const {cells, newCell, weightSteps} = this.state;
        const tmpCell = Object.assign({}, newCell);
        tmpCell.table = Object.assign([], weightSteps);
        cells.push(Object.assign({}, tmpCell));
        this.setState({
            cells,
            newCell: {
                table: []
            }
        });
        console.log(this.state.weightSteps);
    }
    addWeightStep() {
        const {newStep, weightSteps} = this.state;
        weightSteps.push(Object.assign({}, newStep));
        this.setState({
            newStep: {},
            weightSteps
        });
    }
    handleStepChange(event) {
        const { name, value } = event.target;
        this.setState({
            newStep: {
                ...this.state.newStep,
                [name]: parseInt(value, 10)
            }
        });
    }

    handleRateChange(event) {
        const { name, value } = event.target;
        const nameKeys = name.split('-').map(i => parseInt(i, 10));
        const cells = Object.assign([], this.state.cells);
        cells[nameKeys[0]].table[nameKeys[1]].value = parseInt(value, 10);
        this.setState({
            cells: cells
        });
    }
    handleMinimumChange(event) {
        const { name, value } = event.target;
        const nameKeys = name.split('-').map(i => parseInt(i, 10));
        const { cells } = this.state;
        const adjCellTable = cells[nameKeys[0]].table.map((x) => {
            x.min_value = parseInt(value, 10);
            return x;
        });
        cells[nameKeys[0]].min_value = parseInt(value, 10);
        cells[nameKeys[0]].table = adjCellTable;
        this.setState({
            cells: cells
        });
    }

    handleTopLevelSelect(selection) {
        this.setState({
            [selection.name]: selection,
            steps: {
                ...this.state.steps,
                [selection.name]: true
            }
        });
    }
    saveWeightSteps() {
        this.setState({steps: {
            ...this.state.steps,
            weightSteps: true
        }});
    }

    saveEdit() {
        console.log(this.state);
        const { cells, nexus, currency, rateBasis, truckingBasis } = this.state;
        const data = cells.map((c) => {
            delete c.min_value;
            c.nexus_id = nexus.value.id;
            c.currency = currency.label;
            return c;
        });
        const meta = {
            type: rateBasis.value,
            modifier: truckingBasis.value,
            nexus_id: nexus.value.id
        };
        this.props.adminDispatch.saveNewTrucking({meta, data});
        // this.props.closeForm();
    }
    prepForSelect(arr, labelKey, valueKey, glossary) {
        return arr.map((a) => {
            return {value: valueKey ? a[valueKey] : a, label: glossary ? glossary[a[labelKey]] : a[labelKey] };
        });
    }

    render() {
        const {theme, nexuses} = this.props;
        const {nexus, currency, rateBasis, steps, cells, newStep, weightSteps, newCell, truckingBasis } = this.state;
        const textStyle = theme && theme.colors ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : {color: 'black'};
        const truckingBasises = [
            {value: 'city', label: 'City'},
            {value: 'zipcode', label: 'Zip Code'}
        ];
        const nexusOpts = this.prepForSelect(nexuses, 'name', false, false);
        const selectNexus = (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className="flex-100 layout-row layout-align-start-center">
                    <h4 className="flex-100 letter_3">Select a Cargo Type</h4>
                    <div className="flex-75 layout-row">
                        <NamedSelect
                            name="nexus"
                            classes={`${styles.select}`}
                            value={nexus}
                            options={nexusOpts}
                            className="flex-100"
                            onChange={this.handleTopLevelSelect}
                        />
                    </div>
                </div>
            </div>
        );
        const selectRateBasis = (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className="flex-100 layout-row layout-align-start-center">
                    <h4 className="flex-100 letter_3">Select a Rate Basis</h4>
                    <div className="flex-75 layout-row">
                        <NamedSelect
                            name="rateBasis"
                            classes={`${styles.select}`}
                            value={rateBasis}
                            options={rateBasises}
                            className="flex-100"
                            onChange={this.handleTopLevelSelect}
                        />
                    </div>
                </div>
            </div>
        );
        const selectTruckingBasis = (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className="flex-100 layout-row layout-align-start-center">
                    <h4 className="flex-100 letter_3">Select your Trucking Zone Basis</h4>
                    <div className="flex-75 layout-row">
                        <NamedSelect
                            name="truckingBasis"
                            classes={`${styles.select}`}
                            value={truckingBasis}
                            options={truckingBasises}
                            className="flex-100"
                            onChange={this.handleTopLevelSelect}
                        />
                    </div>
                </div>
            </div>
        );
        const selectCurrency = (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className="flex-100 layout-row layout-align-start-center">
                    <h4 className="flex-100 letter_3">Select a Currency</h4>
                    <div className="flex-75 layout-row">
                        <NamedSelect
                            name="currency"
                            classes={`${styles.select}`}
                            value={currency}
                            options={currencyOptions}
                            className="flex-100"
                            onChange={this.handleTopLevelSelect}
                        />
                    </div>
                </div>
            </div>
        );
        const nexusResult = (
            <div className="flex-50 layout-row layout-wrap layout-align-start-center">
                <h4 className="flex-none letter_3">Location: </h4>
                <div className="flex-10"></div>
                <h4 className="flex-none letter_3">{nexus.label}</h4>
            </div>
        );
        const currencyResult = (
            <div className="flex-50 layout-row layout-wrap layout-align-start-center">
                <h4 className="flex-none letter_3">Currency: </h4>
                <div className="flex-10"></div>
                <h4 className="flex-none letter_3">{currency.label}</h4>
            </div>
        );
        const rateBasisResult = (
            <div className="flex-50 layout-row layout-wrap layout-align-start-center">
                <h4 className="flex-none letter_3">Rate Basis: </h4>
                <div className="flex-10"></div>
                <h4 className="flex-none letter_3">{rateBasis.label}</h4>
            </div>
        );
        const truckingBasisResult = (
            <div className="flex-50 layout-row layout-wrap layout-align-start-center">
                <h4 className="flex-none letter_3">Trucking Zone Basis: </h4>
                <div className="flex-10"></div>
                <h4 className="flex-none letter_3">{truckingBasis.label}</h4>
            </div>
        );

        const panel = cells.map((s, i) => {
            return (
                <div key={`cell_${i}`} className="flex-100 layout-row layout-align-start-center layout-wrap">
                    <div className="flex-50 layout-row layout-row layout-wrap layout-align-start-start">
                        <p className="flex-none">{` Effective Zipcode Range ${s.lower_zip} - ${s.upper_zip}`}</p>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                        <div  className="flex-25 layout-row layout-wrap layout-align-start-start">
                            <div className="flex-100 layout-row layout-align-start-center">
                                <p className="flex-none sup">Minimum charge (Flat Rate)</p>
                            </div>
                            <div className="flex-100 layout-row layout-align-start-center input_box">
                                <input type="number" value={s.min_value} onChange={this.handleMinimumChange} name={`${i}-minimum`}/>
                            </div>
                        </div>
                        {
                            weightSteps.map((ws, iw) => {
                                return (<div key={`ws_${iw}`} className="flex-25 layout-row layout-wrap layout-align-start-start">
                                    <div className="flex-100 layout-row layout-align-start-center">
                                        <p className="flex-none sup">{`${ws.min} - ${ws.max} ${currency.label} ${rateBasis.label}`}</p>
                                    </div>
                                    <div className="flex-100 layout-row layout-align-start-center input_box">
                                        <input type="number" value={s.table[iw].value} onChange={this.handleRateChange} name={`${i}-${iw}`}/>
                                    </div>
                                </div>);
                            })

                        }
                    </div>
                </div>
            );
        });
        const addNewPrice = (
            <div className="flex-100 layout-row layout-align-start-center">
                <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
                    <div className="flex-100 layout-row layout-align-start-center">
                        <p className="flex-none sup_l">Lower limit zipcode</p>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-center input_box">
                        <input type="number" name="lower_zip" value={newCell.lower_zip} placeholder="Lower Zip" onChange={this.handleChange}/>
                    </div>
                </div>
                <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
                    <div className="flex-100 layout-row layout-align-start-center">
                        <p className="flex-none sup_l">Upper limit zipcode</p>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-center input_box">
                        <input type="number" name="upper_zip" value={newCell.upper_zip} placeholder="Upper Zip" onChange={this.handleChange}/>
                    </div>
                </div>
                <div className="flex-10 layout-row layout-align-center-center" onClick={this.addNewCell}>
                    <p className="flex-none">Add another zip code</p>
                    <i className="fa fa-plus-square-o clip" style={textStyle}></i>
                </div>
            </div>
        );
        const rateView = (
            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                {addNewPrice}
                {panel}
            </div>
        );
        const weightStepsArr = (
            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                {
                    weightSteps.map((ws, i) => {
                        return (
                            <div key={`ows_${i}`} className="flex-33 layout-row layout-wrap layout-align-center-start">
                                <div className="flex-100 layout-row">
                                    <p className="flex-none">{`Weight Range:  ${ws.min} ${ws.max} ${rateBasis.label}`}</p>
                                </div>
                            </div>
                        );
                    })
                }
            </div>
        );
        const setWeightSteps = (
            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                <div className="flex-100 layout-row layout-align-start-center">
                    <p className="flex-none no_m">{`Set pricing weight steps. Values ${rateBasis.label} and inclusive`}</p>
                </div>
                <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start input_box_full">
                    <input type="number" name="min" value={newStep.min} placeholder="Lower Limit" onChange={this.handleStepChange}/>
                </div>
                <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start input_box_full">
                    <input type="number" name="max" value={newStep.max} placeholder="Upper Limit" onChange={this.handleStepChange}/>
                </div>
                <div className="flex-33 layout-row layout-align-center-center" onClick={this.addWeightStep}>
                    <p className="flex-none">Add another weight step</p>
                    <i className="fa fa-plus-square-o clip" style={textStyle}></i>
                </div>
                <div className="flex-100 layout-row layout-align-start-center">
                    {weightStepsArr}
                </div>
                <div className="flex-100 layout-row layout-align-end-center">
                    <RoundButton
                        theme={theme}
                        size="small"
                        text="Next"
                        active
                        handleNext={this.saveWeightSteps}
                        iconClass="fa-chevron-right"
                    />
                </div>
            </div>
        );
        const saveBtn = (
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
        );
        const contextPanel = (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                    {steps.nexus === false ? selectNexus :  nexusResult}
                    {steps.nexus === true && steps.rateBasis === false ? selectRateBasis : rateBasisResult}
                    {steps.rateBasis === true && steps.currency === false ? selectCurrency : currencyResult }
                    {steps.currency === true && steps.truckingBasis === false ? selectTruckingBasis : truckingBasisResult }
                    {steps.truckingBasis === true && steps.weightSteps === false ? setWeightSteps : weightStepsArr }
                </div>
            </div>
        );
        return(
            <div className={` ${styles.editor_backdrop} flex-none layout-row layout-wrap layout-align-center-center`}>
                <div className={` ${styles.editor_fade} flex-none layout-row layout-wrap layout-align-center-start`} onClick={this.props.closeForm}>
                </div>
                <div className={` ${styles.editor_box} flex-none layout-row layout-wrap layout-align-center-start`}>
                    <div className="flex-95 layout-row layout-wrap layout-align-center-start">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                            <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >New Trucking Pricing</p>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <div className="flex-60 layout-row layout-align-start-center">
                                <i className="fa fa-map-signs clip" style={textStyle}></i>
                                <p className="flex-none offset-5">{nexus ? nexus.label : ''}</p>
                            </div>
                        </div>
                        {steps.weightSteps ? rateView : contextPanel}
                        {cells.length > 0 ? saveBtn : ''}
                    </div>
                </div>
            </div>
        );
    }
}
AdminTruckingCreator.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    pricing: PropTypes.object,
    isNew: PropTypes.bool,
    userId: PropTypes.number
};
