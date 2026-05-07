module Contract where

-- Auftrag: komplexe Finanzverträge als Daten repräsentieren
-- Vertrag zwischen 2 Parteien, eine davon "wir"

{-
Vorgehensweise:

- einfaches Beispiel
  "Ich bekomme Weihnachten 100€."
- Beispiel zerlegen in "atomare Bestandteile" / "Ideen" / "Bausteine"

  - Währung: "Ich bekomme 1€ jetzt."
  - Betrag: "Ich bekomme 100€ jetzt."
  - Später: "Ich bekomme Weihnachten 100€."
  ----> Selbstbezüge

- nächstes Beispiel: Currency Swap
  Weihnachten bekomme ich 100€ und zahle 100$.
-}

newtype Date = MkDate String -- ISO-Format
  deriving (Show, Eq, Ord)

xmas :: Date
xmas = MkDate "2026-12-24"

type Amount = Double

data Currency = EUR | USD | GBP | YEN
  deriving Show

{-
data Contract =
      ZeroCouponBond Date Amount Currency
    | Future
    | Call
    | Put
    deriving Show

-- "Ich bekomme Weihnachten 100€."
zcb1 :: Contract
zcb1 = ZeroCouponBond xmas 100 EUR
-}



-- "Ich bekomme 1€ jetzt."
c1 :: Contract
c1 = One EUR

-- "Ich bekomme 100€ jetzt."
c2 :: Contract
c2 = Many 100 (One EUR)

-- "Ich bekomme 2000€ jetzt."
c3 = Many 20 (Many 100 (One EUR))

-- "Ich bekomme Weihnachten 100€."
zcb1 = Later xmas (Many 100 (One EUR))

zeroCouponBond :: Date -> Amount -> Currency -> Contract
zeroCouponBond date amount currency = Later date (Many amount (One currency))

zcb1' :: Contract
zcb1' = zeroCouponBond xmas 100 EUR

-- "Ich zahle 1€ jetzt."
c4 :: Contract
c4 = Exchange (One EUR)

-- "Ich bekomme 1€ jetzt."
c5 :: Contract
c5 = Exchange (Exchange (One EUR))

fxSwap1 = Later xmas (And (Many 100 (One EUR))
                          (Exchange (Many 100 (One USD))))

fxSwap1' = And (zeroCouponBond xmas 100 EUR)
               (Exchange (zeroCouponBond xmas 100 USD))

data Direction = Incoming | Outgoing
  deriving Show

data Payment = MkPayment Date Direction Amount Currency
  deriving Show

data Contract =
    Zero
  | One Currency
  | Many Amount Contract
  | Later Date Contract
  | Exchange Contract
  | And Contract Contract
  deriving Show

-- Bedeutung eines Vertrags / Semantik
-- Zahlungen bis zu dem Datum, "heute"
-- -> "Residualvertrag"
semantics :: Contract -> Date -> ([Payment], Contract)
semantics Zero _ = ([], Zero)
semantics (One currency) now = ([MkPayment now Incoming 1 currency], Zero)
semantics (Many amount contract) now =
  let (ps, c) = semantics contract now
  in (map (scalePayment amount) ps, many' amount c)
semantics (Later date contract) now
  | now >= date = semantics contract now
  | otherwise = ([], Later date contract)
semantics (Exchange contract) now =
  let (ps, c) = semantics contract now
  in (map exchangePayments ps, exchange' c)
semantics (And contract1 contract2) now =
  let (ps1, c1) = semantics contract1 now
      (ps2, c2) = semantics contract2 now
  in (ps1 ++ ps2, and' c1 c2)

-- >>> and' Zero Zero
-- Zero
and' :: Contract -> Contract -> Contract
and' Zero contract = contract
and' contract Zero = contract
and' c1 c2 = And c1 c2

many' :: Amount -> Contract -> Contract
many' _ Zero = Zero
many' a c = Many a c

exchange' :: Contract -> Contract
exchange' Zero = Zero
exchange' c = Exchange c

exchangePayments :: Payment -> Payment
exchangePayments (MkPayment date Incoming amount currency) = MkPayment date Outgoing amount currency
exchangePayments (MkPayment date Outgoing amount currency) = MkPayment date Incoming amount currency

scalePayment :: Amount -> Payment -> Payment
scalePayment a (MkPayment date direction amount currency) = MkPayment date direction (a * amount) currency

-- |
-- >>> semantics c6 (MkDate "2026-05-06")
-- ([MkPayment (MkDate "2026-05-06") Incoming 100.0 EUR],Many 100.0 (Later (MkDate "2026-12-24") (One EUR)))
c6 :: Contract
c6 = Many 100 (And (One EUR)
                   (Later xmas (One EUR)))

-- |
-- >>> semantics c7 (MkDate "2026-05-06")
-- ([MkPayment (MkDate "2026-05-06") Outgoing 100.0 EUR],Zero)
c7 :: Contract
c7 = Exchange (Many 100 (One EUR))
