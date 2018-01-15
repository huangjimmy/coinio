/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */

#include <cps/native_contract/genesis_state.hpp>

// these are required to serialize a genesis_state
#include <fc/smart_ref_impl.hpp>   // required for gcc in release mode

namespace cpsio { namespace native_contract {

chain::chain_id_type genesis_state_type::compute_chain_id() const {
   return initial_chain_id;
}

} } // cpsio::native_contract
