import React, { Component } from 'react'
import Chart from 'chart.js'
// import PropTypes from 'prop-types'
import styles from './AdminFCL.scss'

const cont20cap = {
  labels: ['K-ON!', 'is', 'a', 'master', 'piece'],
  datasets: [{
    data: [65, 59, 80, 81, 56]
  }]
}

const cont20val = {
  labels: ['K-ON!', 'is', 'a', 'master', 'piece'],
  datasets: [{
    data: [65, 59, 80, 81, 56]
  }]
}

const cont40cap = {
  labels: ['K-ON!', 'is', 'a', 'master', 'piece'],
  datasets: [{
    data: [65, 59, 80, 81, 56]
  }]
}

const cont40val = {
  labels: ['K-ON!', 'is', 'a', 'master', 'piece'],
  datasets: [{
    data: [65, 59, 80, 81, 56]
  }]
}

const cont45cap = {
  labels: ['K-ON!', 'is', 'a', 'master', 'piece'],
  datasets: [{
    data: [65, 59, 80, 81, 56]
  }]
}

const cont45val = {
  labels: ['K-ON!', 'is', 'a', 'master', 'piece'],
  datasets: [{
    data: [65, 59, 80, 81, 56]
  }]
}

const noLegendOptions = {
  legend: {
    display: false
  }
}

function createDoughnutChart (ref, data, options = {}) {
  return new Chart(ref, {
    type: 'doughnut',
    data,
    options: noLegendOptions
  })
}

function createPieChart (ref, data, options = {}) {
  return new Chart(ref, {
    type: 'pie',
    data,
    options: noLegendOptions
  })
}

export class AdminFCL extends Component {
  constructor (props) {
    super(props)

    this.cont20 = {
      capacity: [],
      value: []
    }

    this.cont40 = {
      capacity: [],
      value: []
    }

    this.cont45 = {
      capacity: [],
      value: []
    }

    // this.setChart = (element, ref) => {
    //   ref = element
    // }

    this.state = {
      // labels: this.props.labels,
      // datasets: this.props.datasets,
      // options: this.props.options
    }
  }

  componentDidMount () {
    createPieChart(this.cont20.value, cont20val)
    createPieChart(this.cont40.value, cont40val)
    createPieChart(this.cont45.value, cont45val)
    createDoughnutChart(this.cont20.capacity, cont20cap)
    createDoughnutChart(this.cont40.capacity, cont40cap)
    createDoughnutChart(this.cont45.capacity, cont45cap)
  }

  render () {
    return (
      <div className="layout-column flex-100 layout-wrap layout-align-start-stretch">
        <div className="layout-row flex-10 layout-align-center-center">
          <span className={`${styles.title}`}>Pending bookings</span>
        </div>
        <div className="layout-row flex-90 layout-wrap layout-align-space-around-stretch">
          <div className="layout-column flex-25 layout-wrap layout-align-center-stretch">
            <div className="layout-row flex-10 layout-align-center-center">
              <span className={`${styles.title}`}>20&rsquo; Container</span>
            </div>
            <div className="layout-row flex-60 layout-wrap layout-align-space-between-stretch">
              <div className="layout-column flex-45 layout-wrap layout-align-start-center">
                <div className="layout-row flex-20 layout-align-start-center">
                  <span className={`${styles.title}`}>Capacity</span>
                </div>
                <div className="layout-column flex-80 layout-wrap layout-align-center-stretch">
                  <canvas
                    ref={(c) => {
                      this.cont20.capacity = c
                    }}
                    className=""
                  />
                </div>
              </div>
              <div className="layout-column flex-45 layout-wrap layout-align-start-center">
                <div className="layout-row flex-20 layout-align-start-center">
                  <span className={`${styles.title}`}>Value</span>
                </div>
                <div className="layout-column flex-50 layout-wrap layout-align-center-center">
                  <canvas
                    ref={(c) => {
                      this.cont20.value = c
                    }}
                    className=""
                  />
                </div>
                <div className="layout-column flex-20 layout-align-center-center">
                  <span className={`${styles.title}`}>€</span>
                </div>
              </div>
            </div>
            <div className={`layout-row flex-30 layout-wrap
                layout-align-space-between-center ${styles.total}`}
            >
              <span className="">Total shipments</span>
              <span className={`${styles.totalamount}`}>42</span>
            </div>
          </div>
          <div className="layout-column flex-25 layout-wrap layout-align-center-stretch">
            <div className="layout-row flex-10 layout-align-center-center">
              <span className={`${styles.title}`}>40&rsquo; Container</span>
            </div>
            <div className="layout-row flex-60 layout-wrap layout-align-space-between-stretch">
              <div className="layout-column flex-45 layout-wrap layout-align-start-center">
                <div className="layout-row flex-20 layout-align-start-center">
                  <span className={`${styles.title}`}>Capacity</span>
                </div>
                <div className="layout-column flex-80 layout-wrap layout-align-center-stretch">
                  <canvas
                    ref={(c) => {
                      this.cont40.capacity = c
                    }}
                    className=""
                  />
                </div>
              </div>
              <div className="layout-column flex-45 layout-wrap layout-align-start-center">
                <div className="layout-row flex-20 layout-align-start-center">
                  <span className={`${styles.title}`}>Value</span>
                </div>
                <div className="layout-column flex-50 layout-wrap layout-align-center-center">
                  <canvas
                    ref={(c) => {
                      this.cont40.value = c
                    }}
                    className=""
                  />
                </div>
                <div className="layout-column flex-20 layout-align-center-center">
                  <span className={`${styles.title}`}>€</span>
                </div>
              </div>
            </div>
            <div className={`layout-row flex-30 layout-wrap
                layout-align-space-between-center ${styles.total}`}
            >
              <span className="">Total shipments</span>
              <span className={`${styles.totalamount}`}>42</span>
            </div>
          </div>
          <div className="layout-column flex-25 layout-wrap layout-align-center-stretch">
            <div className="layout-row flex-10 layout-align-center-center">
              <span className={`${styles.title}`}>45&rsquo; Container</span>
            </div>
            <div className="layout-row flex-60 layout-wrap layout-align-space-between-stretch">
              <div className="layout-column flex-45 layout-wrap layout-align-start-center">
                <div className="layout-row flex-20 layout-align-start-center">
                  <span className={`${styles.title}`}>Capacity</span>
                </div>
                <div className="layout-column flex-80 layout-wrap layout-align-center-stretch">
                  <canvas
                    ref={(c) => {
                      this.cont45.capacity = c
                    }}
                    className=""
                  />
                </div>
              </div>
              <div className="layout-column flex-45 layout-wrap layout-align-start-center">
                <div className="layout-row flex-20 layout-align-start-center">
                  <span className={`${styles.title}`}>Value</span>
                </div>
                <div className="layout-column flex-50 layout-wrap layout-align-center-center">
                  <canvas
                    ref={(c) => {
                      this.cont45.value = c
                    }}
                    className=""
                  />
                </div>
                <div className="layout-column flex-20 layout-align-center-center">
                  <span className={`${styles.title}`}>€</span>
                </div>
              </div>
            </div>
            <div className={`layout-row flex-30 layout-wrap
                layout-align-space-between-center ${styles.total}`}
            >
              <span className="">Total shipments</span>
              <span className={`${styles.totalamount}`}>42</span>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

// AdminFCL.propTypes = {
//   labels: PropTypes.arrayOf(PropTypes.string),
//   datasets: PropTypes.node,
//   options: PropTypes.node
// }
//
// AdminFCL.defaultProps = {
//   labels: [''],
//   datasets: [],
//   options: {}
// }

export default AdminFCL
