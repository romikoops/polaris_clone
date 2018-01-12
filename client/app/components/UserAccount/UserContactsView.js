import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { UserShipmentRow } from './';
import { AdminAddressTile } from '../Admin';
import styles from './UserAccount.scss';
import { RoundButton } from '../RoundButton/RoundButton';
import {v4} from 'node-uuid';
const EditProfileBox = ({user, handleChange, onSave, close, style, theme}) => {
    return (
        <div className="flex-75 layout-row layout-align-start-start layout-wrap">
            <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Company</sup>
                </div>
                <div className="input_box_full flex-100 layout-row layout-align-start-center ">
                    <input className="flex-90" type="text" value={user.company_name} onChange={handleChange} value={user.company_name} name="company_name" />
                </div>
            </div>
            <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">First Name</sup>
                </div>
                <div className="input_box_full flex-100 layout-row layout-align-start-center ">
                    <input className="flex-none" type="text" value={user.first_name} onChange={handleChange} value={user.first_name} name="first_name" />
                </div>
            </div>
            <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Last Name</sup>
                </div>
                <div className="input_box_full flex-100 layout-row layout-align-start-center ">
                    <input className="flex-none" type="text" value={user.last_name} onChange={handleChange} value={user.last_name} name="last_name" />
                </div>
            </div>
            <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Email</sup>
                </div>
                <div className="input_box_full flex-100 layout-row layout-align-start-center ">
                    <input className="flex-none" type="text" value={user.email} onChange={handleChange} value={user.email} name="email" />
                </div>
            </div>
            <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Phone</sup>
                </div>
                <div className="input_box_full flex-100 layout-row layout-align-start-center ">
                    <input className="flex-none" type="text" value={user.phone} onChange={handleChange} value={user.phone} name="phone" />
                </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 flex-gt-sm-50 layout-row layout-align-center-center button_padding">
                    <RoundButton theme={theme} handleNext={close}  size="small" text="close" iconClass="fa-times"/>
                </div>
                <div className="flex-100 flex-gt-sm-50 layout-row layout-align-center-center button_padding">
                    <RoundButton theme={theme} handleNext={onSave} active size="small" text="Save" iconClass="fa-floppy-o"/>
                </div>
            </div>
        </div>
    );
};
const ProfileBox = ({user, style, edit}) => {
    return (
        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
            <div className="flex-100 layout-row layout-align-end-center layout-wrap">
                <div className="flex-15 layout-row layout-align-center-center" onClick={edit}>
                    <i className="fa fa-pencil clip" style={style}></i>
                </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Company</sup>
                </div>
                <div className="flex-100 layout-row layout-align-start-center ">
                    <p className="flex-none"> {user.company_name}</p>
                </div>
            </div>
            <div className="flex-50 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">First Name</sup>
                </div>
                <div className="flex-100 layout-row layout-align-start-center ">
                    <p className="flex-none"> {user.first_name}</p>
                </div>
            </div>
            <div className="flex-50 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Last Name</sup>
                </div>
                <div className="flex-100 layout-row layout-align-start-center ">
                    <p className="flex-none"> {user.last_name}</p>
                </div>
            </div>
            <div className="flex-50 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Email</sup>
                </div>
                <div className="flex-100 layout-row layout-align-start-center ">
                    <p className="flex-none"> {user.email}</p>
                </div>
            </div>
            <div className="flex-50 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Phone</sup>
                </div>
                <div className="flex-100 layout-row layout-align-start-center ">
                    <p className="flex-none"> {user.phone}</p>
                </div>
            </div>

        </div>
    );
};
export class UserContactsView extends Component {
    constructor(props) {
        super(props);
        this.state = {
          editBool: false,
          editObj: {}
        };
        this.editProfile = this.editProfile.bind(this);
        this.closeEdit = this.closeEdit.bind(this);
        this.saveEdit = this.saveEdit.bind(this);
        this.handleChange = this.handleChange.bind(this);
    }
    componentDidMount() {
        const { contactData, loading, userDispatch, match } = this.props;
        if (!contactData && !loading) {
            userDispatch.getContact(match.params.id, false);
        }
    }
    editProfile() {
        const { contactData } = this.props;
        const { contact } = contactData;
        this.setState({
            editBool: true,
            editObj: contact
        });
    }
    closeEdit() {
        this.setState({
            editBool: false
        });
    }
    handleChange(ev) {
      const { name, value } = ev.target;
      this.setState({
        editObj: {
          ...this.state.editObj,
          [name]: value
        }
      });
    }

    saveEdit() {
        const { userDispatch, contact } = this.props;
        userDispatch.updateContact(contact, this.state.editObj);
        this.closeEdit();
    }
    render() {
        const {theme, contactData, hubs} = this.props;
        if (!contactData) {
            return '';
        }
        const { contact, shipments, location} = contactData;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const  {
            editBool,
            editObj
        } = this.state;

        const shipRows = [];
        shipments.forEach((ship) => {
            shipRows.push( <UserShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment}  client={contact}/>);
        });
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none clip`} style={textStyle}>Contact Overview</p>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Details </p>
                    </div>
                      {
                        editBool ?
                        <EditProfileBox user={editObj} style={textStyle} theme={theme}  handleChange={this.handleChange} onSave={this.saveEdit} close={this.closeEdit}/> :
                        <ProfileBox user={contact} style={textStyle} theme={theme} edit={this.editProfile}/>
                      }
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Related Shipments</p>
                    </div>
                    {shipRows}
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Locations</p>
                    </div>
                    <AdminAddressTile key={v4()} address={location} theme={theme} client={contact}/>
                </div>
            </div>
        );
    }
}
UserContactsView.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    contactData: PropTypes.array
};
