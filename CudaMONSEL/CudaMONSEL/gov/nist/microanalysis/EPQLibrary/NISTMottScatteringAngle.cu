#include "gov\nist\microanalysis\EPQLibrary\NISTMottScatteringAngle.cuh"
#include "gov\nist\microanalysis\Utility\Math2.cuh"
#include "gov\nist\microanalysis\EPQLibrary\Reference.cuh"
#include "gov\nist\microanalysis\EPQLibrary\Element.cuh"
#include "gov\nist\microanalysis\EPQLibrary\PhysicalConstants.cuh"
#include "gov\nist\microanalysis\EPQLibrary\FromSI.cuh"
#include "gov\nist\microanalysis\EPQLibrary\ScreenedRutherfordScatteringAngle.cuh"

namespace NISTMottScatteringAngle
{
   static const Reference::Author* auRef[] = { &Reference::CPowell, &Reference::FSalvat, &Reference::AJablonski };
   static const Reference::WebSite REFERENCE("http://www.nist.gov/srd/nist64.htm", "NIST Electron Elastic-Scattering Cross-Section Database version 3.1", "2007 AUGUST 24", auRef, 3);

   const int SPWEM_LEN = 61;
   const int X1_LEN = 201;
   const double DL50 = ::log(50.0);
   const double PARAM = (::log(2.0e4) - DL50) / 60.0;

   static const double MAX_NISTMOTT = ToSI::keV(20.0);

   static double value(double a, double b, double c, double y0, double y1, double y2, double x)
   {
      return (x - b) * (x - c) * y0 / ((a - b) * (a - c)) + (x - a) * (x - c) * y1 / ((b - a) * (b - c)) + (x - a) * (x - b) * y2 / ((c - a) * (c - b));
   }

   // https://www.oreilly.com/library/view/c-cookbook/0596007612/ch03s06.html
   static double sciToDub(const std::string& str)
   {
      std::string tmp = str.substr(str.find_first_not_of(" "));
      std::stringstream ss(tmp);
      double d = 0;
      ss >> d;

      if (ss.fail()) {
         std::string s = "Unable to format ";
         s += tmp;
         s += " as a number!";
         throw (s);
      }

      return (d);
   }

   void NISTMottScatteringAngle::loadData(int an)
   {
      std::string name(an < 10 ? ".\\gov\\nist\\microanalysis\\EPQLibrary\\NistXSec/E0" + std::to_string(an) + ".D64" : ".\\gov\\nist\\microanalysis\\EPQLibrary\\NistXSec/E" + std::to_string(an) + ".D64");
      printf("Reading: %s\n", name.c_str());
      try {
         std::ifstream t(name);
         if (!t.good()) throw 0;
         std::string line;
         std::getline(t, line);
         for (int j = 0; j < SPWEM_LEN; ++j) {
            std::getline(t, line);
            mSpwem[j] = sciToDub(line);
            for (int i = 0; i < X1_LEN; ++i) {
               std::getline(t, line);
               mX1[j][i] = sciToDub(line);
            }
         }
         t.close();
      }
      catch (std::exception&) {
         printf("Unable to construct NISTMottScatteringAngle: %s\n", name.c_str());
      }
   }

   NISTMottScatteringAngle::NISTMottScatteringAngle(const ElementT& elm) :
      RandomizedScatterT("NIST Elastic cross-section", REFERENCE),
      mElement(elm),
      mSpwem(SPWEM_LEN, 0),
      mX1(SPWEM_LEN, VectorXd(X1_LEN, 0)),
      mRutherford(ScreenedRutherfordScatteringAngle::getSRSA(elm.getAtomicNumber()))
   {
      loadData(elm.getAtomicNumber());
   }

   StringT NISTMottScatteringAngle::toString() const
   {
      return "CrossSection[NIST-Mott," + StringT(mElement.toAbbrev()) + "]";
   }

   const ElementT& NISTMottScatteringAngle::getElement() const
   {
      return mElement;
   }
   
   double NISTMottScatteringAngle::totalCrossSection(const double energy) const
   {
      if (energy < MAX_NISTMOTT) {
         double scale = PhysicalConstants::BohrRadius * PhysicalConstants::BohrRadius;
         double logE = ::log(FromSI::eV(energy));
         int j = 1 + (int)((logE - DL50) / PARAM);
         if (j == 1)
            return value(DL50, DL50 + PARAM, DL50 + 2.0 * PARAM, mSpwem[0], mSpwem[1], mSpwem[2], logE) * scale;
         else if (j == SPWEM_LEN)
            return value(DL50 + 58.0 * PARAM, DL50 + 59.0 * PARAM, DL50 + 60.0 * PARAM, mSpwem[SPWEM_LEN - 3], mSpwem[SPWEM_LEN - 2], mSpwem[SPWEM_LEN - 1], logE)
            * scale;
         else {
            double e0 = DL50 + (j - 2) * PARAM;
            return value(e0, e0 + PARAM, e0 + 2.0 * PARAM, mSpwem[j - 2], mSpwem[j - 1], mSpwem[j], logE) * scale;
         }
      }
      else {
         return mRutherford.totalCrossSection(energy);
      }
   }

   double NISTMottScatteringAngle::randomScatteringAngle(const double energy) const
   {
      if (energy < MAX_NISTMOTT) {
         double logE = ::log(FromSI::eV(energy));
         int j = (int)((logE - DL50) / PARAM); // offset to zero-based
         double e2 = DL50 + (j + 1) * PARAM;
         double e1 = e2 - PARAM;
         int i = (logE - e1 < e2 - logE ? j : j + 1); // offset to zero-based
         if (!((i >= 0) && (i < SPWEM_LEN))) printf("%d %s %lf %s %lf %s %lf\n", i, "\t", FromSI::eV(energy), "\t", e1, "\t", e2);
         // via j
         int k = Math2::randomInt(200); // offset to zero-based
         double x = (mX1[i][k + 1] - mX1[i][k]) * Math2::random();
         double q = mX1[i][k] + x;
         double com = 1.0 - 2.0 * q * q;
         return com > -1.0 ? (com < 1.0 ? ::acos(com) : 0.0) : PhysicalConstants::PI;
      }
      else {
         return mRutherford.randomScatteringAngle(energy);
      }
   }

   const VectorXd& NISTMottScatteringAngle::getSpwem() const
   {
      return mSpwem;
   }

   const MatrixXd& NISTMottScatteringAngle::getX1() const
   {
      return mX1;
   }

   const NISTMottScatteringAngle* mScatter[113];

   void init()
   {
      mScatter[1] = new NISTMottScatteringAngle(Element::H);
      mScatter[2] = new NISTMottScatteringAngle(Element::He);
      mScatter[3] = new NISTMottScatteringAngle(Element::Li);
      mScatter[4] = new NISTMottScatteringAngle(Element::Be);
      mScatter[5] = new NISTMottScatteringAngle(Element::B);
      mScatter[6] = new NISTMottScatteringAngle(Element::C);
      mScatter[7] = new NISTMottScatteringAngle(Element::N);
      mScatter[8] = new NISTMottScatteringAngle(Element::O);
      mScatter[9] = new NISTMottScatteringAngle(Element::F);
      mScatter[10] = new NISTMottScatteringAngle(Element::Ne);
      mScatter[11] = new NISTMottScatteringAngle(Element::Na);
      mScatter[12] = new NISTMottScatteringAngle(Element::Mg);
      mScatter[13] = new NISTMottScatteringAngle(Element::Al);
      mScatter[14] = new NISTMottScatteringAngle(Element::Si);
      mScatter[15] = new NISTMottScatteringAngle(Element::P);
      mScatter[16] = new NISTMottScatteringAngle(Element::S);
      mScatter[17] = new NISTMottScatteringAngle(Element::Cl);
      mScatter[18] = new NISTMottScatteringAngle(Element::Ar);
      mScatter[19] = new NISTMottScatteringAngle(Element::K);
      mScatter[20] = new NISTMottScatteringAngle(Element::Ca);
      mScatter[21] = new NISTMottScatteringAngle(Element::Sc);
      mScatter[22] = new NISTMottScatteringAngle(Element::Ti);
      mScatter[23] = new NISTMottScatteringAngle(Element::V);
      mScatter[24] = new NISTMottScatteringAngle(Element::Cr);
      mScatter[25] = new NISTMottScatteringAngle(Element::Mn);
      mScatter[26] = new NISTMottScatteringAngle(Element::Fe);
      mScatter[27] = new NISTMottScatteringAngle(Element::Co);
      mScatter[28] = new NISTMottScatteringAngle(Element::Ni);
      mScatter[29] = new NISTMottScatteringAngle(Element::Cu);
      mScatter[30] = new NISTMottScatteringAngle(Element::Zn);
      mScatter[31] = new NISTMottScatteringAngle(Element::Ga);
      mScatter[32] = new NISTMottScatteringAngle(Element::Ge);
      mScatter[33] = new NISTMottScatteringAngle(Element::As);
      mScatter[34] = new NISTMottScatteringAngle(Element::Se);
      mScatter[35] = new NISTMottScatteringAngle(Element::Br);
      mScatter[36] = new NISTMottScatteringAngle(Element::Kr);
      mScatter[37] = new NISTMottScatteringAngle(Element::Rb);
      mScatter[38] = new NISTMottScatteringAngle(Element::Sr);
      mScatter[39] = new NISTMottScatteringAngle(Element::Y);
      mScatter[40] = new NISTMottScatteringAngle(Element::Zr);
      mScatter[41] = new NISTMottScatteringAngle(Element::Nb);
      mScatter[42] = new NISTMottScatteringAngle(Element::Mo);
      mScatter[43] = new NISTMottScatteringAngle(Element::Tc);
      mScatter[44] = new NISTMottScatteringAngle(Element::Ru);
      mScatter[45] = new NISTMottScatteringAngle(Element::Rh);
      mScatter[46] = new NISTMottScatteringAngle(Element::Pd);
      mScatter[47] = new NISTMottScatteringAngle(Element::Ag);
      mScatter[48] = new NISTMottScatteringAngle(Element::Cd);
      mScatter[49] = new NISTMottScatteringAngle(Element::In);
      mScatter[50] = new NISTMottScatteringAngle(Element::Sn);
      mScatter[51] = new NISTMottScatteringAngle(Element::Sb);
      mScatter[52] = new NISTMottScatteringAngle(Element::Te);
      mScatter[53] = new NISTMottScatteringAngle(Element::I);
      mScatter[54] = new NISTMottScatteringAngle(Element::Xe);
      mScatter[55] = new NISTMottScatteringAngle(Element::Cs);
      mScatter[56] = new NISTMottScatteringAngle(Element::Ba);
      mScatter[57] = new NISTMottScatteringAngle(Element::La);
      mScatter[58] = new NISTMottScatteringAngle(Element::Ce);
      mScatter[59] = new NISTMottScatteringAngle(Element::Pr);
      mScatter[60] = new NISTMottScatteringAngle(Element::Nd);
      mScatter[61] = new NISTMottScatteringAngle(Element::Pm);
      mScatter[62] = new NISTMottScatteringAngle(Element::Sm);
      mScatter[63] = new NISTMottScatteringAngle(Element::Eu);
      mScatter[64] = new NISTMottScatteringAngle(Element::Gd);
      mScatter[65] = new NISTMottScatteringAngle(Element::Tb);
      mScatter[66] = new NISTMottScatteringAngle(Element::Dy);
      mScatter[67] = new NISTMottScatteringAngle(Element::Ho);
      mScatter[68] = new NISTMottScatteringAngle(Element::Er);
      mScatter[69] = new NISTMottScatteringAngle(Element::Tm);
      mScatter[70] = new NISTMottScatteringAngle(Element::Yb);
      mScatter[71] = new NISTMottScatteringAngle(Element::Lu);
      mScatter[72] = new NISTMottScatteringAngle(Element::Hf);
      mScatter[73] = new NISTMottScatteringAngle(Element::Ta);
      mScatter[74] = new NISTMottScatteringAngle(Element::W);
      mScatter[75] = new NISTMottScatteringAngle(Element::Re);
      mScatter[76] = new NISTMottScatteringAngle(Element::Os);
      mScatter[77] = new NISTMottScatteringAngle(Element::Ir);
      mScatter[78] = new NISTMottScatteringAngle(Element::Pt);
      mScatter[79] = new NISTMottScatteringAngle(Element::Au);
      mScatter[80] = new NISTMottScatteringAngle(Element::Hg);
      mScatter[81] = new NISTMottScatteringAngle(Element::Tl);
      mScatter[82] = new NISTMottScatteringAngle(Element::Pb);
      mScatter[83] = new NISTMottScatteringAngle(Element::Bi);
      mScatter[84] = new NISTMottScatteringAngle(Element::Po);
      mScatter[85] = new NISTMottScatteringAngle(Element::At);
      mScatter[86] = new NISTMottScatteringAngle(Element::Rn);
      mScatter[87] = new NISTMottScatteringAngle(Element::Fr);
      mScatter[88] = new NISTMottScatteringAngle(Element::Ra);
      mScatter[89] = new NISTMottScatteringAngle(Element::Ac);
      mScatter[90] = new NISTMottScatteringAngle(Element::Th);
      mScatter[91] = new NISTMottScatteringAngle(Element::Pa);
      mScatter[92] = new NISTMottScatteringAngle(Element::U);
      mScatter[93] = new NISTMottScatteringAngle(Element::Np);
      mScatter[94] = new NISTMottScatteringAngle(Element::Pu);
      mScatter[95] = new NISTMottScatteringAngle(Element::Am);
      mScatter[96] = new NISTMottScatteringAngle(Element::Cm);
   }

   const NISTMottScatteringAngle& getNISTMSA(int an)
   {
      return *mScatter[an];
   }

   NISTMottRandomizedScatterFactory::NISTMottRandomizedScatterFactory() : RandomizedScatterFactoryT("NIST Mott Inelastic Cross-Section", REFERENCE)
   {
   }

   void NISTMottRandomizedScatterFactory::initializeDefaultStrategy()
   {
   }

   const RandomizedScatterT& NISTMottRandomizedScatterFactory::get(const ElementT& elm) const
   {
      return getNISTMSA(elm.getAtomicNumber());
   }

   const NISTMottRandomizedScatterFactory NISTMottRandomizedFactory;
   const RandomizedScatterFactoryT& Factory = NISTMottRandomizedFactory;
}
