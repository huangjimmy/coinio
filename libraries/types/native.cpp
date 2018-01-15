/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */
#include <cps/types/native.hpp>
#include <fc/crypto/base58.hpp>
#include <fc/crypto/ripemd160.hpp>
#include <fc/io/raw.hpp>
#include <fc/fixed_string.hpp>
#include <fc/reflect/variant.hpp>

namespace fc {
  void to_variant(const cpsio::types::name& c, fc::variant& v) { v = std::string(c); }
  void from_variant(const fc::variant& v, cpsio::types::name& check) { check = v.get_string(); }

  void to_variant(const std::vector<cpsio::types::field>& c, fc::variant& v) {
     fc::mutable_variant_object mvo; mvo.reserve(c.size());
     for(const auto& f : c) {
        mvo.set(f.name, cpsio::types::string(f.type));
     }
     v = std::move(mvo);
  }
  void from_variant(const fc::variant& v, std::vector<cpsio::types::field>& fields) {
     const auto& obj = v.get_object();
     fields.reserve(obj.size());
     for(const auto& f : obj)
        fields.emplace_back(cpsio::types::field{ f.key(), f.value().get_string() });
  }
  void to_variant(const std::map<std::string,cpsio::types::struct_t>& c, fc::variant& v)
  {
     fc::mutable_variant_object mvo; mvo.reserve(c.size());
     for(const auto& item : c) {
        if(item.second.base.size())
           mvo.set(item.first, fc::mutable_variant_object("base",item.second.base)("fields",item.second.fields));
        else
           mvo.set(item.first, fc::mutable_variant_object("fields",item.second.fields));
     }
     v = std::move(mvo);
  }
  void from_variant(const fc::variant& v, std::map<std::string,cpsio::types::struct_t>& structs) {
     const auto& obj = v.get_object();
     structs.clear();
     for(const auto& f : obj) {
        auto& stru = structs[f.key()];
        if(f.value().get_object().contains("fields"))
           fc::from_variant(f.value().get_object()["fields"], stru.fields);
        if(f.value().get_object().contains("base"))
           fc::from_variant(f.value().get_object()["base"], stru.base);
        stru.name = f.key();
     }
  }
}

bool cpsio::types::field::operator==(const cpsio::types::field& other) const {
   return std::tie(name, type) == std::tie(other.name, other.type);
}

bool cpsio::types::struct_t::operator==(const cpsio::types::struct_t& other) const {
   return std::tie(name, base, fields) == std::tie(other.name, other.base, other.fields);
}
