import React, {Component} from 'react';
import PropTypes from 'prop-types';
import './BookingDetails.scss';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import { AddressBook } from '../AddressBook/AddressBook';
import { ShipmentContactsBox } from '../ShipmentContactsBox/ShipmentContactsBox';
import { CargoDetails } from '../CargoDetails/CargoDetails';
import { RoundButton } from '../Roundbutton/Roundbutton';

export class BookingDetails extends Component {
    constructor(props) {
        super(props);
        this.state = {
            addressBook: false,
            consignee: {
                firstName: '',
                lastName: '',
                email: '',
                phone: '',
                street: '',
                number: '',
                zipCode: '',
                city: '',
                country: ''
            },
            shipper: {
                firstName: '',
                lastName: '',
                email: '',
                phone: '',
                street: '',
                number: '',
                zipCode: '',
                city: '',
                country: ''
            },
            notifyees: [

            ],
            default: {
                contact: {
                    firstName: '',
                    lastName: '',
                    email: '',
                    phone: '',
                    street: '',
                    number: '',
                    zipCode: '',
                    city: '',
                    country: ''
                },
                notifyee: {
                    firstName: '',
                    lastName: '',
                    email: '',
                    phone: ''
                }
            },
            insurance: {
                bool: false
            },
            customs: {
                bool: false
            },
            hsCode: '',
            totalGoodsValue: 0,
            cargoNotes: ''

        };
        this.addNotifyee = this.addNotifyee.bind(this);
        this.setFromBook = this.setFromBook.bind(this);
        this.handleInput = this.handleInput.bind(this);
        this.handleNotifyeeInput = this.handleNotifyeeInput.bind(this);
        this.toggleAddressBook = this.toggleAddressBook.bind(this);
    }

    setFromBook(target, value) {
        this.setState({[target]: value});
    }
    toggleAddressBook() {
        const addressBool = this.state.addressBook;
        this.setState({addressBook: !addressBool});
    }
    addNotifyee() {
        const prevArr = this.state.notifyees;
        prevArr.push(this.state.default.notifyee);
        this.setState({notifyees: prevArr});
    }
    handleInput(event) {
        const { name, value } = event.target;
        const targetKeys = name.split('-');
        console.log(name, value);
        this.setState({
            [targetKeys[0]]: {...this.state[targetKeys[0]], [targetKeys[1]]: value}
        });
    }
    handleNotifyeeInput(event) {
        const { name, value } = event.target;
        const targetKeys = name.split('-');
        this.setState({
            [targetKeys[0]]: {...this.state[targetKeys[0]], [targetKeys[1]]: value}
        });
    }
    pushUpData() {
        const { consignee, shipper, notifyees, hsCode, totalGoodsValue, cargoNotes} = this.state;
        const data = {
            shipment: {
                id: this.props.shipmentData.shipment.id,
                consignee,
                shipper,
                notifyees,
                hsCode,
                totalGoodsValue,
                cargoNotes
            }
        };
        debugger;
        this.props.nextStage(data);
    }

    toNextStage() {
        this.pushUpData();
    }

    render() {
        const { theme, shipmentData } = this.props;
        const { shipment, hubs, contacts, userLocations, schedules } = shipmentData;
        const { consignee, shipper, notifyees } = this.state;
        const addrView = this.state.addressBook ?
        <AddressBook contacts={contacts} userLocations={userLocations} theme={theme} setDetails={this.setFromBook}/> :
        <ShipmentContactsBox consignee={consignee} shipper={shipper} addNotifyee={this.addNotifyee} notifyees={notifyees} theme={theme} handleChange={this.handleInput} handleNotifyeeChange={this.handleNotifyeeInput}/>;
        return (
        <div className="flex-100 layout-row layout-wrap layout-align-center-start">
            <div className="flex-100 layout-row layout-align-end-center">
              <RoundButton active text="Address Book" handleNext={this.toggleAddressBook}/>
            </div>
          { shipment ? <RouteHubBox hubs={hubs} route={schedules[0]} theme={theme}/> : ''}
          {addrView}
          <CargoDetails />
        </div>

      );
    }
}
BookingDetails.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    nextStage: PropTypes.func
};
