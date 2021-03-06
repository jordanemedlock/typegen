{-|
Module      : GenProg.Execute
Description : Executes a population
Copyright   : (c) Jordan Medlock, 2015
                  University of New Mexico, 2015
License     : None
Maintainer  : medlock@unm.edu
Stability   : experimental
Portability : POSIX
-}

module GenProg.Execute (
  executePopulation
) where


import GenProg.Types

import System.Process
import System.Timeout
import System.Directory
import System.IO
import Text.Read
import Control.Monad
import Control.Applicative

-- | Executes and evaluates a 'Population' and returns a list of the individuals
-- score, or a string with an error
executePopulation :: Population -> IO [Either String Int]
executePopulation pop = mapM executeString $ showPopulation pop

executeInd :: Int -> String -> IO (Either String Int)
executeInd i s = do
  let fname = ("Tmp.hs")
  writeFile fname s
  x <- runFile fname
  return $ case readMaybe x of
    Nothing -> Left $ show x
    (Just x) -> Right x

sec = 10^6

executeString :: String -> IO (Either String Int)
executeString s = do
  writeFile "Tmp.hs" s
  x <- runFile "Tmp.hs"
  writeFile "/dev/null" (s ++ x) -- This is a weird thing that I had to do because
                                 -- it was being too lazy
  return $ case readMaybe x of
    Nothing -> Left x
    (Just x) -> Right x

runFile name = do
  -- Compile
  let command = (shell $ "./timeout 2 \"runghc "++name++"\"") { std_out = CreatePipe
                                          , std_err = CreatePipe }
  (_, (Just handle), (Just std_err_h), pH) <- createProcess command
  output <- hGetContents handle
  err2 <- hGetContents std_err_h
  -- waitForProcess pH
  return $ if null err2 then output else err2

logIfNothing :: String -> Maybe a -> IO (Maybe a)
logIfNothing str Nothing = do
  appendFile "errors.txt" (str ++ "\n")
  return Nothing
logIfNothing _ x = return x
