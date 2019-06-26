#include "gov\nist\nanoscalemetrology\JMONSEL\GanachaudMokraniPolaronTrapSM.cuh"
#include "gov\nist\microanalysis\Utility\Math2.cuh"
#include "gov\nist\microanalysis\NISTMonte\Electron.cuh"
#include "gov\nist\nanoscalemetrology\JMONSEL\SEmaterial.cuh"

namespace GanachaudMokraniPolaronTrapSM
{
   GanachaudMokraniPolaronTrapSM::GanachaudMokraniPolaronTrapSM(double prefactor, double extinction) :
      prefactor(prefactor),
      extinction(extinction),
      CUTOFF(-::log(10. / prefactor) / extinction)
   {
      if (prefactor < 0.) printf("ERROR: Nonpositive prefactor in GanachaudMokraniPolaronTrapSM constructor.");
      if (extinction < 0.) printf("ERROR: Nonpositive extinction in GanachaudMokraniPolaronTrapSM constructor.");
   }

   ElectronT* GanachaudMokraniPolaronTrapSM::scatter(ElectronT* pe)
   {
      pe->setEnergy(0.); // So listeners, if any, will record the energy change.
      pe->setTrajectoryComplete(true); // It's trapped
      return NULL;
   }

   double GanachaudMokraniPolaronTrapSM::scatterRate(const ElectronT* pe)
   {
      const double kE0 = pe->getEnergy();
      if (kE0 > CUTOFF) return 0.;
      const double result = prefactor * ::exp(-extinction * kE0);
      return result;
   }

   void GanachaudMokraniPolaronTrapSM::setMaterial(const MaterialT* mat)
   {
   }

   StringT GanachaudMokraniPolaronTrapSM::toString() const
   {
      return "FittedInelSM(" + amp::to_string(prefactor) + "," + amp::to_string(extinction) + "," + amp::to_string(CUTOFF) + ")";
   }
}
