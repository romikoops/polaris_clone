import React, {Component} from 'react';
import PropTypes from 'prop-types';
import Select from 'react-select';
import 'react-select/dist/react-select.css';
import styles from './ShipmentContainers.scss';
import { CONTAINER_DESCRIPTIONS, CONTAINER_TARE_WEIGHTS } from '../../constants';
import { Checkbox } from '../Checkbox/Checkbox';
import defs from '../../styles/default_classes.scss';
const containerDescriptions = CONTAINER_DESCRIPTIONS;
const containerTareWeights = CONTAINER_TARE_WEIGHTS;
export class ShipmentContainers extends Component {
    constructor(props) {
        super(props);
        this.handleContainerSelect = this.handleContainerSelect.bind(this);
        this.toggleDangerousGoods = this.toggleDangerousGoods.bind(this);
    }

    handleContainerSelect(val) {
        const ev1 = {target: {name: 'sizeClass', value: val.value}};
        const ev2 = {target: {name: 'tareWeight', value: val.tare_weight}};
        this.props.handleDelta(ev1);
        this.props.handleDelta(ev2);
    }

    toggleDangerousGoods() {
        const event = {target: {name: 'dangerousGoods', value: !this.props.containers[0].dangerousGoods}};
        this.props.handleDelta(event);
    }

    render() {
        const { containers, handleDelta, addContainer } = this.props;
        const newContainer = containers[0];
        const containerOptions = [];
        Object.keys(containerDescriptions).forEach(key => {
            containerOptions.push({value: key, label: containerDescriptions[key], tare_weight: containerTareWeights[key]});
        });
        const grossWeight = parseInt(newContainer.payload_in_kg, 10) + parseInt(newContainer.tareWeight, 10);
        const containersAdded = [];
        if (this.props.containers) {
            this.props.containers.forEach((cont, i) => {
                if (i !== 0) {
                    const tmpCont = (
                        <div className="flex-100 layout-row">
                          <div className="flex-20 layout-row layout-align-center-center">
                            {containerDescriptions[cont.sizeClass]}
                          </div>
                          <div className="flex-20 layout-row layout-align-center-center">
                            {cont.payload_in_kg} kg
                          </div>
                          <div className="flex-20 layout-row layout-align-center-center">
                            {parseInt(cont.payload_in_kg, 10) + parseInt(cont.tareWeight, 10)} kg
                          </div>
                          <div className="flex-20 layout-row layout-align-center-center">
                              Dangerous Goods: {cont.dangerousGoods ? 'Yes' : 'No'}
                            </div>
                        </div>
                    );
                    containersAdded.push(tmpCont);
                }
            });
        }
        return (
        <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className={`layout-row flex-none ${defs.content_width} layout-wrap layout-align-start-center`} >
              <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                  <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                    <p className="flex-100"> Container Size </p>
                    <Select placeholder={newContainer.sizeClass} className={styles.select} name="container-size" value={newContainer.type} options={containerOptions} onChange={this.handleContainerSelect} />
                  </div>

                  <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                      <p className="flex-100"> Net Weight </p>
                      <div className={`flex-95 layout-row ${styles.input_box}`}>
                        <input className="flex-80" name="payload_in_kg" value={newContainer.payload_in_kg} type="number" onChange={handleDelta}/>
                        <div className="flex-20 layout-row layout-align-center-center">
                          kg
                        </div>
                      </div>
                    </div>
                <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                  <p className="flex-100"> Gross Weight </p>
                  <div className={`flex-95 layout-row ${styles.input_box}`}>
                    <input className="flex-80" name="payload_in_kg" value={grossWeight} type="number" />
                    <div className="flex-20 layout-row layout-align-center-center">
                      kg
                    </div>
                  </div>
                </div>

                  <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                    <p className="flex-100"> Dangerous Goods </p>
                    <Checkbox onChange={this.toggleDangerousGoods} checked={newContainer.dangerousGoods} />
                  </div>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                    <div className="layout-row flex-none layout-align-start-center" onClick={addContainer}>
                      <i className="flex-none fa fa-plus-square-o" />
                      <p className="flex-none flex-offset-5"> Add unit </p>
                    </div>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                  <div className={`layout-row flex-none ${defs.content_width} layout-wrap`} >
                    { containersAdded }
                  </div>
                </div>
            </div>
          </div>
        );
    }
}

ShipmentContainers.propTypes = {
    theme: PropTypes.object,
    addContainer: PropTypes.func,
    containers: PropTypes.array,
    handleDelta: PropTypes.func
};
