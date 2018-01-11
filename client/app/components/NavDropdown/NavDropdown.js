import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './NavDropdown.scss';
import defaults from '../../styles/default_classes.scss';

export class NavDropdown extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const textClass = this.props.invert ? styles.white : styles.black;
        const links = this.props.linkOptions.map(op => {
            const icon = (
                <i
                    className={`fa ${op.fontAwesomeIcon} ${defaults.spacing_sm_right}`}
                    aria-hidden="true"
                />
            );

            if (op.url) {
                return (
                    <a key={op.key} href={op.url}>
                        {op.fontAwesomeIcon ? icon : ''}
                        {op.text}
                    </a>
                );
            }
            return (
                <div onClick={op.select}>{op.key}</div>
            );
        });
        return (
            <div className={`${styles.dropdown} ${textClass}`}>
                <div className={`${styles.dropbtn}`}>
                    {this.props.dropDownImage ?
                        <img
                            src={this.props.dropDownImage}
                            className={styles.dropDownImage}
                            alt=""
                        /> :
                        ''}
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
