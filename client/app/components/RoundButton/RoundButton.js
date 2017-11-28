import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './RoundButton.scss';

export class RoundButton extends Component {
    render() {
        const { text, theme, active, back, icon, iconClass, width, height, fontSize } = this.props;
        const activeBtnStyle = {
            background:
                theme && theme.colors
                    ? '-webkit-linear-gradient(95.41deg, ' +
                      theme.colors.primary +
                      ' 0%,' +
                      theme.colors.secondary +
                      ' 100%)'
                    : 'black'
        };
        const btnStyle = this.props.active ? activeBtnStyle : {};
        let bStyle;
        if (active) {
            bStyle = styles.active;
        } else if (back) {
            bStyle = styles.back;
        } else if (!active && !back) {
            bStyle = styles.neutral;
        }
        let iconC;
        if (icon) {
            iconC = <img src={icon} alt="" className="flex-none icon" />;
        } else if (iconClass) {
            const classStr = 'flex-none icon_f fa ' + iconClass;
            iconC = <i className={classStr} />;
        }
        if (width)  btnStyle.width  = width;
        if (height) btnStyle.height = height;
        if (fontSize) btnStyle.fontSize = fontSize;
        return (
            <button
                className={styles.round_btn + ' ' + bStyle}
                onClick={this.props.handleNext}
                style={btnStyle}
            >
                <div className="layout-fill layout-row layout-align-space-around-center">
                    {iconC}
                    <p className="flex-none">{text}</p>
                </div>
            </button>
        );
    }
}

RoundButton.propTypes = {
    text: PropTypes.string,
    handleNext: PropTypes.func,
    active: PropTypes.bool,
    back: PropTypes.bool,
    theme: PropTypes.object,
    icon: PropTypes.string,
    iconClass: PropTypes.string
};
