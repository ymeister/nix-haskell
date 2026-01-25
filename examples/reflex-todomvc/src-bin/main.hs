{-# LANGUAGE CPP #-}
{-# LANGUAGE ForeignFunctionInterface #-}

import qualified Reflex.TodoMVC
import Reflex.Dom (run)

#if defined(wasm32_HOST_ARCH)
foreign export javascript "hs_start" main :: IO ()
#endif

main :: IO ()
main = run Reflex.TodoMVC.main
