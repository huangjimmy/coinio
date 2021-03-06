/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */
#pragma once

#include <cps/chain/chain_administration_interface.hpp>

namespace cpsio { namespace native_contract {
using chain::producer_round;

class native_contract_chain_administrator : public chain::chain_administration_interface {
   producer_round get_next_round(chainbase::database& db);
   chain::blockchain_configuration get_blockchain_configuration(const chainbase::database& db,
                                                               const producer_round& round);
};

inline std::unique_ptr<chain::chain_administration_interface> make_administrator() {
   return std::unique_ptr<chain::chain_administration_interface>(new native_contract_chain_administrator());
}

} } // namespace cpsio::native_contract
