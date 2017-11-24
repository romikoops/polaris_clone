import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import { history } from '../../helpers';
import styles from './NavDropdown.scss';
import accountIcon from '../../assets/images/icons/person-dark.svg';

export class NavDropdown extends Component {
    constructor(props) {
        super(props);
    }

    handleClick() {}

    render() {
        const links = this.props.linkOptions.map(op => {
            return (
                <a key={op.key} href={op.url}>
                    {op.text}
                </a>
            );
        });

        return (
            <div className={`${styles.dropdown}`}>
                <div className={`${styles.dropbtn}`}>
                    <img
                        src={accountIcon}
                        className={styles.accountIcon}
                        alt=""
                    />
                    {this.props.user ? (
                        <span>
                            {this.props.user.data.first_name}{' '}
                            {this.props.user.data.last_name}
                        </span>
                    ) : (
                        ''
                    )}
                    <i
                        className="fa fa-caret-down spacing-sm-left"
                        aria-hidden="true"
                    />
                </div>
                <div className={`${styles.dropdowncontent}`}>{links}</div>
            </div>
        );
    }
}

NavDropdown.propTypes = {
    linkOptions: PropTypes.array
};
