import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { NamedSelect } from '../NamedSelect/NamedSelect';
import FormsyInput from '../FormsyInput/FormsyInput';
import { RoundButton } from '../RoundButton/RoundButton';
import { gradientTextGenerator } from '../../helpers';
import { currencyOptions, rateBasises } from '../../constants/admin.constants';
import Formsy from 'formsy-react';
import GmapsWrapper from '../../hocs/GmapsWrapper';
import { PlaceSearch } from '../Maps/PlaceSearch';
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
            cities: [],
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
    addNewCell(model) {
        const {cells, weightSteps} = this.state;
        const tmpCell = {...model};
        tmpCell.table = weightSteps.map(s => Object.assign({}, s));
        cells.push(tmpCell);
        this.setState({
            cells,
            newCell: {
                upper_zip: '',
                lower_zip: '',
                table: []
            }
        });
    }
    addWeightStep(model) {
        const {weightSteps} = this.state;
        weightSteps.push({...model});
        this.setState({
            newStep: {
                min: parseInt(model.max, 10) + 1,
                max: parseInt(model.max, 10) + 4
            },
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

    handlePlaceChange(place) {
        const { cities } = this.state;
        const newLocation = {
            streetNumber: '',
            street: '',
            zipCode: '',
            city: '',
            country: '',
        };
        place.address_components.forEach(ac => {
            if (ac.types.includes('street_number')) {
                newLocation.streetNumber = ac.long_name;
            }

            if (ac.types.includes('route') || ac.types.includes('premise')) {
                newLocation.street = ac.long_name;
            }

            if (ac.types.includes('administrative_area_level_1') || ac.types.includes('locality')) {
                newLocation.city = ac.long_name;
            }

            if (ac.types.includes('postal_code')) {
                newLocation.zipCode = ac.long_name;
            }

            if (ac.types.includes('country')) {
                newLocation.country = ac.long_name;
            }
        });
        newLocation.latitude = place.geometry.location.lat();
        newLocation.longitude = place.geometry.location.lng();
        newLocation.geocodedAddress = place.formatted_address;
        this.setState({
            cities: cities.push(newLocation)
        });
    }

    handleRateChange(event) {
        const { name, value } = event.target;
        const nameKeys = name.split('-').map(i => parseInt(i, 10));
        const cells = [...this.state.cells];
        // debugger;
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
        this.props.closeForm();
    }
    prepForSelect(arr, labelKey, valueKey, glossary) {
        return arr.map((a) => {
            return {value: valueKey ? a[valueKey] : a, label: glossary ? glossary[a[labelKey]] : a[labelKey] };
        });
    }
    grammaratize(label) {
        let result;
        switch(label) {
            case 'Per Container':
                result = 'containers';
                break;
            case 'Per Item':
                result = 'items';
                break;
            case 'Per cbm':
                result = 'cbms';
                break;
            case 'Per cbm/ton':
                result = 'cbms/tons';
                break;
            case 'Per Shipment':
                result = 'shipments';
                break;
            default:
                result = '';
                break;
        }
        return result;
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
                    <h4 className="flex-100 letter_3">Select a City</h4>
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
                            disabled={!steps.nexus}
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
                            disabled={!steps.rateBasis}
                            options={currencyOptions}
                            className="flex-100"
                            onChange={this.handleTopLevelSelect}
                        />
                    </div>
                </div>
            </div>
        );
        const cityInput = (
            <div className="flex-100 layout-row layout-wrap">
                <h3 className="flex-40">Find Cities</h3>
                <div className="offset-5 flex-55">
                    <GmapsWrapper
                        theme={theme}
                        component={PlaceSearch}
                        inputStyles={{
                            width: '96%',
                            marginTop: '9px',
                            background: 'white'
                        }}
                        handlePlaceChange={this.handlePlaceChange}
                        hideMap
                    />
                </div>
            </div>
        );
        console.log(cityInput);
        const panel = cells.map((s, i) => {
            const wsInputs = [];
            weightSteps.forEach((ws, iw) => {
                wsInputs.push(<div key={`ws_${iw}`} className="flex-25 layout-row layout-wrap layout-align-start-start">
                    <div className="flex-100 layout-row layout-align-start-center">
                        <p className="flex-none sup">{`${ws.min} - ${ws.max} ${currency.label} ${rateBasis.label}`}</p>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-center input_box">
                        <input type="number" value={cells[i].table[iw].value} onChange={this.handleRateChange} name={`${i}-${iw}`}/>
                    </div>
                </div>);
            });
            return (
                <div key={`cell_${i}`} className="flex-100 layout-row layout-align-start-center layout-wrap">
                    <div className="flex-50 layout-row layout-row layout-wrap layout-align-start-start">
                        <p className="flex-none">{`Zipcode Range ${s.lower_zip} - ${s.upper_zip}`}</p>
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
                        { wsInputs }
                    </div>
                </div>
            );
        });
        const addNewZip = (
            <div className="flex-100 layout-row layout-align-start-center">
                <Formsy onValidSubmit={this.addNewCell} className="flex-100 layout-row layout-align-start-center" >
                    <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
                        <div className="flex-100 layout-row layout-align-start-center">
                            <p className="flex-none sup_l">Lower limit zipcode</p>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center input_box">
                            <FormsyInput type="number" name="lower_zip" value={newCell.lower_zip} placeholder="Lower Zip" />
                        </div>
                    </div>
                    <div className="flex-33 layout-row layout-row layout-wrap layout-align-center-start">
                        <div className="flex-100 layout-row layout-align-start-center">
                            <p className="flex-none sup_l">Upper limit zipcode</p>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center input_box">
                            <FormsyInput type="number" name="upper_zip" value={newCell.upper_zip} placeholder="Upper Zip" />
                        </div>
                    </div>
                    <div className="flex-33 layout-row layout-align-center-center" >
                        <RoundButton
                            theme={theme}
                            size="small"
                            text="Add another"
                            iconClass="fa-plus-square-o"
                        />
                    </div>
                </Formsy>
            </div>
        );
        const rateView = (
            <div className="flex-100 layout-row layout-align-start-center layout-wrap height_100">
                {addNewZip}
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
                                    <p className="flex-none">{`Weight Range:  ${ws.min} - ${ws.max} ${this.grammaratize(rateBasis.label)}`}</p>
                                </div>
                            </div>
                        );
                    })
                }
            </div>
        );
        const setWeightSteps = (
            <div className="flex-100 layout-row layout-align-start-center layout-wrap height_100">

                <div className="flex-100 layout-row layout-align-start-center">
                    <p className="flex-none">{`Set pricing weight steps. Values ${rateBasis.label} and inclusive`}</p>
                </div>
                <Formsy onValidSubmit={this.addWeightStep} className="flex-100 layout-row layout-align-start-center" >
                    <div className="flex-33 layout-row layout-row layout-wrap layout-align-start-start input_box">
                        <FormsyInput type="number" name="min" value={newStep.min} validations="isNumeric" placeholder="Lower Limit"  />
                    </div>
                    <div className="flex-33 layout-row layout-row layout-wrap layout-align-start-start input_box">
                        <FormsyInput type="number" name="max" value={newStep.max} validations="isNumeric" placeholder="Upper Limit"  />
                    </div>
                    <div className="flex-33 layout-row layout-align-center-center">
                        <RoundButton
                            theme={theme}
                            size="small"
                            text="Add another"
                            iconClass="fa-plus-square-o"
                        />
                    </div>
                </Formsy>
                <div className="flex-100 layout-row layout-align-start-center">
                    {weightStepsArr}
                </div>
                <div className="flex-100 layout-row layout-align-end-center button_padding">
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
            <div className="flex-100 layout-align-end-center layout-row button_padding" style={{margin: '15px'}}>
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

                    {selectNexus}
                    {selectRateBasis}
                    {selectCurrency}
                    {selectTruckingBasis}
                    {steps.truckingBasis === true && steps.weightSteps === false ? setWeightSteps : weightStepsArr }
                </div>
            </div>
        );
        return(
            <div className={` ${styles.editor_backdrop} flex-none layout-row layout-wrap layout-align-center-center`}>
                <div className={` ${styles.editor_fade} flex-none layout-row layout-wrap layout-align-center-start`} onClick={this.props.closeForm}>
                </div>
                <div className={` ${styles.editor_box} flex-none layout-row layout-wrap layout-align-center-start`}>
                    <div className="flex-95 layout-row layout-wrap layout-align-center-start height_100">
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
