{-# OPTIONS -fallow-overlapping-instances #-}

module TypeChecking.Serialise where

import Control.Monad
import Data.Binary

import Syntax.Common
import Syntax.Concrete.Name as C
import Syntax.Abstract.Name as A
import Syntax.Internal
import Syntax.Scope.Base
import Syntax.Position
import Syntax.Common
import Syntax.Fixity
import Syntax.Literal

import TypeChecking.Monad

import Utils.Serialise
import Utils.Tuple

-- | Current version of the interface. Only interface files of this version
--   will be parsed.
currentInterfaceVersion :: InterfaceVersion
currentInterfaceVersion = InterfaceVersion 117

instance Binary InterfaceVersion where
    put (InterfaceVersion v) = put v
    get = do
	v <- liftM InterfaceVersion get
	if (v == currentInterfaceVersion)
	    then return v
	    else fail "Wrong interface version"

instance Binary C.Name where
    put (C.NoName a b) = putWord8 0 >> put a >> put b
    put (C.Name r xs) = putWord8 1 >> put r >> put xs
    get = do
      tag_ <- getWord8
      case tag_ of
	0 -> liftM2 C.NoName get get
	1 -> liftM2 C.Name get get
	_ -> fail "no parse"

instance Binary NamePart where
  put Hole = putWord8 0
  put (Id a) = putWord8 1 >> put a
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> return Hole
      1 -> get >>= \a -> return (Id a)
      _ -> fail "no parse"

instance Binary Range where
    put _ = return ()
    get	  = return $ Range p p
	where p = Pn "[imported]" 0 0
--     put (Range a b) = put a >> put b
--     get = liftM2 Range get get

instance Binary Position where
    put NoPos	   = putWord8 0
    put (Pn f l c) = putWord8 1 >> put f >> put l >> put c
    get = do
	tag_ <- getWord8
	case tag_ of
	    0	-> return NoPos
	    1	-> liftM3 Pn get get get
	    _ -> fail "no parse"

instance Binary C.QName where
  put (Qual a b) = putWord8 0 >> put a >> put b
  put (C.QName a) = putWord8 1 >> put a
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> get >>= \a -> get >>= \b -> return (Qual a b)
      1 -> get >>= \a -> return (C.QName a)
      _ -> fail "no parse"

instance Binary Scope where
  put (Scope a b c) = put a >> put b >> put c
  get = get >>= \a -> get >>= \b -> get >>= \c -> return (Scope a b c)

instance Binary Access where
  put PrivateAccess = putWord8 0
  put PublicAccess = putWord8 1
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> return PrivateAccess
      1 -> return PublicAccess
      _ -> fail "no parse"

instance Binary NameSpace where
  put (NameSpace a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (NameSpace a b)

instance Binary AbstractName where
  put (AbsName a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (AbsName a b)

instance Binary AbstractModule where
  put (AbsModule a) = put a
  get = get >>= \a -> return (AbsModule a)

instance Binary KindOfName where
  put DefName = putWord8 0
  put ConName = putWord8 1
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> return DefName
      1 -> return ConName
      _ -> fail "no parse"

instance Binary Syntax.Fixity.Fixity where
  put (LeftAssoc a b) = putWord8 0 >> put a >> put b
  put (RightAssoc a b) = putWord8 1 >> put a >> put b
  put (NonAssoc a b) = putWord8 2 >> put a >> put b
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> get >>= \a -> get >>= \b -> return (LeftAssoc a b)
      1 -> get >>= \a -> get >>= \b -> return (RightAssoc a b)
      2 -> get >>= \a -> get >>= \b -> return (NonAssoc a b)
      _ -> fail "no parse"

instance Binary A.QName where
  put (A.QName a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (A.QName a b)

instance Binary A.ModuleName where
  put (A.MName a) = put a
  get = get >>= \a -> return (A.MName a)

instance Binary A.Name where
  put (A.Name a b c d) = put a >> put b >> put c >> put d
  get = get >>= \a -> get >>= \b -> get >>= \c -> get >>= \d -> return (A.Name a b c d)

instance Binary NameId where
  put (NameId a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (NameId a b)

instance Binary Signature where
  put (Sig a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (Sig a b)

instance Binary Section where
  put (Section a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (Section a b)

instance Binary Telescope where
  put EmptyTel = putWord8 0
  put (ExtendTel a b) = putWord8 1 >> put a >> put b
  get = do
    tag_ <- getWord8
    case tag_ of
      0	-> return EmptyTel
      1 -> get >>= \a -> get >>= \b -> return (ExtendTel a b)
      _ -> fail "no parse"

instance (Binary a) => Binary (Syntax.Common.Arg a) where
  put (Arg a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (Arg a b)

instance Binary Syntax.Common.Hiding where
  put Hidden = putWord8 0
  put NotHidden = putWord8 1
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> return Hidden
      1 -> return NotHidden
      _ -> fail "no parse"

instance Binary Syntax.Internal.Type where
  put (El a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (El a b)

instance Binary Syntax.Internal.MetaId where
  put (MetaId a) = put a
  get = get >>= \a -> return (MetaId a)

instance (Binary a) => Binary (Syntax.Internal.Blocked a) where
  put (Blocked a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (Blocked a b)

instance (Binary a) => Binary (Syntax.Internal.Abs a) where
  put (Abs a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (Abs a b)

instance Binary Syntax.Internal.Term where
  put (Var a b) = putWord8 0 >> put a >> put b
  put (Lam a b) = putWord8 1 >> put a >> put b
  put (Lit a) = putWord8 2 >> put a
  put (Def a b) = putWord8 3 >> put a >> put b
  put (Con a b) = putWord8 4 >> put a >> put b
  put (Pi a b) = putWord8 5 >> put a >> put b
  put (Fun a b) = putWord8 6 >> put a >> put b
  put (Sort a) = putWord8 7 >> put a
  put (MetaV a b) = putWord8 8 >> put a >> put b
  put (BlockedV a) = putWord8 9 >> put a
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> get >>= \a -> get >>= \b -> return (Var a b)
      1 -> get >>= \a -> get >>= \b -> return (Lam a b)
      2 -> get >>= \a -> return (Lit a)
      3 -> get >>= \a -> get >>= \b -> return (Def a b)
      4 -> get >>= \a -> get >>= \b -> return (Con a b)
      5 -> get >>= \a -> get >>= \b -> return (Pi a b)
      6 -> get >>= \a -> get >>= \b -> return (Fun a b)
      7 -> get >>= \a -> return (Sort a)
      8 -> get >>= \a -> get >>= \b -> return (MetaV a b)
      9 -> get >>= \a -> return (BlockedV a)
      _ -> fail "no parse"

instance Binary Syntax.Internal.Sort where
  put (Type a) = putWord8 0 >> put a
  put Prop = putWord8 1
  put (Lub a b) = putWord8 2 >> put a >> put b
  put (Suc a) = putWord8 3 >> put a
  put (MetaS a) = putWord8 4 >> put a
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> get >>= \a -> return (Type a)
      1 -> return Prop
      2 -> get >>= \a -> get >>= \b -> return (Lub a b)
      3 -> get >>= \a -> return (Suc a)
      4 -> get >>= \a -> return (MetaS a)
      _ -> fail "no parse"

instance Binary Syntax.Literal.Literal where
  put (LitInt a b) = putWord8 0 >> put a >> put b
  put (LitFloat a b) = putWord8 1 >> put a >> put b
  put (LitString a b) = putWord8 2 >> put a >> put b
  put (LitChar a b) = putWord8 3 >> put a >> put b
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> get >>= \a -> get >>= \b -> return (LitInt a b)
      1 -> get >>= \a -> get >>= \b -> return (LitFloat a b)
      2 -> get >>= \a -> get >>= \b -> return (LitString a b)
      3 -> get >>= \a -> get >>= \b -> return (LitChar a b)
      _ -> fail "no parse"

instance Binary Definition where
  put (Defn a b c) = put a >> put b >> put c
  get = get >>= \a -> get >>= \b -> get >>= \c -> return (Defn a b c)

instance Binary Defn where
  put Axiom		     = putWord8 0
  put (Function a b)	     = putWord8 1 >> put a >> put b
  put (Datatype a b c d e f) = putWord8 2 >> put a >> put b >> put c >> put d >> put e >> put f
  put (Record a b c d e f)   = putWord8 3 >> put a >> put b >> put c >> put d >> put e >> put f
  put (Constructor a b c d)  = putWord8 4 >> put a >> put b >> put c >> put d
  put (Primitive a b c)	     = putWord8 5 >> put a >> put b >> put c
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> return Axiom
      1 -> get >>= \a -> get >>= \b -> return (Function a b)
      2 -> get >>= \a -> get >>= \b -> get >>= \c -> get >>= \d -> get >>= \e -> get >>= \f -> return (Datatype a b c d e f)
      3 -> get >>= \a -> get >>= \b -> get >>= \c -> get >>= \d -> get >>= \e -> get >>= \f -> return (Record a b c d e f)
      4 -> get >>= \a -> get >>= \b -> get >>= \c -> get >>= \d -> return (Constructor a b c d)
      5 -> get >>= \a -> get >>= \b -> get >>= \c -> return (Primitive a b c)
      _ -> fail "no parse"

instance Binary Syntax.Common.IsAbstract where
  put AbstractDef = putWord8 0
  put ConcreteDef = putWord8 1
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> return AbstractDef
      1 -> return ConcreteDef
      _ -> fail "no parse"

instance Binary Syntax.Internal.Clause where
  put (Clause a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (Clause a b)

instance Binary Syntax.Internal.ClauseBody where
  put (Body a) = putWord8 0 >> put a
  put (Bind a) = putWord8 1 >> put a
  put (NoBind a) = putWord8 2 >> put a
  put NoBody = putWord8 3
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> get >>= \a -> return (Body a)
      1 -> get >>= \a -> return (Bind a)
      2 -> get >>= \a -> return (NoBind a)
      3 -> return NoBody
      _ -> fail "no parse"

instance Binary Syntax.Internal.Pattern where
  put (VarP a) = putWord8 0 >> put a
  put (ConP a b) = putWord8 1 >> put a >> put b
  put (LitP a) = putWord8 2 >> put a
  put WildP = putWord8 3
  put AbsurdP = putWord8 4
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> get >>= \a -> return (VarP a)
      1 -> get >>= \a -> get >>= \b -> return (ConP a b)
      2 -> get >>= \a -> return (LitP a)
      3 -> return WildP
      4 -> return AbsurdP
      _ -> fail "no parse"

instance Binary a => Binary (Builtin a) where
    put (Prim a) = putWord8 0 >> put a
    put (Builtin a) = putWord8 1 >> put a
    get = do
	tag_ <- getWord8
	case tag_ of
	    0	-> liftM Prim get
	    1	-> liftM Builtin get
	    _ -> fail "no parse"

instance Binary Interface where
    put (Interface a b c d e f) = put a >> put b >> put c >> put d >> put e >> put f
    get = liftM5 Interface get get get get get `ap` get

