import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ShipmentCargoItems.scss';
import defs from '../../styles/default_classes.scss';
import '../../styles/select-css-custom.css';
import { v4 } from 'node-uuid';
import { TextHeading } from '../TextHeading/TextHeading';
import getInputs from './inputs';

export class ShipmentCargoItems extends Component {
    constructor(props) {
        super(props);
        this.state = {
            cargoItemTypes: [],
            firstRenderInputs: !this.props.nextStageAttempt
        };
        this.handleCargoChange = this.handleCargoChange.bind(this);
        this.addNewCargo = this.addNewCargo.bind(this);
        this.toggleDangerousGoods = this.toggleDangerousGoods.bind(this);
        this.setFirstRenderInputs = this.setFirstRenderInputs.bind(this);
        this.handleCargoItemQ = this.handleCargoItemQ.bind(this);
        this.handleCargoItemType = this.handleCargoItemType.bind(this);
    }

    handleCargoChange(event) {
        const { name, value } = event.target;
        this.setState({
            newCargoItem: { ...this.state.newCargoItem, [name]: value }
        });
    }

    setFirstRenderInputs(bool) {
        this.setState({firstRenderInputs: bool});
    }

    addNewCargo() {
        this.props.addCargoItem();
        this.setState({firstRenderInputs: true});
    }
    handleCargoItemQ(event) {
        const modifiedEvent = { target: event };
        this.props.handleDelta(modifiedEvent);
    }
    handleCargoItemType(event) {
        const index = event.name.split('-')[0];
        const modifiedEvent = {
            target: { name: event.name, value: event.key }
        };
        const newCargoItemTypes = this.state.cargoItemTypes;
        newCargoItemTypes[index] = event;
        this.setState({cargoItemTypes: newCargoItemTypes});
        this.props.handleDelta(modifiedEvent);

        console.log('event');
        console.log(event);
        if (!event.dimension_x) return;

        const modifiedEventDimentionX = {
            target: { name: index + '-dimension_x', value: event.dimension_x }
        };
        const modifiedEventDimentionY = {
            target: { name: index + '-dimension_y', value: event.dimension_y }
        };
        this.props.handleDelta(modifiedEventDimentionX);
        this.props.handleDelta(modifiedEventDimentionY);
    }
    toggleDangerousGoods(i) {
        const event = {
            target: {
                name: i + '-dangerousGoods',
                value: !this.props.cargoItems[i].dangerousGoods
            }
        };
        this.props.handleDelta(event);
    }
    deleteCargo(index) {
        const { cargoItemTypes } = this.state;
        cargoItemTypes.splice(index, 1);
        this.setState({ cargoItemTypes });

        this.props.deleteItem('cargoItems', index);
    }
    render() {
        const { cargoItems, theme } = this.props;
        const { cargoItemTypes } = this.state;
        const cargosAdded = [];
        const availableCargoItemTypes = this.props.availableCargoItemTypes ? (
            this.props.availableCargoItemTypes.map(cargoItemType => (
                {
                    label: cargoItemType.description,
                    key: cargoItemType.id,
                    dimension_x: cargoItemType.dimension_x,
                    dimension_y: cargoItemType.dimension_y
                }
            ))
        ) : [];
        const numberOptions = [];
        for (let i = 1; i <= 20; i++) {
            numberOptions.push({label: i, value: i});
        }
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };

        const generateSeparator = () => (
            <div key={v4()} className={`${styles.separator} flex-100`}>
                <hr/>
            </div>
        );
        const generateCargoItem = (cargoItem, i) => {
            const inputs = getInputs.call(
                this,
                cargoItem,
                i,
                theme,
                cargoItemTypes,
                availableCargoItemTypes,
                numberOptions
            );
            return (
                <div
                    key={i}
                    className="layout-row flex-100 layout-wrap layout-align-start-center"
                    style={{ position: 'relative' }}
                >
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                        {inputs.colliType}
                        {inputs.quantity}
                        {inputs.grossWeight}
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                        {inputs.length}
                        {inputs.height}
                        {inputs.width}
                        {inputs.dangerousGoods}
                    </div>

                    {
                        cargoItem ? (
                            <i
                                className={`fa fa-trash ${styles.delete_icon}`}
                                onClick={() => this.deleteCargo(i)}
                            ></i>
                        ) : ''
                    }
                </div>
            );
        };

        if (cargoItems) {
            cargoItems.forEach((cargoItem, i) => {
                if (i > 0) cargosAdded.push(generateSeparator());
                if (!cargoItemTypes[i]) {
                    // Set a default cargo item type as the select box value

                    // Define labels of the default cargo item types in order of priority
                    const defaultTypeLabels = [
                        'Pallet',
                        '100.0cm × 120.0cm Pallet: Europe, Asia'
                    ];

                    // Try to find one of the labels in the available cargo item types
                    let defaultType;
                    defaultTypeLabels.find(defaultTypeLabel => (
                        defaultType = availableCargoItemTypes.find(cargoItemType => (
                            cargoItemType.label === defaultTypeLabel
                        ))
                    ));

                    // In case none of the defaultTypeLabels match the available
                    // cargo item types, set the default to the first available.
                    defaultType = defaultType || availableCargoItemTypes[0];

                    this.handleCargoItemType(
                        Object.assign({ name: i + '-colliType'}, defaultType )
                    );
                }
                cargosAdded.push(generateCargoItem(cargoItem, i));
            });
        }

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
                <div
                    className={`layout-row flex-none ${defs.content_width} layout-wrap layout-align-center-center section_padding`}
                    style={{ margin: '0 0 70px 0' }}
                >
                    <TextHeading theme={theme} text="Cargo Units" size={3}/>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                        { cargosAdded }
                    </div>

                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`${styles.add_unit_wrapper} content_width`}>
                            <div className={`layout-row flex-none ${styles.add_unit} layout-wrap layout-align-center-center`} onClick={this.addNewCargo}>
                                <p> Add unit</p>
                                <i className="fa fa-plus-square-o clip" style={textStyle}/>
                            </div>
                        </div>
                        <div className={`flex-100 ${styles.new_container_placeholder}`} >
                            { generateSeparator(null, -1) }
                            { generateCargoItem(null, -1) }
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

ShipmentCargoItems.propTypes = {
    theme: PropTypes.object,
    deleteItem: PropTypes.func,
    cargoItems: PropTypes.array,
    addCargoItem: PropTypes.func,
    handleDelta: PropTypes.func
};
