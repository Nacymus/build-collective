const BuildCollective  = artifacts.require('BuildCollective');

contract('BuildCollective', () => {
    let buildCollective = null;
    before(async () => {
        buildCollective = await BuildCollective.deployed();
    });

    it('Should Sign up a user and return it based on address', async () => {
        await buildCollective.signUp("Nassim ZERKA");
        const user = await buildCollective.getUser("0x1Aff49d42eB7deFA5E0E45da5dD029b16469e310");
        assert(user.username === "Nassim ZERKA" );
    });

    it('Should Sign up an Enterprise and return it based on address', async () => {
        await buildCollective.enterpriseSignUp("stmelectronics");
        const company = await buildCollective.getEnterprise("0x1Aff49d42eB7deFA5E0E45da5dD029b16469e310");
        assert(company.name === "stmelectronics" );
    });

});