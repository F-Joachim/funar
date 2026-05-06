module Contract where

-- Auftrag: komplexe Finanzverträge als Daten repräsentieren
-- Vertrag zwischen 2 Parteien, eine davon "wir"

{-
Vorgehensweise:

- einfaches Beispiel
  "Ich bekomme Weihnachten 100€."

-}

data Date = MkDate String -- ISO-Format
  deriving (Show, Eq, Ord)

xmas = MkDate "2026-12-24"

type Amount = Double

data Currency = EUR | USD | GBP | YEN
  deriving Show

data Contract =
    ZeroCouponBond Date Amount Currency
    deriving Show

-- "Ich bekomme Weihnachten 100€."
zcb1 :: Contract
zcb1 = ZeroCouponBond xmas 100 EUR