pragma solidity ^0.4.25;


contract Bolao {
    struct Jogador 
    {
	    string nome;
	    uint256 saldo;
	    uint8 apostas;
	    bool isValue;
    }
    
    event ApostaEvent(
        address indexed apostador,
        uint8 apostas
    );
    
    mapping(address => Jogador) public jogadoresInfo;
    address private gerente;
    address[] public jogadores;
    address public ultimoGanhador;

    constructor() public {
        gerente = msg.sender;
    }

    function entrar(string pNome, uint256 pSaldo) public payable {
        require(msg.value == 1 ether);
	    if (jogadoresInfo[msg.sender].isValue == false)
	    {
	    	jogadoresInfo[msg.sender] = Jogador({ nome: pNome, saldo: pSaldo, apostas: 1, isValue: true});
	    }
	    else
	    {
		    jogadoresInfo[msg.sender].apostas = jogadoresInfo[msg.sender].apostas + 1;
 	    }
 	    jogadoresInfo[msg.sender].saldo = pSaldo - msg.value;
	    jogadores.push(msg.sender);
	    emit ApostaEvent(msg.sender, jogadoresInfo[msg.sender].apostas);
    }

    function escolherGanhador() public restricted {
        uint index = randomico() % jogadores.length;
        jogadores[index].transfer(address(this).balance);
        ultimoGanhador = jogadores[index];
        limpar();
    }

    modifier restricted() {
        require(msg.sender == gerente);
        _;
    }

    function getJogadores() public view returns (address[]) {
        return jogadores;
    }

    function getJogadorPorId(address id) public view returns(string, uint256, uint8){
	return (jogadoresInfo[id].nome, jogadoresInfo[id].saldo, jogadoresInfo[id].apostas);

    }

    function getGerente() public view returns (address) {
        return gerente;
    }

    function getUltimoGanhador() public view returns (address) {
	return ultimoGanhador;
    }
    
    function getSaldo() public view returns (uint256){
	return address(this).balance;
    }

    function limpar() private {
        jogadores = new address[](0);
    }

    function randomico() private view returns (uint) {
        uint(keccak256(abi.encodePacked(block.difficulty, now, jogadores)));
    }
}
