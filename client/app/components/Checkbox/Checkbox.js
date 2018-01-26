import React, {Component} from 'react';
import PropTypes from 'prop-types';
import styles from './Checkbox.scss';

export class Checkbox extends Component {
    constructor(props) {
        super(props);
        this.state = {
            checked: props.checked,
            showCheck: true
        };
        this.handleChange = this.handleChange.bind(this);
    }

    componentWillUnmount() {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId);
        }
    }

    handleChange() {
        this.setState({
            checked: !this.state.checked,
        });
        this.props.onChange(!this.state.checked);
    }
    render() {
        const { disabled, theme } = this.props;
        const { checked } = this.state;
        const checkGradient = {
            background: theme && theme.colors ? `-webkit-linear-gradient(left, ${theme.colors.primary} 0%, ${theme.colors.secondary} 100%)` : 'black',
        };
        const sizeStyles = this.props.size ? { height: this.props.size, width: this.props.size } : {};
        const border = { border: `1px solid ${theme && theme.colors ? theme.colors.secondary : 'black'}`};
        return (
            <div className={`${styles.checkbox} flex-none`} style={border}>
                <label>
                    <input
                        type="checkbox"
                        checked={checked}
                        disabled={disabled}
                        onChange={this.handleChange}
                        onClick={this.props.onClick}
                    />
                    <span style={sizeStyles}>
                        <i className={`fa fa-check ${checked ? styles.show : ''}`} style={checkGradient} />
                    </span>
                </label>
            </div>
        );
    }
}
Checkbox.propTypes = {
    checked: PropTypes.bool,
    disabled: PropTypes.bool,
    theme: PropTypes.object
};
Checkbox.defaultProps = {
    checked: false,
    disabled: false,
};
