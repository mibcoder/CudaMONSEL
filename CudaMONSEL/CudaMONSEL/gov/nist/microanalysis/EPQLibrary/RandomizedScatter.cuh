#ifndef _RANDOMIZED_SCATTER_CUH_
#define _RANDOMIZED_SCATTER_CUH_

#include "gov\nist\microanalysis\NISTMonte\Declarations.cuh"
#include "gov\nist\microanalysis\EPQLibrary\AlgorithmClass.cuh"

namespace RandomizedScatter
{
   class RandomizedScatter : public AlgorithmClassT
   {
   protected:
      RandomizedScatter(StringT name, const ReferenceT& ref);

      void initializeDefaultStrategy() override;
      AlgorithmClass const * const * RandomizedScatter::getAllImplementations() const;

   public:
      virtual double randomScatteringAngle(double energy) const = 0;
      virtual double totalCrossSection(double energy) const = 0;
      virtual const ElementT& getElement() const = 0;
   };
}

#endif