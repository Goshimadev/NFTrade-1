const NFTrade = artifacts.require("NFTrade");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("NFTrade", function (/* accounts */) {
  it("should assert true", async function () {
    await NFTrade.deployed();
    return assert.isTrue(true);
  });
});
