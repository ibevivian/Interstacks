# Inter Stacks

Inter Stacks is a decentralized exchange (DEX) platform designed to facilitate cross-chain swaps between Bitcoin (BTC) and Stacks (STX). This project includes a Clarity smart contract that allows users to deposit, withdraw, and request cross-chain swaps.

## Features

- **Deposit STX**: Users can deposit STX tokens into the contract.
- **Withdraw STX**: Users can withdraw their STX tokens from the contract.
- **Request Swap**: Users can request a cross-chain swap from BTC to STX.
- **Approve Swap**: The contract owner can approve swap requests.

## Smart Contract Functions

### Public Functions
1. **Deposit**: Deposit STX tokens into the contract.
   ```clarity
   (deposit (amount uint))

2. **Withdraw**: Withdraw STX tokens from the contract.
    ```clarity
    (withdraw (amount uint))

3. **Request Swap**: Request a cross-chain swap from BTC to STX.
    ```clarity
    (request-swap (amount uint))

4. **Approve Swap**: Approve a swap request (only callable by the contract owner).
    ```clarity
    (approve-swap (user principal))


### Read-Only Functions
1. **Get Balance**: Retrieve the STX balance of a user.
    ```clarity
    (get-balance (user principal))

2. **Get Swap Request**: Retrieve the swap request amount for a user.
    ```clarity
    (get-swap-request (user principal))

### How to Use
1. **Deploy the Contract**: Deploy the Clarity smart contract to the Stacks blockchain.

2. **Deposit STX**: Users can deposit STX tokens into the contract using the deposit function.

3. **Request Swap**: Users can request a cross-chain swap using the request-swap function.

4. **Approve Swap**: The contract owner can approve swap requests using the approve-swap function.

5. **Withdraw STX**: Users can withdraw their STX tokens using the withdraw function.


### Error Codes
1. **ERR_NOT_OWNER (100)**: The caller is not the contract owner.

2. **ERR_INSUFFICIENT_BALANCE (101)**: The user does not have enough balance.

3. **ERR_INVALID_AMOUNT (102)**: The amount is invalid (e.g., zero or negative).


