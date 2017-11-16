import React, {Component} from 'react';
import PropTypes from 'prop-types';
import Select from 'react-select';
import 'react-select/dist/react-select.css';
import GmapsLoader from '../../hocs/GmapsLoader';
import { CONTAINER_DESCRIPTIONS, CONTAINER_TARE_WEIGHTS } from '../../constants';
// import { moment } from '../../constants';
// import { connect } from 'react-redux';
// import { MapContainer } from '../Map/Map';
import './ShipmentDetails.scss';
import DayPickerInput from 'react-day-picker/DayPickerInput';
import 'react-day-picker/lib/style.css';
import { RoundButton } from '../RoundButton/RoundButton';
import { ShipmentLocationBox } from '../ShipmentLocationBox/ShipmentLocationBox';
const containerDescriptions = CONTAINER_DESCRIPTIONS;
const containerTareWeights = CONTAINER_TARE_WEIGHTS;
export class ShipmentDetails extends Component {
    constructor(props) {
        super(props);
        console.log(this.props);
        this.state = {
            selectedDay: undefined,
            origin: {
                street: '',
                zipCode: '',
                city: ''
            },
            destination: {
                street: '',
                zipCode: '',
                city: ''
            },
            containers: {
                new: {
                    weight: 0,
                    type: '',
                    tare_weight: 0
                },
                added: []
            }
        };
        this.handleAddressChange = this.handleAddressChange.bind(this);
        this.handleDayChange = this.handleDayChange.bind(this);
        this.handleWeightChange = this.handleWeightChange.bind(this);
        this.handleNextStage = this.handleNextStage.bind(this);
        this.handleContainerSelect = this.handleContainerSelect.bind(this);
        this.addNewContainer = this.addNewContainer.bind(this);
        this.newContainerGrossWeight = this.newContainerGrossWeight.bind(this);
    }
    newContainerGrossWeight() {
        const container = this.state.containers.new;
        container.type ? container.tare_weight + container.weight : 0;
    }
    handleDayChange(selectedDay) {
        this.setState({ selectedDay });
    }
    logChange(val) {
        console.log('Selected: ', val);
    }

    handleAddressChange(event) {
        const eventKeys = event.target.name.split('-');
        const key1 = eventKeys[0];
        const key2 = eventKeys[1];
        const val = event.target.value;
        this.setState({
            [key1]: {
                [key2]: val
            }
        });
    }
    handleWeightChange(event) {
        const target = event.target;
        this.setState({ containers: {new: { ...this.state.containers.new, weight: target.value } }});
    }
    handleContainerSelect(val) {
        this.setState({
            containers: {
                new: {
                    type: val.value,
                    tare_weight: val.tare_weight
                }
            }
        });
    }
    addNewContainer() {
        const newCont = this.state.containers.new;
        this.setState({
            containers: {
                new: {
                    weight: 0,
                    type: '',
                    tare_weight: 0
                },
                added: [
                    newCont
                ]
            }
        });
    }
    handleNextStage() {
        console.log('NEXT STAGE PLZ');
        this.props.history.push(this.props.match.url + '/choose_route');
    }
    returnToDashboard() {
        this.props.history.push('/dashboard');
    }

    render() {
        const theme = this.props.theme;
        // const textStyle = {
        //     background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        // };
        const containerOptions = [];
        Object.keys(containerDescriptions).forEach(key => {
            containerOptions.push({value: key, label: containerDescriptions[key], tare_weight: containerTareWeights[key]});
        });
        const grossWeight = parseInt(this.state.containers.new.weight, 10) + parseInt(this.state.containers.new.tare_weight, 10);
        const containersAdded = [];
        if (this.state.containers.added) {
            this.state.containers.added.forEach(cont => {
                const tmpCont = (
            <div className="flex-100 layout-row">
              <div className="flex-20 layout-row layout-align-center-center">
                {cont.type}
              </div>
              <div className="flex-20 layout-row layout-align-center-center">
                {cont.weight}
              </div>
              <div className="flex-20 layout-row layout-align-center-center">
                {cont.weight + cont.tare_weight}
              </div>
            </div>
            );
                containersAdded.push(tmpCont);
            });
        }

        const value = this.state.selectedDay ? this.state.selectedDay.format('DD/MM/YYYY') : '';
        return (
        <div className="layout-row flex-100 layout-wrap" >
          <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className="layout-row flex-75 layout-align-start-center" >
              <div className="layout-row flex-none layout-wrap" >
                <p className="flex-100"> {'Approximate Pickup Date:'} </p>
                <DayPickerInput name="birthday"
                  placeholder="DD/MM/YYYY"
                  format="DD/MM/YYYY"
                  value={value}
                  onDayChange={this.handleDayChange} />
              </div>
            </div>
          </div>
          <div className="layout-row flex-100 layout-wrap" >
            <GmapsLoader theme={theme} selectLocation={this.selectOrigin} component={ShipmentLocationBox} />
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className="layout-row flex-75 layout-wrap layout-align-start-center" >
              <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                <p className="flex-100"> Container Size </p>
                <Select name="container-size" value={this.state.containers.new.type} options={containerOptions} onChange={this.handleContainerSelect} />
              </div>
              <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                <p className="flex-100"> Net Weight </p>
                <input value={this.state.containers.new.weight} type="number" onChange={this.handleWeightChange}/>
              </div>
              <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                <p className="flex-100"> Gross Weight </p>
                <input value={grossWeight} type="number" />
              </div>
              <div className="layout-row flex-100 layout-wrap" >
                { containersAdded }
              </div>
            </div>
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className="layout-row flex-75 layout-wrap layout-align-start-center" >
              <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                <p className="flex-100"> Dangerous Goods </p>
                <Select name="dangerous-goods" value="" options={containerOptions} onChange={this.logChange} />
              </div>
              <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                <p className="flex-100"> Insurance </p>
                <Select name="insurance" value="" options={containerOptions} onChange={this.logChange} />
              </div>
            </div>
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className="layout-row flex-75 layout-wrap layout-align-start-center" >
              <RoundButton text="Choose from haulage options" handleNext={this.handleNextStage} theme={theme} active />
              <p> Choose from haulage options </p>
            </div>
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className="layout-row flex-75 layout-wrap layout-align-start-center" >
              <RoundButton text="Back to Dashboard" handleNext={this.returnToDashboard} theme={theme} active={false}/>
              <p> Back to Dashboard </p>
            </div>
          </div>
        </div>
      );
    }
}

ShipmentDetails.propTypes = {
    theme: PropTypes.object,
    shipment: PropTypes.object,
    history: PropTypes.object,
    match: PropTypes.object
};
