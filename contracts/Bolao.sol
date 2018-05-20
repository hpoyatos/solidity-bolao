pragma solidity 0.4.24;


contract Bolao {
    address private gerente;
    address[] private jogadores;

    function contructor() public {
        gerente = msg.sender;
    }

    function entrar() public payable {
        require(msg.value >= 1 ether);
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

    function getGerente() public view returns (address) {
        return gerente;
    }

    function limpar() private {
        jogadores = new address[](0);
    }

    function randomico() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, now, jogadores)));
    }
}
