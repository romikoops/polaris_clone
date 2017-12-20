import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './UserAccount.scss';
import { UserLocations } from './';
import { AdminClientTile } from '../Admin';
import { RoundButton } from '../RoundButton/RoundButton';
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
const EditProfileBox = ({user, handleChange, onSave, close, style, theme}) => {
    return (
        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
            <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Company</sup>
                </div>
                <div className="input_box flex-100 layout-row layout-align-start-center ">
                    <input className="flex-90" type="text" value={user.company_name} onChange={handleChange} value={user.company_name} name="company_name" />
                </div>
            </div>
            <div className="flex-50 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">First Name</sup>
                </div>
                <div className="input_box flex-100 layout-row layout-align-start-center ">
                    <input className="flex-none" type="text" value={user.first_name} onChange={handleChange} value={user.first_name} name="first_name" />
                </div>
            </div>
            <div className="flex-50 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Last Name</sup>
                </div>
                <div className="input_box flex-100 layout-row layout-align-start-center ">
                    <input className="flex-none" type="text" value={user.last_name} onChange={handleChange} value={user.last_name} name="last_name" />
                </div>
            </div>
            <div className="flex-50 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Email</sup>
                </div>
                <div className="input_box flex-100 layout-row layout-align-start-center ">
                    <input className="flex-none" type="text" value={user.email} onChange={handleChange} value={user.email} name="email" />
                </div>
            </div>
            <div className="flex-50 layout-row layout-align-start-start layout-wrap">
                <div className="flex-100 layout-row layout-align-start-start ">
                    <sup style={style} className="clip flex-none">Phone</sup>
                </div>
                <div className="input_box flex-100 layout-row layout-align-start-center ">
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

export class UserProfile extends Component {
    constructor(props) {
        super(props);
        this.state = {
          editBool: false,
          editObj: {}
        };
        this.doNothing = this.doNothing.bind(this);
        this.makePrimary = this.makePrimary.bind(this);
        this.editProfile = this.editProfile.bind(this);
        this.closeEdit = this.closeEdit.bind(this);
        this.saveEdit = this.saveEdit.bind(this);
        this.handleChange = this.handleChange.bind(this);
    }
    componentDidMount() {
        this.props.setNav('profile');
    }
    doNothing() {
        console.log('');
    }
    makePrimary(locationId) {
        const { userDispatch, user } = this.props;
        userDispatch.makePrimary(user.id, locationId);
    }
    editProfile() {
        const { user } = this.props;
        this.setState({
            editBool: true,
            editObj: user
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
        const { authDispatch, user } = this.props;
        authDispatch.updateUser(user, this.state.editObj);
        this.closeEdit();
    }
    render() {
        const {user, aliases, locations, theme} = this.props;
        if (!user) {
          return '';
        }
        const  {
            editBool,
            editObj
        } = this.state;
        const contactArr  = aliases.map(cont => {
            return (
                <AdminClientTile client={cont} theme={theme} />
            );
        });
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <h1 className="sec_title_text flex-none cli" style={textStyle} >Profile</h1>
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className="flex-100 layout-row layout-align-space-between-center sec_header">
                        <p className="sec_header_text flex-none"  > Account Details </p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        <div className="flex-50 layout-row layout-align-start-center">
                            {
                                editBool ?
                                    <EditProfileBox user={editObj} style={textStyle} theme={theme}  handleChange={this.handleChange} onSave={this.saveEdit} close={this.closeEdit}/> :
                                    <ProfileBox user={user} style={textStyle} theme={theme} edit={this.editProfile}/>
                            }
                        </div>
                    </div>
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className="flex-100 layout-row layout-align-space-between-center sec_header">
                        <p className="sec_header_text flex-none"  > Aliases </p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        { contactArr }
                    </div>
                </div>

                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className="flex-100 layout-row layout-align-space-between-center sec_header">
                        <p className="sec_header_text flex-none"  > Saved Locations </p>
                    </div>
                    <UserLocations setNav={this.doNothing} locations={locations} makePrimary={this.makePrimary} theme={theme} user={user}/>
                </div>

            </div>
        );
    }
}

UserProfile.propTypes = {
    user: PropTypes.object
};
