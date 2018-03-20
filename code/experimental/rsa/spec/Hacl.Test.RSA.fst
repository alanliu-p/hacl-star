module Hacl.Test.RSA

open FStar.Mul
open Spec.Lib.IntTypes
open Spec.Lib.IntSeq
open Spec.Lib.IntSeq.Lemmas
open Spec.Lib.RawIntTypes

open Hacl.Spec.Lib
open Hacl.Spec.Convert
open Hacl.Spec.RSA

open FStar.All

val ctest:
    x0:size_nat{x0 >= 6} -> iLen:size_nat ->
    modBits:size_nat -> n:lbytes (bits_to_text modBits) ->
    pkeyBits:size_nat -> e:lbytes (bits_to_text pkeyBits) ->
    skeyBits:size_nat -> d:lbytes (bits_to_text skeyBits) ->
    pTLen:size_nat -> p:lbytes pTLen ->
    qTLen:size_nat -> q:lbytes qTLen ->
    rBlindTLen:size_nat -> rBlind:lbytes rBlindTLen ->
    msgLen:size_nat -> msg:lbytes msgLen ->
    saltLen:size_nat -> salt:lbytes saltLen ->
    sgnt_expected:lbytes (bits_to_text modBits) -> ML bool
let ctest x0 iLen modBits n pkeyBits e skeyBits d pTLen p qTLen q rBlindTLen rBlind msgLen msg saltLen salt sgnt_expected =
    let pow2_i = pow2 (x0 - 6) in
    let nLen = bits_to_bn modBits in
    let eLen = bits_to_bn pkeyBits in
    let dLen = bits_to_bn skeyBits in
    let pLen = get_size_nat pTLen in
    let qLen = get_size_nat qTLen in
    let rBlindLen = get_size_nat rBlindTLen in

    let pkeyLen:size_nat = nLen + eLen in
    let skeyLen:size_nat = pkeyLen + dLen + pLen + qLen in
    let skey:lseqbn skeyLen = create skeyLen (u64 0) in

    let nNat = sub skey 0 nLen in
    let eNat = sub skey nLen eLen in
    let dNat = sub skey pkeyLen dLen in
    let pNat = sub skey (pkeyLen + dLen) pLen in
    let qNat = sub skey (pkeyLen + dLen + pLen) qLen in

    let nNat = text_to_nat (bits_to_text modBits) n nNat in
    let skey = update_sub skey 0 nLen nNat in
    let eNat = text_to_nat (bits_to_text pkeyBits) e eNat in
    let skey = update_sub skey nLen eLen eNat in
    let dNat = text_to_nat (bits_to_text skeyBits) d dNat in
    let skey = update_sub skey pkeyLen dLen dNat in
    let pNat = text_to_nat pTLen p pNat in
    let skey = update_sub skey (pkeyLen + dLen) pLen pNat in
    let qNat = text_to_nat qTLen q qNat in
    let skey = update_sub skey (pkeyLen + dLen + pLen) qLen qNat in

    let pkey = sub skey 0 pkeyLen in

    let rBlindNat:lseqbn rBlindLen = create rBlindLen (u64 0) in
    let rBlindNat = text_to_nat rBlindTLen rBlind rBlindNat in
    let rBlind0 = rBlindNat.[0] in
    
    let nTLen = bits_to_text modBits in
    let sgnt:lbytes nTLen = create nTLen (u8 0) in
    let sgnt = rsa_sign nLen pow2_i iLen modBits pkeyBits skeyBits pLen qLen skey rBlind0 saltLen salt msgLen msg sgnt in
    IO.print_string "\n sgnt \n";
    List.iter (fun a -> IO.print_string (UInt8.to_string_hex (u8_to_UInt8 a))) (as_list sgnt);
    IO.print_string "\n the expected sgnt \n";
    List.iter (fun a -> IO.print_string (UInt8.to_string_hex (u8_to_UInt8 a))) (as_list sgnt_expected);
    IO.print_string "\n";
    //let check_sgnt = eq_bytes nTLen sgnt sgnt_expected in
    let verify_sgnt = rsa_verify nLen pow2_i iLen modBits pkeyBits pkey saltLen sgnt_expected msgLen msg in
    //check_sgnt && verify_sgnt
    verify_sgnt

val test1: unit -> ML bool
let test1() =
    let modBits = 1024 in
    let nLen = bits_to_text modBits in
    let n : lbytes nLen = createL [
	u8 0xa5; u8 0x6e; u8 0x4a; u8 0x0e; u8 0x70; u8 0x10; u8 0x17; u8 0x58; u8 0x9a; u8 0x51; u8 0x87; u8 0xdc; u8 0x7e; u8 0xa8; u8 0x41; u8 0xd1;
	u8 0x56; u8 0xf2; u8 0xec; u8 0x0e; u8 0x36; u8 0xad; u8 0x52; u8 0xa4; u8 0x4d; u8 0xfe; u8 0xb1; u8 0xe6; u8 0x1f; u8 0x7a; u8 0xd9; u8 0x91;
	u8 0xd8; u8 0xc5; u8 0x10; u8 0x56; u8 0xff; u8 0xed; u8 0xb1; u8 0x62; u8 0xb4; u8 0xc0; u8 0xf2; u8 0x83; u8 0xa1; u8 0x2a; u8 0x88; u8 0xa3;
	u8 0x94; u8 0xdf; u8 0xf5; u8 0x26; u8 0xab; u8 0x72; u8 0x91; u8 0xcb; u8 0xb3; u8 0x07; u8 0xce; u8 0xab; u8 0xfc; u8 0xe0; u8 0xb1; u8 0xdf;
	u8 0xd5; u8 0xcd; u8 0x95; u8 0x08; u8 0x09; u8 0x6d; u8 0x5b; u8 0x2b; u8 0x8b; u8 0x6d; u8 0xf5; u8 0xd6; u8 0x71; u8 0xef; u8 0x63; u8 0x77;
	u8 0xc0; u8 0x92; u8 0x1c; u8 0xb2; u8 0x3c; u8 0x27; u8 0x0a; u8 0x70; u8 0xe2; u8 0x59; u8 0x8e; u8 0x6f; u8 0xf8; u8 0x9d; u8 0x19; u8 0xf1;
	u8 0x05; u8 0xac; u8 0xc2; u8 0xd3; u8 0xf0; u8 0xcb; u8 0x35; u8 0xf2; u8 0x92; u8 0x80; u8 0xe1; u8 0x38; u8 0x6b; u8 0x6f; u8 0x64; u8 0xc4;
	u8 0xef; u8 0x22; u8 0xe1; u8 0xe1; u8 0xf2; u8 0x0d; u8 0x0c; u8 0xe8; u8 0xcf; u8 0xfb; u8 0x22; u8 0x49; u8 0xbd; u8 0x9a; u8 0x21; u8 0x37] in
    let pkeyBits = 24 in
    let eLen = bits_to_text pkeyBits in
    let e : lbytes eLen = createL [u8 0x01; u8 0x00; u8 0x01] in
    let skeyBits = 1024 in
    let dLen = bits_to_text skeyBits in
    let d : lbytes dLen = createL [
        u8 0x33; u8 0xa5; u8 0x04; u8 0x2a; u8 0x90; u8 0xb2; u8 0x7d; u8 0x4f; u8 0x54; u8 0x51; u8 0xca; u8 0x9b; u8 0xbb; u8 0xd0; u8 0xb4; u8 0x47;
	u8 0x71; u8 0xa1; u8 0x01; u8 0xaf; u8 0x88; u8 0x43; u8 0x40; u8 0xae; u8 0xf9; u8 0x88; u8 0x5f; u8 0x2a; u8 0x4b; u8 0xbe; u8 0x92; u8 0xe8;
	u8 0x94; u8 0xa7; u8 0x24; u8 0xac; u8 0x3c; u8 0x56; u8 0x8c; u8 0x8f; u8 0x97; u8 0x85; u8 0x3a; u8 0xd0; u8 0x7c; u8 0x02; u8 0x66; u8 0xc8;
	u8 0xc6; u8 0xa3; u8 0xca; u8 0x09; u8 0x29; u8 0xf1; u8 0xe8; u8 0xf1; u8 0x12; u8 0x31; u8 0x88; u8 0x44; u8 0x29; u8 0xfc; u8 0x4d; u8 0x9a;
	u8 0xe5; u8 0x5f; u8 0xee; u8 0x89; u8 0x6a; u8 0x10; u8 0xce; u8 0x70; u8 0x7c; u8 0x3e; u8 0xd7; u8 0xe7; u8 0x34; u8 0xe4; u8 0x47; u8 0x27;
	u8 0xa3; u8 0x95; u8 0x74; u8 0x50; u8 0x1a; u8 0x53; u8 0x26; u8 0x83; u8 0x10; u8 0x9c; u8 0x2a; u8 0xba; u8 0xca; u8 0xba; u8 0x28; u8 0x3c;
	u8 0x31; u8 0xb4; u8 0xbd; u8 0x2f; u8 0x53; u8 0xc3; u8 0xee; u8 0x37; u8 0xe3; u8 0x52; u8 0xce; u8 0xe3; u8 0x4f; u8 0x9e; u8 0x50; u8 0x3b;
	u8 0xd8; u8 0x0c; u8 0x06; u8 0x22; u8 0xad; u8 0x79; u8 0xc6; u8 0xdc; u8 0xee; u8 0x88; u8 0x35; u8 0x47; u8 0xc6; u8 0xa3; u8 0xb3; u8 0x25] in
    let pLen = 64 in
    let p : lbytes pLen = createL [
        u8 0xe7; u8 0xe8; u8 0x94; u8 0x27; u8 0x20; u8 0xa8; u8 0x77; u8 0x51; u8 0x72; u8 0x73; u8 0xa3; u8 0x56; u8 0x05; u8 0x3e; u8 0xa2; u8 0xa1;
        u8 0xbc; u8 0x0c; u8 0x94; u8 0xaa; u8 0x72; u8 0xd5; u8 0x5c; u8 0x6e; u8 0x86; u8 0x29; u8 0x6b; u8 0x2d; u8 0xfc; u8 0x96; u8 0x79; u8 0x48;
        u8 0xc0; u8 0xa7; u8 0x2c; u8 0xbc; u8 0xcc; u8 0xa7; u8 0xea; u8 0xcb; u8 0x35; u8 0x70; u8 0x6e; u8 0x09; u8 0xa1; u8 0xdf; u8 0x55; u8 0xa1;
        u8 0x53; u8 0x5b; u8 0xd9; u8 0xb3; u8 0xcc; u8 0x34; u8 0x16; u8 0x0b; u8 0x3b; u8 0x6d; u8 0xcd; u8 0x3e; u8 0xda; u8 0x8e; u8 0x64; u8 0x43 ] in
    let qLen = 64 in
    let q : lbytes qLen = createL [
        u8 0xb6; u8 0x9d; u8 0xca; u8 0x1c; u8 0xf7; u8 0xd4; u8 0xd7; u8 0xec; u8 0x81; u8 0xe7; u8 0x5b; u8 0x90; u8 0xfc; u8 0xca; u8 0x87; u8 0x4a;
        u8 0xbc; u8 0xde; u8 0x12; u8 0x3f; u8 0xd2; u8 0x70; u8 0x01; u8 0x80; u8 0xaa; u8 0x90; u8 0x47; u8 0x9b; u8 0x6e; u8 0x48; u8 0xde; u8 0x8d;
        u8 0x67; u8 0xed; u8 0x24; u8 0xf9; u8 0xf1; u8 0x9d; u8 0x85; u8 0xba; u8 0x27; u8 0x58; u8 0x74; u8 0xf5; u8 0x42; u8 0xcd; u8 0x20; u8 0xdc;
        u8 0x72; u8 0x3e; u8 0x69; u8 0x63; u8 0x36; u8 0x4a; u8 0x1f; u8 0x94; u8 0x25; u8 0x45; u8 0x2b; u8 0x26; u8 0x9a; u8 0x67; u8 0x99; u8 0xfd ] in
    let rBlindLen = 8 in
    let rBlind : lbytes rBlindLen = createL [u8 0xa5; u8 0x6e; u8 0x4a; u8 0x0e; u8 0x70; u8 0x10; u8 0x17; u8 0x58] in
    let msgLen = 51 in
    let msg:lbytes msgLen = createL [
        u8 0x85; u8 0x13; u8 0x84; u8 0xcd; u8 0xfe; u8 0x81; u8 0x9c; u8 0x22; u8 0xed; u8 0x6c; u8 0x4c; u8 0xcb; u8 0x30; u8 0xda; u8 0xeb; u8 0x5c;
        u8 0xf0; u8 0x59; u8 0xbc; u8 0x8e; u8 0x11; u8 0x66; u8 0xb7; u8 0xe3; u8 0x53; u8 0x0c; u8 0x4c; u8 0x23; u8 0x3e; u8 0x2b; u8 0x5f; u8 0x8f;
        u8 0x71; u8 0xa1; u8 0xcc; u8 0xa5; u8 0x82; u8 0xd4; u8 0x3e; u8 0xcc; u8 0x72; u8 0xb1; u8 0xbc; u8 0xa1; u8 0x6d; u8 0xfc; u8 0x70; u8 0x13;
        u8 0x22; u8 0x6b; u8 0x9e ] in
    let saltLen = 20 in	
    let salt:lbytes saltLen = createL [
        u8 0xef; u8 0x28; u8 0x69; u8 0xfa; u8 0x40; u8 0xc3; u8 0x46; u8 0xcb; u8 0x18; u8 0x3d; u8 0xab; u8 0x3d; u8 0x7b; u8 0xff; u8 0xc9; u8 0x8f; 
        u8 0xd5; u8 0x6d; u8 0xf4; u8 0x2d] in
    let sgnt_expected : lbytes nLen = createL [
        u8 0x62; u8 0xeb; u8 0xb8; u8 0x03; u8 0x3a; u8 0x2d; u8 0x0b; u8 0x8b; u8 0xec; u8 0x42; u8 0x56; u8 0x52; u8 0x29; u8 0x9b; u8 0x3f; u8 0x02;
        u8 0x8f; u8 0xa8; u8 0x0c; u8 0x28; u8 0x11; u8 0x0d; u8 0xf5; u8 0x37; u8 0x47; u8 0x2e; u8 0x5e; u8 0xd6; u8 0x28; u8 0x62; u8 0xb9; u8 0x98;
        u8 0x36; u8 0xe5; u8 0x7a; u8 0xa9; u8 0x8d; u8 0x4b; u8 0x94; u8 0x9a; u8 0x21; u8 0xf0; u8 0x21; u8 0xee; u8 0x33; u8 0x89; u8 0xff; u8 0x52;
        u8 0x66; u8 0xe0; u8 0x54; u8 0xd4; u8 0x4e; u8 0x8c; u8 0x92; u8 0x48; u8 0x0a; u8 0xc9; u8 0x10; u8 0x67; u8 0xde; u8 0xfb; u8 0xae; u8 0xd4;
        u8 0xdc; u8 0x3c; u8 0xe2; u8 0x43; u8 0xe8; u8 0x17; u8 0x52; u8 0x66; u8 0xd3; u8 0xec; u8 0x69; u8 0xfd; u8 0xb0; u8 0xed; u8 0xea; u8 0xc1;
        u8 0x1c; u8 0x8c; u8 0x9e; u8 0x3e; u8 0x99; u8 0x41; u8 0x54; u8 0xa9; u8 0x33; u8 0x95; u8 0xa5; u8 0x11; u8 0xb4; u8 0xa1; u8 0x72; u8 0xf6;
        u8 0x64; u8 0x4f; u8 0x37; u8 0xf6; u8 0x80; u8 0x7b; u8 0x86; u8 0x71; u8 0x6f; u8 0xc9; u8 0x07; u8 0xe1; u8 0xd0; u8 0xfc; u8 0x75; u8 0xbd;
        u8 0xa7; u8 0x7e; u8 0x41; u8 0x1b; u8 0xfc; u8 0x60; u8 0xfd; u8 0x2e; u8 0xd9; u8 0x27; u8 0x8e; u8 0x92; u8 0x1a; u8 0x33; u8 0x02; u8 0x1f] in
    let res = ctest 11 15 modBits n pkeyBits e skeyBits d pLen p qLen q rBlindLen rBlind msgLen msg saltLen salt sgnt_expected in
    res

val test2: unit -> ML bool
let test2() =
    let modBits = 1025 in
    let nLen = bits_to_text modBits in
    let n : lbytes nLen = createL [
        u8 0x01; u8 0xd4; u8 0x0c; u8 0x1b; u8 0xcf; u8 0x97; u8 0xa6; u8 0x8a; u8 0xe7; u8 0xcd; u8 0xbd; u8 0x8a; u8 0x7b; u8 0xf3; u8 0xe3; u8 0x4f;
        u8 0xa1; u8 0x9d; u8 0xcc; u8 0xa4; u8 0xef; u8 0x75; u8 0xa4; u8 0x74; u8 0x54; u8 0x37; u8 0x5f; u8 0x94; u8 0x51; u8 0x4d; u8 0x88; u8 0xfe;
        u8 0xd0; u8 0x06; u8 0xfb; u8 0x82; u8 0x9f; u8 0x84; u8 0x19; u8 0xff; u8 0x87; u8 0xd6; u8 0x31; u8 0x5d; u8 0xa6; u8 0x8a; u8 0x1f; u8 0xf3;
        u8 0xa0; u8 0x93; u8 0x8e; u8 0x9a; u8 0xbb; u8 0x34; u8 0x64; u8 0x01; u8 0x1c; u8 0x30; u8 0x3a; u8 0xd9; u8 0x91; u8 0x99; u8 0xcf; u8 0x0c;
        u8 0x7c; u8 0x7a; u8 0x8b; u8 0x47; u8 0x7d; u8 0xce; u8 0x82; u8 0x9e; u8 0x88; u8 0x44; u8 0xf6; u8 0x25; u8 0xb1; u8 0x15; u8 0xe5; u8 0xe9;
        u8 0xc4; u8 0xa5; u8 0x9c; u8 0xf8; u8 0xf8; u8 0x11; u8 0x3b; u8 0x68; u8 0x34; u8 0x33; u8 0x6a; u8 0x2f; u8 0xd2; u8 0x68; u8 0x9b; u8 0x47;
        u8 0x2c; u8 0xbb; u8 0x5e; u8 0x5c; u8 0xab; u8 0xe6; u8 0x74; u8 0x35; u8 0x0c; u8 0x59; u8 0xb6; u8 0xc1; u8 0x7e; u8 0x17; u8 0x68; u8 0x74;
        u8 0xfb; u8 0x42; u8 0xf8; u8 0xfc; u8 0x3d; u8 0x17; u8 0x6a; u8 0x01; u8 0x7e; u8 0xdc; u8 0x61; u8 0xfd; u8 0x32; u8 0x6c; u8 0x4b; u8 0x33;
        u8 0xc9 ] in
    let pkeyBits = 24 in
    let eLen = bits_to_text pkeyBits in
    let e : lbytes eLen = createL [u8 0x01; u8 0x00; u8 0x01] in
    let skeyBits = 1024  in
    let dLen = bits_to_text skeyBits in
    let d : lbytes dLen = createL [
        u8 0x02; u8 0x7d; u8 0x14; u8 0x7e; u8 0x46; u8 0x73; u8 0x05; u8 0x73; u8 0x77; u8 0xfd; u8 0x1e; u8 0xa2; u8 0x01; u8 0x56; u8 0x57; u8 0x72;
        u8 0x17; u8 0x6a; u8 0x7d; u8 0xc3; u8 0x83; u8 0x58; u8 0xd3; u8 0x76; u8 0x04; u8 0x56; u8 0x85; u8 0xa2; u8 0xe7; u8 0x87; u8 0xc2; u8 0x3c;
        u8 0x15; u8 0x57; u8 0x6b; u8 0xc1; u8 0x6b; u8 0x9f; u8 0x44; u8 0x44; u8 0x02; u8 0xd6; u8 0xbf; u8 0xc5; u8 0xd9; u8 0x8a; u8 0x3e; u8 0x88;
        u8 0xea; u8 0x13; u8 0xef; u8 0x67; u8 0xc3; u8 0x53; u8 0xec; u8 0xa0; u8 0xc0; u8 0xdd; u8 0xba; u8 0x92; u8 0x55; u8 0xbd; u8 0x7b; u8 0x8b;
        u8 0xb5; u8 0x0a; u8 0x64; u8 0x4a; u8 0xfd; u8 0xfd; u8 0x1d; u8 0xd5; u8 0x16; u8 0x95; u8 0xb2; u8 0x52; u8 0xd2; u8 0x2e; u8 0x73; u8 0x18;
        u8 0xd1; u8 0xb6; u8 0x68; u8 0x7a; u8 0x1c; u8 0x10; u8 0xff; u8 0x75; u8 0x54; u8 0x5f; u8 0x3d; u8 0xb0; u8 0xfe; u8 0x60; u8 0x2d; u8 0x5f;
        u8 0x2b; u8 0x7f; u8 0x29; u8 0x4e; u8 0x36; u8 0x01; u8 0xea; u8 0xb7; u8 0xb9; u8 0xd1; u8 0xce; u8 0xcd; u8 0x76; u8 0x7f; u8 0x64; u8 0x69;
        u8 0x2e; u8 0x3e; u8 0x53; u8 0x6c; u8 0xa2; u8 0x84; u8 0x6c; u8 0xb0; u8 0xc2; u8 0xdd; u8 0x48; u8 0x6a; u8 0x39; u8 0xfa; u8 0x75; u8 0xb1 ] in
    let pLen = 65 in
    let p : lbytes pLen = createL [
        u8 0x01; u8 0x66; u8 0x01; u8 0xe9; u8 0x26; u8 0xa0; u8 0xf8; u8 0xc9; u8 0xe2; u8 0x6e; u8 0xca; u8 0xb7; u8 0x69; u8 0xea; u8 0x65; u8 0xa5;
        u8 0xe7; u8 0xc5; u8 0x2c; u8 0xc9; u8 0xe0; u8 0x80; u8 0xef; u8 0x51; u8 0x94; u8 0x57; u8 0xc6; u8 0x44; u8 0xda; u8 0x68; u8 0x91; u8 0xc5;
        u8 0xa1; u8 0x04; u8 0xd3; u8 0xea; u8 0x79; u8 0x55; u8 0x92; u8 0x9a; u8 0x22; u8 0xe7; u8 0xc6; u8 0x8a; u8 0x7a; u8 0xf9; u8 0xfc; u8 0xad;
        u8 0x77; u8 0x7c; u8 0x3c; u8 0xcc; u8 0x2b; u8 0x9e; u8 0x3d; u8 0x36; u8 0x50; u8 0xbc; u8 0xe4; u8 0x04; u8 0x39; u8 0x9b; u8 0x7e; u8 0x59;
        u8 0xd1 ] in
    let qLen = 65 in
    let q : lbytes qLen = createL [
        u8 0x01; u8 0x4e; u8 0xaf; u8 0xa1; u8 0xd4; u8 0xd0; u8 0x18; u8 0x4d; u8 0xa7; u8 0xe3; u8 0x1f; u8 0x87; u8 0x7d; u8 0x12; u8 0x81; u8 0xdd;
        u8 0xda; u8 0x62; u8 0x56; u8 0x64; u8 0x86; u8 0x9e; u8 0x83; u8 0x79; u8 0xe6; u8 0x7a; u8 0xd3; u8 0xb7; u8 0x5e; u8 0xae; u8 0x74; u8 0xa5;
        u8 0x80; u8 0xe9; u8 0x82; u8 0x7a; u8 0xbd; u8 0x6e; u8 0xb7; u8 0xa0; u8 0x02; u8 0xcb; u8 0x54; u8 0x11; u8 0xf5; u8 0x26; u8 0x67; u8 0x97;
        u8 0x76; u8 0x8f; u8 0xb8; u8 0xe9; u8 0x5a; u8 0xe4; u8 0x0e; u8 0x3e; u8 0x8a; u8 0x01; u8 0xf3; u8 0x5f; u8 0xf8; u8 0x9e; u8 0x56; u8 0xc0;
        u8 0x79 ] in
    let rBlindLen = 8 in
    let rBlind : lbytes rBlindLen = createL [u8 0xbb; u8 0x34; u8 0x64; u8 0x01; u8 0x1c; u8 0x30; u8 0x3a; u8 0xd9] in
    let msgLen = 234 in
    let msg : lbytes msgLen = createL [
        u8 0xe4; u8 0xf8; u8 0x60; u8 0x1a; u8 0x8a; u8 0x6d; u8 0xa1; u8 0xbe; u8 0x34; u8 0x44; u8 0x7c; u8 0x09; u8 0x59; u8 0xc0; u8 0x58; u8 0x57;
        u8 0x0c; u8 0x36; u8 0x68; u8 0xcf; u8 0xd5; u8 0x1d; u8 0xd5; u8 0xf9; u8 0xcc; u8 0xd6; u8 0xad; u8 0x44; u8 0x11; u8 0xfe; u8 0x82; u8 0x13;
        u8 0x48; u8 0x6d; u8 0x78; u8 0xa6; u8 0xc4; u8 0x9f; u8 0x93; u8 0xef; u8 0xc2; u8 0xca; u8 0x22; u8 0x88; u8 0xce; u8 0xbc; u8 0x2b; u8 0x9b;
        u8 0x60; u8 0xbd; u8 0x04; u8 0xb1; u8 0xe2; u8 0x20; u8 0xd8; u8 0x6e; u8 0x3d; u8 0x48; u8 0x48; u8 0xd7; u8 0x09; u8 0xd0; u8 0x32; u8 0xd1;
        u8 0xe8; u8 0xc6; u8 0xa0; u8 0x70; u8 0xc6; u8 0xaf; u8 0x9a; u8 0x49; u8 0x9f; u8 0xcf; u8 0x95; u8 0x35; u8 0x4b; u8 0x14; u8 0xba; u8 0x61;
        u8 0x27; u8 0xc7; u8 0x39; u8 0xde; u8 0x1b; u8 0xb0; u8 0xfd; u8 0x16; u8 0x43; u8 0x1e; u8 0x46; u8 0x93; u8 0x8a; u8 0xec; u8 0x0c; u8 0xf8;
        u8 0xad; u8 0x9e; u8 0xb7; u8 0x2e; u8 0x83; u8 0x2a; u8 0x70; u8 0x35; u8 0xde; u8 0x9b; u8 0x78; u8 0x07; u8 0xbd; u8 0xc0; u8 0xed; u8 0x8b;
        u8 0x68; u8 0xeb; u8 0x0f; u8 0x5a; u8 0xc2; u8 0x21; u8 0x6b; u8 0xe4; u8 0x0c; u8 0xe9; u8 0x20; u8 0xc0; u8 0xdb; u8 0x0e; u8 0xdd; u8 0xd3;
        u8 0x86; u8 0x0e; u8 0xd7; u8 0x88; u8 0xef; u8 0xac; u8 0xca; u8 0xca; u8 0x50; u8 0x2d; u8 0x8f; u8 0x2b; u8 0xd6; u8 0xd1; u8 0xa7; u8 0xc1;
        u8 0xf4; u8 0x1f; u8 0xf4; u8 0x6f; u8 0x16; u8 0x81; u8 0xc8; u8 0xf1; u8 0xf8; u8 0x18; u8 0xe9; u8 0xc4; u8 0xf6; u8 0xd9; u8 0x1a; u8 0x0c;
        u8 0x78; u8 0x03; u8 0xcc; u8 0xc6; u8 0x3d; u8 0x76; u8 0xa6; u8 0x54; u8 0x4d; u8 0x84; u8 0x3e; u8 0x08; u8 0x4e; u8 0x36; u8 0x3b; u8 0x8a;
        u8 0xcc; u8 0x55; u8 0xaa; u8 0x53; u8 0x17; u8 0x33; u8 0xed; u8 0xb5; u8 0xde; u8 0xe5; u8 0xb5; u8 0x19; u8 0x6e; u8 0x9f; u8 0x03; u8 0xe8;
        u8 0xb7; u8 0x31; u8 0xb3; u8 0x77; u8 0x64; u8 0x28; u8 0xd9; u8 0xe4; u8 0x57; u8 0xfe; u8 0x3f; u8 0xbc; u8 0xb3; u8 0xdb; u8 0x72; u8 0x74;
        u8 0x44; u8 0x2d; u8 0x78; u8 0x58; u8 0x90; u8 0xe9; u8 0xcb; u8 0x08; u8 0x54; u8 0xb6; u8 0x44; u8 0x4d; u8 0xac; u8 0xe7; u8 0x91; u8 0xd7;
        u8 0x27; u8 0x3d; u8 0xe1; u8 0x88; u8 0x97; u8 0x19; u8 0x33; u8 0x8a; u8 0x77; u8 0xfe ] in
    let saltLen = 20 in
    let salt : lbytes saltLen = createL [
        u8 0x7f; u8 0x6d; u8 0xd3; u8 0x59; u8 0xe6; u8 0x04; u8 0xe6; u8 0x08; u8 0x70; u8 0xe8; u8 0x98; u8 0xe4; u8 0x7b; u8 0x19; u8 0xbf; u8 0x2e;
        u8 0x5a; u8 0x7b; u8 0x2a; u8 0x90] in
    let sgnt_expected : lbytes nLen = createL [
        u8 0x01; u8 0x90; u8 0x44; u8 0x7a; u8 0x91; u8 0xa3; u8 0xef; u8 0x1e; u8 0x9a; u8 0x36; u8 0x44; u8 0xb2; u8 0x2d; u8 0xb0; u8 0x9d; u8 0xb3;
        u8 0x7b; u8 0x45; u8 0xe1; u8 0xd5; u8 0xfa; u8 0x2e; u8 0xa0; u8 0x8a; u8 0xec; u8 0x35; u8 0xd9; u8 0x81; u8 0x54; u8 0xc5; u8 0x2f; u8 0x31;
        u8 0x5d; u8 0x4a; u8 0x71; u8 0x26; u8 0x70; u8 0xa2; u8 0x7e; u8 0xc4; u8 0xe5; u8 0xe3; u8 0xa0; u8 0x96; u8 0xf2; u8 0xe1; u8 0x0a; u8 0xa6;
        u8 0x23; u8 0x90; u8 0x66; u8 0x40; u8 0x42; u8 0xc7; u8 0xb6; u8 0xb8; u8 0x2f; u8 0x24; u8 0x79; u8 0x70; u8 0xc6; u8 0x74; u8 0xf0; u8 0xca;
        u8 0x79; u8 0x57; u8 0xb9; u8 0xe0; u8 0xf3; u8 0x0b; u8 0x23; u8 0x39; u8 0x07; u8 0x71; u8 0xee; u8 0x4a; u8 0x67; u8 0xd9; u8 0x1b; u8 0x30;
        u8 0x39; u8 0xc6; u8 0x45; u8 0xee; u8 0x63; u8 0x7f; u8 0x50; u8 0x84; u8 0x20; u8 0x2d; u8 0x5b; u8 0x03; u8 0x03; u8 0xd5; u8 0x46; u8 0x6d;
        u8 0x92; u8 0x72; u8 0xc5; u8 0xd7; u8 0x73; u8 0x36; u8 0x8a; u8 0xbc; u8 0x06; u8 0x84; u8 0xd6; u8 0xbc; u8 0xc1; u8 0x9d; u8 0x30; u8 0x27;
        u8 0x73; u8 0x24; u8 0x54; u8 0x3e; u8 0xcd; u8 0xaf; u8 0x56; u8 0xf7; u8 0x44; u8 0x6e; u8 0x20; u8 0x79; u8 0xb8; u8 0x9c; u8 0xc4; u8 0x8f;
        u8 0x2d ] in
    let res = ctest 11 15 modBits n pkeyBits e skeyBits d pLen p qLen q rBlindLen rBlind msgLen msg saltLen salt sgnt_expected in
    res

val test3: unit -> ML bool
let test3() =
    let modBits = 1536 in
    let nLen = bits_to_text modBits in
    let n :lbytes nLen = createL [
        u8 0xe6; u8 0xbd; u8 0x69; u8 0x2a; u8 0xc9; u8 0x66; u8 0x45; u8 0x79; u8 0x04; u8 0x03; u8 0xfd; u8 0xd0; u8 0xf5; u8 0xbe; u8 0xb8; u8 0xb9;
        u8 0xbf; u8 0x92; u8 0xed; u8 0x10; u8 0x00; u8 0x7f; u8 0xc3; u8 0x65; u8 0x04; u8 0x64; u8 0x19; u8 0xdd; u8 0x06; u8 0xc0; u8 0x5c; u8 0x5b;
        u8 0x5b; u8 0x2f; u8 0x48; u8 0xec; u8 0xf9; u8 0x89; u8 0xe4; u8 0xce; u8 0x26; u8 0x91; u8 0x09; u8 0x97; u8 0x9c; u8 0xbb; u8 0x40; u8 0xb4;
        u8 0xa0; u8 0xad; u8 0x24; u8 0xd2; u8 0x24; u8 0x83; u8 0xd1; u8 0xee; u8 0x31; u8 0x5a; u8 0xd4; u8 0xcc; u8 0xb1; u8 0x53; u8 0x42; u8 0x68;
        u8 0x35; u8 0x26; u8 0x91; u8 0xc5; u8 0x24; u8 0xf6; u8 0xdd; u8 0x8e; u8 0x6c; u8 0x29; u8 0xd2; u8 0x24; u8 0xcf; u8 0x24; u8 0x69; u8 0x73;
        u8 0xae; u8 0xc8; u8 0x6c; u8 0x5b; u8 0xf6; u8 0xb1; u8 0x40; u8 0x1a; u8 0x85; u8 0x0d; u8 0x1b; u8 0x9a; u8 0xd1; u8 0xbb; u8 0x8c; u8 0xbc;
        u8 0xec; u8 0x47; u8 0xb0; u8 0x6f; u8 0x0f; u8 0x8c; u8 0x7f; u8 0x45; u8 0xd3; u8 0xfc; u8 0x8f; u8 0x31; u8 0x92; u8 0x99; u8 0xc5; u8 0x43;
        u8 0x3d; u8 0xdb; u8 0xc2; u8 0xb3; u8 0x05; u8 0x3b; u8 0x47; u8 0xde; u8 0xd2; u8 0xec; u8 0xd4; u8 0xa4; u8 0xca; u8 0xef; u8 0xd6; u8 0x14;
        u8 0x83; u8 0x3d; u8 0xc8; u8 0xbb; u8 0x62; u8 0x2f; u8 0x31; u8 0x7e; u8 0xd0; u8 0x76; u8 0xb8; u8 0x05; u8 0x7f; u8 0xe8; u8 0xde; u8 0x3f;
        u8 0x84; u8 0x48; u8 0x0a; u8 0xd5; u8 0xe8; u8 0x3e; u8 0x4a; u8 0x61; u8 0x90; u8 0x4a; u8 0x4f; u8 0x24; u8 0x8f; u8 0xb3; u8 0x97; u8 0x02;
        u8 0x73; u8 0x57; u8 0xe1; u8 0xd3; u8 0x0e; u8 0x46; u8 0x31; u8 0x39; u8 0x81; u8 0x5c; u8 0x6f; u8 0xd4; u8 0xfd; u8 0x5a; u8 0xc5; u8 0xb8;
        u8 0x17; u8 0x2a; u8 0x45; u8 0x23; u8 0x0e; u8 0xcb; u8 0x63; u8 0x18; u8 0xa0; u8 0x4f; u8 0x14; u8 0x55; u8 0xd8; u8 0x4e; u8 0x5a; u8 0x8b] in
    let pkeyBits = 24 in
    let eLen = bits_to_text pkeyBits in
    let e : lbytes eLen = createL [u8 0x01; u8 0x00; u8 0x01] in
    let skeyBits = 1536 in 
    let dLen = bits_to_text skeyBits in
    let d : lbytes dLen = createL [
        u8 0x6a; u8 0x7f; u8 0xd8; u8 0x4f; u8 0xb8; u8 0x5f; u8 0xad; u8 0x07; u8 0x3b; u8 0x34; u8 0x40; u8 0x6d; u8 0xb7; u8 0x4f; u8 0x8d; u8 0x61;
        u8 0xa6; u8 0xab; u8 0xc1; u8 0x21; u8 0x96; u8 0xa9; u8 0x61; u8 0xdd; u8 0x79; u8 0x56; u8 0x5e; u8 0x9d; u8 0xa6; u8 0xe5; u8 0x18; u8 0x7b;
        u8 0xce; u8 0x2d; u8 0x98; u8 0x02; u8 0x50; u8 0xf7; u8 0x35; u8 0x95; u8 0x75; u8 0x35; u8 0x92; u8 0x70; u8 0xd9; u8 0x15; u8 0x90; u8 0xbb;
        u8 0x0e; u8 0x42; u8 0x7c; u8 0x71; u8 0x46; u8 0x0b; u8 0x55; u8 0xd5; u8 0x14; u8 0x10; u8 0xb1; u8 0x91; u8 0xbc; u8 0xf3; u8 0x09; u8 0xfe;
        u8 0xa1; u8 0x31; u8 0xa9; u8 0x2c; u8 0x8e; u8 0x70; u8 0x27; u8 0x38; u8 0xfa; u8 0x71; u8 0x9f; u8 0x1e; u8 0x00; u8 0x41; u8 0xf5; u8 0x2e;
        u8 0x40; u8 0xe9; u8 0x1f; u8 0x22; u8 0x9f; u8 0x4d; u8 0x96; u8 0xa1; u8 0xe6; u8 0xf1; u8 0x72; u8 0xe1; u8 0x55; u8 0x96; u8 0xb4; u8 0x51;
        u8 0x0a; u8 0x6d; u8 0xae; u8 0xc2; u8 0x61; u8 0x05; u8 0xf2; u8 0xbe; u8 0xbc; u8 0x53; u8 0x31; u8 0x6b; u8 0x87; u8 0xbd; u8 0xf2; u8 0x13;
        u8 0x11; u8 0x66; u8 0x60; u8 0x70; u8 0xe8; u8 0xdf; u8 0xee; u8 0x69; u8 0xd5; u8 0x2c; u8 0x71; u8 0xa9; u8 0x76; u8 0xca; u8 0xae; u8 0x79;
        u8 0xc7; u8 0x2b; u8 0x68; u8 0xd2; u8 0x85; u8 0x80; u8 0xdc; u8 0x68; u8 0x6d; u8 0x9f; u8 0x51; u8 0x29; u8 0xd2; u8 0x25; u8 0xf8; u8 0x2b;
        u8 0x3d; u8 0x61; u8 0x55; u8 0x13; u8 0xa8; u8 0x82; u8 0xb3; u8 0xdb; u8 0x91; u8 0x41; u8 0x6b; u8 0x48; u8 0xce; u8 0x08; u8 0x88; u8 0x82;
        u8 0x13; u8 0xe3; u8 0x7e; u8 0xeb; u8 0x9a; u8 0xf8; u8 0x00; u8 0xd8; u8 0x1c; u8 0xab; u8 0x32; u8 0x8c; u8 0xe4; u8 0x20; u8 0x68; u8 0x99;
        u8 0x03; u8 0xc0; u8 0x0c; u8 0x7b; u8 0x5f; u8 0xd3; u8 0x1b; u8 0x75; u8 0x50; u8 0x3a; u8 0x6d; u8 0x41; u8 0x96; u8 0x84; u8 0xd6; u8 0x29 ] in
    let pLen = 96 in
    let p : lbytes pLen = createL [
        u8 0xf8; u8 0xeb; u8 0x97; u8 0xe9; u8 0x8d; u8 0xf1; u8 0x26; u8 0x64; u8 0xee; u8 0xfd; u8 0xb7; u8 0x61; u8 0x59; u8 0x6a; u8 0x69; u8 0xdd;
        u8 0xcd; u8 0x0e; u8 0x76; u8 0xda; u8 0xec; u8 0xe6; u8 0xed; u8 0x4b; u8 0xf5; u8 0xa1; u8 0xb5; u8 0x0a; u8 0xc0; u8 0x86; u8 0xf7; u8 0x92;
        u8 0x8a; u8 0x4d; u8 0x2f; u8 0x87; u8 0x26; u8 0xa7; u8 0x7e; u8 0x51; u8 0x5b; u8 0x74; u8 0xda; u8 0x41; u8 0x98; u8 0x8f; u8 0x22; u8 0x0b;
        u8 0x1c; u8 0xc8; u8 0x7a; u8 0xa1; u8 0xfc; u8 0x81; u8 0x0c; u8 0xe9; u8 0x9a; u8 0x82; u8 0xf2; u8 0xd1; u8 0xce; u8 0x82; u8 0x1e; u8 0xdc;
        u8 0xed; u8 0x79; u8 0x4c; u8 0x69; u8 0x41; u8 0xf4; u8 0x2c; u8 0x7a; u8 0x1a; u8 0x0b; u8 0x8c; u8 0x4d; u8 0x28; u8 0xc7; u8 0x5e; u8 0xc6;
        u8 0x0b; u8 0x65; u8 0x22; u8 0x79; u8 0xf6; u8 0x15; u8 0x4a; u8 0x76; u8 0x2a; u8 0xed; u8 0x16; u8 0x5d; u8 0x47; u8 0xde; u8 0xe3; u8 0x67 ] in
    let qLen = 96 in
    let q : lbytes qLen = createL [
        u8 0xed; u8 0x4d; u8 0x71; u8 0xd0; u8 0xa6; u8 0xe2; u8 0x4b; u8 0x93; u8 0xc2; u8 0xe5; u8 0xf6; u8 0xb4; u8 0xbb; u8 0xe0; u8 0x5f; u8 0x5f;
        u8 0xb0; u8 0xaf; u8 0xa0; u8 0x42; u8 0xd2; u8 0x04; u8 0xfe; u8 0x33; u8 0x78; u8 0xd3; u8 0x65; u8 0xc2; u8 0xf2; u8 0x88; u8 0xb6; u8 0xa8;
        u8 0xda; u8 0xd7; u8 0xef; u8 0xe4; u8 0x5d; u8 0x15; u8 0x3e; u8 0xef; u8 0x40; u8 0xca; u8 0xcc; u8 0x7b; u8 0x81; u8 0xff; u8 0x93; u8 0x40;
        u8 0x02; u8 0xd1; u8 0x08; u8 0x99; u8 0x4b; u8 0x94; u8 0xa5; u8 0xe4; u8 0x72; u8 0x8c; u8 0xd9; u8 0xc9; u8 0x63; u8 0x37; u8 0x5a; u8 0xe4;
        u8 0x99; u8 0x65; u8 0xbd; u8 0xa5; u8 0x5c; u8 0xbf; u8 0x0e; u8 0xfe; u8 0xd8; u8 0xd6; u8 0x55; u8 0x3b; u8 0x40; u8 0x27; u8 0xf2; u8 0xd8;
        u8 0x62; u8 0x08; u8 0xa6; u8 0xe6; u8 0xb4; u8 0x89; u8 0xc1; u8 0x76; u8 0x12; u8 0x80; u8 0x92; u8 0xd6; u8 0x29; u8 0xe4; u8 0x9d; u8 0x3d ] in
    let rBlindLen = 8 in
    let rBlind : lbytes rBlindLen = createL [u8 0x35; u8 0x26; u8 0x91; u8 0xc5; u8 0x24; u8 0xf6; u8 0xdd; u8 0x8e] in
    let msgLen = 107 in
    let msg : lbytes msgLen = createL [
        u8 0xc8; u8 0xc9; u8 0xc6; u8 0xaf; u8 0x04; u8 0xac; u8 0xda; u8 0x41; u8 0x4d; u8 0x22; u8 0x7e; u8 0xf2; u8 0x3e; u8 0x08; u8 0x20; u8 0xc3;
        u8 0x73; u8 0x2c; u8 0x50; u8 0x0d; u8 0xc8; u8 0x72; u8 0x75; u8 0xe9; u8 0x5b; u8 0x0d; u8 0x09; u8 0x54; u8 0x13; u8 0x99; u8 0x3c; u8 0x26;
        u8 0x58; u8 0xbc; u8 0x1d; u8 0x98; u8 0x85; u8 0x81; u8 0xba; u8 0x87; u8 0x9c; u8 0x2d; u8 0x20; u8 0x1f; u8 0x14; u8 0xcb; u8 0x88; u8 0xce;
        u8 0xd1; u8 0x53; u8 0xa0; u8 0x19; u8 0x69; u8 0xa7; u8 0xbf; u8 0x0a; u8 0x7b; u8 0xe7; u8 0x9c; u8 0x84; u8 0xc1; u8 0x48; u8 0x6b; u8 0xc1;
        u8 0x2b; u8 0x3f; u8 0xa6; u8 0xc5; u8 0x98; u8 0x71; u8 0xb6; u8 0x82; u8 0x7c; u8 0x8c; u8 0xe2; u8 0x53; u8 0xca; u8 0x5f; u8 0xef; u8 0xa8;
        u8 0xa8; u8 0xc6; u8 0x90; u8 0xbf; u8 0x32; u8 0x6e; u8 0x8e; u8 0x37; u8 0xcd; u8 0xb9; u8 0x6d; u8 0x90; u8 0xa8; u8 0x2e; u8 0xba; u8 0xb6;
        u8 0x9f; u8 0x86; u8 0x35; u8 0x0e; u8 0x18; u8 0x22; u8 0xe8; u8 0xbd; u8 0x53; u8 0x6a; u8 0x2e ] in
    let saltLen = 20 in
    let salt : lbytes saltLen = createL [
        u8 0xb3; u8 0x07; u8 0xc4; u8 0x3b; u8 0x48; u8 0x50; u8 0xa8; u8 0xda; u8 0xc2; u8 0xf1; u8 0x5f; u8 0x32; u8 0xe3; u8 0x78; u8 0x39; u8 0xef;
        u8 0x8c; u8 0x5c; u8 0x0e; u8 0x91] in
    let sgnt_expected : lbytes nLen = createL [
        u8 0x0c; u8 0x58; u8 0xaa; u8 0x0a; u8 0x5d; u8 0xe6; u8 0xd8; u8 0xa0; u8 0x0b; u8 0xb6; u8 0xac; u8 0x2d; u8 0x5c; u8 0x04; u8 0xfb; u8 0x0f;
        u8 0xa3; u8 0x01; u8 0x12; u8 0x49; u8 0x3b; u8 0xde; u8 0x42; u8 0x28; u8 0x8a; u8 0x5b; u8 0xad; u8 0x5c; u8 0x7b; u8 0x4b; u8 0x51; u8 0x8e;
        u8 0x21; u8 0xf3; u8 0x1c; u8 0x18; u8 0x54; u8 0x71; u8 0xb5; u8 0x9f; u8 0x87; u8 0x33; u8 0xc1; u8 0x3f; u8 0xe4; u8 0xc7; u8 0xfe; u8 0xc4;
        u8 0xa2; u8 0x4d; u8 0x0d; u8 0x0c; u8 0xd6; u8 0x62; u8 0xec; u8 0xd5; u8 0xe7; u8 0x21; u8 0xb0; u8 0x53; u8 0x62; u8 0xd9; u8 0xb6; u8 0x72;
        u8 0xa3; u8 0xd8; u8 0x26; u8 0x82; u8 0x55; u8 0x2c; u8 0x58; u8 0x30; u8 0x0d; u8 0xa6; u8 0x14; u8 0x65; u8 0x66; u8 0x38; u8 0xe6; u8 0x61;
        u8 0x83; u8 0x9d; u8 0x33; u8 0xb4; u8 0xd3; u8 0xd3; u8 0x7e; u8 0x0f; u8 0xce; u8 0x8b; u8 0xa0; u8 0xe4; u8 0x93; u8 0xd0; u8 0x2b; u8 0xc4;
        u8 0x73; u8 0xf8; u8 0x53; u8 0x78; u8 0x71; u8 0xbb; u8 0x56; u8 0x55; u8 0xc6; u8 0x94; u8 0x07; u8 0xb3; u8 0x62; u8 0xe0; u8 0x73; u8 0x90;
        u8 0x07; u8 0xe0; u8 0x36; u8 0x7a; u8 0x39; u8 0xc0; u8 0x38; u8 0xce; u8 0xd3; u8 0x7f; u8 0xf4; u8 0xfb; u8 0x9f; u8 0x16; u8 0x0d; u8 0x4d;
        u8 0x06; u8 0x39; u8 0x62; u8 0x17; u8 0x31; u8 0x5e; u8 0xe8; u8 0xd7; u8 0x5d; u8 0x91; u8 0x0b; u8 0x51; u8 0x28; u8 0x45; u8 0xf9; u8 0x70;
        u8 0xfe; u8 0x74; u8 0xe4; u8 0x12; u8 0x26; u8 0x84; u8 0x71; u8 0xc9; u8 0x51; u8 0x81; u8 0x62; u8 0x51; u8 0x6c; u8 0xd6; u8 0xf9; u8 0x66;
        u8 0x89; u8 0x2a; u8 0x74; u8 0x0e; u8 0x1b; u8 0x8a; u8 0x88; u8 0x76; u8 0x6a; u8 0x30; u8 0xfc; u8 0xe9; u8 0xb6; u8 0x0e; u8 0x03; u8 0x32;
        u8 0xd7; u8 0xa0; u8 0x1b; u8 0xa5; u8 0xfa; u8 0x13; u8 0x5f; u8 0xe7; u8 0xc4; u8 0x92; u8 0x72; u8 0xac; u8 0xbb; u8 0x1d; u8 0x30; u8 0xf1] in
    let res = ctest 11 7 modBits n pkeyBits e skeyBits d pLen p qLen q rBlindLen rBlind msgLen msg saltLen salt sgnt_expected in
    res

val test4: unit -> ML bool
let test4() =
    let modBits = 2048 in
    let nLen = bits_to_text modBits in
    let n : lbytes nLen = createL [
        u8 0xa5; u8 0xdd; u8 0x86; u8 0x7a; u8 0xc4; u8 0xcb; u8 0x02; u8 0xf9; u8 0x0b; u8 0x94; u8 0x57; u8 0xd4; u8 0x8c; u8 0x14; u8 0xa7; u8 0x70;
        u8 0xef; u8 0x99; u8 0x1c; u8 0x56; u8 0xc3; u8 0x9c; u8 0x0e; u8 0xc6; u8 0x5f; u8 0xd1; u8 0x1a; u8 0xfa; u8 0x89; u8 0x37; u8 0xce; u8 0xa5;
        u8 0x7b; u8 0x9b; u8 0xe7; u8 0xac; u8 0x73; u8 0xb4; u8 0x5c; u8 0x00; u8 0x17; u8 0x61; u8 0x5b; u8 0x82; u8 0xd6; u8 0x22; u8 0xe3; u8 0x18;
        u8 0x75; u8 0x3b; u8 0x60; u8 0x27; u8 0xc0; u8 0xfd; u8 0x15; u8 0x7b; u8 0xe1; u8 0x2f; u8 0x80; u8 0x90; u8 0xfe; u8 0xe2; u8 0xa7; u8 0xad;
        u8 0xcd; u8 0x0e; u8 0xef; u8 0x75; u8 0x9f; u8 0x88; u8 0xba; u8 0x49; u8 0x97; u8 0xc7; u8 0xa4; u8 0x2d; u8 0x58; u8 0xc9; u8 0xaa; u8 0x12;
        u8 0xcb; u8 0x99; u8 0xae; u8 0x00; u8 0x1f; u8 0xe5; u8 0x21; u8 0xc1; u8 0x3b; u8 0xb5; u8 0x43; u8 0x14; u8 0x45; u8 0xa8; u8 0xd5; u8 0xae;
        u8 0x4f; u8 0x5e; u8 0x4c; u8 0x7e; u8 0x94; u8 0x8a; u8 0xc2; u8 0x27; u8 0xd3; u8 0x60; u8 0x40; u8 0x71; u8 0xf2; u8 0x0e; u8 0x57; u8 0x7e;
        u8 0x90; u8 0x5f; u8 0xbe; u8 0xb1; u8 0x5d; u8 0xfa; u8 0xf0; u8 0x6d; u8 0x1d; u8 0xe5; u8 0xae; u8 0x62; u8 0x53; u8 0xd6; u8 0x3a; u8 0x6a;
        u8 0x21; u8 0x20; u8 0xb3; u8 0x1a; u8 0x5d; u8 0xa5; u8 0xda; u8 0xbc; u8 0x95; u8 0x50; u8 0x60; u8 0x0e; u8 0x20; u8 0xf2; u8 0x7d; u8 0x37;
        u8 0x39; u8 0xe2; u8 0x62; u8 0x79; u8 0x25; u8 0xfe; u8 0xa3; u8 0xcc; u8 0x50; u8 0x9f; u8 0x21; u8 0xdf; u8 0xf0; u8 0x4e; u8 0x6e; u8 0xea;
        u8 0x45; u8 0x49; u8 0xc5; u8 0x40; u8 0xd6; u8 0x80; u8 0x9f; u8 0xf9; u8 0x30; u8 0x7e; u8 0xed; u8 0xe9; u8 0x1f; u8 0xff; u8 0x58; u8 0x73;
        u8 0x3d; u8 0x83; u8 0x85; u8 0xa2; u8 0x37; u8 0xd6; u8 0xd3; u8 0x70; u8 0x5a; u8 0x33; u8 0xe3; u8 0x91; u8 0x90; u8 0x09; u8 0x92; u8 0x07;
        u8 0x0d; u8 0xf7; u8 0xad; u8 0xf1; u8 0x35; u8 0x7c; u8 0xf7; u8 0xe3; u8 0x70; u8 0x0c; u8 0xe3; u8 0x66; u8 0x7d; u8 0xe8; u8 0x3f; u8 0x17;
        u8 0xb8; u8 0xdf; u8 0x17; u8 0x78; u8 0xdb; u8 0x38; u8 0x1d; u8 0xce; u8 0x09; u8 0xcb; u8 0x4a; u8 0xd0; u8 0x58; u8 0xa5; u8 0x11; u8 0x00;
        u8 0x1a; u8 0x73; u8 0x81; u8 0x98; u8 0xee; u8 0x27; u8 0xcf; u8 0x55; u8 0xa1; u8 0x3b; u8 0x75; u8 0x45; u8 0x39; u8 0x90; u8 0x65; u8 0x82;
        u8 0xec; u8 0x8b; u8 0x17; u8 0x4b; u8 0xd5; u8 0x8d; u8 0x5d; u8 0x1f; u8 0x3d; u8 0x76; u8 0x7c; u8 0x61; u8 0x37; u8 0x21; u8 0xae; u8 0x05] in
    let pkeyBits = 24 in
    let eLen = bits_to_text pkeyBits in
    let e : lbytes eLen = createL [u8 0x01; u8 0x00; u8 0x01] in
    let skeyBits = 2048 in
    let dLen = bits_to_text skeyBits in
    let d : lbytes dLen = createL [
        u8 0x2d; u8 0x2f; u8 0xf5; u8 0x67; u8 0xb3; u8 0xfe; u8 0x74; u8 0xe0; u8 0x61; u8 0x91; u8 0xb7; u8 0xfd; u8 0xed; u8 0x6d; u8 0xe1; u8 0x12;
        u8 0x29; u8 0x0c; u8 0x67; u8 0x06; u8 0x92; u8 0x43; u8 0x0d; u8 0x59; u8 0x69; u8 0x18; u8 0x40; u8 0x47; u8 0xda; u8 0x23; u8 0x4c; u8 0x96;
        u8 0x93; u8 0xde; u8 0xed; u8 0x16; u8 0x73; u8 0xed; u8 0x42; u8 0x95; u8 0x39; u8 0xc9; u8 0x69; u8 0xd3; u8 0x72; u8 0xc0; u8 0x4d; u8 0x6b;
        u8 0x47; u8 0xe0; u8 0xf5; u8 0xb8; u8 0xce; u8 0xe0; u8 0x84; u8 0x3e; u8 0x5c; u8 0x22; u8 0x83; u8 0x5d; u8 0xbd; u8 0x3b; u8 0x05; u8 0xa0;
        u8 0x99; u8 0x79; u8 0x84; u8 0xae; u8 0x60; u8 0x58; u8 0xb1; u8 0x1b; u8 0xc4; u8 0x90; u8 0x7c; u8 0xbf; u8 0x67; u8 0xed; u8 0x84; u8 0xfa;
        u8 0x9a; u8 0xe2; u8 0x52; u8 0xdf; u8 0xb0; u8 0xd0; u8 0xcd; u8 0x49; u8 0xe6; u8 0x18; u8 0xe3; u8 0x5d; u8 0xfd; u8 0xfe; u8 0x59; u8 0xbc;
        u8 0xa3; u8 0xdd; u8 0xd6; u8 0x6c; u8 0x33; u8 0xce; u8 0xbb; u8 0xc7; u8 0x7a; u8 0xd4; u8 0x41; u8 0xaa; u8 0x69; u8 0x5e; u8 0x13; u8 0xe3;
        u8 0x24; u8 0xb5; u8 0x18; u8 0xf0; u8 0x1c; u8 0x60; u8 0xf5; u8 0xa8; u8 0x5c; u8 0x99; u8 0x4a; u8 0xd1; u8 0x79; u8 0xf2; u8 0xa6; u8 0xb5;
        u8 0xfb; u8 0xe9; u8 0x34; u8 0x02; u8 0xb1; u8 0x17; u8 0x67; u8 0xbe; u8 0x01; u8 0xbf; u8 0x07; u8 0x34; u8 0x44; u8 0xd6; u8 0xba; u8 0x1d;
        u8 0xd2; u8 0xbc; u8 0xa5; u8 0xbd; u8 0x07; u8 0x4d; u8 0x4a; u8 0x5f; u8 0xae; u8 0x35; u8 0x31; u8 0xad; u8 0x13; u8 0x03; u8 0xd8; u8 0x4b;
        u8 0x30; u8 0xd8; u8 0x97; u8 0x31; u8 0x8c; u8 0xbb; u8 0xba; u8 0x04; u8 0xe0; u8 0x3c; u8 0x2e; u8 0x66; u8 0xde; u8 0x6d; u8 0x91; u8 0xf8;
        u8 0x2f; u8 0x96; u8 0xea; u8 0x1d; u8 0x4b; u8 0xb5; u8 0x4a; u8 0x5a; u8 0xae; u8 0x10; u8 0x2d; u8 0x59; u8 0x46; u8 0x57; u8 0xf5; u8 0xc9;
        u8 0x78; u8 0x95; u8 0x53; u8 0x51; u8 0x2b; u8 0x29; u8 0x6d; u8 0xea; u8 0x29; u8 0xd8; u8 0x02; u8 0x31; u8 0x96; u8 0x35; u8 0x7e; u8 0x3e;
        u8 0x3a; u8 0x6e; u8 0x95; u8 0x8f; u8 0x39; u8 0xe3; u8 0xc2; u8 0x34; u8 0x40; u8 0x38; u8 0xea; u8 0x60; u8 0x4b; u8 0x31; u8 0xed; u8 0xc6;
        u8 0xf0; u8 0xf7; u8 0xff; u8 0x6e; u8 0x71; u8 0x81; u8 0xa5; u8 0x7c; u8 0x92; u8 0x82; u8 0x6a; u8 0x26; u8 0x8f; u8 0x86; u8 0x76; u8 0x8e;
        u8 0x96; u8 0xf8; u8 0x78; u8 0x56; u8 0x2f; u8 0xc7; u8 0x1d; u8 0x85; u8 0xd6; u8 0x9e; u8 0x44; u8 0x86; u8 0x12; u8 0xf7; u8 0x04; u8 0x8f] in
    let pLen = 128 in
    let p : lbytes pLen = createL [
        u8 0xcf; u8 0xd5; u8 0x02; u8 0x83; u8 0xfe; u8 0xee; u8 0xb9; u8 0x7f; u8 0x6f; u8 0x08; u8 0xd7; u8 0x3c; u8 0xbc; u8 0x7b; u8 0x38; u8 0x36;
        u8 0xf8; u8 0x2b; u8 0xbc; u8 0xd4; u8 0x99; u8 0x47; u8 0x9f; u8 0x5e; u8 0x6f; u8 0x76; u8 0xfd; u8 0xfc; u8 0xb8; u8 0xb3; u8 0x8c; u8 0x4f;
        u8 0x71; u8 0xdc; u8 0x9e; u8 0x88; u8 0xbd; u8 0x6a; u8 0x6f; u8 0x76; u8 0x37; u8 0x1a; u8 0xfd; u8 0x65; u8 0xd2; u8 0xaf; u8 0x18; u8 0x62;
        u8 0xb3; u8 0x2a; u8 0xfb; u8 0x34; u8 0xa9; u8 0x5f; u8 0x71; u8 0xb8; u8 0xb1; u8 0x32; u8 0x04; u8 0x3f; u8 0xfe; u8 0xbe; u8 0x3a; u8 0x95;
        u8 0x2b; u8 0xaf; u8 0x75; u8 0x92; u8 0x44; u8 0x81; u8 0x48; u8 0xc0; u8 0x3f; u8 0x9c; u8 0x69; u8 0xb1; u8 0xd6; u8 0x8e; u8 0x4c; u8 0xe5;
        u8 0xcf; u8 0x32; u8 0xc8; u8 0x6b; u8 0xaf; u8 0x46; u8 0xfe; u8 0xd3; u8 0x01; u8 0xca; u8 0x1a; u8 0xb4; u8 0x03; u8 0x06; u8 0x9b; u8 0x32;
        u8 0xf4; u8 0x56; u8 0xb9; u8 0x1f; u8 0x71; u8 0x89; u8 0x8a; u8 0xb0; u8 0x81; u8 0xcd; u8 0x8c; u8 0x42; u8 0x52; u8 0xef; u8 0x52; u8 0x71;
        u8 0x91; u8 0x5c; u8 0x97; u8 0x94; u8 0xb8; u8 0xf2; u8 0x95; u8 0x85; u8 0x1d; u8 0xa7; u8 0x51; u8 0x0f; u8 0x99; u8 0xcb; u8 0x73; u8 0xeb ] in
    let qLen = 128 in
    let q : lbytes qLen = createL [
        u8 0xcc; u8 0x4e; u8 0x90; u8 0xd2; u8 0xa1; u8 0xb3; u8 0xa0; u8 0x65; u8 0xd3; u8 0xb2; u8 0xd1; u8 0xf5; u8 0xa8; u8 0xfc; u8 0xe3; u8 0x1b;
        u8 0x54; u8 0x44; u8 0x75; u8 0x66; u8 0x4e; u8 0xab; u8 0x56; u8 0x1d; u8 0x29; u8 0x71; u8 0xb9; u8 0x9f; u8 0xb7; u8 0xbe; u8 0xf8; u8 0x44;
        u8 0xe8; u8 0xec; u8 0x1f; u8 0x36; u8 0x0b; u8 0x8c; u8 0x2a; u8 0xc8; u8 0x35; u8 0x96; u8 0x92; u8 0x97; u8 0x1e; u8 0xa6; u8 0xa3; u8 0x8f;
        u8 0x72; u8 0x3f; u8 0xcc; u8 0x21; u8 0x1f; u8 0x5d; u8 0xbc; u8 0xb1; u8 0x77; u8 0xa0; u8 0xfd; u8 0xac; u8 0x51; u8 0x64; u8 0xa1; u8 0xd4;
        u8 0xff; u8 0x7f; u8 0xbb; u8 0x4e; u8 0x82; u8 0x99; u8 0x86; u8 0x35; u8 0x3c; u8 0xb9; u8 0x83; u8 0x65; u8 0x9a; u8 0x14; u8 0x8c; u8 0xdd;
        u8 0x42; u8 0x0c; u8 0x7d; u8 0x31; u8 0xba; u8 0x38; u8 0x22; u8 0xea; u8 0x90; u8 0xa3; u8 0x2b; u8 0xe4; u8 0x6c; u8 0x03; u8 0x0e; u8 0x8c;
        u8 0x17; u8 0xe1; u8 0xfa; u8 0x0a; u8 0xd3; u8 0x78; u8 0x59; u8 0xe0; u8 0x6b; u8 0x0a; u8 0xa6; u8 0xfa; u8 0x3b; u8 0x21; u8 0x6d; u8 0x9c;
        u8 0xbe; u8 0x6c; u8 0x0e; u8 0x22; u8 0x33; u8 0x97; u8 0x69; u8 0xc0; u8 0xa6; u8 0x15; u8 0x91; u8 0x3e; u8 0x5d; u8 0xa7; u8 0x19; u8 0xcf ] in
    let rBlindLen = 8 in
    let rBlind : lbytes rBlindLen = createL [u8 0x7b; u8 0x9b; u8 0xe7; u8 0xac; u8 0x73; u8 0xb4; u8 0x5c; u8 0x00] in
    let msgLen = 128 in
    let msg : lbytes msgLen = createL [
        u8 0xdd; u8 0x67; u8 0x0a; u8 0x01; u8 0x46; u8 0x58; u8 0x68; u8 0xad; u8 0xc9; u8 0x3f; u8 0x26; u8 0x13; u8 0x19; u8 0x57; u8 0xa5; u8 0x0c;
        u8 0x52; u8 0xfb; u8 0x77; u8 0x7c; u8 0xdb; u8 0xaa; u8 0x30; u8 0x89; u8 0x2c; u8 0x9e; u8 0x12; u8 0x36; u8 0x11; u8 0x64; u8 0xec; u8 0x13;
        u8 0x97; u8 0x9d; u8 0x43; u8 0x04; u8 0x81; u8 0x18; u8 0xe4; u8 0x44; u8 0x5d; u8 0xb8; u8 0x7b; u8 0xee; u8 0x58; u8 0xdd; u8 0x98; u8 0x7b;
        u8 0x34; u8 0x25; u8 0xd0; u8 0x20; u8 0x71; u8 0xd8; u8 0xdb; u8 0xae; u8 0x80; u8 0x70; u8 0x8b; u8 0x03; u8 0x9d; u8 0xbb; u8 0x64; u8 0xdb;
        u8 0xd1; u8 0xde; u8 0x56; u8 0x57; u8 0xd9; u8 0xfe; u8 0xd0; u8 0xc1; u8 0x18; u8 0xa5; u8 0x41; u8 0x43; u8 0x74; u8 0x2e; u8 0x0f; u8 0xf3;
        u8 0xc8; u8 0x7f; u8 0x74; u8 0xe4; u8 0x58; u8 0x57; u8 0x64; u8 0x7a; u8 0xf3; u8 0xf7; u8 0x9e; u8 0xb0; u8 0xa1; u8 0x4c; u8 0x9d; u8 0x75;
        u8 0xea; u8 0x9a; u8 0x1a; u8 0x04; u8 0xb7; u8 0xcf; u8 0x47; u8 0x8a; u8 0x89; u8 0x7a; u8 0x70; u8 0x8f; u8 0xd9; u8 0x88; u8 0xf4; u8 0x8e;
        u8 0x80; u8 0x1e; u8 0xdb; u8 0x0b; u8 0x70; u8 0x39; u8 0xdf; u8 0x8c; u8 0x23; u8 0xbb; u8 0x3c; u8 0x56; u8 0xf4; u8 0xe8; u8 0x21; u8 0xac] in
    let saltLen = 20 in
    let salt : lbytes saltLen = createL [
        u8 0x8b; u8 0x2b; u8 0xdd; u8 0x4b; u8 0x40; u8 0xfa; u8 0xf5; u8 0x45; u8 0xc7; u8 0x78; u8 0xdd; u8 0xf9; u8 0xbc; u8 0x1a; u8 0x49; u8 0xcb;
        u8 0x57; u8 0xf9; u8 0xb7; u8 0x1b] in
    let sgnt_expected : lbytes nLen = createL [
        u8 0xa4; u8 0x4e; u8 0x5c; u8 0x83; u8 0xc6; u8 0xfe; u8 0xdf; u8 0x7f; u8 0x44; u8 0x33; u8 0x78; u8 0x82; u8 0x54; u8 0x2a; u8 0x96; u8 0x10;
        u8 0x72; u8 0x4a; u8 0xa6; u8 0xf5; u8 0xb8; u8 0xf1; u8 0x3b; u8 0x4f; u8 0x51; u8 0xeb; u8 0x9e; u8 0xf9; u8 0x84; u8 0xf5; u8 0x19; u8 0xaa;
        u8 0xe9; u8 0xe3; u8 0x4b; u8 0x26; u8 0x4e; u8 0x8d; u8 0x06; u8 0xb6; u8 0x93; u8 0x66; u8 0x4d; u8 0xe1; u8 0xcc; u8 0xe1; u8 0x36; u8 0xd0;
        u8 0x6d; u8 0x10; u8 0x7f; u8 0x64; u8 0x51; u8 0x99; u8 0x8a; u8 0xf9; u8 0x01; u8 0x21; u8 0x3f; u8 0xc8; u8 0x95; u8 0x83; u8 0xe6; u8 0xbe;
        u8 0xfe; u8 0x1e; u8 0xd1; u8 0x12; u8 0x35; u8 0xf5; u8 0xb5; u8 0xce; u8 0x8b; u8 0xd4; u8 0x72; u8 0xb3; u8 0x84; u8 0xef; u8 0xf0; u8 0xcd;
        u8 0x80; u8 0xd3; u8 0x75; u8 0xbd; u8 0x6a; u8 0x88; u8 0xae; u8 0x6f; u8 0x5b; u8 0x76; u8 0x75; u8 0xc2; u8 0x50; u8 0x8b; u8 0xa9; u8 0xb9;
        u8 0xf0; u8 0x17; u8 0x1e; u8 0x10; u8 0xc9; u8 0x58; u8 0xd4; u8 0xc0; u8 0x4c; u8 0x10; u8 0x0e; u8 0xf9; u8 0x06; u8 0xcc; u8 0x97; u8 0x58;
        u8 0x0d; u8 0xe7; u8 0x73; u8 0xad; u8 0x9d; u8 0xf4; u8 0xda; u8 0x13; u8 0xd5; u8 0x95; u8 0xbe; u8 0xe2; u8 0x4a; u8 0xf8; u8 0x12; u8 0x88;
        u8 0x4e; u8 0xd4; u8 0xdc; u8 0xe8; u8 0x09; u8 0x51; u8 0xec; u8 0xd0; u8 0x4b; u8 0x1b; u8 0xa6; u8 0xd7; u8 0x8c; u8 0x29; u8 0x34; u8 0xe6;
        u8 0xab; u8 0x0a; u8 0x77; u8 0x36; u8 0x83; u8 0x91; u8 0x1f; u8 0xcc; u8 0x68; u8 0x91; u8 0x35; u8 0x37; u8 0x67; u8 0x27; u8 0x78; u8 0x09;
        u8 0xec; u8 0x74; u8 0x6f; u8 0x95; u8 0x98; u8 0xe4; u8 0xf8; u8 0xf0; u8 0xcb; u8 0x1d; u8 0x3d; u8 0x37; u8 0x84; u8 0x3f; u8 0xea; u8 0x2a;
        u8 0x8c; u8 0xb0; u8 0x91; u8 0xf2; u8 0x91; u8 0x91; u8 0x22; u8 0x76; u8 0x9e; u8 0xe4; u8 0x17; u8 0xda; u8 0x18; u8 0xd6; u8 0x03; u8 0xf7;
        u8 0x98; u8 0x37; u8 0x0c; u8 0xad; u8 0x7b; u8 0x76; u8 0x0a; u8 0x7f; u8 0x57; u8 0x3a; u8 0xea; u8 0xf5; u8 0x16; u8 0xa0; u8 0xf9; u8 0x0d;
        u8 0x95; u8 0x25; u8 0x65; u8 0xb8; u8 0xa1; u8 0x9a; u8 0x8f; u8 0xc3; u8 0xf0; u8 0xee; u8 0x7d; u8 0x39; u8 0x1d; u8 0x9b; u8 0x8b; u8 0x3f;
        u8 0x98; u8 0xbe; u8 0xbb; u8 0x0d; u8 0x5d; u8 0x01; u8 0x0e; u8 0x32; u8 0xe0; u8 0xb8; u8 0x00; u8 0xe9; u8 0x65; u8 0x6f; u8 0x64; u8 0x08;
        u8 0x2b; u8 0xb1; u8 0xac; u8 0x95; u8 0xa2; u8 0x23; u8 0xf4; u8 0x31; u8 0xec; u8 0x40; u8 0x6a; u8 0x42; u8 0x95; u8 0x4b; u8 0x2d; u8 0x57] in
    let res = ctest 12 31 modBits n pkeyBits e skeyBits d pLen p qLen q rBlindLen rBlind msgLen msg saltLen salt sgnt_expected in
    res
    
val test: unit -> ML bool
let test() = test1() && test2() && test3() && test4()
