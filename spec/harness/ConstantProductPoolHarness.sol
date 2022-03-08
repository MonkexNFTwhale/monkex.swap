pragma solidity ^0.8.2;

import "../../contracts/pool/constant-product/ConstantProductPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ConstantProductPoolHarness is ConstantProductPool {
    // state variables ///////////
    // mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) public amountOutHarness;
    address public otherHarness;
    address public tokenInHarness;

    // constructor ///////////////
    constructor(bytes memory _deployData, address _masterDeployer) ConstantProductPool(_deployData, _masterDeployer) {}

    // getters ///////////////////
    function tokenBalanceOf(IERC20 token, address user) public view returns (uint256 balance) {
        return token.balanceOf(user);
    }

    // wrappers //////////////////
    function mintWrapper(address to) public returns (uint256 liquidity) {
        bytes memory data = abi.encode(to);

        return super.mint(data);
    }

    function burnWrapper(address to, bool unwrapBento) public returns (uint256 liquidity0_, uint256 liquidity1_) {
        bytes memory data = abi.encode(to, unwrapBento);

        IPool.TokenAmount[] memory withdrawnAmounts = super.burn(data);

        return (withdrawnAmounts[0].amount, withdrawnAmounts[1].amount);
    }

    function burnSingleWrapper(
        address tokenOut,
        address to,
        bool unwrapBento
    ) public returns (uint256 amount) {
        bytes memory data = abi.encode(tokenOut, to, unwrapBento);

        return super.burnSingle(data);
    }

    // swapWrapper
    function swapWrapper(
        address tokenIn,
        address recipient,
        bool unwrapBento
    ) public returns (uint256 amountOut) {
        bytes memory data = abi.encode(tokenIn, recipient, unwrapBento);

        return super.swap(data);
    }

    function flashSwapWrapper(
        address tokenIn,
        address recipient,
        bool unwrapBento,
        uint256 amountIn,
        bytes memory context
    ) public returns (uint256 amountOut) {
        // require(otherHarness != recipient, "recepient is other");
        require(tokenInHarness == tokenIn);

        bytes memory data = abi.encode(tokenIn, recipient, unwrapBento, amountIn, context);

        return super.flashSwap(data);
    }

    function getAmountOutWrapper(address tokenIn, uint256 amountIn) public view returns (uint256 finalAmountOut) {
        bytes memory data = abi.encode(tokenIn, amountIn);

        return super.getAmountOut(data);
    }

    // overrides /////////////////
    // WARNING: Be careful of interlocking "lock" modifier
    // if adding to the overrided code blocks
    function mint(bytes memory data) public override nonReentrant returns (uint256 liquidity) {}

    function burn(bytes memory data) public override nonReentrant returns (IPool.TokenAmount[] memory withdrawnAmounts) {}

    function burnSingle(bytes memory data) public override nonReentrant returns (uint256 amount) {}

    function swap(bytes memory data) public override nonReentrant returns (uint256 amountOut) {}

    function flashSwap(bytes memory data) public override nonReentrant returns (uint256 amountOut) {}

    function getAmountOut(bytes memory data) public view override returns (uint256 finalAmountOut) {}

    // simplifications ///////////
    // function _getAmountOut(
    //     uint256 amountIn,
    //     uint256 reserveIn,
    //     uint256 reserveOut
    // ) internal view override returns (uint256) {
    //     if (amountIn == 0 || reserveOut == 0) {
    //         return 0;
    //     }

    //     return amountOutHarness[amountIn][reserveIn][reserveOut];
    // }
}
