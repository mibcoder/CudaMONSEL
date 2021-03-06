#include "gov\nist\nanoscalemetrology\JMONSEL\FittedInelSM.cuh"
#include "gov\nist\microanalysis\Utility\Math2.cuh"
#include "gov\nist\microanalysis\NISTMonte\Electron.cuh"
#include "gov\nist\nanoscalemetrology\JMONSEL\SEmaterial.cuh"

namespace FittedInelSM
{
   FittedInelSM::FittedInelSM(const SEmaterialT& mat, double energySEgen, const SlowingDownAlgT& sdAlg) : sdAlg(sdAlg), energySEgen(energySEgen)
   {
      setMaterial(&mat);
   }

   ElectronT* FittedInelSM::scatter(ElectronT* pe)
   {
      double phi = 2 * Math2::PI * Math2::random();
      double theta = ::acos(1. - (2. * Math2::random()));
      return new ElectronT(*pe, theta, phi, energySEgen + eFermi); // TODO: deal with the new electron
   }

   double FittedInelSM::scatterRate(const ElectronT* pe)
   {
      if (pe->getEnergy() <= (energySEgen + eFermi))
         return 0.;
      return (-sdAlg.compute(1.e-10, pe) * 1.e10) / energySEgen;
   }

   void FittedInelSM::setMaterial(const MaterialT* mat)
   {
      if (!mat->isSEmaterial()) {
         printf("FittedInelSM::setMaterial: not SEmaterial\n");
      }
      eFermi = ((SEmaterialT*)mat)->getEFermi();
   }

   StringT FittedInelSM::toString() const
   {
      return "FittedInelSM(" + std::to_string(eFermi) + "," + std::to_string(energySEgen) + "," + StringT(sdAlg.toString()) + ")";
   }
}
