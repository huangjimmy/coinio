/**
 *  @file
 *  @copyright defined in cps/LICENSE.txt
 */

#include <cps/utilities/tempdir.hpp>

#include <cstdlib>

namespace cpsio { namespace utilities {

fc::path temp_directory_path()
{
   const char* cps_tempdir = getenv("CPS_TEMPDIR");
   if( cps_tempdir != nullptr )
      return fc::path( cps_tempdir );
   return fc::temp_directory_path() / "cps-tmp";
}

} } // cpsio::utilities
