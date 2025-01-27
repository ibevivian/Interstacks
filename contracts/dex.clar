;; Define the contract
(define-constant CONTRACT_OWNER tx-sender)

;; Data maps to store user balances and swap requests
(define-map balances principal uint) ;; Map to store user STX balances
(define-map swapRequests principal uint) ;; Map to store swap requests

;; Error codes
(define-constant ERR_NOT_OWNER 100)
(define-constant ERR_INSUFFICIENT_BALANCE 101)
(define-constant ERR_INVALID_AMOUNT 102)
(define-constant ERR_TRANSFER_FAILED 103)
(define-constant ERR_NO_SWAP_REQUEST 104)

;; Deposit STX into the contract
(define-public (deposit (amount uint))
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT) ;; Ensure amount is greater than 0
    (asserts! (stx-transfer? amount tx-sender (as-contract tx-sender)) ERR_TRANSFER_FAILED) ;; Transfer STX
    (map-set balances tx-sender (+ (default-to u0 (map-get? balances tx-sender)) amount)) ;; Update balance
    (ok true)
  )
)

;; Withdraw STX from the contract
(define-public (withdraw (amount uint))
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT) ;; Ensure amount is greater than 0
    (asserts! (>= (default-to u0 (map-get? balances tx-sender)) amount) ERR_INSUFFICIENT_BALANCE) ;; Check balance
    (map-set balances tx-sender (- (default-to u0 (map-get? balances tx-sender)) amount)) ;; Deduct balance
    (asserts! (stx-transfer? amount (as-contract tx-sender) tx-sender) ERR_TRANSFER_FAILED) ;; Transfer STX
    (ok true)
  )
)

;; Request a cross-chain swap (BTC to STX)
(define-public (request-swap (amount uint))
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT) ;; Ensure amount is greater than 0
    (asserts! (>= (default-to u0 (map-get? balances tx-sender)) amount) ERR_INSUFFICIENT_BALANCE) ;; Check balance
    (map-set swapRequests tx-sender amount) ;; Store swap request
    (ok true)
  )
)

;; Cancel a swap request
(define-public (cancel-swap)
  (begin
    (let ((amount (default-to u0 (map-get? swapRequests tx-sender)))) ;; Get swap request amount
      (asserts! (> amount u0) ERR_NO_SWAP_REQUEST) ;; Ensure there is a swap request
      (map-set swapRequests tx-sender u0) ;; Clear swap request
      (ok true)
    )
  )
)

;; Approve a swap request (only contract owner can call this)
(define-public (approve-swap (user principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_OWNER) ;; Ensure caller is owner
    (let ((amount (default-to u0 (map-get? swapRequests user)))) ;; Get swap request amount
      (asserts! (> amount u0) ERR_INVALID_AMOUNT) ;; Ensure amount is greater than 0
      (map-set swapRequests user u0) ;; Clear swap request
      (map-set balances user (- (default-to u0 (map-get? balances user)) amount)) ;; Deduct balance
      (ok true)
    )
  )
)

;; Transfer ownership to another principal (only contract owner can call this)
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_OWNER) ;; Ensure caller is owner
    (var-set CONTRACT_OWNER new-owner) ;; Update contract owner
    (ok true)
  )
)

;; Get user balance
(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? balances user)))
)

;; Get user swap request
(define-read-only (get-swap-request (user principal))
  (ok (default-to u0 (map-get? swapRequests user)))
)

;; Get contract owner
(define-read-only (get-owner)
  (ok CONTRACT_OWNER)
)