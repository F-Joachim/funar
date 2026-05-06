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

data Contract =
    ZeroCouponBond Date Amount Currency