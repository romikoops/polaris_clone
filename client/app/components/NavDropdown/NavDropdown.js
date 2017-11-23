import React, { Component } from 'react';
import styles from './NavDropdown.scss';
import accountIcon from '../../assets/images/icons/person-dark.svg';

export class NavDropdown extends Component {
    render() {
        console.log(this.props.user);
        return (
            <div className={`${styles.dropdown}`}>
                <div className={`${styles.dropbtn}`}>
                    <img
                        src={accountIcon}
                        className={styles.accountIcon}
                        alt=""
                    />
                    <h1>
                        {this.props.user ? this.props.user.data.first_name : ''}
                    </h1>
                    Firstname Lastname{' '}
                    <i
                        className="fa fa-caret-down spacing-sm-left"
                        aria-hidden="true"
                    />
                </div>
                <div className={`${styles.dropdowncontent}`}>
                    <a href="#">Link 1</a>
                    <a href="#">Link 2</a>
                    <a href="#">Link 3</a>
                </div>
            </div>
        );
    }
}
