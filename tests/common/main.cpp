/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */
#include <cstdlib>
#include <iostream>
#include <boost/test/included/unit_test.hpp>

extern uint32_t CPS_TESTING_GENESIS_TIMESTAMP;

boost::unit_test::test_suite* init_unit_test_suite(int argc, char* argv[]) {
   std::srand(time(NULL));
   std::cout << "Random number generator seeded to " << time(NULL) << std::endl;
   const char* genesis_timestamp_str = getenv("CPS_TESTING_GENESIS_TIMESTAMP");
   if( genesis_timestamp_str != nullptr )
   {
      CPS_TESTING_GENESIS_TIMESTAMP = std::stoul( genesis_timestamp_str );
   }
   std::cout << "CPS_TESTING_GENESIS_TIMESTAMP is " << CPS_TESTING_GENESIS_TIMESTAMP << std::endl;
   return nullptr;
}
