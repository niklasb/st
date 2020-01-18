const Token = artifacts.require('Token');
const UpgradeProxy = artifacts.require('UpgradeProxy');
const StableCoin = artifacts.require('StableCoin');

contract('Token', ([issuer, auditor, holder]) => {
  let token;

  beforeEach('setup', async () => {
    let logic = await Token.new();
    let proxy = await UpgradeProxy.new(issuer, logic.address, auditor);
    let stablecoin = await StableCoin.new();
    token = await Token.at(proxy.address);
    token.construct({from: issuer});
  });

  it('can be deployed', async () => {
    assert.equal(await token.symbol(), "BOND");
    //await token
  });
})
