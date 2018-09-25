pragma solidity ^0.4.24;


contract Bolao {
    struct Jogador 
    {
	    string nome;
	    address carteira;
    }
    
    mapping(address => Jogador) public jogadoresInfo;
    address private gerente;
    address[] public jogadores;

    constructor() public {
        gerente = msg.sender;
    }

    function entrar(string pNome) public payable {
        require(msg.value == 1 ether);
	    jogadoresInfo[msg.sender] = Jogador({ nome: pNome, carteira: msg.sender });
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

   /* function getJogadores() public view returns (address[]) {
        return jogadores;
    }*/

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