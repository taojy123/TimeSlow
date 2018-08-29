const Tslow = artifacts.require('./Tslow.sol')

module.exports = deployer => {
	deployer.deploy(Tslow)
}
