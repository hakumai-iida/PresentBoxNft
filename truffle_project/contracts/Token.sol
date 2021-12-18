// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./Lib/LibB64.sol";
import "./Lib/LibStr.sol";

//-----------------------------------
// トークン
//-----------------------------------
contract Token is Ownable, ERC721 {
    //-----------------------------------------
    // 定数
    //-----------------------------------------    
    string constant private TOKEN_NAME = "Xmas Present Token 2021";
    string constant private TOKEN_SYMBOL = "XPT-2021";
    string constant private GIF_HASH = "QmbLGTXWGgxp7r3DEAusR8sCerMJQJxisiarBDN4zQK5KE";
    string constant private PNG_HASH = "QmYMsfUJqQFUsPoygiRDPZ3qTBhvyaTf19sKtkN7iJ4U3t";
    uint256 constant private TOTAL_SUPPLY = 13;

    //-----------------------------------------
    // ストレージ
    //-----------------------------------------
    string private _gifHash;
    string private _pngHash;
    string[] private _htmls;
    uint256[] private _unixtimes;

    //-----------------------------------------
    // コンストラクタ
    //-----------------------------------------
    constructor() Ownable() ERC721( TOKEN_NAME, TOKEN_SYMBOL ) {}

    //-----------------------------------------
    // [external] トークンの発行
    //-----------------------------------------
    function mintToken( string calldata html, uint256 unixtime ) external {
        require( _htmls.length < TOTAL_SUPPLY, "upper limit of minting" );

        _safeMint( msg.sender, _htmls.length );
        _htmls.push( html );
        _unixtimes.push( unixtime );
    }

    //-----------------------------------------
    // [public] トークンURI
    //-----------------------------------------
    function tokenURI( uint256 tokenId ) public view override returns (string memory) {
        require( _exists(tokenId), "nonexistent token" );

        bytes memory bytesId = bytes(LibStr.numToStr(tokenId, 2));
        bytes memory bytesName = abi.encodePacked( '"name":"', TOKEN_SYMBOL, ' #', bytesId, '"' );
        bytes memory bytesDescription = ',"description":"A christmas gift token for 2021!"';
        bytes memory bytesImage;
        bytes memory bytesAnimationUrl;

        if( _unixtimes[tokenId] <= block.timestamp ){
            bytesImage = abi.encodePacked( ',"image":"https://ipfs.infura.io/ipfs/', PNG_HASH ,'/p', bytesId, '.png"' );
            bytesAnimationUrl = '';
        }else{
            bytesImage = abi.encodePacked( ',"image":"https://ipfs.infura.io/ipfs/', GIF_HASH, '/b', bytesId, '.gif"' );
            bytesAnimationUrl = abi.encodePacked( ',"animation_url":"https://ipfs.infura.io/ipfs/', _htmls[tokenId], '"' );
        }

        bytes memory bytesMeta = abi.encodePacked( '{', bytesName, bytesDescription, bytesImage, bytesAnimationUrl, '}' );
        return( string( abi.encodePacked( 'data:application/json;base64,', LibB64.encode( bytesMeta ) ) ) );
    }

    //-----------------------------------------
    // [external] HTML修復
    //-----------------------------------------
    function repairHtml( uint256 tokenId, string calldata html, uint256 unixtime ) external onlyOwner {
        require( _exists(tokenId), "nonexistent token" );
        _htmls[tokenId] = html;
        _unixtimes[tokenId] = unixtime;
    }
}
