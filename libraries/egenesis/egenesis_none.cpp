/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */

#include <cps/egenesis/egenesis.hpp>

namespace cpsio { namespace egenesis {

using namespace cpsio::chain;

chain_id_type get_egenesis_chain_id()
{
   return chain_id_type();
}

void compute_egenesis_json( std::string& result )
{
   result = "";
}

fc::sha256 get_egenesis_json_hash()
{
   return fc::sha256::hash( "" );
}

} }
