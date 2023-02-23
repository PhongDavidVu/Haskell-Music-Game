--     AUTHOR
-- Tuan Phong Vu - 1266265
--
--     Description
-- Musician Game is a guessing game between between Performer and Composer
-- Implement both the Composer and Performer part of the Music Game
-- ----------------------------------------------------------------------------
-- Musician Game will invole the Composer to select 3-pitch musicial chord,
-- where each pitch comprises of a musical note ranging from ('A'..'G') and
-- an octave ranging from (1..3) which is represented as type Pitch in project.
-- The goal of this haskell module is to be able to make pitches from string,
-- guess the pitches then provide feedback in the form of (Int,Int,Int) and
-- base on the feedback to be able to provide repeated guesses until correct,
-- pitches is guessed
--
-- The guessing process is run as followed:
--  Generate all
--  An initial guess which was hardcoded in as a most optimal initial guess
--  With the given initial guess, generate all possible guess left 
--  Utilizing feedback and a "score" system base on the lowest expected number
--   of remaining candidates, we can find the next best guess
--  Repeat until correct guess are achieved


module Proj2 (Pitch, toPitch, feedback,
            GameState, initialGuess, nextGuess) where
            
import Data.List
import Data.Char
import Data.Ord
import Data.Maybe


-- Type Pitch represent a described pitch, compound of a note under the form of
-- Char and an octave under the form of Int
data Pitch = Pitch {note :: Char,
                    octave :: Int }
                    deriving (Eq)
                    
-- Type GameState is simply a list of 3-pitches, will be use to keep track of 
-- the remaining candidate later
data GameState = GameState [[Pitch]] deriving Show

-- Taking in a Pitch type and convert it into a string keeping all the detail
pitchToString :: Pitch -> String
pitchToString x = (note x):[intToDigit(octave x)]

-- An Instance declaration for Pitch is in a show class to make sure the output
-- is in correct format
instance Show Pitch where
    show (Pitch x y) = id pitchToString(Pitch x y) 


-- Taking a string and gives Just the Pitch named by the string or Nothing if
-- invalid input are found
toPitch :: String -> Maybe Pitch 
toPitch pitchString
    |pitchString == "" = Nothing 
    |isDigit (last pitchString) == False = Nothing
    |((head pitchString) `elem` ['A'..'G'] &&
        (digitToInt(last pitchString) `elem` [1..3])) &&
        length pitchString  == 2 = 
        Just 
       (Pitch {note = head pitchString, octave = digitToInt(last pitchString)})
    
    |otherwise  = Nothing

-- A helper function to give the Pitch from String without Maybe type.
transform :: String -> Pitch
transform x = fromJust(toPitch x)

-- Helper function to get the note only from a 3-pitches (chord) 
getNote :: [Pitch] -> [Char]
getNote pitchlist = (map note pitchlist)

-- Helper function to get the octave only from a 3-pitches (chord) 
getOct :: [Pitch] -> [Int]
getOct pitchlist = (map octave pitchlist)


-- A function score a guess and provide feedback accordingly
-- noteInter and octaveInter are constructed like below to avoid duplicate
feedback :: [Pitch] -> [Pitch] -> (Int, Int, Int)
feedback target guess = (correct, correctNote, correctOctave)
    where 
        correct = length (intersect target guess)
        
        noteInter = (getNote guess) \\ ((getNote guess) \\ (getNote target))
        octaveInter = (getOct guess) \\ ((getOct guess) \\ (getOct target))
        
        correctNote = length (noteInter) - correct
        correctOctave = length (octaveInter) - correct
        
-- function takes no input and returns a pair of an initial guess alongside the
-- corresponding GameState, which is all possibles combination of chord, except
-- our initial guess
initialGuess :: ([Pitch],GameState)   
initialGuess = (guess, GameState (game))
    where
        guess = map transform ["A2", "B2", "C3"]
        everyChord = map transform ["A1","A2","A3","B1","B2","B3","C1","C2",
              "C3","D1","D2","D3","E1","E2","E3","F1","F2","F3","G1","G2","G3"]
        game = [pitch | pitch <- subsequences everyChord, 
               length pitch == 3 && pitch /= guess]
        


-- Picking best next guess --

-- Takes a pair of the previous guess and game state and the feedback, giving
-- the next pair of guess and game state
-- We reduce the GameState by only keeping chord that statisfy deleteFunction
-- i.e remove previous guess
-- Then picking the best guess possible out of the new GameState
nextGuess :: ([Pitch],GameState) -> (Int,Int,Int) -> ([Pitch],GameState)
nextGuess (lastGuess, GameState state) score = (nextBest, (GameState newState))
    where
        newState = filter (\x -> (deleteFunction x lastGuess score)) state   
                                  
        nextBest = pickBest (GameState newState)

-- Reducing possible target function by taking a possible guess and previous
-- guess and removing "inconsistent" guess. i.e different feedback
deleteFunction :: [Pitch] -> [Pitch] -> (Int,Int,Int) -> Bool
deleteFunction guess lastguess lastscore
    = feedback guess lastguess == lastscore

-- Getting the expected remaining candidates left after a guess is considered.
-- We will later utilise this to find the best possible guess
-- We first compute all possible scores for the remain candidate, we then
-- proceed to find the expected remaining candidates by grouping those guess
-- that generate same score and find its probability out of all possible guess
-- Which then return both the expected remaining candidate value and the guess.
candidateLeft :: [Pitch] -> GameState -> (Double, [Pitch])
candidateLeft target (GameState state)   
    = (expectedValue, target)
    where
        scores  = [x | guess <-  state, let x = feedback target guess]
        expectedValue = sum [ remain | grp <- group(scores)
         , let remain = (fromIntegral(length grp)/fromIntegral(length scores)) * 
                                              fromIntegral(length grp)]

-- Choosing a best guess given a game state
-- Using our candidateLeft as our scoring system, we score all of our guesses
-- in the game state, we then simply picking guess with the minimum expected 
-- number of remaining candidate given by our candidate left function
pickBest :: GameState -> [Pitch]
pickBest (GameState currState) = snd (bestGuess)
    where
        allScore = [ scoreTup | targ <- currState
                       , let nextState = GameState (currState \\ [targ])
                       , let scoreTup = candidateLeft targ nextState]
        bestGuess = minimumBy (comparing fst) allScore