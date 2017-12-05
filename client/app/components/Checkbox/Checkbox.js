import React, {Component} from 'react';
import PropTypes from 'prop-types';
import styles from './Checkbox.scss';

export class Checkbox extends Component {
    // static propTypes = {
    //     checked: PropTypes.bool,
    //     disabled: PropTypes.bool,
    // };
    // static defaultProps = {
    //     checked: false,
    //     disabled: false,
    // };
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
        this.props.onChange();
    }
    render() {
        const { disabled, theme } = this.props;
        const { checked } = this.state;
        const checkGradient = {
            background: `-webkit-linear-gradient(left, ${theme.colors.primary} 0%, ${theme.colors.secondary} 100%)`,
        };
        return (
            <div className={`${styles.checkbox} flex-none`}>
                <label>
                    <input
                        type="checkbox"
                        checked={checked}
                        disabled={disabled}
                        onChange={this.handleChange}
                    />
                    <span>
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
};
Checkbox.defaultProps = {
    checked: false,
    disabled: false,
};
