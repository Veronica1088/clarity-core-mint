;; CoreMint NFT Platform - Enhanced Version

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-not-found (err u102))
(define-constant err-invalid-royalty (err u103))
(define-constant err-contract-paused (err u104))
(define-constant err-invalid-token-uri (err u105))

;; Define NFT token
(define-non-fungible-token core-nft uint)

;; Data vars
(define-data-var last-token-id uint u0)
(define-data-var contract-paused bool false)

;; Data maps
(define-map token-metadata uint {
  uri: (string-utf8 500),
  royalty: uint,
  creator: principal
})
(define-map creator-royalties principal uint)

;; Contract pause/unpause
(define-public (set-contract-pause (paused bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set contract-paused paused))))

;; Get the next token ID
(define-private (get-next-token-id)
  (let ((token-id (+ (var-get last-token-id) u1)))
    (var-set last-token-id token-id)
    token-id))

;; Validate royalty percentage
(define-private (validate-royalty (royalty uint))
  (and (<= royalty u1000) (>= royalty u0)))

;; Mint new NFT
(define-public (mint-nft (uri (string-utf8 500)) (royalty uint))
  (begin
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (validate-royalty royalty) err-invalid-royalty)
    (let ((token-id (get-next-token-id)))
      (try! (nft-mint? core-nft token-id tx-sender))
      (map-set token-metadata token-id {
        uri: uri,
        royalty: royalty,
        creator: tx-sender
      })
      (ok token-id))))

;; Batch mint NFTs
(define-public (batch-mint-nft (uris (list 10 (string-utf8 500))) (royalties (list 10 uint)))
  (begin
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (is-eq (len uris) (len royalties)) err-invalid-token-uri)
    (ok (map mint-nft uris royalties))))

;; Burn NFT
(define-public (burn-nft (token-id uint))
  (begin
    (asserts! (is-eq tx-sender (unwrap-panic (nft-get-owner? core-nft token-id))) err-not-token-owner)
    (try! (nft-burn? core-nft token-id tx-sender))
    (ok true)))

;; Transfer NFT
(define-public (transfer-nft (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (not (var-get contract-paused)) err-contract-paused)
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (try! (nft-transfer? core-nft token-id sender recipient))
    (ok true)))

;; Get token metadata
(define-read-only (get-token-metadata (token-id uint))
  (ok (map-get? token-metadata token-id)))

;; Get contract pause status
(define-read-only (get-contract-pause)
  (ok (var-get contract-paused)))
