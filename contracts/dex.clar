;; Define data variables for contract state
(define-data-var contract-owner principal tx-sender)
(define-data-var is-paused bool false)
(define-data-var swap-fee uint u0)

;; Data maps to store user balances and swap requests
(define-map balances principal uint)
(define-map swap-requests principal uint)

;; Error codes
(define-constant err-not-owner (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-transfer-failed (err u103))
(define-constant err-no-swap-request (err u104))
(define-constant err-contract-paused (err u105))
(define-constant err-emergency-already-triggered (err u106))
(define-constant err-invalid-owner (err u107))
(define-constant err-invalid-fee (err u108))

;; Constants for validation
(define-constant MAX_FEE_PERCENTAGE u1000) ;; 10% in basis points
(define-constant ZERO_ADDRESS 'SP000000000000000000002Q6VF78)

;; Data variable to track emergency state
(define-data-var emergency-state bool false)

;; Modifier to check if the contract is paused
(define-private (check-not-paused)
    (not (var-get is-paused))
)

;; Validate new owner address
(define-private (validate-owner (new-owner principal))
    (and 
        (not (is-eq new-owner ZERO_ADDRESS))
        (not (is-eq new-owner (var-get contract-owner)))
    )
)

;; Validate fee amount
(define-private (validate-fee (fee uint))
    (<= fee MAX_FEE_PERCENTAGE)
)

;; Get contract STX balance
(define-read-only (get-contract-balance)
    (stx-get-balance (as-contract tx-sender))
)

;; Emergency withdrawal function - only owner can call
(define-public (emergency-withdraw)
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
        (asserts! (not (var-get emergency-state)) err-emergency-already-triggered)
        
        (let ((contract-balance (get-contract-balance)))
            (begin
                (var-set emergency-state true)
                (var-set is-paused true)
                (try! (as-contract (stx-transfer? contract-balance tx-sender (var-get contract-owner))))
                (ok contract-balance)
            )
        )
    )
)

;; Check if emergency mode is active
(define-read-only (is-emergency-active)
    (ok (var-get emergency-state))
)

;; Reset emergency state - only owner can call
(define-public (reset-emergency-state)
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
        (var-set emergency-state false)
        (ok true)
    )
)

;; Deposit STX into the contract
(define-public (deposit (amount uint))
    (begin
        (asserts! (check-not-paused) err-contract-paused)
        (asserts! (not (var-get emergency-state)) err-emergency-already-triggered)
        (asserts! (> amount u0) err-invalid-amount)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set balances tx-sender (+ (default-to u0 (map-get? balances tx-sender)) amount))
        (ok true)
    )
)

;; Withdraw STX from the contract
(define-public (withdraw (amount uint))
    (begin
        (asserts! (check-not-paused) err-contract-paused)
        (asserts! (not (var-get emergency-state)) err-emergency-already-triggered)
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (>= (default-to u0 (map-get? balances tx-sender)) amount) err-insufficient-balance)
        (map-set balances tx-sender (- (default-to u0 (map-get? balances tx-sender)) amount))
        (try! (stx-transfer? amount (as-contract tx-sender) tx-sender))
        (ok true)
    )
)

;; Request a cross-chain swap (BTC to STX)
(define-public (request-swap (amount uint))
    (let ((fee (var-get swap-fee)))
        (begin
            (asserts! (check-not-paused) err-contract-paused)
            (asserts! (not (var-get emergency-state)) err-emergency-already-triggered)
            (asserts! (> amount u0) err-invalid-amount)
            (asserts! (>= (default-to u0 (map-get? balances tx-sender)) (+ amount fee)) err-insufficient-balance)
            (map-set balances tx-sender (- (default-to u0 (map-get? balances tx-sender)) fee))
            (map-set swap-requests tx-sender amount)
            (ok true)
        )
    )
)

;; Cancel a swap request
(define-public (cancel-swap)
    (let ((amount (default-to u0 (map-get? swap-requests tx-sender))))
        (begin
            (asserts! (check-not-paused) err-contract-paused)
            (asserts! (not (var-get emergency-state)) err-emergency-already-triggered)
            (asserts! (> amount u0) err-no-swap-request)
            (map-set swap-requests tx-sender u0)
            (ok true)
        )
    )
)

;; Approve a swap request (only contract owner can call this)
(define-public (approve-swap (user principal))
    (begin
        (asserts! (check-not-paused) err-contract-paused)
        (asserts! (not (var-get emergency-state)) err-emergency-already-triggered)
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
        (let ((amount (default-to u0 (map-get? swap-requests user))))
            (begin
                (asserts! (> amount u0) err-invalid-amount)
                (map-set swap-requests user u0)
                (map-set balances user (- (default-to u0 (map-get? balances user)) amount))
                (ok true)
            )
        )
    )
)

;; Get user balance
(define-read-only (get-balance (user principal))
    (ok (default-to u0 (map-get? balances user)))
)

;; Get user swap request
(define-read-only (get-swap-request (user principal))
    (ok (default-to u0 (map-get? swap-requests user)))
)

;; Get contract owner
(define-read-only (get-owner)
    (ok (var-get contract-owner))
)

;; Transfer ownership to a new principal
(define-public (transfer-ownership (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
        (asserts! (validate-owner new-owner) err-invalid-owner)
        (var-set contract-owner new-owner)
        (ok true)
    )
)

;; Pause the contract (only owner can call this)
(define-public (pause)
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
        (var-set is-paused true)
        (ok true)
    )
)

;; Unpause the contract (only owner can call this)
(define-public (unpause)
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
        (var-set is-paused false)
        (ok true)
    )
)

;; Set the swap fee (only owner can call this)
(define-public (set-swap-fee (fee uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-owner)
        (asserts! (validate-fee fee) err-invalid-fee)
        (var-set swap-fee fee)
        (ok true)
    )
)

;; Get the current swap fee
(define-read-only (get-swap-fee)
    (ok (var-get swap-fee))
)