;; CoreMint NFT Platform

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-not-found (err u102))

;; Define NFT token
(define-non-fungible-token core-nft uint)

;; Data vars
(define-data-var last-token-id uint u0)

;; Data maps
(define-map token-metadata uint (string-utf8 500))
(define-map token-royalties uint uint)
(define-map creator-royalties principal uint)

;; Get the next token ID
(define-private (get-next-token-id)
  (let ((token-id (+ (var-get last-token-id) u1)))
    (var-set last-token-id token-id)
    token-id))

;; Mint new NFT
(define-public (mint-nft (metadata (string-utf8 500)) (royalty uint))
  (let ((token-id (get-next-token-id)))
    (try! (nft-mint? core-nft token-id tx-sender))
    (map-set token-metadata token-id metadata)
    (map-set token-royalties token-id royalty)
    (ok token-id)))

;; Transfer NFT
(define-public (transfer-nft (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (try! (nft-transfer? core-nft token-id sender recipient))
    (ok true)))

;; Get token metadata
(define-read-only (get-token-metadata (token-id uint))
  (ok (map-get? token-metadata token-id)))

;; Get token royalty
(define-read-only (get-token-royalty (token-id uint))
  (ok (map-get? token-royalties token-id)))
