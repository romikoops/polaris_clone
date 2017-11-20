import React, {Component} from 'react';
import PropTypes from 'prop-types';
import Select from 'react-select';
import 'react-select/dist/react-select.css';
import { CONTAINER_DESCRIPTIONS, CONTAINER_TARE_WEIGHTS } from '../../constants';
import { Checkbox } from '../Checkbox/Checkbox';
const containerDescriptions = CONTAINER_DESCRIPTIONS;
const containerTareWeights = CONTAINER_TARE_WEIGHTS;
export class ShipmentContainers extends Component {
    constructor(props) {
        super(props);
        this.state = {
            newContainer: {
                weight: 0,
                type: '',
                tare_weight: 0,
                dangerousGoods: false
            }
        };
        this.handleWeightChange = this.handleWeightChange.bind(this);
        this.handleContainerSelect = this.handleContainerSelect.bind(this);
        this.addNewContainer = this.addNewContainer.bind(this);
        this.newContainerGrossWeight = this.newContainerGrossWeight.bind(this);
    }
    handleWeightChange(event) {
        const target = event.target;
        this.setState({ containers: {new: { ...this.state.newContainer, weight: target.value } }});
    }
    handleContainerSelect(val) {
        this.setState({
            newContainer: {
                type: val.value,
                tare_weight: val.tare_weight
            }
        });
    }
    addNewContainer() {
        const newCont = this.state.newContainer;
        this.props.addContainer(newCont);
        this.setState({
            newContainer: {
                weight: 0,
                type: '',
                tare_weight: 0,
                dangerousGoods: false
            }
        });
    }
    render() {
        const containerOptions = [];
        Object.keys(containerDescriptions).forEach(key => {
            containerOptions.push({value: key, label: containerDescriptions[key], tare_weight: containerTareWeights[key]});
        });
        const grossWeight = parseInt(this.state.newContainer.weight, 10) + parseInt(this.state.newContainer.tare_weight, 10);
        const containersAdded = [];
        if (this.props.containers) {
            this.props.containers.forEach(cont => {
                const tmpCont = (
            <div className="flex-100 layout-row">
              <div className="flex-20 layout-row layout-align-center-center">
                {cont.type}
              </div>
              <div className="flex-20 layout-row layout-align-center-center">
                {cont.weight}
              </div>
              <div className="flex-20 layout-row layout-align-center-center">
                {cont.weight + cont.tare_weight}
              </div>
            </div>
            );
                containersAdded.push(tmpCont);
            });
        }
        return (
        <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className="layout-row flex-75 layout-wrap layout-align-start-center" >
              <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                  <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                    <p className="flex-100"> Container Size </p>
                    <Select name="container-size" value={this.state.newContainer.type} options={containerOptions} onChange={this.handleContainerSelect} />
                  </div>
                  <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                    <p className="flex-100"> Net Weight </p>
                    <input value={this.state.newContainer.weight} type="number" onChange={this.handleWeightChange}/>
                  </div>
                  <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                    <p className="flex-100"> Gross Weight </p>
                    <input value={grossWeight} type="number" />
                  </div>
                  <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                    <p className="flex-100"> Dangerous Goods </p>
                    <Checkbox onChange={this.toggleDangerousGoods} checked={this.state.newContainer.dangerousGoods} />
                  </div>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                    <div className="layout-row flex-none layout-align-start-center" onClick={this.addNewCargo}>
                      <i className="flex-none fa fa-plus-square-o" />
                      <p className="flex-none flex-offset-5"> Add unit </p>
                    </div>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                  <div className="layout-row flex-100 layout-wrap" >
                    { containersAdded }
                  </div>
                </div>
            </div>
          </div>
        );
    }
}

ShipmentContainers.PropTypes = {
    theme: PropTypes.object,
    addContainer: PropTypes.func,
    containers: PropTypes.array
};
