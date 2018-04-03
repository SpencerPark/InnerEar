{-# LANGUAGE OverloadedStrings #-}

module Reflex.Synth.Spec where

import GHCJS.Marshal.Pure
import GHCJS.Types
import Control.Applicative

data SourceNodeSpec
  = Silent
  | Oscillator OscillatorType Frequency
  -- TODO | Buffer BufferSrc
  deriving (Show)

data SourceSinkNodeSpec
  = Filter FilterSpec
  -- TODO | Convolver Buffer normalize :: Boolean
  | Delay Time
  -- Compressor threshold knee ratio reduction attack release
  | Compressor Amplitude Amplitude Amplitude Gain Time Time
  | Gain Gain
  | WaveShaper [Double] OversampleAmount
  -- DistortAt Amplitude
  deriving (Show)

data SinkNodeSpec
  = Destination
  deriving (Show)

data OscillatorType 
  = Sine 
  | Square 
  | Sawtooth 
  | Triangle 
  deriving (Show, Eq)

instance PToJSVal OscillatorType where
  pToJSVal Sine = jsval ("sine" :: JSString)
  pToJSVal Square = jsval ("square" :: JSString)
  pToJSVal Sawtooth = jsval ("sawtooth" :: JSString)
  pToJSVal Triangle = jsval ("triangle" :: JSString)

data FilterSpec
  = LowPass Frequency Double
  | HighPass Frequency Double
  | BandPass Frequency Double
  | LowShelf Frequency Gain
  | HighShelf Frequency Gain
  | Peaking Frequency Double Gain
  | Notch Frequency Double
  | AllPass Frequency Double
  -- | IIR [Double] [Double] feedforward feedback
  deriving (Show)

data OversampleAmount
  = None
  | Times2
  | Times4
  deriving (Show)
  
instance PToJSVal OversampleAmount where
  pToJSVal None = jsval ("none" :: JSString)
  pToJSVal Times2 = jsval ("x2" :: JSString)
  pToJSVal Times4 = jsval ("x4" :: JSString)

data Amplitude
  = Amp Double
  | Db Double
  deriving (Show)

type Gain = Amplitude

inAmp :: Amplitude -> Double
inAmp (Amp a) = a
inAmp (Db db) = 10.0 ** (db / 20.0)

inDb :: Amplitude -> Double
inDb (Amp a) = 20.0 * (logBase 10 a)
inDb (Db db) = db

data Frequency
  = Hz Double
  | Midi Double
  deriving (Show)

inHz :: Frequency -> Double
inHz (Hz hz) = hz
inHz (Midi n) = 440.0 * (2.0 ** ((n - 69.0) / 12.0))

inMidi :: Frequency -> Double
inMidi (Hz hz) = 69.0 + 12.0 * (logBase 2 (hz / 440.0))
inMidi (Midi n) = n

data Time
  = Sec Double
  | Millis Double
  deriving (Show)

inSec :: Time -> Double
inSec (Sec s) = s
inSec (Millis ms) = ms / 1000.0

inMillis :: Time -> Double
inMillis (Sec s) = s * 1000.0
inMillis (Millis ms) = ms

instance Eq Time where
  t1 == t2 = inMillis t1 == inMillis t2

instance Ord Time where
  t1 <= t2 = inMillis t1 <= inMillis t2

instance Num Time where
  t1 + t2 = Millis $ (inMillis t1) + (inMillis t2)
  t1 - t2 = Millis $ (inMillis t1) - (inMillis t2)
  t1 * t2 = Millis $ (inMillis t1) * (inMillis t2)
  abs (Millis ms) = Millis $ abs ms
  abs (Sec s) = Sec $ abs s
  signum x = 
    case inMillis x of 
      y | y < 0 -> -1
        | y == 0 -> 0
        | otherwise -> 1
  fromInteger ms = Millis $ fromIntegral ms

--data PlaybackParam = PlaybackParam{
--  start::Double,    -- portion through the buffer that playback starts
--  end::Double,
--  loop::Bool
--} deriving (Read, Show, Eq)
--
--getPlaybackParam :: Source -> Maybe PlaybackParam
--getPlaybackParam (NodeSource (BufferNode (LoadedFile _ x)) _) = Just x
--getPlaybackParam _ = Nothing
--
--isLoadedFile :: Source -> Bool
--isLoadedFile (NodeSource (BufferNode (LoadedFile _ _)) _) = True
--isLoadedFile _ = False
