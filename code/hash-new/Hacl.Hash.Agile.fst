module Hacl.Hash.Agile

open Hacl.Hash.Definitions
open Spec.Hash.Helpers

(** A series of static multiplexers that will be useful when building the
    generic Merkle-Damgard construction. *)

inline_for_extraction noextract
let alloca (a: hash_alg): alloca_st a =
  match a with
  | MD5 -> Hacl.Hash.Core.MD5.alloca
  | SHA1 -> Hacl.Hash.Core.SHA1.alloca
  | SHA2_224 -> Hacl.Hash.Core.SHA2.alloca_224
  | SHA2_256 -> Hacl.Hash.Core.SHA2.alloca_256
  | SHA2_384 -> Hacl.Hash.Core.SHA2.alloca_384
  | SHA2_512 -> Hacl.Hash.Core.SHA2.alloca_512

inline_for_extraction noextract
let init (a: hash_alg): init_st a =
  match a with
  | MD5 -> Hacl.Hash.Core.MD5.init
  | SHA1 -> Hacl.Hash.Core.SHA1.init
  | SHA2_224 -> Hacl.Hash.Core.SHA2.init_224
  | SHA2_256 -> Hacl.Hash.Core.SHA2.init_256
  | SHA2_384 -> Hacl.Hash.Core.SHA2.init_384
  | SHA2_512 -> Hacl.Hash.Core.SHA2.init_512

inline_for_extraction noextract
let update (a: hash_alg): update_st a =
  match a with
  | MD5 -> Hacl.Hash.Core.MD5.update
  | SHA1 -> Hacl.Hash.Core.SHA1.update
  | SHA2_224 -> Hacl.Hash.Core.SHA2.update_224
  | SHA2_256 -> Hacl.Hash.Core.SHA2.update_256
  | SHA2_384 -> Hacl.Hash.Core.SHA2.update_384
  | SHA2_512 -> Hacl.Hash.Core.SHA2.update_512

inline_for_extraction noextract
let pad (a: hash_alg): pad_st a =
  match a with
  | MD5 -> Hacl.Hash.Core.MD5.pad
  | SHA1 -> Hacl.Hash.Core.SHA1.pad
  | SHA2_224 -> Hacl.Hash.Core.SHA2.pad_224
  | SHA2_256 -> Hacl.Hash.Core.SHA2.pad_256
  | SHA2_384 -> Hacl.Hash.Core.SHA2.pad_384
  | SHA2_512 -> Hacl.Hash.Core.SHA2.pad_512

inline_for_extraction noextract
let finish (a: hash_alg): finish_st a =
  match a with
  | MD5 -> Hacl.Hash.Core.MD5.finish
  | SHA1 -> Hacl.Hash.Core.SHA1.finish
  | SHA2_224 -> Hacl.Hash.Core.SHA2.finish_224
  | SHA2_256 -> Hacl.Hash.Core.SHA2.finish_256
  | SHA2_384 -> Hacl.Hash.Core.SHA2.finish_384
  | SHA2_512 -> Hacl.Hash.Core.SHA2.finish_512
