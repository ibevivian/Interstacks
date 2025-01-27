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

;; Modifier to check if the contract is paused
(define-private (check-not-paused)
    (not (var-get is-paused))
)

;; Deposit STX into the contract
(define-public (deposit (amount uint))
    (begin
        (asserts! (check-not-paused) err-contract-paused)
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
        (var-set swap-fee fee)
        (ok true)
    )
)

;; Get the current swap fee
(define-read-only (get-swap-fee)
    (ok (var-get swap-fee))
)