import React from 'react'

function deprecated (WrappedComponent, msg = '') {
  return class extends React.Component {
    componentDidMount () {
      if (process.env.NODE_ENV === 'development') {
        console.warn(`${WrappedComponent.displayName} is deprecated`, msg)
      }
    }

    render () {
      return (
        <WrappedComponent {...this.props} />
      )
    }
  }
}

export default deprecated
