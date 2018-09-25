pragma solidity ^0.4.24;


contract Bolao {
    struct Jogador 
    {
	string nome;
	address carteira;
    }

    address private gerente;
    Jogador[] public jogadores;

    constructor() public {
        gerente = msg.sender;
    }

    function entrar(string pNome) public payable {
        require(msg.value == 1 ether);
	Jogador memory j = Jogador({ nome: pNome, carteira: msg.sender });
	jogadores.push(j);
        //jogadores.push(Jogador({ nome: pNome, carteira: msg.sender}));
    }

    function escolherGanhador() public restricted {
        uint index = randomico() % jogadores.length;
        jogadores[index].carteira.transfer(address(this).balance);
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
        jogadores = new Jogador[](0);
    }

    function randomico() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, now, jogadores)));
    }
}
