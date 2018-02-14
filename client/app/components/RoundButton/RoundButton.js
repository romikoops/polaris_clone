import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './RoundButton.scss';
import { gradientCSSGenerator } from '../../helpers';
import styled from 'styled-components';
export class RoundButton extends Component {
    render() {
        const { text, theme, active, back, icon, iconClass, size } = this.props;

        const activeBtnStyle = theme && theme.colors ? gradientCSSGenerator(theme.colors.primary, theme.colors.secondary) : 'black';

        const btnStyle = this.props.active ? activeBtnStyle : {};

        let bStyle;
        const StyledButton = styled.button`
            background: ${btnStyle};
           
        `;

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
        const activeButton = (
            <StyledButton
                className={styles.round_btn + ' ' + bStyle + ' ' + sizeClass}
                onClick={this.props.handleNext}
            >
                <div className="layout-fill layout-row layout-align-space-around-center">
                    <p className={styles.content}>
                        <span className={`${styles.icon} ${styles.icon_margin}`}>{iconC}</span>
                        {text}
                    </p>
                </div>
            </StyledButton>
        );
        const inactiveButton = (
            <button
                className={styles.round_btn + ' ' + bStyle + ' ' + sizeClass}
                onClick={this.props.handleNext}
            >
                <div className="layout-fill layout-row layout-align-space-around-center">
                    <p className={styles.content}>
                        <span className={`${styles.icon} ${styles.icon_margin}`}>{iconC}</span>
                        {text}
                    </p>
                </div>
            </button>
        );

        return (
            active ? activeButton : inactiveButton
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
