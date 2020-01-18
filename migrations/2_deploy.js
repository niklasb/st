const Token = artifacts.require('Token')
const StableCoin = artifacts.require('StableCoin')

module.exports = (deployer) => {
  deployer.deploy(Token)
  deployer.deploy(StableCoin)
}
