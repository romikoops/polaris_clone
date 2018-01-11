
import React, {Component} from 'react';
// import {LoginPage} from '../../containers/LoginPage';
import styles from './LandingTop.scss';
import PropTypes from 'prop-types';
import { RoundButton } from '../RoundButton/RoundButton';
import Header from '../Header/Header';
import { moment } from '../../constants';

// import SignIn from '../SignIn/SignIn';  default LandingTop;
export class LandingTop extends Component {
    constructor(props) {
        super(props);
        this.toAccount = this.toAccount.bind(this);
        this.toBooking = this.toBooking.bind(this);
        this.toAdmin = this.toAdmin.bind(this);
    }
    toAccount() {
        this.props.goTo('/account');
    }
    toAdmin() {
        this.props.toAdmin(true);
    }
    toBooking() {
        this.props.goTo('/booking');
    }
    render() {
        const { authDispatch, theme, user } = this.props;
        const handleNext = () => {
            if (this.props.loggedIn) {
                this.toBooking();
            } else {
                const unixTimeStamp = moment().unix().toString();
                const randNum = Math.floor(Math.random() * 100).toString();
                const randSuffix = unixTimeStamp + randNum;
                const email = `guest${randSuffix}@${this.props.tenant.data.subdomain}.com`;

                authDispatch.register({
                    email: email,
                    password: 'guestpassword',
                    password_confirmation: 'guestpassword',
                    first_name: 'Guest',
                    last_name: '',
                    tenant_id: this.props.tenant.data.id,
                    guest: true
                }, true);
            }
        };
        const myAccount = (
            <RoundButton text="My Account" theme={theme} handleNext={() => this.toAccount()} active/>
        );
        const toAdmin = (
            <RoundButton text="Admin Dashboard" theme={theme} handleNext={this.toAdmin} active/>
        );
        return (
            <div className={styles.landing_top + ' layout-row flex-100 layout-align-center'}>
                <div className={styles.top_mask}> </div>
                <div className="layout-row flex-100 layout-wrap">
                    <div className={styles.top_row + ' flex-100 layout-row'}>
                        <Header user={user} theme={theme} invert={true}/>
                    </div>
                    <div className={'flex-100 flex-gt-sm-50 layout-column layout-align-space-around-center ' + styles.layout_elem}>
                        <RoundButton text="Book Now" theme={theme} handleNext={handleNext} active/>
                        { user ? myAccount : '' }
                        { user && user.role_id === 1 ? toAdmin : '' }
                    </div>

                    <div className={'flex-100 flex-gt-sm-50 layout-row layout-align-center-end ' + styles.layout_elem}>
                        <div className={styles.sign_up}>
                            <h2>Never spend precious time on transportation again LCL shipping made simple</h2>
                            <h3>Enjoy the most advanced and easy to use booking system in the market</h3>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

LandingTop.propTypes = {
    theme: PropTypes.object
};
