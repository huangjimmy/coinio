/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */
#include <cpslib/cps.hpp>

#include "test_api.hpp"

unsigned int test_types::types_size() {
   
   WASM_ASSERT( sizeof(int64_t) == 8, "int64_t size != 8");
   WASM_ASSERT( sizeof(uint64_t) ==  8, "uint64_t size != 8");
   WASM_ASSERT( sizeof(uint32_t) ==  4, "uint32_t size != 4");
   WASM_ASSERT( sizeof(int32_t) ==  4, "int32_t size != 4");
   WASM_ASSERT( sizeof(uint128_t) == 16, "uint128_t size != 16");
   WASM_ASSERT( sizeof(int128_t) == 16, "int128_t size != 16");
   WASM_ASSERT( sizeof(uint8_t) ==  1, "uint8_t size != 1");
   
   WASM_ASSERT( sizeof(account_name) ==  8, "account_name size !=  8");
   WASM_ASSERT( sizeof(token_name) ==  8, "token_name size !=  8");
   WASM_ASSERT( sizeof(table_name) ==  8, "table_name size !=  8");
   WASM_ASSERT( sizeof(time) ==  4, "time size !=  4");
   WASM_ASSERT( sizeof(uint256) == 32, "uint256 != 32" );

   return WASM_TEST_PASS;
}

unsigned int test_types::char_to_symbol() {
   
   WASM_ASSERT( cpsio::char_to_symbol('1') ==  1, "cpsio::char_to_symbol('1') !=  1");
   WASM_ASSERT( cpsio::char_to_symbol('2') ==  2, "cpsio::char_to_symbol('2') !=  2");
   WASM_ASSERT( cpsio::char_to_symbol('3') ==  3, "cpsio::char_to_symbol('3') !=  3");
   WASM_ASSERT( cpsio::char_to_symbol('4') ==  4, "cpsio::char_to_symbol('4') !=  4");
   WASM_ASSERT( cpsio::char_to_symbol('5') ==  5, "cpsio::char_to_symbol('5') !=  5");
   WASM_ASSERT( cpsio::char_to_symbol('a') ==  6, "cpsio::char_to_symbol('a') !=  6");
   WASM_ASSERT( cpsio::char_to_symbol('b') ==  7, "cpsio::char_to_symbol('b') !=  7");
   WASM_ASSERT( cpsio::char_to_symbol('c') ==  8, "cpsio::char_to_symbol('c') !=  8");
   WASM_ASSERT( cpsio::char_to_symbol('d') ==  9, "cpsio::char_to_symbol('d') !=  9");
   WASM_ASSERT( cpsio::char_to_symbol('e') == 10, "cpsio::char_to_symbol('e') != 10");
   WASM_ASSERT( cpsio::char_to_symbol('f') == 11, "cpsio::char_to_symbol('f') != 11");
   WASM_ASSERT( cpsio::char_to_symbol('g') == 12, "cpsio::char_to_symbol('g') != 12");
   WASM_ASSERT( cpsio::char_to_symbol('h') == 13, "cpsio::char_to_symbol('h') != 13");
   WASM_ASSERT( cpsio::char_to_symbol('i') == 14, "cpsio::char_to_symbol('i') != 14");
   WASM_ASSERT( cpsio::char_to_symbol('j') == 15, "cpsio::char_to_symbol('j') != 15");
   WASM_ASSERT( cpsio::char_to_symbol('k') == 16, "cpsio::char_to_symbol('k') != 16");
   WASM_ASSERT( cpsio::char_to_symbol('l') == 17, "cpsio::char_to_symbol('l') != 17");
   WASM_ASSERT( cpsio::char_to_symbol('m') == 18, "cpsio::char_to_symbol('m') != 18");
   WASM_ASSERT( cpsio::char_to_symbol('n') == 19, "cpsio::char_to_symbol('n') != 19");
   WASM_ASSERT( cpsio::char_to_symbol('o') == 20, "cpsio::char_to_symbol('o') != 20");
   WASM_ASSERT( cpsio::char_to_symbol('p') == 21, "cpsio::char_to_symbol('p') != 21");
   WASM_ASSERT( cpsio::char_to_symbol('q') == 22, "cpsio::char_to_symbol('q') != 22");
   WASM_ASSERT( cpsio::char_to_symbol('r') == 23, "cpsio::char_to_symbol('r') != 23");
   WASM_ASSERT( cpsio::char_to_symbol('s') == 24, "cpsio::char_to_symbol('s') != 24");
   WASM_ASSERT( cpsio::char_to_symbol('t') == 25, "cpsio::char_to_symbol('t') != 25");
   WASM_ASSERT( cpsio::char_to_symbol('u') == 26, "cpsio::char_to_symbol('u') != 26");
   WASM_ASSERT( cpsio::char_to_symbol('v') == 27, "cpsio::char_to_symbol('v') != 27");
   WASM_ASSERT( cpsio::char_to_symbol('w') == 28, "cpsio::char_to_symbol('w') != 28");
   WASM_ASSERT( cpsio::char_to_symbol('x') == 29, "cpsio::char_to_symbol('x') != 29");
   WASM_ASSERT( cpsio::char_to_symbol('y') == 30, "cpsio::char_to_symbol('y') != 30");
   WASM_ASSERT( cpsio::char_to_symbol('z') == 31, "cpsio::char_to_symbol('z') != 31");
 
   for(unsigned char i = 0; i<255; i++) {
      if((i >= 'a' && i <= 'z') || (i >= '1' || i <= '5')) continue;
      WASM_ASSERT( cpsio::char_to_symbol(i) == 0, "cpsio::char_to_symbol() != 0");
   }

   return WASM_TEST_PASS;  
}

unsigned int test_types::string_to_name() {

   WASM_ASSERT( cpsio::string_to_name("a") == N(a) , "cpsio::string_to_name(a)" );
   WASM_ASSERT( cpsio::string_to_name("ba") == N(ba) , "cpsio::string_to_name(ba)" );
   WASM_ASSERT( cpsio::string_to_name("cba") == N(cba) , "cpsio::string_to_name(cba)" );
   WASM_ASSERT( cpsio::string_to_name("dcba") == N(dcba) , "cpsio::string_to_name(dcba)" );
   WASM_ASSERT( cpsio::string_to_name("edcba") == N(edcba) , "cpsio::string_to_name(edcba)" );
   WASM_ASSERT( cpsio::string_to_name("fedcba") == N(fedcba) , "cpsio::string_to_name(fedcba)" );
   WASM_ASSERT( cpsio::string_to_name("gfedcba") == N(gfedcba) , "cpsio::string_to_name(gfedcba)" );
   WASM_ASSERT( cpsio::string_to_name("hgfedcba") == N(hgfedcba) , "cpsio::string_to_name(hgfedcba)" );
   WASM_ASSERT( cpsio::string_to_name("ihgfedcba") == N(ihgfedcba) , "cpsio::string_to_name(ihgfedcba)" );
   WASM_ASSERT( cpsio::string_to_name("jihgfedcba") == N(jihgfedcba) , "cpsio::string_to_name(jihgfedcba)" );
   WASM_ASSERT( cpsio::string_to_name("kjihgfedcba") == N(kjihgfedcba) , "cpsio::string_to_name(kjihgfedcba)" );
   WASM_ASSERT( cpsio::string_to_name("lkjihgfedcba") == N(lkjihgfedcba) , "cpsio::string_to_name(lkjihgfedcba)" );
   WASM_ASSERT( cpsio::string_to_name("mlkjihgfedcba") == N(mlkjihgfedcba) , "cpsio::string_to_name(mlkjihgfedcba)" );
   WASM_ASSERT( cpsio::string_to_name("mlkjihgfedcba1") == N(mlkjihgfedcba2) , "cpsio::string_to_name(mlkjihgfedcba2)" );
   WASM_ASSERT( cpsio::string_to_name("mlkjihgfedcba55") == N(mlkjihgfedcba14) , "cpsio::string_to_name(mlkjihgfedcba14)" );
   
   WASM_ASSERT( cpsio::string_to_name("azAA34") == N(azBB34) , "cpsio::string_to_name N(azBB34)" );
   WASM_ASSERT( cpsio::string_to_name("AZaz12Bc34") == N(AZaz12Bc34) , "cpsio::string_to_name AZaz12Bc34" );
   WASM_ASSERT( cpsio::string_to_name("AAAAAAAAAAAAAAA") == cpsio::string_to_name("BBBBBBBBBBBBBDDDDDFFFGG") , "cpsio::string_to_name BBBBBBBBBBBBBDDDDDFFFGG" );
   
   return WASM_TEST_PASS;
}

unsigned int test_types::name_class() {

   WASM_ASSERT ( cpsio::name(cpsio::string_to_name("azAA34")).value == N(azAA34), "cpsio::name != N(azAA34)" );
   WASM_ASSERT ( cpsio::name(cpsio::string_to_name("AABBCC")).value == 0, "cpsio::name != N(0)" );
   WASM_ASSERT ( cpsio::name(cpsio::string_to_name("AA11")).value == N(AA11), "cpsio::name != N(AA11)" );
   WASM_ASSERT ( cpsio::name(cpsio::string_to_name("11AA")).value == N(11), "cpsio::name != N(11)" );
   WASM_ASSERT ( cpsio::name(cpsio::string_to_name("22BBCCXXAA")).value == N(22), "cpsio::name != N(22)" );
   WASM_ASSERT ( cpsio::name(cpsio::string_to_name("AAAbbcccdd")) == cpsio::name(cpsio::string_to_name("AAAbbcccdd")), "cpsio::name == cpsio::name" );

   uint64_t tmp = cpsio::name(cpsio::string_to_name("11bbcccdd"));
   WASM_ASSERT(N(11bbcccdd) == tmp, "N(11bbcccdd) == tmp");

   return WASM_TEST_PASS;  
}
