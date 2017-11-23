import React, { Component } from 'react';

import styles from './Header.scss';
import logo from '../../assets/images/logos/logo_black.png';
import accountIcon from '../../assets/images/icons/person-dark.svg';

export class Header extends Component {
    state = {
        selectedOption: ''
    };
    handleChange = selectedOption => {
        this.setState({ selectedOption });
        console.log(`Selected: ${selectedOption.label}`);
    };

    render() {
        return (
            <div
                className={`${
                    styles.header
                } layout-row flex-100 layout-wrap layout-align-center`}
            >
                <div className="content-width layout-row flex-none">
                    <div className="layout-row flex-50 layout-align-start-center">
                        <img src="" alt="" />
                    </div>
                    <div className="layout-row flex-50 layout-align-end-center">
                        <div className={`${styles.dropdown}`}>
                            <div className={`${styles.dropbtn}`}>
                                <img src={accountIcon} className={styles.accountIcon} alt=""/>
                                Firstname Lastname <i className="fa fa-caret-down spacing-sm-left" aria-hidden="true"></i>
                            </div>
                            <div className={`${styles.dropdowncontent}`}>
                                <a href="#">Link 1</a>
                                <a href="#">Link 2</a>
                                <a href="#">Link 3</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}
