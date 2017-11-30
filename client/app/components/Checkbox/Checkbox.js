import React, {Component} from 'react';
import PropTypes from 'prop-types';
import './Checkbox.scss';

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
        };
        this.handleChange = this.handleChange.bind(this);
    }

    handleChange() {
        this.setState({
            checked: !this.state.checked,
        });
        this.props.onChange();
    }

    render() {
        const { disabled } = this.props;
        const { checked } = this.state;
        return (
            <div className="React__checkbox flex-none">
                <label>
                    <input
                        type="checkbox"
                        className="React__checkbox--input"
                        checked={checked}
                        disabled={disabled}
                        onChange={this.handleChange}
                    />
                    <span className="React__checkbox--span">
                        <i
                            className="React__checkbox--span fa fa-check"
                        />
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
