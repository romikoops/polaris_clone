import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './LoginRegistrationWrapper.scss';
import { LoginPage } from '../../containers/LoginPage/LoginPage';
import { RegistrationPage } from '../../containers/RegistrationPage/RegistrationPage';

export class LoginRegistrationWrapper extends Component {
    constructor(props) {
        super(props);
        this.state = {};
        this.components = { LoginPage, RegistrationPage };
    }

    render() {
        const toggleComp = (CurrentComp) => {
            const NextComp = CurrentComp === LoginPage ? RegistrationPage : LoginPage;
            this.setState({
                Comp: NextComp
            });
        };
        const { initialCompName } = this.props;
        const DefaultComp = initialCompName ? this.components[initialCompName] : LoginPage;
    	const Comp = this.state.Comp || DefaultComp;
        const compProps = this.props[Comp.WrappedComponent.name + 'Props'];
        return (
            <div>
                <div onClick={() => toggleComp(Comp)}>Toggle</div>
                <div>
                    <Comp {...compProps} />
                </div>
            </div>
	    );
    }
}

LoginRegistrationWrapper.propTypes = {
    component: PropTypes.func
};
