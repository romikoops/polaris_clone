import React, {Component} from 'react';
import PropTypes from 'prop-types';
import styles from './AddressBook.scss';
import { v4 } from 'node-uuid';
import { RoundButton } from '../RoundButton/RoundButton';
import { ContactCard } from '../ContactCard/ContactCard';
export class AddressBook extends Component {
    constructor(props) {
        super(props);
        this.state = {
            setShipper: true,
            setConsignee: false,
            setNotifyees: false,
            notifyees: []
        };
        this.setContact = this.setContact.bind(this);
        this.toggleNotifyees = this.toggleNotifyees.bind(this);
    }
    toggleNotifyees(id) {
        this.setState({ selectedNotifyees: { ...this.state.selectedNotifyees, [id]: !this.state.selectedNotifyees[id] } });
    }
    setContact(type, val) {
        this.props.setDetails(type, val);
        switch(type) {
            case 'shipper':
                this.setState({
                    setShipper: false,
                    shipper: val,
                    setConsignee: true
                });
                break;
            case 'consignee':
                this.setState({
                    setShipper: false,
                    consignee: val,
                    setConsignee: false,
                    setNotifyees: true
                });
                break;
            case 'notifyee':
                const notifyees = this.state.notifyees;
                notifyees.push(val);
                this.setState({
                    setShipper: false,
                    notifyees: notifyees,
                    setConsignee: false,
                    setNotifyees: true
                });
                break;
            default:
                break;
        }
    }

    render() {
        const { contacts, userLocations, theme } = this.props;
        const { notifyees, shipper, consignee } = this.state;
        const shipperOptions = [...userLocations, ...contacts];
        const contactsArray = [];
        const shipperArray = [];
        const notifyeeArray = [];
        const noteArr = [];
        if (contacts) {
            contacts.forEach(c => {
                contactsArray.push(
                    <ContactCard contactData={c} theme={theme} select={this.setContact} key={v4()} target="consignee" />
                );
                notifyeeArray.push(
                    <ContactCard contactData={c} theme={theme} key={v4()} target="notifyee" select={this.setContact}  />
                );
            });
        }

        if (shipperOptions) {
            shipperOptions.forEach(c => {
                shipperArray.push(
                    <ContactCard contactData={c} theme={theme} select={this.setContact} key={v4()} target="shipper" />
                );
            });
        }
        if (notifyees.length > 0) {
            notifyees.forEach(nt => {
                noteArr.push(<p key={v4()} className="flex-50 layout-row"> {nt.contact.first_name} {nt.contact.last_name}</p>);
            });
        }
        return (
        <div className="flex-100 layout-row layout-wrap layout-align-center-start">
          <div className="flex-none content-width layout-row layout-wrap">
            <div className="flex-50 layout-row layout-wrap layout-align-start-start">
                <div className={` ${styles.prompt} flex-100 layout-row layout-align-start-center`}>
                    {this.state.setShipper ? <h1> Set Shipper Details</h1> : ''}
                    {this.state.setConsignee ? <h1> Set Consignee Details</h1> : ''}
                    {this.state.setNotifyees ? <h1> Set Notifyees Details</h1> : ''}
                </div>
                <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                    {shipper ? (
                        <div className={` ${styles.results} flex-90 layout-row`}>
                            <p className="flex-40 title"> Shipping from:</p>
                            <p className="flex-60 offset-5"> {shipper.contact.first_name} {shipper.contact.last_name} </p>
                            <p className="flex-100 "> {shipper.location.geocoded_address} </p>
                        </div>
                    ) : ''}
                    {consignee ? (
                        <div className={` ${styles.results} flex-90 layout-row`}>

                            <p className="flex-40 title"> Shipping from:</p>
                            <p className="flex-60 offset-5"> {consignee.contact.first_name} {consignee.contact.last_name} </p>
                            <p className="flex-100 "> {consignee.location.geocoded_address} </p>
                        </div>
                     ) : ''}
                    {notifyees.length > 0 ? (
                        <div className={` ${styles.n_results} flex-90 layout-row layout-wrap`}>

                            <p className="flex-100 title"> Notifying:</p>
                            {noteArr}
                        </div>
                    ) : ''}
                </div>
            </div>
            <div className={`${styles.contact_scroll} flex-50 layout-row layout-wrap`}>
                {this.state.setShipper ? shipperArray : ''}
                {this.state.setConsignee ? contactsArray : ''}
                {this.state.setNotifyees ? notifyeeArray : ''}
            </div>
            <div className="flex-100 layout-row layout-align-center-center">
                <div className="content-width layout-row layout-align-end-center button_padding">
                    <RoundButton active handleNext={this.props.closeAddressBook} theme={theme} text="Done" />
                </div>
          </div>
          </div>
        </div>
      );
    }
}
AddressBook.PropTypes = {
    contacts: PropTypes.array,
    userLocations: PropTypes.array,
    theme: PropTypes.object,
    setDetails: PropTypes.func,
    closeAddressBook: PropTypes.func
};

