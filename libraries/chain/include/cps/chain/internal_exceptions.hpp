/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */
#pragma once

#include <fc/exception/exception.hpp>
#include <cps/chain/exceptions.hpp>

#define CPS_DECLARE_INTERNAL_EXCEPTION( exc_name, seqnum, msg )  \
   FC_DECLARE_DERIVED_EXCEPTION(                                      \
      internal_ ## exc_name,                                          \
      cpsio::chain::internal_exception,                            \
      3990000 + seqnum,                                               \
      msg                                                             \
      )

namespace cpsio { namespace chain {

FC_DECLARE_DERIVED_EXCEPTION( internal_exception, cpsio::chain::chain_exception, 3990000, "internal exception" )

CPS_DECLARE_INTERNAL_EXCEPTION( verify_auth_max_auth_exceeded, 1, "Exceeds max authority fan-out" )
CPS_DECLARE_INTERNAL_EXCEPTION( verify_auth_account_not_found, 2, "Auth account not found" )

} } // cpsio::chain
