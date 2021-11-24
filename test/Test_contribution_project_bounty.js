const { assert } = require("@vue/compiler-core");
const { default: Web3 } = require("web3");

const BuildCollective  = artifacts.require('BuildCollective');

contract('BuildCollective', accounts => {
    const ownerProject = accounts[0];
    const project = accounts[1];
    const contrib = accounts[2];
    const noncontrib = accounts[3];
    const project2 = accounts[4]
    before(async () => {
        buildCollective = await BuildCollective.deployed();
    });

    it('Should Sign up an owner as a user and return it based on address', async () => {
        await buildCollective.signUp("Project Owner", {from: ownerProject});
        const user = await buildCollective.getUser("0x1Aff49d42eB7deFA5E0E45da5dD029b16469e310");
        assert(user.username === "Project Owner");
    });

    it('Owner should add a project', async () => {
        await buildCollective.addNewProject("DAAR_Project_3", "https://github.com/ghivert/build-collective", "0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E", {from: ownerProject});
        const theproject = await buildCollective.projects("0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E", {from: ownerProject});
        assert(theproject.owner === "Project Owner");
    });


    it('Should Sign up a contributor to a project and checks it is in the mapping of project contributors', async () => {
        await buildCollective.signUp("Project Contributor", {from: contrib});
        const user = await buildCollective.getUser("0xF363B2F2E00a71F6043e08200311d4CB1D43Bb7a");
        assert(user.username === "Project Contributor" );
    });

    it('Should Sign up a non-contributor to a project and checks it is not in the mapping of project contributors', async () => {
        await buildCollective.signUp("Non Contributor", {from: noncontrib});
        const user = await buildCollective.getUser("0xC54407596a4b20453dB078cCb75d4e965A875691");
        assert(user.username === "Non Contributor" );
    });

    it('checks that a user which contributes to a project is in the contributors list', async () => {
        await buildCollective.contribute("DAAR_Project_3","0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E", "https://github.com/Nacymus/build-collective/lastcommit", {from: contrib});
        const user = await buildCollective.contributors("0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E", "0xF363B2F2E00a71F6043e08200311d4CB1D43Bb7a", {from: contrib});
        const proj = await buildCollective.projects("0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E");
        assert (user.username === "Project Contributor");
        assert(proj.LastGitCommit === "https://github.com/Nacymus/build-collective/lastcommit");
    });

    it('Should set a bounty on bug in  aproject and checks this,is stored to bountiesl list', async () => {
        await buildCollective.setBounty("premier bug à réparer", "0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E", 200, {from:ownerProject});
        const bount = await buildCollective.bounties("0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E", {from:ownerProject});
        assert(bount.bug === "premier bug à réparer");
    });

    it('checks that a fix is suggested in a commit to a project', async () => {
        await buildCollective.fixBug("0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E", "https://github.com/Nacymus/build-collective/fixbugcommit", {from: contrib});
        const proj = await buildCollective.projects("0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E", {from: contrib});
        assert(proj.LastGitCommit === "https://github.com/Nacymus/build-collective/fixbugcommit");
    });

    // Start testing eth tranferring functions. 
    // At this stage, both asserts and the figures we see on Ganache UI are proof of correct transfers.      

    
    it('checks that a user donates to a project', async () => {
        //let proj = await buildCollective.projects("0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E");
        await buildCollective.donateToProject("DAAR_Project_3", "0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E", 5, {from: noncontrib, value: web3.utils.toWei('5', 'Ether')});
        
    });


    it('checks that an owner of project redistributes eth to contributors', async () => {
        //let proj = await buildCollective.projects("0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E");
        await buildCollective.payContrib("0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E", "0xF363B2F2E00a71F6043e08200311d4CB1D43Bb7a", 5, {from: ownerProject, value: web3.utils.toWei('5', 'Ether')});
        
    });

    it('checks that an owner of project redistributes eth to contributors', async () => {
        //let proj = await buildCollective.projects("0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E");
        await buildCollective.validateFix("0xF363B2F2E00a71F6043e08200311d4CB1D43Bb7a" ,"0xc9612f7464DDAb678AD3561e84c49cB51Bb58b1E", "premier bug à réparer", {from: ownerProject, value: web3.utils.toWei('5', 'Ether')});
        
    });



});