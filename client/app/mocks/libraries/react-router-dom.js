import * as ReactRouterDom from 'react-router-dom'

ReactRouterDom.withRouter = jest.fn().mockImplementation(x => x)
