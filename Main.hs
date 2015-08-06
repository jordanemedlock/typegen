{-# LANGUAGE OverloadedStrings #-}

import Search.ParseInstances
import Search.Instances
import Types.TestFunction
import Types.Type
import Types.Value
import Types.ProcessTypes
import Control.Applicative
import GenProg.Types
import GenProg.Test
import GenProg.Mutations
import GenProg.Execute
import Control.Monad
import System.Environment
import Control.Arrow
import Data.Either

main = do
  n <- read <$> head <$> getArgs
  testRunPop n

testTypeStuff = do
  let a = (Polymorphic "a" (map Constraint []))
  let b = (Polymorphic "b" (map Constraint []))
  let list x = (Application (Concrete "[]") x)
  let map' = (Function (Function a b) (Function (list a) (list b)))
  let filter' = (Function (Function a (Concrete "Bool")) (Function (list a) (list a)))
  let applic = apply filter' (Function a a)
  print applic
  print $ showType <$> applic

testPrintPop :: Int -> IO ()
testPrintPop n = do
  let a x = (Polymorphic "a" (map Constraint x))
  let b x = (Polymorphic "b" (map Constraint x))
  let plusT = (Function (a ["Num"]) (Function (a ["Num"]) (a ["Num"])))
  let num = a ["Num"]
  let lit n = Atom num (show n)
  let plus = Atom plusT "(+)"
  let ind = Individual "f :: (Num a) => a -> a" ["x :: (Num a) -> a"] [] (lit 1)
  x <- mutations ind
  x <- concat <$> mapM mutations x
  x <- concat <$> mapM mutations x
  mapM_ (putStrLn . showIndividual) x
  -- tests <- mkUnaryTests (\x -> x^2) (0::Int,10) 10
  -- let pop = Population y tests
  -- mapM_ (putStrLn . showValue . func) y
  -- fits <- executePopulation pop
  -- mapM_ print $ zip [1..] fits

testRunPop :: Int -> IO ()
testRunPop n = do
  let a x = (Polymorphic "a" (map Constraint x))
  let b x = (Polymorphic "b" (map Constraint x))
  let plusT = (Function (a ["Num"]) (Function (a ["Num"]) (a ["Num"])))
  let num = a ["Num"]
  let lit n = Atom num (show n)
  let plus = Atom plusT "(+)"
  let ind = Individual "f :: (Num a) => a -> a" ["x :: (Num a) -> a"] [] (lit 1)
  x <- mutations ind
  tests <- mkUnaryTests (\x -> x^2) (0::Int,10) 10
  let pop = Population x tests
  -- mapM_ (putStrLn . showValue . func) x
  fits <- executePopulation pop
  let newInds = map snd $ (filter (isRight.fst) $ zip fits x)
  newX <- concat <$> mapM mutations newInds
  let newPop = Population newX tests
  fits <- executePopulation newPop
  mapM_ (print.(showIndividual***id)) $ zip x fits


testTests = do
  tests <- mkUnaryTests (\x -> x^2) (0::Int,10) 100
  putStrLn $ showTests tests

testInstances = do
  x <- getInstances "Integer"
  print x

testMutations = do
  let a x = (Polymorphic "a" (map Constraint x))
  let b x = (Polymorphic "b" (map Constraint x))
  let plusT = (Function (a ["Num"]) (Function (a ["Num"]) (a ["Num"])))
  let num = a ["Num"]
  let lit n = Atom num (show n)
  let plus = Atom plusT "(+)"
  let ind = Individual "f :: (Num a) => a -> a -> a" ["x :: (Num a) -> a","y :: (Num a) -> a"] [] (lit 1)
  x <- mutations ind
  mapM_ (printInd) x
  mapM_ ((mapM_ printInd)<=<mutations) x

printInd ind = do
  putStrLn $ showIndividual ind
  putStrLn ""
