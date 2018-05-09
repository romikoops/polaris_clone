import React, { Component } from 'react'
import Chart from 'chart.js'
// import PropTypes from 'prop-types'
import styles from './AdminCustomers.scss'

const chartData = {
  labels: ['K-ON!', 'is', 'a', 'master', 'piece'],
  datasets: [
    {
      label: 'My First dataset',
      fillColor: 'rgba(220,220,220,0.2)',
      strokeColor: 'rgba(220,220,220,1)',
      pointColor: 'rgba(220,220,220,1)',
      pointStrokeColor: '#fff',
      pointHighlightFill: '#fff',
      pointHighlightStroke: 'rgba(220,220,220,1)',
      data: [65, 59, 80, 81, 56]
    }
  ]
}

const chartOptions = {

}

export class AdminCustomers extends Component {
  constructor (props) {
    super(props)

    this.chart = null

    this.setChart = (element) => {
      this.chart = element
    }

    this.state = {
      // labels: this.props.labels,
      // datasets: this.props.datasets,
      // options: this.props.options
    }
  }

  componentDidMount () {
    this.createChart()
  }

  createChart () {
    const chartCanvas = this.chart

    return new Chart(chartCanvas, {
      type: 'bar',
      data: chartData,
      options: chartOptions
    })
  }

  render () {
    return (
      <div className="layout-column flex-100 layout-align-space-start-center">
        <div className="layout-row flex-10 layout-wrap layout-align-space-start-start">
          <span className={`${styles.title}`}>Pending bookings</span>
        </div>
        <div className="layout-column flex-90 layout-align-space-start-center">
          <canvas ref={this.setChart} className="flex-100" />
        </div>
      </div>
    )
  }
}

// AdminCustomers.propTypes = {
//   labels: PropTypes.arrayOf(PropTypes.string),
//   datasets: PropTypes.node,
//   options: PropTypes.node
// }
//
// AdminCustomers.defaultProps = {
//   labels: [''],
//   datasets: [],
//   options: {}
// }

export default AdminCustomers
