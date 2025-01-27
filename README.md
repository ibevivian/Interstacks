# Inter Stacks

Inter Stacks is a decentralized exchange (DEX) platform designed to facilitate cross-chain swaps between Bitcoin (BTC) and Stacks (STX). The platform implements comprehensive safety features, fee management, and administrative controls through a Clarity smart contract.

## Core Features

- **Asset Management**
  - Deposit and withdraw STX tokens
  - Real-time balance tracking
  - Contract-wide balance monitoring

- **Cross-Chain Swaps**
  - Request BTC to STX swaps
  - Configurable swap fees
  - Cancel pending swap requests
  - Owner-controlled swap approval

- **Safety & Security**
  - Emergency withdrawal system
  - Contract pause mechanism
  - Owner-controlled fee limits
  - Ownership transfer capabilities

## Smart Contract Functions

### Asset Management
```clarity
(deposit (amount uint))           ;; Deposit STX into contract
(withdraw (amount uint))          ;; Withdraw STX from contract
(get-balance (user principal))    ;; Check user balance
(get-contract-balance)           ;; Get total contract balance
```

### Swap Operations
```clarity
(request-swap (amount uint))              ;; Request BTC to STX swap
(cancel-swap)                             ;; Cancel pending swap request
(approve-swap (user principal))           ;; Approve swap (owner only)
(get-swap-request (user principal))       ;; Check swap request status
```

### Administrative Controls
```clarity
(transfer-ownership (new-owner principal)) ;; Transfer contract ownership
(pause)                                    ;; Pause contract operations
(unpause)                                 ;; Resume contract operations
(set-swap-fee (fee uint))                 ;; Set swap fee amount
(get-swap-fee)                           ;; Check current swap fee
```

### Emergency Features
```clarity
(emergency-withdraw)              ;; Withdraw all funds (owner only)
(reset-emergency-state)          ;; Reset after emergency
(is-emergency-active)           ;; Check emergency status
```

## Error Codes

| Code | Description | Trigger |
|------|-------------|---------|
| 100 | ERR_NOT_OWNER | Non-owner calling restricted function |
| 101 | ERR_INSUFFICIENT_BALANCE | Withdrawal/swap exceeds balance |
| 102 | ERR_INVALID_AMOUNT | Zero or negative amount specified |
| 103 | ERR_TRANSFER_FAILED | STX transfer operation failed |
| 104 | ERR_NO_SWAP_REQUEST | No active swap request found |
| 105 | ERR_CONTRACT_PAUSED | Operation during contract pause |
| 106 | ERR_EMERGENCY_ALREADY_TRIGGERED | Duplicate emergency trigger |
| 107 | ERR_INVALID_OWNER | Invalid owner address specified |
| 108 | ERR_INVALID_FEE | Fee exceeds maximum allowed |

## Security Features

### Fee Management
- Maximum fee cap of 10% (1000 basis points)
- Owner-controlled fee adjustment
- Fee validation on all modifications

### Emergency Controls
- Complete contract pause capability
- Emergency fund withdrawal system
- State reset functionality
- Zero address validation

### Access Control
- Owner-only administrative functions
- Transferable ownership
- Pausable operations
- Emergency state management

## Implementation Guide

1. **Contract Deployment**
   - Deploy the Clarity contract to Stacks blockchain
   - Initial owner set to contract deployer

2. **Configuration**
   - Set desired swap fee (owner)
   - Verify contract state is unpaused
   - Configure emergency withdrawal addresses

3. **User Operations**
   - Users deposit STX using `deposit`
   - Request swaps via `request-swap`
   - Monitor status with `get-swap-request`
   - Withdraw using `withdraw`

4. **Administrative Tasks**
   - Monitor contract balance
   - Approve valid swap requests
   - Adjust fees as needed
   - Handle emergencies if required

## Best Practices

1. **For Users**
   - Verify contract status before operations
   - Check balances regularly
   - Confirm swap requests were processed
   - Keep private keys secure

2. **For Administrators**
   - Regular balance reconciliation
   - Prompt swap request processing
   - Monitor for suspicious activity
   - Test emergency procedures periodically

## Development Notes

- Built with Clarity smart contract language
- Implements comprehensive error handling
- Includes extensive safety checks
- Follows principle of least privilege