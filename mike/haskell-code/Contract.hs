{-# LANGUAGE InstanceSigs #-}
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



data Date = MkDate String -- ISO-Format
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

data Contract =
    Zero
  | One Currency
  | Many Amount Contract
  | Later Date Contract
  | Exchange Contract
  | And Contract Contract
  deriving Show

instance Semigroup Contract where
    (<>) :: Contract -> Contract -> Contract
    (<>) = And

instance Monoid Contract where
    mempty :: Contract
    mempty = Zero

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

scalePayment :: Amount -> Payment -> Payment
scalePayment factor (MkPayment direction date amount currency) =
  MkPayment direction date (factor * amount) currency

invertPayment :: Payment -> Payment
invertPayment (MkPayment date Incoming amount currency) =
  MkPayment date Outgoing amount currency
invertPayment (MkPayment date Outgoing amount currency) =
  MkPayment date Incoming amount currency

-- Bedeutung eines Vertrags / Semantik
-- Zahlungen bis zu dem Datum, "heute"
-- -> "Residualvertrag"
semantics :: Contract -> Date -> ([Payment], Contract)
-- semantics Zero today = ([], Zero)
semantics Zero today = mempty
semantics (One currency) today = ([MkPayment today Incoming 1 currency], Zero)
semantics (Many amount contract) today =
  let (payments, residualContract) = semantics contract today
   in (map (scalePayment amount) payments, Many amount residualContract)
semantics (Exchange contract) today =
  let (payments, residualContract) = semantics contract today
   in (map invertPayment payments, Exchange residualContract)
semantics (Later date contract) today =
  if today >= date
    then semantics contract today
    else ([], Later date contract)
semantics (And contract1 contract2) today =
--  let (payments1, residualContract1) = semantics contract1 today
--      (payments2, residualContract2) = semantics contract2 today
--   in (payments1 ++ payments2, And residualContract1 residualContract2)
  let (payments1, residualContract1) = semantics contract1 today
      (payments2, residualContract2) = semantics contract2 today
   in (payments1 <> payments2, residualContract1 <> residualContract2)


-- >>> semantics c6 (MkDate "2026-05-06")
-- ([MkPayment (MkDate "2026-05-06") Incoming 100.0 EUR],Many 100.0 (And Zero (Later (MkDate "2026-12-24") (One EUR))))

c6 = Many 100 (And (One EUR)
                   (Later xmas (One EUR)))
