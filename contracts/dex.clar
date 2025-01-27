;; Define the contract
(define-constant CONTRACT_OWNER tx-sender)

;; Data maps to store user balances and swap requests
(define-data-var balances (map principal uint) {})
(define-data-var swapRequests (map principal uint) {})

;; Error codes
(define-constant ERR_NOT_OWNER 100)
(define-constant ERR_INSUFFICIENT_BALANCE 101)
(define-constant ERR_INVALID_AMOUNT 102)

;; Deposit STX into the contract
(define-public (deposit (amount uint))
  (begin
    (asserts! (> amount 0) ERR_INVALID_AMOUNT)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set balances tx-sender (+ (default-to 0 (map-get? balances tx-sender)) amount))
    (ok true)
  )
)

;; Withdraw STX from the contract
(define-public (withdraw (amount uint))
  (begin
    (asserts! (> amount 0) ERR_INVALID_AMOUNT)
    (asserts! (>= (default-to 0 (map-get? balances tx-sender)) amount) ERR_INSUFFICIENT_BALANCE)
    (map-set balances tx-sender (- (default-to 0 (map-get? balances tx-sender)) amount))
    (try! (stx-transfer? amount (as-contract tx-sender) tx-sender))
    (ok true)
  )
)

;; Request a cross-chain swap (BTC to STX)
(define-public (request-swap (amount uint))
  (begin
    (asserts! (> amount 0) ERR_INVALID_AMOUNT)
    (asserts! (>= (default-to 0 (map-get? balances tx-sender)) amount) ERR_INSUFFICIENT_BALANCE)
    (map-set swapRequests tx-sender amount)
    (ok true)
  )
)

;; Approve a swap request (only contract owner can call this)
(define-public (approve-swap (user principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_OWNER)
    (let ((amount (default-to 0 (map-get? swapRequests user))))
      (asserts! (> amount 0) ERR_INVALID_AMOUNT)
      (map-set swapRequests user 0)
      (map-set balances user (- (default-to 0 (map-get? balances user)) amount))
      (ok true)
    )
  )
)

;; Get user balance
(define-read-only (get-balance (user principal))
  (ok (default-to 0 (map-get? balances user)))
)

;; Get user swap request
(define-read-only (get-swap-request (user principal))
  (ok (default-to 0 (map-get? swapRequests user)))
)