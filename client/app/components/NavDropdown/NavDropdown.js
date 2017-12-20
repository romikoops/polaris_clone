import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './NavDropdown.scss';
import defaults from '../../styles/default_classes.scss';

export class NavDropdown extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const links = this.props.linkOptions.map(op => {
            const icon = (
                <i
                    className={`fa ${op.fontAwesomeIcon} ${defaults.spacing_sm_right}`}
                    aria-hidden="true"
                />
            );
            return (
                <a key={op.key} href={op.url}>
                    {op.fontAwesomeIcon ? icon : ''}
                    {op.text}
                </a>
            );
        });
        return (
            <div className={`${styles.dropdown}`}>
                <div className={`${styles.dropbtn}`}>
                    <img
                        src={this.props.dropDownImage}
                        className={styles.dropDownImage}
                        alt=""
                    />
                    {this.props.dropDownText ? (
                        <span>{this.props.dropDownText}</span>
                    ) : (
                        ''
                    )}
                    <i
                        className={`fa fa-caret-down ${defaults.spacing_sm_left}`}
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
