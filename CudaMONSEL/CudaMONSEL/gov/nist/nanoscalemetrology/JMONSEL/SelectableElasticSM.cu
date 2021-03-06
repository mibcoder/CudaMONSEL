#include "gov\nist\nanoscalemetrology\JMONSEL\SelectableElasticSM.cuh"
#include "gov\nist\microanalysis\EPQLibrary\NISTMottScatteringAngle.cuh"
#include "gov\nist\microanalysis\NISTMonte\Electron.cuh"
#include "gov\nist\microanalysis\Utility\Math2.cuh"
#include "gov\nist\microanalysis\EPQLibrary\Material.cuh"
#include "gov\nist\microanalysis\EPQLibrary\PhysicalConstants.cuh"

namespace SelectableElasticSM
{
   SelectableElasticSM::SelectableElasticSM(const MaterialT& mat, const RandomizedScatterFactoryT& rsf) : rsf(rsf)
   {
      setMaterial(&mat);
   }

   SelectableElasticSM::SelectableElasticSM(const MaterialT& mat) : rsf(NISTMottScatteringAngle::Factory)
   {
      setMaterial(&mat);
   }

   //SelectableElasticSM::SelectableElasticSM(const SelectableElasticSM& sm) : rsf(sm.rsf), 
   //{
   //   setMaterial(sm.mat);
   //}

   void SelectableElasticSM::setCache(double kE)
   {
      /*
      * Algorithm: 1. Get scaled cross section (cross section times weight
      * fraction divided by atomic weight) for each element in this material 2.
      * From this, determine the total scaled cross section. 3. Cache these for
      * later use.
      */
      totalScaledCrossSection = 0.;
      for (int i = 0; i < nce; i++) {
         totalScaledCrossSection += rse[i]->totalCrossSection(kE) * scalefactor[i];
         cumulativeScaledCrossSection[i] = totalScaledCrossSection;
      }
      // Remember kinetic energy for which the cache was created
      cached_kE = kE;
   }

   double SelectableElasticSM::scatterRate(const ElectronT* pe)
   {
      setCache(pe->getEnergy()); // computes totalScaledCrossSection for this
      // eK
      return totalScaledCrossSection * densityNa;
   }

   ElectronT* SelectableElasticSM::scatter(ElectronT* pe)
   {
      double kE = pe->getPreviousEnergy();
      if (kE != cached_kE)
         setCache(kE);
      // Decide which element we scatter from
      double r = Math2::random() * totalScaledCrossSection;
      int index = 0; // Index is first index

      // Increment index and mechanism until cumulative scatter rate exceeds r
      while (cumulativeScaledCrossSection[index] < r)
         index++;

      double alpha = rse[index]->randomScatteringAngle(kE);
      double beta = 2 * Math2::PI * Math2::random();
      pe->updateDirection(alpha, beta);
      pe->setScatteringElement(&(rse[index]->getElement()));
      return NULL; // This mechanism is elastic. No SE.
   }

   void SelectableElasticSM::setMaterial(const MaterialT* mat)
   {
      nce = mat->getElementCount();
      densityNa = mat->getDensity() * PhysicalConstants::AvagadroNumber;
      if (nce > 0) {
         // Element[] elements = (Element[]) mat.getElementSet().toArray();
         Element::UnorderedSetT elements = mat->getElementSet();
         rse.resize(nce);
         scalefactor.resize(nce);
         cumulativeScaledCrossSection.resize(nce);

         int i = 0;
         for (auto elm : elements) {
            rse[i] = &rsf.get(*elm);
            // The factor of 1000 in the next line is to convert atomic
            // weight in g/mole to kg/mole.
            scalefactor[i] = (1000. * mat->weightFraction(*elm, true)) / elm->getAtomicWeight();
            i++;
         }
      }
   }
}