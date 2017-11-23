const A = artifacts.require('A')
const B = artifacts.require('B')

describe('A & B', async () => {
  let a
  let b

  before(async () => {
  })

  context('in normal operation', () => {
    before(async () => {
      a = await A.new()
      b = await B.new()
    })

    it('succeeds profiling', async () => {
      await a.profile.sendTransaction()
      await b.profile.sendTransaction()
    })

    it('can profile', async () => {

      const aEstimatedGas = await a.profile.estimateGas()
      const bEstimatedGas = await b.profile.estimateGas()

      console.log('A#profile()', aEstimatedGas.toString())
      console.log('B#profile()', bEstimatedGas.toString())
    })
  })
})
