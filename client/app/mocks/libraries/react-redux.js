import * as ReactRedux from 'react-redux'

ReactRedux.connect = jest.fn().mockImplementation((mapStateToProps, mapDispatchToProps) => Component => Component)
