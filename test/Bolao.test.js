const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const { interface, bytecode } = require('../compile');

let bolao;
let accounts;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();

  bolao = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data: bytecode })
    .send({ from: accounts[0], gas: '1000000' });
});

describe('Contrato de Bolão', () => {
  it('publicando o contrato', () => {
    assert.ok(bolao.options.address);
  });

  it('permitindo que uma conta entre no bolão', async () => {
    await bolao.methods.entrar().send({
      from: accounts[0],
      value: web3.utils.toWei('1', 'ether')
    });

    const jogadores = await bolao.methods.getJogadores().call({
      from: accounts[0]
    });

    assert.equal(accounts[0], jogadores[0]);
    assert.equal(1, jogadores.length);
  });

  it('permitindo que múltiplas contas entrem no bolão', async () => {
    await bolao.methods.entrar().send({
      from: accounts[0],
      value: web3.utils.toWei('1', 'ether')
    });
    await bolao.methods.entrar().send({
      from: accounts[1],
      value: web3.utils.toWei('1', 'ether')
    });
    await bolao.methods.entrar().send({
      from: accounts[2],
      value: web3.utils.toWei('1', 'ether')
    });

    const jogadores = await bolao.methods.getJogadores().call({
      from: accounts[0]
    });

    assert.equal(accounts[0], jogadores[0]);
    assert.equal(accounts[1], jogadores[1]);
    assert.equal(accounts[2], jogadores[2]);
    assert.equal(3, jogadores.length);
  });

  it('solicitando uma quantia mínima para entrar no bolão', async () => {
    try {
      await bolao.methods.entrar().send({
        from: accounts[0],
        value: web3.utils.toWei('0.9', 'ether')
      });
      assert(false);
    } catch (err) {
      assert(err);
    }
  });

  it('só o gerente pode chamar "escolher ganhador"', async () => {
    try {
      await bolao.methods.escolherGanhador().send({
        from: accounts[1]
      });
      assert(false);
    } catch (err) {
      assert(err);
    }
  });

  it('enviando dinheiro para o ganhador e limpando o array de jogadores', async () => {
    await bolao.methods.entrar().send({
      from: accounts[0],
      value: web3.utils.toWei('2', 'ether')
    });

    const initialBalance = await web3.eth.getBalance(accounts[0]);
    await bolao.methods.escolherGanhador().send({ from: accounts[0] });
    const finalBalance = await web3.eth.getBalance(accounts[0]);
    const difference = finalBalance - initialBalance;

    assert(difference > web3.utils.toWei('1.8', 'ether'));
  });
});
