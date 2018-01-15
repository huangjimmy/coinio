/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */
#include <cpslib/cps.hpp>
#include <cpslib/db.hpp>

namespace proxy {
   
   //@abi action
   struct PACKED( set_owner ) {
      account_name owner;	
   };

   //@abi table
   struct PACKED( config ) {
      config( account_name o = account_name() ):owner(o){}
      const uint64_t     key = N(config);
      account_name        owner;
   };

   using configs = cpsio::table<N(proxy),N(proxy),N(configs),config,uint64_t>;

} /// namespace proxy
