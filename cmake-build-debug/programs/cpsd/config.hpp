/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 *
 * \warning This file is machine generated. DO NOT EDIT.  See config.hpp.in for changes.
 */
#pragma once

#ifndef CONFIG_HPP_IN
#define CONFIG_HPP_IN

namespace cpsio { namespace cpsd { namespace config {
  constexpr uint64_t version = 0x233ba4e5;

  template<typename I>
  std::string itoh(I n, size_t hlen = sizeof(I)<<1) {
    static const char* digits = "0123456789abcdef";
    std::string r(hlen, '0');
    for(size_t i = 0, j = (hlen - 1) * 4 ; i < hlen; ++i, j -= 4)
      r[i] = digits[(n>>j) & 0x0f];
    return r;
  }
}}}

#endif // CONFIG_HPP_IN