{-# LANGUAGE DeriveDataTypeable #-}

module InnerEar.Exercises.ThresholdOfSilence (thresholdOfSilenceExercise) where

import Reflex
import Reflex.Dom
import Data.Map

import Reflex.Synth.Types
import InnerEar.Exercises.MultipleChoice
import InnerEar.Types.ExerciseId
import InnerEar.Types.Exercise
import InnerEar.Types.Score
import InnerEar.Types.Data (Datum)
import InnerEar.Widgets.UserMedia
import InnerEar.Widgets.SpecEval



type Config = Int -- gain value for attenuated sounds

configs :: [Config]
configs = [-20,-30,-40,-50,-60,-70,-80,-90,-100,-110]

data Answer = Answer Bool deriving (Eq,Ord)

answers :: [Answer]
answers = [Answer True,Answer False]

instance Show Answer where
  show (Answer True) = "Attenuated Sound"
  show (Answer False) = "No sound at all"

renderAnswer :: Config -> Source -> Answer -> Sound
renderAnswer db s (Answer True) = GainSound (Sound s)  ((fromIntegral db)::Double) -- 2.0 -- should be a sound source attenuated by dB value
renderAnswer db _ (Answer False) = NoSound -- 2.0

thresholdOfSilenceConfigWidget :: MonadWidget t m => Config -> m (Event t Config)
thresholdOfSilenceConfigWidget i = radioConfigWidget msg configs i
  where msg = "Please choose the level of attenuation for this exercise:"

displayEval :: MonadWidget t m => Dynamic t (Map Answer Score) -> m ()
displayEval = displayMultipleChoiceEvaluationGraph' "Session Performance" "" answers

generateQ :: Config -> [Datum Config [Answer] Answer (Map Answer Score)] -> IO ([Answer],Answer)
generateQ _ _ = randomMultipleChoiceQuestion answers

thresholdOfSilenceExercise :: MonadWidget t m => Exercise t m Int [Answer] Answer (Map Answer Score)
thresholdOfSilenceExercise = multipleChoiceExercise
  1
  answers
  renderAnswer
  ThresholdOfSilence
  (-20)
  thresholdOfSilenceConfigWidget
  displayEval
  generateQ
  (Just "Please write a reflection here...")