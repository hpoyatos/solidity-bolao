pragma solidity ^0.4.25;


contract Bolao {
    struct Jogador
    {
	    string nome;
        address carteira;
	    uint256 apostas;
	    bool isValue;
    }

    event ApostaEvent(
        address indexed carteira,
        string nome,
        uint256 apostas,
        uint256 apostasTotal,
        uint256 premio
    );

    event FimDeJogoEvent(
        address indexed carteira,
        string ganhador,
        uint256 premio
    );

    mapping(address => Jogador) public jogadoresInfo;
    address private gerente;
    address[] public jogadores;
    address[] public apostas;
    uint256 public premio;
    uint256 public numApostas;

    constructor() public {
        gerente = msg.sender;
        numApostas = 0;
        premio = 0;
    }

    function entrar(string pNome) public payable {
        require(msg.value == 1 ether);
	    if (jogadoresInfo[msg.sender].isValue == false)
	    {
	    	jogadoresInfo[msg.sender] = Jogador({ nome: pNome, carteira: msg.sender, apostas: 1, isValue: true});
	    	jogadores.push(msg.sender);
	    }
	    else
	    {
		    jogadoresInfo[msg.sender].apostas = jogadoresInfo[msg.sender].apostas + 1;
 	    }
	    apostas.push(msg.sender);
        numApostas++;
        premio = premio + msg.value;
	    emit ApostaEvent(msg.sender, jogadoresInfo[msg.sender].nome, jogadoresInfo[msg.sender].apostas, numApostas, address(this).balance);
    }

    function escolherGanhador() public restricted {
        uint index = randomico() % jogadores.length;
        jogadores[index].transfer(address(this).balance);

        if (jogadoresInfo[jogadores[index]].isValue == true)
	    {
            emit FimDeJogoEvent(jogadores[index], jogadoresInfo[jogadores[index]].nome, premio);
	    }
	    limpar();
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

    function getJogadorPorId(address id) public view returns(string, address, uint256){
	    return (jogadoresInfo[id].nome, jogadoresInfo[id].carteira, jogadoresInfo[id].apostas);
    }

    function getGerente() public view returns (address) {
        return gerente;
    }

    function getSaldo() public view returns (uint256){
	return address(this).balance;
    }

    function limpar() private {
        jogadores = new address[](0);
        apostas = new address[](0);
        numApostas = 0;
        premio = 0;
    }

    function randomico() private view returns (uint) {
        uint(keccak256(abi.encodePacked(block.difficulty, now, jogadores)));
    }
}
