import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './LoadingBox.scss';
export class LoadingBox extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        const { theme, text } = this.props;
        const logo = theme && theme.logo ? theme.logo : '';
        const backgroundStyle = {
            backgroundColor:
        theme && theme.colors ? theme.colors.primary : 'darkslategrey'
        };

        return (
            <div
                className={`layout-fill layout-row layout-align-center-center ${styles.loader_box}`}
            >
                    <div
                        className={`layout-column layout-align-center-center ${
                            styles.loader
                        }`}
                    >
                        <img src={logo} alt="" className={`flex-none ${styles.logo}`} />
                        <div className={`flex-none layout-row layout-align-space-between-center ${styles.dot_row}`}>
                            <div className={`${styles.dot1} flex-none`} style={backgroundStyle}></div>
                            <div className={`${styles.dot2} flex-none`} style={backgroundStyle}></div>
                            <div className={`${styles.dot3} flex-none`} style={backgroundStyle}></div>
                        </div>

                    </div>
            </div>
        );
    }
}

LoadingBox.propTypes = {
  theme: PropTypes.object,
  text: PropTypes.string
};
