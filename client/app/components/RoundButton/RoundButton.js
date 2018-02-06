import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './RoundButton.scss';
import { gradientGenerator } from '../../helpers';
export class RoundButton extends Component {
    render() {
        const { text, theme, active, back, icon, iconClass, size } = this.props;

        const activeBtnStyle = theme && theme.colors ? gradientGenerator(theme.colors.primary, theme.colors.secondary) : {color: 'black'};
        console.log(activeBtnStyle);
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

        let sizeClass;

        switch (size) {
            case 'large':
                sizeClass = styles.large;
                break;
            case 'small':
                sizeClass = styles.small;
                break;
            case 'full':
                sizeClass = styles.full;
                break;

            default:
                sizeClass = styles.large;
                break;
        }

        return (
            <button
                className={styles.round_btn + ' ' + bStyle + ' ' + sizeClass}
                onClick={this.props.handleNext}
                style={btnStyle}
            >
                <div className="layout-fill layout-row layout-align-space-around-center">
                    <p className={styles.content}>
                        <span className={styles.icon}>{iconC}</span>
                        {text}
                    </p>
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
    iconClass: PropTypes.string,
    size: PropTypes.string
};
