import React, { Component } from 'react';
import PropTypes from 'prop-types';
import './BookingDetails.scss';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import { AddressBook } from '../AddressBook/AddressBook';
import { ShipmentContactsBox } from '../ShipmentContactsBox/ShipmentContactsBox';
import { CargoDetails } from '../CargoDetails/CargoDetails';
import { history } from '../../helpers';

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
            notifyees: [],
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
        this.toNextStage = this.toNextStage.bind(this);
        this.handleCargoInput = this.handleCargoInput.bind(this);
    }

    setFromBook(target, value) {
        this.setState({ [target]: value });
    }
    toggleAddressBook() {
        const addressBool = this.state.addressBook;
        this.setState({ addressBook: !addressBool });
    }
    addNotifyee() {
        const prevArr = this.state.notifyees;
        prevArr.unshift(this.state.default.notifyee);
        this.setState({notifyees: prevArr});
    }
    handleInput(event) {
        const { name, value } = event.target;
        const targetKeys = name.split('-');
        console.log(name, value);
        this.setState({
            [targetKeys[0]]: {
                ...this.state[targetKeys[0]],
                [targetKeys[1]]: value
            }
        });
    }
    handleCargoInput(event) {
        const { name, value } = event.target;
        this.setState({ [name]: value });
    }
    handleNotifyeeInput(event) {
        const { name, value } = event.target;
        const targetKeys = name.split('-');
        const ind = parseInt(targetKeys[1], 10);
        const notifyees = this.state.notifyees;
        notifyees[ind][targetKeys[2]] = value;
        this.setState({
<<<<<<< HEAD
            [targetKeys[0]]: {
                ...this.state[targetKeys[0]],
                [targetKeys[1]]: value
            }
=======
            notifyees: notifyees
>>>>>>> master
        });
    }
    pushUpData() {}
    saveDraft() {}
    toDashboard() {
        history.push('/dashboard');
    }

    toNextStage() {
        const {
            consignee,
            shipper,
            notifyees,
            hsCode,
            totalGoodsValue,
            cargoNotes
        } = this.state;
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
        this.props.nextStage(data);
    }
    closeBook() {
        this.setState({addressBook: false});
    }

    render() {
        const { theme, shipmentData } = this.props;
        const {
            shipment,
            hubs,
            contacts,
            userLocations,
            schedules
        } = shipmentData;
        const { consignee, shipper, notifyees } = this.state;
<<<<<<< HEAD
        const addrView = this.state.addressBook ? (
            <AddressBook
                contacts={contacts}
                userLocations={userLocations}
                theme={theme}
                setDetails={this.setFromBook}
            />
        ) : (
            <ShipmentContactsBox
                consignee={consignee}
                shipper={shipper}
                addNotifyee={this.addNotifyee}
                notifyees={notifyees}
                theme={theme}
                handleChange={this.handleInput}
                handleNotifyeeChange={this.handleNotifyeeInput}
            />
        );
=======
        const aBook = <AddressBook contacts={contacts} userLocations={userLocations} theme={theme} setDetails={this.setFromBook} closeAddressBook={this.closeBook}/>;
        const cForm = <ShipmentContactsBox consignee={consignee} shipper={shipper} addNotifyee={this.addNotifyee} notifyees={notifyees} theme={theme} handleChange={this.handleInput} handleNotifyeeChange={this.handleNotifyeeInput}/>;
        const addrView = this.state.addressBook ? aBook : cForm;
>>>>>>> master
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div className="flex-100 layout-row layout-align-end-center">
                    <RoundButton
                        active
                        text="Address Book"
                        handleNext={this.toggleAddressBook}
                    />
                </div>
                {shipment ? (
                    <RouteHubBox hubs={hubs} route={schedules} theme={theme} />
                ) : (
                    ''
                )}
                {addrView}
                <CargoDetails handleChange={this.handleCargoInput} />
                <div className="flex-100 layout-row layout-align-start-center">
                    <RoundButton
                        active
                        handleNext={this.toNextStage}
                        text="Finish Booking"
                    />
                    <RoundButton
                        handleNext={this.saveDraft}
                        text="Save as Draft"
                        iconClass="fa-floppy-o"
                    />
                </div>
                <div className="flex-100 layout-row layout-align-start-center">
                    <RoundButton
                        back
                        handleNext={this.toDashboard}
                        text="Back to Dashboard"
                        iconClass="fa-angle-left"
                    />
                </div>
            </div>
<<<<<<< HEAD
        );
=======
          { shipment && theme && hubs ? <RouteHubBox hubs={hubs} route={schedules} theme={theme}/> : ''}
          {addrView}
          <CargoDetails handleChange={this.handleCargoInput} shipmentData={shipmentData}/>
          <div className="flex-100 layout-row layout-align-center-center">
            <div className="content-width layout-row layout-align-start-center button_padding">
                <RoundButton active handleNext={this.toNextStage} theme={theme} text="Finish Booking" />
                <RoundButton  handleNext={this.saveDraft} text="Save as Draft" iconClass="fa-floppy-o"/>
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-center-center">
            <div className="content-width layout-row layout-align-start-center button_padding">
                <RoundButton back handleNext={this.toDashboard} text="Back to Dashboard" iconClass="fa-angle-left"/>
            </div>
          </div>
        </div>
      );
>>>>>>> master
    }
}
BookingDetails.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    nextStage: PropTypes.func
};
