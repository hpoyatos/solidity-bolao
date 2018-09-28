pragma solidity ^0.4.25;


contract Bolao {
    struct Jogador
    {
	    string nome;
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
    address[] public apostas;
    address public ultimoGanhador;

    constructor() public {
        gerente = msg.sender;
    }

    function entrar(string pNome) public payable {
        require(msg.value == 1 ether);
	    if (jogadoresInfo[msg.sender].isValue == false)
	    {
	    	jogadoresInfo[msg.sender] = Jogador({ nome: pNome, apostas: 1, isValue: true});
	    	jogadores.push(msg.sender);
	    }
	    else
	    {
		    jogadoresInfo[msg.sender].apostas = jogadoresInfo[msg.sender].apostas + 1;
 	    }
	    apostas.push(msg.sender);
	    emit ApostaEvent(msg.sender, jogadoresInfo[msg.sender].apostas);
    }

    function escolherGanhador() public restricted payable returns (string) {
        uint index = randomico() % jogadores.length;
        jogadores[index].transfer(address(this).balance);
        ultimoGanhador = jogadores[index];
        limpar();
        return jogadoresInfo[ultimoGanhador].nome;
    }

    modifier restricted() {
        require(msg.sender == gerente);
        _;
    }

    function getJogadores() public view returns (address[]) {
        return jogadores;
    }

    function getApostas() public view returns (address[]) {
        return apostas;
    }

    function getJogadorPorId(address id) public view returns(string, uint8){
	    return (jogadoresInfo[id].nome, jogadoresInfo[id].apostas);
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
        apostas = new address[](0);
    }

    function randomico() private view returns (uint) {
        uint(keccak256(abi.encodePacked(block.difficulty, now, jogadores)));
    }
}
