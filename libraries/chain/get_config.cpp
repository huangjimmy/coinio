/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */

#include <cps/chain/get_config.hpp>
#include <cps/chain/config.hpp>
#include <cps/chain/types.hpp>

namespace cpsio { namespace chain {

fc::variant_object get_config()
{
   fc::mutable_variant_object result;

   result["key_prefix"] = config::key_prefix;
   result["default_block_interval_seconds"] = config::default_block_interval_seconds;
   result["MaxBlockSize"] = config::default_max_block_size;
   result["MaxSecondsUntilExpiration"] = config::default_max_trx_lifetime;
   result["ProducerCount"] = config::blocks_per_round;
   result["irreversible_threshold_percent"] = config::irreversible_threshold_percent;
   return result;
}

} } // cpsio::chain
