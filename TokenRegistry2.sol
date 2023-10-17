// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract TokenRegistry {
    address public owner;
    mapping(address => bool) public admins;
    
    struct Token {
        address tokenAddress;
        string name;
        string symbol;
        uint8 decimals;
        string logoLink;
        string website;
        string twitter;
        string telegram;
        string describes;
    }
    Token[] public tokens;

    event TokenAdded(address indexed tokenAddress, string name, string symbol, uint8 decimals, string logoLink, string website, string twitter, string telegram,string describes);
    event TokenUpdated(address indexed tokenAddress, string name, string symbol, uint8 decimals, string logoLink, string website, string twitter, string telegram,string describes);
    event LogoLinkUpdated(address indexed tokenAddress, string newLogoLink);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == owner, "Only admin can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function addToken(address _tokenAddress, string memory _logoLink, string memory _website, string memory _twitter, string memory _telegram, string memory _describes ) external onlyAdmin {
        require(admins[msg.sender] || msg.sender == owner, "Only admin can add tokens");
        
        IERC20 token = IERC20(_tokenAddress);
        tokens.push(Token(_tokenAddress, token.name(), token.symbol(), token.decimals(), _logoLink, _website, _twitter, _telegram, _describes));
        emit TokenAdded(_tokenAddress, token.name(), token.symbol(), token.decimals(), _logoLink, _website, _twitter, _telegram, _describes);
    }

    function updateToken(uint256 _index, address _newTokenAddress, string memory _newLogoLink, string memory _newWebsite, string memory _newTwitter, string memory _newTelegram, string memory _newDescribes) external onlyAdmin {
        require(_index < tokens.length, "Index out of bounds");
        
        IERC20 newToken = IERC20(_newTokenAddress);
        tokens[_index].tokenAddress = _newTokenAddress;
        tokens[_index].name = newToken.name();
        tokens[_index].symbol = newToken.symbol();
        tokens[_index].decimals = newToken.decimals();
        tokens[_index].logoLink = _newLogoLink;
        tokens[_index].website = _newWebsite;
        tokens[_index].twitter = _newTwitter;
        tokens[_index].telegram = _newTelegram;
        tokens[_index].describes = _newDescribes;


        emit TokenUpdated(_newTokenAddress, newToken.name(), newToken.symbol(), newToken.decimals(), _newLogoLink, _newWebsite, _newTwitter, _newTelegram, _newDescribes);
    }

    function updateLogoLink(address _tokenAddress, string memory _newLogoLink) external onlyAdmin {
        require(admins[msg.sender] || msg.sender == owner, "Only admin can update logo link");
        
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].tokenAddress == _tokenAddress) {
                tokens[i].logoLink = _newLogoLink;
                emit LogoLinkUpdated(_tokenAddress, _newLogoLink);
                break;
            }
        }
    }

    function addAdmin(address _admin) external onlyOwner {
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) external onlyOwner {
        require(_admin != owner, "Cannot remove owner as admin");
        admins[_admin] = false;
        emit AdminRemoved(_admin);
    }

    function getTokenCount() external view returns (uint256) {
        return tokens.length;
    }

    function getTokenByIndex(uint256 _index) external view returns (TokenInfo memory) {
        require(_index < tokens.length, "Index out of bounds");
    return TokenInfo(
        tokens[_index].tokenAddress,
        tokens[_index].name,
        tokens[_index].symbol,
        tokens[_index].decimals,
        tokens[_index].logoLink,
        tokens[_index].website,
        tokens[_index].twitter,
        tokens[_index].telegram,
        tokens[_index].describes
    );    
    }

    function getTokenByAddress(address _tokenAddress) external view returns (address tokenAddress, string memory name, string memory symbol, uint8 decimals, string memory logoLink,string memory website,string memory twitter,string memory telegram,string memory describes) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].tokenAddress == _tokenAddress) {
        return (tokens[i].tokenAddress, tokens[i].name, tokens[i].symbol, tokens[i].decimals, tokens[i].logoLink, tokens[i].website, tokens[i].twitter, tokens[i].telegram, tokens[i].describes);
            }
        }
        revert("Token not found");
    }

    function getTokenList() external view returns (TokenInfo[] memory) {
        TokenInfo[] memory tokenList = new TokenInfo[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            tokenList[i] = TokenInfo(tokens[i].tokenAddress, tokens[i].name, tokens[i].symbol, tokens[i].decimals, tokens[i].logoLink, tokens[i].website, tokens[i].twitter, tokens[i].telegram, tokens[i].describes);
        }

        return tokenList;
    }

    struct TokenInfo {
        address tokenAddress;
        string name;
        string symbol;
        uint8 decimals;
        string logoLink;
        string website;
        string twitter;
        string telegram;
        string describes;
    }
}
