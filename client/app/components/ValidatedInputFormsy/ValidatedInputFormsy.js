import React, { Component } from 'react';
import { withFormsy } from 'formsy-react';

class ValidatedInputFormsy extends Component {
    constructor(props) {
        super(props);
        this.changeValue = this.changeValue.bind(this);
        this.state = {
        	firstRender: true
        };
    }

    changeValue(event) {
        this.props.onChange(event);
        this.setState({
        	firstRender: false
        });
        // setValue() will set the value of the component, which in
        // turn will validate it and the rest of the form
        // Important: Don't skip this step. This pattern is required
        // for Formsy to work.
        this.props.setValue(event.currentTarget.value);
    }

    render() {
    // An error message is returned only if the component is invalid
    	console.log(this.state);
        const errorMessage = this.props.getErrorMessage();
        const wrapperStyles = {
        	width: '100%',
        	height: '100%'
        };
        const inputStyles = {
            width: '100%',
            height: '100%',
            boxSizing: 'border-box'
        };
        console.log(this.props);
        return (
            <div style={wrapperStyles}>
                <input
                	style={inputStyles}
                    onChange={this.changeValue}
                    type={this.props.type}
                    value={(this.props.getValue().toString()) || ''}
                />
                <span>{this.state.firstRender ? '' : errorMessage}</span>
            </div>
        );
    }
}

export default withFormsy(ValidatedInputFormsy);
