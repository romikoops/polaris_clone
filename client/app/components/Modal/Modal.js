import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Modal.scss';

export class Modal extends Component {
    constructor(props) {
        super(props);
        this.state = {
            hidden: false
        };
        this.hide = this.hide.bind(this);
    }
    hide() {
        this.setState({
            hidden: true
        });
        this.props.parentToggle();
    }

    render() {
        if (this.state.hidden) return '';
	    return (
            <div>
		    	<div className={`${styles.modal_background} ${styles.full_size}`} onClick={this.hide}></div>

	    		<div className={`${styles.modal} layout-row layout-align-center-center`}>
	    			{this.props.component}
	    		</div>
            </div>
	    );
    }
}

Modal.propTypes = {
    component: PropTypes.func,
    parentToggle: PropTypes.func
};
