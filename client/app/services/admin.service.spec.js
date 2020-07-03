import { adminService } from './admin.service'
import { pricing } from '../mocks'

const { fetch } = global

describe('Admin Service', () => {
  describe('getPricings', () => {
    beforeEach(() => {
      fetch.resetMocks()
    })

    describe('get pricings with options', () => {
      it('returns the list of pricings after building a query params', () => {
        const options = {
          filters: [{ id: 'test_id', value: 'Test value' }],
          sorted: [{ id: 'carrier', desc: true }]
        }

        const expectedResponse = [pricing]
        expect.assertions(1)
        fetch.mockResponses([
          JSON.stringify({ success: false, data: expectedResponse }),
          { status: 200 }
        ])

        return adminService.getPricings(options).then((resp) => {
          expect(resp.data).toEqual(expectedResponse)
        })
      })
    })
  })
})
