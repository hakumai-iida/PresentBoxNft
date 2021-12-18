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
    string constant private TOKEN_NAME = "Xmas Gift Token 2021";
    string constant private TOKEN_SYMBOL = "XGT-2021";
    uint256 constant private TOTAL_SUPPLY = 13;

    //-----------------------------------------
    // ストレージ
    //-----------------------------------------
    uint[] private _times;

    //-----------------------------------------
    // コンストラクタ
    //-----------------------------------------
    constructor() Ownable() ERC721( TOKEN_NAME, TOKEN_SYMBOL ) {}

    //-----------------------------------------
    // [external] トークンの発行
    //-----------------------------------------
    function mintToken( uint256 time ) external {
        require( _times.length < TOTAL_SUPPLY, "upper limit of minting" );

        _safeMint( msg.sender, _times.length );
        _times.push( time );
    }

    //-----------------------------------------
    // [public] トークンURI
    //-----------------------------------------
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require( _exists(tokenId), "nonexistent token" );

        bytes memory bytesName = abi.encodePacked( '{"name":"', TOKEN_SYMBOL, ' #', LibStr.numToStr(tokenId, 0), '"' );
        bytes memory bytesDescription = ',"description":"A christmas gift token for 2021!"';
        bytes memory bytesImage;
        bytes memory bytesAnimationUrl;

        if( _times[tokenId] <= block.timestamp ){
            bytesImage = abi.encodePacked( ',"image":"https://ipfs.infura.io/ipfs/QmYMsfUJqQFUsPoygiRDPZ3qTBhvyaTf19sKtkN7iJ4U3t/p', LibStr.numToStr(tokenId, 2), '.png"' );
            bytesAnimationUrl = '}';
        }else{
            bytesImage = abi.encodePacked( ',"image":"https://ipfs.infura.io/ipfs/QmbLGTXWGgxp7r3DEAusR8sCerMJQJxisiarBDN4zQK5KE/b', LibStr.numToStr(tokenId, 2), '.gif"' );
            bytesAnimationUrl = createHtml( tokenId );
            bytesAnimationUrl = abi.encodePacked( ',"animation_url":"data:text/html;charset=UTF-8;base64,', LibB64.encode(bytesAnimationUrl), '"}' );
        }

        bytes memory bytesMeta = abi.encodePacked( bytesName, bytesDescription, bytesImage, bytesAnimationUrl );
        return( string( abi.encodePacked( 'data:application/json;base64,', LibB64.encode( bytesMeta ) ) ) );
    }

    //-----------------------------------------
    // [internal] htmlの作成
    //-----------------------------------------
    function createHtml(uint256 tokenId) internal view returns (bytes memory) {
        bytes memory bytesHtml0 = '<html><head><style>*{margin:0;padding:0;}body{background-image:url("https://ipfs.infura.io/ipfs/';
        bytes memory bytesGif = abi.encodePacked( 'QmbLGTXWGgxp7r3DEAusR8sCerMJQJxisiarBDN4zQK5KE/b', LibStr.numToStr(tokenId, 2), '.gif' );
        bytes memory bytesHtml1 = '");background-size:cover;background-attachment:fixed;background-position:center;}p{text-align:center;font-size:4rem;color:#554;margin-top:30px;}.time{font-weight:bold;}.bO{display:none;width:150px;height:150px;cursor:pointer;}.iL{display:none;width:150px;height:150px;opacity:0.7;}</style>';
        bytes memory bytesHtml2 = '<script>let waitSec=0;let intervalId=0;function count(){if(waitSec<=0){clearInterval(intervalId );ready();return;}waitSec--;let day=Math.floor(waitSec/86400);let hh=(Math.floor(waitSec/3600))%24;hh=("00"+hh).slice(-2);let mm=(Math.floor(waitSec/60))%60;mm=("00"+mm).slice(-2);let ss=(waitSec%60);ss=("00"+ss).slice(-2);let e=document.getElementById("sT");if(day<= 0){e.innerHTML=hh+":"+mm+":"+ss;}else{if(day>1){e.innerHTML=day+"days "+hh+":"+mm+":"+ss;}else{e.innerHTML=day+"day "+hh+":"+mm+":"+ss;}}}function wait(){let e=document.getElementById("pR");e.style.display="none";e=document.getElementById("sW");e.innerHTML="Please Wait...";count();intervalId=setInterval(count,1000);}function ready(){let e=document.getElementById("pW");e.style.display="none";e=document.getElementById("pR");e.style.display="block";e=document.getElementById("sR");e.innerHTML="Open the Gift!!";e=document.getElementById("bO");e.style.display="inline";}function start(){let ut=';
        bytes memory bytesTime = bytes(LibStr.numToStr( _times[tokenId], 0 ));
        bytes memory bytesHtml3 = ';let t=Math.floor(new Date().getTime()/1000);if(t<ut){waitSec=ut-t;}if(waitSec>0){wait();}else{ready();}}function updateMeta(){let e=document.getElementById("bO");e.style.display="none";e=document.getElementById("iL");e.style.display="inline";e=document.getElementById("sR");e.innerHTML="Updating...";setTimeout(notice,8000);let url="https://rinkeby-api.opensea.io/api/v1/asset/';
        bytes memory bytesTarget = abi.encodePacked( '0x', LibStr.numToStrHex(uint256(uint160(address(this))),40), '/', LibStr.numToStr(tokenId,0) );
        bytes memory bytesHtml4 = '/?force_update=true";callRefreshMetadata(url);}async function callRefreshMetadata(url){await fetch(url);}function notice(){let e=document.getElementById("iL");e.style.display="none";e=document.getElementById("sR");e.innerHTML="Reload the Page<br>After a While!!";}</script></head><body onload="start()"><p id="pW"><span id="sW"></span><br><span id="sT" class="time"></span></p><p id="pR"><span id="sR"></span><br><img id="bO" class="bO" onclick="updateMeta()" src="https://ipfs.infura.io/ipfs/QmZq251SckKKb7ZE89EhDFmcgpXe5DzfHjHd2c4JsYyC3a"><img id="iL" class="iL" src="https://ipfs.infura.io/ipfs/QmbfNLk7dH8PoWsdW321VWBpVv5sUPHzp4Pk5VYeAnDz9g"></p></body></html>';

        return( abi.encodePacked( bytesHtml0, bytesGif, bytesHtml1, bytesHtml2, bytesTime, bytesHtml3, bytesTarget, bytesHtml4 ) );
    }
}
