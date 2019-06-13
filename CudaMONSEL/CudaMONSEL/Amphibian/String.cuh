/**
* An immutable string class.
*/
#ifndef _STRING_CUH_
#define _STRING_CUH_

#include <cuda_runtime.h>

#define NULL_CHAR '\0'

namespace amp
{
#if (defined(__CUDA_ARCH__) && (__CUDA_ARCH__ > 0))
   __constant__ const int MAX_LEN = sizeof(char) * 32;
#else
   const int MAX_LEN = sizeof(char) * 32;
#endif

   class string
   {
   public:
      __host__ __device__ string();
      __host__ __device__ string(const string&);
      __host__ __device__ string(char const *);

      __host__ __device__ void operator=(const string&);
      __host__ __device__ void operator=(char const *);

      __host__ __device__ bool operator==(const string&) const;
      __host__ __device__ bool operator!=(const string&) const;
      __host__ __device__ bool operator<(const string&) const;

      __host__ __device__ const char* c_str() const;
      __host__ __device__ int size() const;

      __host__ __device__ unsigned int hashcode() const;

   private:
      __host__ __device__ void copy(char const *);

      char str[MAX_LEN];
   };

   __host__ __device__ void IToA(int, char *, int maxArrayLen = 11 /* integer limit */);
   __host__ __device__ int AToI(char const *);
   //__host__ __device__ float AToF(char*);
   //__host__ __device__ double AToD(char*);

   template<typename T>
   __host__ __device__ T AToF(char const * d)
   {
      int mult = 1;
      int idx = 0;
      if (d[0] == '-') {
         mult *= -1;
         idx = 1;
      }

      T res = 0;
      T decDivs = 10;
      bool foundDec = false;
      do {
         char di = d[idx];
         if (di == '.') {
            foundDec = true;
         }
         else if (di >= '0' || di <= '9') {
            int n = di - '0';
            if (foundDec) {
               res = res + n / decDivs;
               decDivs *= 10;
            }
            else {
               res = res * 10 + n;
            }
         }
         ++idx;
      } while (d[idx] != NULL_CHAR);

      return res*mult;
   }

   typedef bool(*pStrCmp)(string&, string&);
   __host__ __device__ bool equal(string&, string&);
   __host__ __device__ bool equal(char const * const a, char const * const b);
   __host__ __device__ bool StartsWith(char* src, char* target);

   struct string_cmp
   {
      __host__ __device__ inline bool operator() (const string& lhs, const string& rhs) const
      {
         return lhs == rhs;
      }
   };

   struct string_hash
   {
      __host__ __device__ inline unsigned int operator() (const string& s) const
      {
         return s.hashcode();
      }
   };
}

//__global__ void kernel(int n)
//{
//   char n_a[16] = "\0";
//   String::IToA(n_a, n);
//   printf("%s\n", n_a);
//}

#endif
