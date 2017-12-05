import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './BookingDetails.scss';
import defaults from '../../styles/default_classes.scss';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import { AddressBook } from '../AddressBook/AddressBook';
import { ShipmentContactsBox } from '../ShipmentContactsBox/ShipmentContactsBox';
import { CargoDetails } from '../CargoDetails/CargoDetails';
import { RoundButton } from '../RoundButton/RoundButton';
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
                bool: false,
                val: 0
            },
            customs: {
                bool: false,
                val: 0
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
        this.handleInsurance = this.handleInsurance.bind(this);
        this.calcInsurance = this.calcInsurance.bind(this);
    }
    componentDidMount() {
        const {prevRequest, setStage} = this.props;
        if (prevRequest && prevRequest.shipment) {
            this.loadPrevReq(prevRequest.shipment);
        }
        setStage(3);
    }
    loadPrevReq(obj) {
        this.setState({
            consignee: obj.consignee,
            shipper: obj.shipper,
            notifyees: obj.notifyees,
            hsCode: obj.hsCode,
            totalGoodsValue: obj.totalGoodsValue,
            cargoNotes: obj.cargoNotes
        });
    }

    setFromBook(target, value) {
        if (target === 'notifyee') {
            this.setNotifyeesFromBook(target, value);
        } else {
            this.setState({
                [target]: {
                    firstName: value.contact.first_name,
                    companyName: value.contact.company_name,
                    lastName: value.contact.last_name,
                    email: value.contact.email,
                    phone: value.contact.phone,
                    street: value.location.street,
                    number: value.location.street_number,
                    zipCode: value.location.zip_code,
                    city: value.location.city,
                    country: value.location.country
                }
            });
        }
    }
    handleInsurance() {
        const {insurance} = this.state;

        if (insurance.bool) {
            this.setState({insurance: {bool: false, val: 0}});
        } else {
            this.calcInsurance();
        }
    }
    calcInsurance(val) {
        const gVal = val ? val : parseInt(this.state.totalGoodsValue, 10);
        const {shipmentData} = this.props;
        if (this.state.insurance) {
            const iVal = (parseFloat(shipmentData.shipment.total_price, 10) + gVal) * 1.1 * 0.17;
            this.setState({insurance: {bool: true, val: iVal}});
        }
    }

    setNotifyeesFromBook(target, value) {
        const tmpAdd = {
            firstName: value.contact.first_name,
            lastName: value.contact.last_name,
            email: value.contact.email,
            phone: value.contact.phone
        };
        const notifyees = this.state.notifyees;
        if (notifyees.indexOf(tmpAdd) > -1) {
            notifyees.slice(notifyees.indexOf(tmpAdd), 1);
            this.setState({notifyees});
        } else {
            notifyees.push(tmpAdd);
            this.setState({notifyees});
        }
    }

    toggleAddressBook() {
        const addressBool = this.state.addressBook;
        this.setState({ addressBook: !addressBool });
    }

    addNotifyee() {
        const prevArr = this.state.notifyees;
        prevArr.unshift(this.state.default.notifyee);
        this.setState({ notifyees: prevArr });
    }

    handleInput(event) {
        const { name, value } = event.target;
        const targetKeys = name.split('-');
        this.setState({
            [targetKeys[0]]: {
                ...this.state[targetKeys[0]],
                [targetKeys[1]]: value
            }
        });
    }

    handleCargoInput(event) {
        const { name, value } = event.target;
        if (name === 'totalGoodsValue') {
            const gVal = parseInt(value, 10);
            this.setState({ [name]: gVal });
            this.calcInsurance(gVal);
        } else {
            this.setState({ [name]: value });
        }
    }

    handleNotifyeeInput(event) {
        const { name, value } = event.target;
        const targetKeys = name.split('-');
        const ind = parseInt(targetKeys[1], 10);
        const notifyees = this.state.notifyees;
        notifyees[ind][targetKeys[2]] = value;
        this.setState({
            notifyees: notifyees
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
            cargoNotes,
            insurance,
            customs
        } = this.state;
        const data = {
            shipment: {
                id: this.props.shipmentData.shipment.id,
                consignee,
                shipper,
                notifyees,
                hsCode,
                totalGoodsValue,
                cargoNotes,
                insurance,
                customs
            }
        };
        this.props.nextStage(data);
    }

    closeBook() {
        this.setState({ addressBook: false });
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
        const aBook = (
            <AddressBook
                contacts={contacts}
                userLocations={userLocations}
                theme={theme}
                setDetails={this.setFromBook}
                closeAddressBook={this.toggleAddressBook}
            />
        );
        const cForm = (
            <ShipmentContactsBox
                consignee={consignee}
                shipper={shipper}
                addNotifyee={this.addNotifyee}
                notifyees={notifyees}
                theme={theme}
                toggleAddressBook={this.toggleAddressBook}
                handleChange={this.handleInput}
                handleNotifyeeChange={this.handleNotifyeeInput}
            />
        );
        const addrView = this.state.addressBook ? aBook : cForm;
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">

                {shipment && theme && hubs ? (
                    <RouteHubBox hubs={hubs} route={schedules} theme={theme} />
                ) : (
                    ''
                )}
                <div className={` ${styles.contacts_border} flex-100 layout-row`}>
                    {addrView}
                </div>
                <CargoDetails
                    theme={theme}
                    handleChange={this.handleCargoInput}
                    shipmentData={shipmentData}
                    hsCode={this.state.hsCode}
                    cargoNotes={this.state.cargoNotes}
                    totalGoodsValue={this.state.totalGoodsValue}
                    handleInsurance={this.handleInsurance}
                    insurance={this.state.insurance}
                />
                <div className={`${styles.btn_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                    <div className={defaults.content_width + ' flex-none  layout-row layout-wrap layout-align-start-center'}>
                        <div className="flex-none layout-row">
                            <RoundButton
                                active
                                handleNext={this.toNextStage}
                                theme={theme}
                                text="Finish Booking"
                            />
                        </div>
                        <div className="flex-none offset-5 layout-row">
                            <RoundButton
                                handleNext={this.saveDraft}
                                text="Save as Draft"
                                iconClass="fa-floppy-o"
                            />
                        </div>
                    </div>
                </div>
                <hr className={`${styles.sec_break} flex-100`}/>
                <div className={`${styles.back_to_dash_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                    <div className={`${defaults.content_width} flex-none content-width layout-row layout-align-start-center`}>
                        <RoundButton theme={theme} text="Back to dashboard" back iconClass="fa-angle-left" />
                    </div>
                </div>
            </div>
        );
    }
}

BookingDetails.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    nextStage: PropTypes.func
};
