/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */
#pragma once

#include <cpslib/types.h>

/**
 *  @defgroup chainapi Chain API
 *  @brief Define API for querying internal chain state
 *  @ingroup contractdev
 */

/**
 *  @defgroup chaincapi Chain C API
 *  @brief C API for querying internal chain state
 *  @ingroup chainapi
 *  @{
 */

extern "C" {
   /**
    * @brief Return the set of active producers
    * @details Return the set of active producers
    *
    * @param producers - location to store the active producers
    *
    *  Example:
    *  @code
    *  account_name producers[21];
    *  get_active_producers(producers, sizeof(account_name)*21);
    *  @endcode
    */

   void get_active_producers( account_name* producers, uint32_t datalen );

   ///@ } chaincapi
}