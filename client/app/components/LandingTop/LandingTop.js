
import React, {Component} from 'react';
import {LoginPage} from '../../containers/LoginPage';
import styles from './LandingTop.scss';
import PropTypes from 'prop-types';
import { RoundButton } from '../RoundButton/RoundButton';
import Header from '../Header/Header';

// import SignIn from '../SignIn/SignIn';  default LandingTop;
export class LandingTop extends Component {
    render() {
        const theme = this.props.theme;
        return (
            <div className={styles.landing_top + ' layout-row flex-100 layout-align-center'}>
                <div className={styles.top_mask}> </div>
                <div className="layout-row flex-100 layout-wrap">
                    <div className={styles.top_row + ' flex-100 layout-row'}>
                        <Header user={false} theme={theme} />
                    </div>
                    <div className={'flex-100 flex-gt-sm-50 ' + styles.layout_elem}>
                        <LoginPage theme={theme} />
                    </div>
                    <div className={'flex-100 flex-gt-sm-50 ' + styles.layout_elem}>
                        <div className={styles.sign_up}>
                            <h2>Never spend precious time on transportation again LCL shipping made simple</h2>
                            <h3>Enjoy the most advanced and easy to use booking system in the market</h3>
                            <RoundButton text="sign up" theme={theme} active/>
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
