{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE TemplateHaskell #-}


{-# HLINT ignore "Redundant id" #-}

module PitchProperties where

import Control.Lens hiding (elements)
import Data.Ratio ((%))
import Pitch.Accidental
import Pitch.Pitch (Octave (..), Pitch (..))
import Pitch.PitchClass (NoteName (..), PitchClass (..))
import Test.Framework (defaultMain, testGroup)
import Test.Framework.Providers.QuickCheck2 (testProperty)
import Test.QuickCheck
import qualified Pitch.Pitch as P
import qualified Pitch.PitchClass as PC
import Control.Applicative (liftA2)


-- Properties for PitchClass and Pitch:

-- When we set an accidental to a specific value, it should always be that value.
prop_setAccidental :: Accidental -> PitchClass -> Bool
prop_setAccidental a pc = (pc & PC.accidental .~ a) ^. PC.accidental == a

-- Similarly, for Pitch:
prop_setAccidentalPitch :: Accidental -> Pitch -> Bool
prop_setAccidentalPitch a p = (p & accidental .~ a) ^. accidental == a


instance Arbitrary Accidental where
  arbitrary =
    frequency
      [ (10, elements allAccidentals),                    -- Picking from the predefined list
        (1, liftA2 Custom arbitrary arbitrary)            -- Generating a custom accidental
      ]



instance Arbitrary NoteName where
  arbitrary = elements [C, D, E, F, G, A, B]

instance Arbitrary PitchClass where
  arbitrary = PitchClass <$> arbitrary <*> arbitrary

{- instance Arbitrary Octave where
  arbitrary :: Gen Octave
  arbitrary = Octave <$> arbitrary
 -}

instance Arbitrary Octave where
  arbitrary = Octave <$> choose (1, 9)

instance Arbitrary Pitch where
  arbitrary = Pitch <$> arbitrary <*> arbitrary <*> arbitrary

-- invertAccidental' :: Accidental -> Accidental
-- invertAccidental' Natural = Natural
-- invertAccidental' Sharp = Flat
-- invertAccidental' Flat = Sharp
-- invertAccidental' QuarterSharp = QuarterFlat
-- invertAccidental' QuarterFlat = QuarterSharp
-- invertAccidental' DoubleFlat = DoubleSharp
-- invertAccidental' DoubleSharp = DoubleFlat
-- invertAccidental' ThreeQuartersFlat = ThreeQuartersSharp
-- invertAccidental' ThreeQuartersSharp = ThreeQuartersFlat
-- invertAccidental' (Custom a) = negate (Custom a)

-- prop_modifyAccidental :: Accidental -> PitchClass -> Bool
-- prop_modifyAccidental a pc =
--   let modifiedPC = pc & accidental .~ a & accidental %~ invertAccidental'
--    in modifiedPC ^. accidental == invertAccidental' a

-- prop_setAndModifyAccidental :: Accidental -> PitchClass -> Bool
-- prop_setAndModifyAccidental a pc =
--   let modifiedPC1 = pc & accidental .~ a & accidental %~ accToNatural
--       modifiedPC2 = pc & accidental %~ accToNatural
--       accToNatural :: Accidental -> Accidental
--       accToNatural _ = Natural
--    in modifiedPC1 == modifiedPC2

-- prop_invertTwiceIsIdentity :: Accidental -> Bool
-- prop_invertTwiceIsIdentity a =
--   let modifiedA = invertAccidental' a
--    in invertAccidental' modifiedA == a

prop_identityAccidentalIsUnchanged :: Accidental -> Bool
prop_identityAccidentalIsUnchanged a =
  let modifiedA = a
   in modifiedA == a

-- prop_modifyAccidentalCommutative :: Accidental -> PitchClass -> Bool
-- prop_modifyAccidentalCommutative a pc =
--   let modifiedPC1 = pc & accidental %~ invertAccidental''
--       modifiedPC2 =
--         pc & accidental %~ (\x -> invertAccidental'' (a & accidental .~ x))
--    in modifiedPC1 == modifiedPC2

----------------------------------------------------------------------------- -}

-- QuickCheck MOVE ------------------------------------------------------------



-- Newtype wrapper for specific accidental strings
newtype AccidentalString
  = AccidentalString String
  deriving (Show)

-- Arbitrary instance for AccidentalString (QuickCheck)
instance Arbitrary AccidentalString where
  arbitrary =
    AccidentalString
      <$> elements
        [ "ff",
          "tqf",
          "f",
          "qf",
          "",
          "n",
          "qs",
          "s",
          "tqs",
          "ss",
          "sharp",
          "flat",
          "natural",
          "quartersharp",
          "semisharp",
          "quarterflat",
          "semiflat",
          "♭",
          "♯",
          "♮",
          "𝄫",
          "𝄪",
          "𝄳",
          "𝄲"
        ]

pure []

runTests :: IO Bool
runTests = $quickCheckAll
