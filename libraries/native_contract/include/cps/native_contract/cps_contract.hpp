/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */
#pragma once

#include <cps/chain/message_handling_contexts.hpp>

#include <cps/types/types.hpp>

namespace native {
namespace cpsio { ///< cps native currency contract
namespace chain = ::cpsio::chain;
namespace types = ::cpsio::types;

void apply_cps_newaccount(chain::apply_context& context);
void apply_cps_transfer(chain::apply_context& context);
void apply_cps_lock(chain::apply_context& context);
void apply_cps_claim(chain::apply_context&);
void apply_cps_unlock(chain::apply_context&);
void apply_cps_okproducer(chain::apply_context&);
void apply_cps_setproducer(chain::apply_context&);
void apply_cps_setproxy(chain::apply_context&);
void apply_cps_setcode(chain::apply_context&);
void apply_cps_updateauth(chain::apply_context&);
void apply_cps_deleteauth(chain::apply_context&);
void apply_cps_linkauth(chain::apply_context&);
void apply_cps_unlinkauth(chain::apply_context&);

} // namespace cpsio
} // namespace native
