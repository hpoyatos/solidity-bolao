pragma solidity ^0.4.24;


contract Bolao {
    struct Jogador 
    {
	    string nome;
	    uint32 saldo;
	    uint8 apostas;
    }
    
    mapping(address => Jogador) public jogadoresInfo;
    address private gerente;
    address[] public jogadores;

    constructor() public {
        gerente = msg.sender;
    }

    function entrar(string pNome, uint32 pSaldo) public payable {
        require(msg.value == 1 ether);
	    if (jogadoresInfo[msg.sender].isValue = false)
	    {
	    	jogadoresInfo[msg.sender] == Jogador({ nome: pNome, saldo: pSaldo, apostas: 1});
	    }
	    else
	    {
		jogadoresInfo[msg.sender].apostas++;
 	    }
	    jogadores.push(msg.sender);
    }

    function escolherGanhador() public restricted {
        uint index = randomico() % jogadores.length;
        jogadores[index].transfer(address(this).balance);
        limpar();
    }

    modifier restricted() {
        require(msg.sender == gerente);
        _;
    }

    function getJogadores() public view returns (address[]) {
        return jogadores;
    }

    function getJogadorPorId(address id) public view returns(string, uint32, uint8){
	return jogadoresInfo(id).nome, jogadoresInfo(id).saldo, jogadoresInfo(id).apostas;

    }

    function getGerente() public view returns (address) {
        return gerente;
    }

    function limpar() private {
        jogadores = new address[](0);
    }

    function randomico() private view returns (uint) {
        uint(keccak256(abi.encodePacked(block.difficulty, now, jogadores)));
    }
}
