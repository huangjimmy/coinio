/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */
#pragma once

#include <cps/chain/types.hpp>
#include <cps/chain/multi_index_includes.hpp>

#include <cps/types/types.hpp>

#include <chainbase/chainbase.hpp>

namespace cpsio {
namespace chain {


/**
 * @brief The balance_object class tracks the CPS balance for accounts
 */
class balance_object : public chainbase::object<balance_object_type, balance_object> {
   OBJECT_CTOR(balance_object)

   id_type id;
   types::account_name owner_name;
   types::share_type balance = 0;
};

struct by_owner_name;

using balance_multi_index = chainbase::shared_multi_index_container<
      balance_object,
   indexed_by<
      ordered_unique<tag<by_id>,
         member<balance_object, balance_object::id_type, &balance_object::id>
      >,
      ordered_unique<tag<by_owner_name>,
         member<balance_object, types::account_name, &balance_object::owner_name>
      >
   >
>;

} } // namespace cpsio::chain

CHAINBASE_SET_INDEX_TYPE(cpsio::chain::balance_object, cpsio::chain::balance_multi_index)
