import React, {Component} from 'react';
import PropTypes from 'prop-types';
import GmapsLoader from '../../hocs/GmapsLoader';
import './ShipmentDetails.scss';
import {moment} from '../../constants';
import DayPickerInput from 'react-day-picker/DayPickerInput';
import 'react-day-picker/lib/style.css';
import { RoundButton } from '../RoundButton/RoundButton';
import { ShipmentLocationBox } from '../ShipmentLocationBox/ShipmentLocationBox';
import { ShipmentContainers } from '../ShipmentContainers/ShipmentContainers';
import { ShipmentCargoItems } from '../ShipmentCargoItems/ShipmentCargoItems';
import { RouteSelector } from '../RouteSelector/RouteSelector';

export class ShipmentDetails extends Component {
    constructor(props) {
        super(props);
        // const { shipment } = this.props;
        console.log(this.props);
        this.state = {
            origin: {
                street: '',
                zipCode: '',
                city: '',
                fullAddress: ''
            },
            destination: {
                street: '',
                zipCode: '',
                city: '',
                fullAddress: ''
            },
            containers: [],
            cargoItems: [],
            shipment: this.props.shipmentData.data,
            allNexuses: this.props.shipmentData.all_nexuses,
            routeSet: false
        };
        if (this.props.shipmentData.data) {
            this.state.selectedDay = this.props.shipmentData.data.planned_pickup_date;
            this.state.has_on_carriage = this.props.shipmentData.data.has_on_carriage;
            this.state.has_pre_carriage = this.props.shipmentData.data.has_pre_carriage;
        }
        this.handleAddressChange = this.handleAddressChange.bind(this);
        this.handleDayChange = this.handleDayChange.bind(this);
        this.handleNextStage = this.handleNextStage.bind(this);
        this.addNewCargoItem = this.addNewCargoItem.bind(this);
        this.addNewContainer = this.addNewContainer.bind(this);
        this.setTargetLocation = this.setTargetLocation.bind(this);
        this.selectRoute = this.selectRoute.bind(this);
        this.toggleCarriage = this.toggleCarriage.bind(this);
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
    addNewCargoItem(ci) {
        const currArray = this.state.cargoItems;
        currArray.push(ci);
        this.setState({cargoItems: currArray});
    }
    addNewContainer(cont) {
        const currArray = this.state.containers;
        currArray.push(cont);
        this.setState({containers: currArray});
    }
    setTargetLocation(target, address) {
        this.setState({[target]: address});
    }
    handleNextStage() {
        console.log('NEXT STAGE PLZ');
        const data = {
            shipment: this.state.shipment ? this.state.shipment : this.props.shipmentData.data
        };
        data.shipment.origin_user_input = this.state.origin.fullAddress ? this.state.origin.fullAddress : '';
        data.shipment.destination_user_input = this.state.destination.fullAddress ? this.state.destination.fullAddress : '';
        data.shipment.origin_id = this.state.origin.hub_id;
        data.shipment.destination_id = this.state.destination.hub_id;
        data.shipment.cargo_items_attributes = this.state.cargoItems;
        data.shipment.containers_attributes = this.state.containers;
        data.shipment.has_on_carriage = this.state.has_on_carriage;
        data.shipment.has_pre_carriage = this.state.has_pre_carriage;
        data.shipment.planned_pickup_date = this.state.selectedDay;
        this.props.setShipmentDetails(data);
    }
    returnToDashboard() {
        this.props.history.push('/dashboard');
    }
    selectRoute(route) {
        this.setState({selectedRoute: route, routeSet: true});
    }
    toggleCarriage(target, value) {
        this.setState({[target]: value});
    }

    render() {
        // const textStyle = {
        //     background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        // }
        const { theme } = this.props;
        let cargoDetails;
        if (this.props.shipmentData.data) {
            if (this.props.shipmentData.data.load_type.includes('fcl')) {
                cargoDetails = <ShipmentContainers containers={this.state.containers} addContainer={this.addNewContainer}/>;
            }
            if (this.props.shipmentData.data.load_type.includes('lcl')) {
                cargoDetails = <ShipmentCargoItems cargoItems={this.state.cargoItems} addCargoItem={this.addNewCargoItem}/>;
            }
          // cargoDetails =  this.state.shipment && this.state.shipment.load_type.includes('fcl') ? <ShipmentContainers containers={this.state.containers} addContainer={this.addNewContainer}/> : <ShipmentCargoItems cargoItems={this.state.cargoItems} addCargoItem={this.addNewCargoItem}/>;
        }
        const rSelect = <RouteSelector theme={theme} setRoute={this.selectRoute} publicRoutes={this.props.shipmentData.public_routes} privateRoutes={this.props.shipmentData.private_routes}/>;
        const mapBox = <GmapsLoader theme={theme} selectLocation={this.setTargetLocation} allNexuses={this.props.shipmentData.all_nexuses} component={ShipmentLocationBox} selectedRoute={this.state.selectedRoute} toggleCarriage={this.toggleCarriage}/>;
        const value = this.state.selectedDay ? moment(this.state.selectedDay).format('DD/MM/YYYY') : '';
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
            { this.state.routeSet ? mapBox : rSelect }
          </div>
          <div className="layout-row flex-100 layout-wrap" >
            {cargoDetails}
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className="layout-row flex-75 layout-wrap layout-align-start-center" >
              <RoundButton text="Choose from haulage options" handleNext={this.handleNextStage} theme={theme} active />
            </div>
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className="layout-row flex-75 layout-wrap layout-align-start-center" >
              <RoundButton text="Back to Dashboard" handleNext={this.returnToDashboard} iconClass="fa-angle-left" theme={theme} back/>
            </div>
          </div>
        </div>
      );
    }
}

ShipmentDetails.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    history: PropTypes.object,
    match: PropTypes.object,
    setShipmentDetails: PropTypes.func
};
