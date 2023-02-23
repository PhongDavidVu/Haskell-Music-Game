The objective of this project is to practice and assess your understanding of functional programming and Haskell. You will write code to implement both the guessing and answering parts of a logical guessing game.

The Game of Musician
Musician is a two-player logical guessing game created for this project. You will not find any information about the game anywhere else, but it is a simple game and this specification will tell you all you need to know.

For a Musician game, one player is the composer and the other is the performer. The composer begins by selecting a three-pitch musical chord, where each pitch comprises a musical note, one of A, B, C, D, E, F, or G, and an octave, one of 1, 2, or 3. This chord will be the target for the game. The order of pitches in the target is irrelevant, and no pitch may appear more than once. This game does not include sharps or flats, and no more or less than three notes may be included in the target.

Once the composer has selected the target chord, the performer repeatedly chooses a similarly defined chord as a guess and tells it to the composer, who responds by giving the performer the following feedback:

how many pitches in the guess are included in the target (correct pitches)
how many pitches have the right note but the wrong octave (correct notes)
how many pitches have the right octave but the wrong note (correct octaves)
In counting correct notes and octaves, multiple occurrences in the guess are only counted as correct if they also appear repeatedly in the target. Correct pitches are not also counted as correct notes and octaves. For example, with a target of A1, B2, A3, a guess of A1, A2, B1 would be counted as 1 correct pitch (A1), two correct notes (A2, B1) and one correct octave (A2). B1 would not be counted as a correct octave, even though it has the same octave as the target A1, because the target A1 was already used to count the guess A1 as a correct pitch. A few more examples:

Target	Guess	Answer
A1,B2,A3	A1,A2,B1	1,2,1
A1,B2,C3	A1,A2,A3	1,0,2
A1,B1,C1	A2,D1,E1	0,1,2
A3,B2,C1	C3,A2,B1	0,3,3
The game finishes once the performer guesses the correct chord (all three pitches in the guess are in the target). The object of the game for the performer is to find the target with the fewest possible guesses.

The Program
You will write Haskell code to implement both the composer and performer parts of the game. This will require you to write a function to return your initial guess, and another to use the feedback from the previous guess to determine the next guess. The latter function will be called repeatedly until it produces the correct guess. You must also implement a function to determine the feedback to give to the composer, given his guess and a target.

You will find it useful to keep information between guesses; since Haskell is a purely functional language, you cannot use a global or static variable to store this. Therefore, your initial guess function must return this game state information, and your next guess function must take the game state as input and return the updated game state as output. You may put any information you like in the game state, but you must define a type GameState to hold this information. If you do not need to maintain any game state, you may simply define type GameState = ().

You must also define a type Pitch to represent pitches in the game, and you must represent your guesses as lists of Pitches. Your Pitch type must be an instance of the Eq and Show type classes. Of course, two Pitches must be considered equal if and only if they are identical. A Pitch must be shown as a two-character string of the upper-case note and the octave numeral, as shown throughout this document. You must also define a function to convert a Pitch into a string.

What you must define
In summary, in addition to defining the GameState and Pitch types, you must define following functions:

toPitch :: String → Maybe Pitch

gives Just the Pitch named by the string, or Nothing if the string is not a valid pitch name.
feedback :: [Pitch] → [Pitch] → (Int,Int,Int)

takes a target and a guess, respectively, and returns the appropriate feedback, as specified above.
initialGuess :: ([Pitch],GameState)

takes no input arguments, and returns a pair of an initial guess and a game state.
nextGuess :: ([Pitch],GameState) → (Int,Int,Int) → ([Pitch],GameState)

takes as input a pair of the previous guess and game state, and the feedback to this guess as a triple of correct pitches, notes, and octaves, and returns a pair of the next guess and game state.
You must call your (main) source file Proj2.hs (or Proj2.lhs if you use literate Haskell), and it must have the following module declaration as the first line of code:

  module Proj2 (Pitch, toPitch, feedback,
                GameState, initialGuess, nextGuess) where
Please put all your code in this one module (the Proj2.hs file).

Testing your code
When you hit the Run button in Grok, it will load your code into GHCi. Then you can test your code, such as:

*Main> toPitch "A3"
Just A3
As a convenience for testing, there is a function

toChord :: String -> [Pitch]
defined. You can supply it a string of space-separated pitch names and it will return a chord (list of Pitches), or report an error if any of the pitches is ill-formed. You may find this helpful when testing your feedback function.

There is also a test driver function to prompt you for the target you would like to test with, and then will run your initialGuess function and repeatedly call your nextGuess function until it guesses the target, showing all the guesses and the count of guesses taken. To run the testing code, just give the main command at the prompt, and enter the target you would like to use. You will then see something like this:

*Main> main
Target chord (3 pitches separated by spaces): G2 A2 F2
Your guess #1:  [A1,B1,C2]
    My answer:  (0,1,1)
Your guess #2:  [C1,D3,E3]
    My answer:  (0,0,0)
Your guess #3:  [A2,F2,G2]
    My answer:  (3,0,0)
You got it in 3 guesses!