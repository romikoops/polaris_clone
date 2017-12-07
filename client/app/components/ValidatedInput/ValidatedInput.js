import React, { Component } from 'react';
import ValidatedInputFormsy from '../ValidatedInputFormsy/ValidatedInputFormsy';
import Formsy from 'formsy-react';

export class ValidatedInput extends Component {
    render() {
        return (
            <Formsy className={this.props.className}>
                <ValidatedInputFormsy {...this.props} />
            </Formsy>
        );
    }
}
