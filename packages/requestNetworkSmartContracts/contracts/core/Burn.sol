pragma solidity 0.4.18;


/// @dev From https://github.com/KyberNetwork/smart-contracts/blob/master/contracts/ERC20Interface.sol
interface ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


/// @title Burn contract. Converts the received ETH to REQ and burn the REQ.
/// @author Request Network
contract Burn {
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    address public kyberContract;
    ERC20 public destErc20;

    /// @param _destErc20 Destination token
    /// @param _kyberContract Kyber contract to use
    function Burn(ERC20 _destErc20, address _kyberContract) public {
        this.destErc20 = _destErc20;
        this.kyberContract = _kyberContract;
    }
    
    /// Fallback
    function() public payable { }

    /// @notice use token address ETH_TOKEN_ADDRESS for ether
    /// @dev makes a trade between src and dest token and send dest token to destAddress
    /// @param srcAmount amount of src tokens
    /// @param maxDestAmount A limit on the amount of dest tokens
    /// @param minConversionRate The minimal conversion rate. If actual rate is lower, trade is canceled.
    /// @return amount of actual dest tokens
    function burn(
        uint srcAmount,
        uint maxDestAmount,
        uint minConversionRate
    )
        external
        returns(uint)
    {
        // Current money on the contract
        // TODO: handle parameters of function
        // TODO: leave some ETH for the gas
        uint ethToConvert = address(this).balance;

        // Amount of the ERC20 converted by Kyber that will be burned
        uint erc20ToBurn = 0;

        // Convert the ETH to ERC20
        erc20ToBurn = kyberContract.trade.value(ethToConvert)(
            // Source
            ETH_TOKEN_ADDRESS,
            
            // Source amount
            ethToConvert,
            
            // Destination
            destErc20);

        // Burn the ERC20
        destErc20.burn(erc20ToBurn);

        return erc20ToBurn;
    }
}
