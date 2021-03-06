#include "gov\nist\microanalysis\EPQLibrary\MaterialFactory.cuh"
#include "gov\nist\microanalysis\EPQLibrary\Composition.cuh"
#include "gov\nist\microanalysis\EPQLibrary\Material.cuh"

namespace MaterialFactory
{
   const StringT K3189 = "K3189";
   const StringT RynasAlTiAlloy = "Ryna's Al-Ti alloy";
   const StringT Mylar = "Mylar";
   const StringT VanadiumPentoxide = "Vanadium Pentoxide";
   const StringT SiliconDioxide = "Silicon Dioxide";
   const StringT Ice = "Ice";
   const StringT PerfectVacuum = "Perfect vacuum";
   const StringT CaCO3 = "Calcium carbonate";
   const StringT Al2O3 = "Alumina";
   const StringT SS316 = "Stainless Steel 316";
   const StringT UraniumOxide = "Uranium oxide";
   const StringT K227 = "K227";
   const StringT K309 = "K309";
   const StringT K411 = "K411";
   const StringT K412 = "K412";
   const StringT K961 = "K961";
   const StringT K1080 = "K1080";
   const StringT K2450 = "K2450";
   const StringT K2451 = "K2451";
   const StringT K2466 = "K2466";
   const StringT K2469 = "K2469";
   const StringT K2472 = "K2472";
   const StringT K2496 = "K2496";
   const StringT ParaleneC = "Paralene C";
   const StringT MagnesiumOxide = "Magnesium Oxide";
   const StringT Chloroapatite = "Chloroapatite";
   const StringT CalciumFluoride = "Calcium Fluoride";
   const StringT GalliumPhosphate = "Gallium Phosphate";
   const StringT Nothing = "None";

   typedef std::unordered_map<StringT, CompositionT*> CompositionMap;

   static const StringT PBaseMaterials[] = {
      K3189,
      RynasAlTiAlloy,
      Mylar,
      VanadiumPentoxide,
      SiliconDioxide,
      Ice,
      CaCO3,
      Al2O3,
      SS316,
      UraniumOxide,
      K227,
      K309,
      K411,
      K412,
      K961,
      K1080,
      K2450,
      K2451,
      K2466,
      K2469,
      K2472,
      K2496,
      ParaleneC,
      MagnesiumOxide,
      Chloroapatite,
      CalciumFluoride
   };

   //public static List<String> BaseMaterials = Collections.unmodifiableList(Arrays.asList(PBaseMaterials));

   const double mElementalDensities[] = {
      0.0,
      0.0,
      0.534,
      1.85,
      2.53,
      2.25,
      0.0,
      0.0,
      0.0,
      0.0,
      0.97,
      1.74,
      2.70, // H to Ne
      2.42,
      1.83 /* Yellow */,
      1.92,
      0.0,
      0.0,
      0.86,
      1.55,
      3.02,
      4.5,
      5.98,
      7.14,
      7.41,
      7.88,
      8.71,
      8.88,
      8.96,
      7.1,
      5.93, // Ga
      5.46,
      5.73,
      4.82,
      0.0,
      0.0,
      1.53,
      2.56,
      3.8,
      6.4,
      8.57,
      10.22,
      11.5,
      12.1,
      12.44,
      12.16,
      10.49,
      8.65,
      7.28,
      7.3, // Sn
      6.62,
      6.25,
      4.94,
      0.0,
      1.87,
      3.5,
      6.15,
      6.90,
      6.48,
      6.96,
      -1.0,
      7.75,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0, // Cs to Dy
      -1.0,
      13.3,
      16.6,
      19.3,
      -1.0,
      22.5,
      22.42,
      21.45,
      19.3,
      14.19 /* solid at -39 C */,
      11.86,
      11.34,
      9.78,
      -1.0,
      -1.0, // Ho to Pt
      0.0,
      -1.0,
      -1.0,
      -1.0,
      11.3,
      -1.0,
      18.7,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0, // Fr to Es
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0,
      -1.0
      // Fm to Uub
   };

   bool canCreate(const ElementT& el)
   {
      return mElementalDensities[el.getAtomicNumber() - 1] > 0.0;
   }

   typedef std::unordered_map <const ElementT*, int> ElementMap; 

   static bool isUpperCase(char c)
   {
      return c >= 65 && c <= 90;
   }

   static bool isDigit(char c)
   {
      return c >= 48&& c <= 57;
   }

   ElementMap parseCompound(StringT str)
   {
      ElementMap elMap;

      StringT elStr;
      char c = (str.length() > 0 ? str.at(0) : INT_MIN);
      for (int i = 0; c != NULL; ++i) {
         c = (i < str.length() ? str.at(i) : NULL);
         if (isUpperCase(c) || isDigit(c) || (c == '(') || (c == NULL)) {
            if (elStr.length() > 0) {
               const ElementT& el = Element::byName(elStr.c_str());
               int count = 1;
               if (!el.isValid()) printf("Unrecognized element %s in %s.", elStr.c_str(), str.c_str());
               elStr = "";
               if (isDigit(c)) {
                  while (isDigit(c)) {
                     elStr += c;
                     ++i;
                     c = (i < str.length() ? str.at(i) : NULL);
                  }
                  count = std::atoi(elStr.c_str());
               }
               int ii = elMap[&el];
               elMap[&el] = ii + count;
               elStr = "";
            }
            while (c == '(') {
               int br = 1;
               for (++i; br > 0; ++i) {
                  c = (i < str.length() ? str.at(i) : NULL);
                  if (c == NULL)
                     printf("Unmatched bracket in %s\n", str.c_str());
                  if (c == ')')
                     --br;
                  if (c == '(')
                     ++br;
                  if (br > 0)
                     elStr += c;
               }
               // Parse bracketed items recursively
               ElementMap subComp = parseCompound(elStr);
               elStr = "";
               c = (i < str.length() ? str.at(i) : NULL);
               int count = 1;
               // Get the count of the bracketed items
               if (isDigit(c)) {
                  while (isDigit(c)) {
                     elStr += c;
                     ++i;
                     c = (i < str.length() ? str.at(i) : NULL);
                  }
                  count = std::atoi(elStr.c_str());
                  elStr = "";
               }
               for (auto e : subComp) {
                  const ElementT* elm = e.first;
                  int ic = elMap[elm];
                  elMap[elm] = ic + count * e.second;
               }
            }
            elStr += c;
         }
         else
            elStr += c;
      }
      // Check for K411 and other anomalies
      if (elMap.size() == 1)
         if (elMap.begin()->second > 1)
            printf("Unusually formated pure element in, ", str.c_str());
      return elMap;
   }

   CompositionT createCompound1(StringT str)
   {
      ElementMap elMap = parseCompound(str);
      CompositionT comp;
      comp.setName(str);
      for (auto e : elMap) comp.addElementByStoiciometry(*e.first, e.second);
      return comp;
   }

   static MaterialT createCompound(StringT str, double density)
   {
      return MaterialT(createCompound(str), density);
   }

   CompositionT createCompound(StringT str)
   {
      {
         int p = str.find("+");
         if (p != std::string::npos) {
            CompositionT cl = createCompound(str.substr(0, p));
            CompositionT cr = createCompound(str.substr(p + 1));
            auto cles = cl.getElementSet();
            auto cres = cr.getElementSet();
            std::unordered_set<const ElementT*> elms;
            elms.insert(cles.begin(), cles.end());
            elms.insert(cres.begin(), cres.end());

            std::vector<const ElementT*> elmA(elms.begin(), elms.end());
            VectorXd massFracs(elms.size());
            for (int i = 0; i < elmA.size(); ++i)
               massFracs[i] = cl.weightFraction(*elmA[i], false) + cr.weightFraction(*elmA[i], false);
            
            CompositionT ret(elmA.data(), elmA.size(), massFracs.data(), massFracs.size());
            return ret;
         }
      }
      {
         int p = str.find("*");
         if (p != std::string::npos) {
            double k;
            try {
               k = std::atof(str.substr(0, p).c_str());
            }
            catch (std::exception&) {
               printf("Error parsing number: %s\n", str.substr(0, p));
            }
            CompositionT cr = createCompound(str.substr(p + 1));
            auto elms = cr.getElementSet();
            std::vector<const ElementT*> elmA(elms.begin(), elms.end());
            std::vector<double> massFracs(elms.size());
            for (int i = 0; i < elmA.size(); ++i)
               massFracs[i] = k * cr.weightFraction(*elmA[i], false);
            CompositionT ret(elmA.data(), elmA.size(), massFracs.data(), massFracs.size());
            return ret;
         }
      }
      return createCompound1(str);
   }

   static const CompositionT compoundSiO2 = createCompound("SiO2");
   static const CompositionT compoundAl2O3 = createCompound("Al2O3");
   static const CompositionT compoundCaO = createCompound("CaO");
   static const CompositionT compoundMgO = createCompound("MgO");
   static const CompositionT compoundTiO2 = createCompound("TiO2");
   static const CompositionT compoundFe2O3 = createCompound("Fe2O3");
   static const CompositionT compoundPbO = createCompound("PbO");
   static const CompositionT compoundBaO = createCompound("BaO");
   static const CompositionT compoundFeO = createCompound("FeO");
   static const CompositionT compoundV2O5 = createCompound("V2O5");

   CompositionT createMaterial(StringT name)
   {
      try {
         if (name == K3189) {
            const CompositionT* comp[] = { &compoundSiO2, &compoundAl2O3, &compoundCaO, &compoundMgO, &compoundTiO2, &compoundFe2O3 };
            double massFracs[] = { 0.400000, 0.140000, 0.140000, 0.100000, 0.020000, 0.200000 };
            CompositionT tmp;
            tmp.defineByMaterialFraction(comp, 6, massFracs, 6);
            MaterialT mat(tmp, ToSI::gPerCC(3.23));
            mat.setName(K3189);
            return mat;
         }
         else if (name == (RynasAlTiAlloy)) {
            const ElementT* elms[] = { &Element::Ti, &Element::Al, &Element::Nb, &Element::W };
            double massFracs[] = { 0.54, 0.31, 0.11, 0.04 };
            double density = ToSI::gPerCC(8.57);
            StringT name = RynasAlTiAlloy;
            return MaterialT(elms, 4, massFracs, 4, density, name.c_str());;
         } 
         else if (name == (Mylar)) {
            MaterialT mat = createCompound("C10H8O4", ToSI::gPerCC(1.39));
            mat.setName(Mylar);
            return mat;
         }
         else if (name == (VanadiumPentoxide)) {
            MaterialT mat = createCompound("V2O5", ToSI::gPerCC(3.357));
            mat.setName(VanadiumPentoxide);
            return mat;
         }
         else if (name == (SiliconDioxide)) {
            MaterialT mat = createCompound("SiO2", ToSI::gPerCC(2.65));
            mat.setName(SiliconDioxide);
            return mat;
         }
         else if (name == (Ice)) {
            MaterialT mat = createCompound("H2O", ToSI::gPerCC(0.917));
            mat.setName(Ice);
            return mat;
         }
         else if (name == (PerfectVacuum)) {
            MaterialT mat(0.0);
            mat.setName(PerfectVacuum);
            return mat;
         }
         else if (name == (CaCO3)) {
            MaterialT mat = createCompound("CaCO3", ToSI::gPerCC(2.7));
            mat.setName(CaCO3);
            return mat;
         }
         else if (name == (Al2O3)) {
            MaterialT mat = createCompound("Al2O3", ToSI::gPerCC(3.97));
            mat.setName(Al2O3);
            return mat;
         }
         else if (name == (SS316)) {
            const ElementT* elms[] = { &Element::Fe, &Element::Ni, &Element::Cr, &Element::Mn, &Element::Si };
            double massFracs[] = { 0.50, 0.205, 0.245, 0.02, 0.03 };
            double density = ToSI::gPerCC(7.8);
            StringT name("SS316");
            MaterialT mat(elms, 5, massFracs, 5, density, name.c_str());
            return mat;
         } else if (name == (UraniumOxide)) {
            MaterialT mat = createCompound("UO2", ToSI::gPerCC(10.0));
            mat.setName(UraniumOxide);
         }
         else if (name == (K227)) {
            const CompositionT* cons[] = { &compoundSiO2, &compoundPbO };
            double massFracs[] = { 0.20000, 0.80000, };
            CompositionT comp;
            comp.defineByMaterialFraction(cons, 2, massFracs, 2);
            comp.setName(K227);
            return comp;
         }
         else if (name == (K309)) {
            CompositionT comp;
            const CompositionT* cons[] = { &compoundAl2O3, &compoundSiO2, &compoundCaO, &compoundFe2O3, &compoundBaO };
            double massFracs[] = { 0.15000, 0.40000, 0.15000, 0.15000, 0.15000, };
            comp.defineByMaterialFraction(cons, 5, massFracs, 5);
            comp.setName(K309);
            return comp;
         }
         else if (name == (K411)) {
            const CompositionT* cons[] = { &compoundMgO, &compoundSiO2, &compoundCaO, &compoundFeO };
            double massFracs[] = { 0.146700, 0.543000, 0.154700, 0.144200 };
            CompositionT comp;
            comp.defineByMaterialFraction(cons, 4, massFracs, 4);
            comp.setName(K411);
            return MaterialT(comp, ToSI::gPerCC(5.0));
         }
         else if (name == (K412)) {
            CompositionT comp;
            const CompositionT* cons[] = { &compoundMgO, &compoundAl2O3, &compoundSiO2, &compoundCaO, &compoundFeO };
            double massFracs[] = { 0.193300, 0.092700, 0.453500, 0.152500, 0.099600 };
            comp.defineByMaterialFraction(cons, 5, massFracs, 5);
            comp.setName(K412);
            return comp;
         }
         else if (name == (K961)) {
            const ElementT* elms[] = { &Element::Na, &Element::Mg, &Element::Al, &Element::Si, &Element::P, &Element::K, &Element::Ca, &Element::Ti, &Element::Mn, &Element::Fe, &Element::O };
            double massFracs[] = { 0.029674, 0.030154, 0.058215, 0.299178, 0.002182, 0.024904, 0.035735, 0.011990, 0.003160, 0.034972, 0.469837 };
            return MaterialT(elms, 11, massFracs, 11, ToSI::gPerCC(6.0), K961.c_str());
         }
         else if (name == (K1080)) {
            const ElementT* elms[] = { &Element::Li, &Element::B, &Element::Mg, &Element::Al, &Element::Si, &Element::Ca, &Element::Ti, &Element::Sr, &Element::Zr, &Element::Lu, &Element::O };
            double massFracs[] = { 0.027871, 0.006215, 0.008634, 0.079384, 0.186986, 0.107204, 0.011990, 0.126838, 0.007403, 0.017588, 0.416459 };
            return MaterialT(elms, 11, massFracs, 11, ToSI::gPerCC(6.0), K1080.c_str());
         }
         else if (name == (K2450)) {
            const CompositionT* cons[] = { &compoundSiO2, &compoundAl2O3, &compoundCaO, &compoundTiO2 };
            double massFracs[] = { 0.30000, 0.30000, 0.30000, 0.10000 };
            CompositionT comp;
            comp.defineByMaterialFraction(cons, 4, massFracs, 4);
            comp.setName(name);
            return comp;
         }
         else if (name == (K2451)) {
            const CompositionT* cons[] = { &compoundSiO2, &compoundAl2O3, &compoundCaO, &compoundV2O5 };
            double massFracs[] = { 0.300000, 0.300000, 0.300000, 0.100000 };
            CompositionT comp;
            comp.defineByMaterialFraction(cons, 4, massFracs, 4);
            comp.setName(name);
            return comp;
         }
         else if (name == (K2466)) {
            CompositionT comp;
            const CompositionT* cons[] = { &compoundSiO2, &compoundBaO, &compoundTiO2 };
            double massFracs[] = { 0.44, 0.48, 0.08 };
            comp.defineByMaterialFraction(cons, 3, massFracs, 3);
            comp.setName(name);
            return comp;
         }
         else if (name == (K2469)) {
            const CompositionT* cons[] = { &compoundSiO2, &compoundBaO, &compoundTiO2 };
            double massFracs[] = { 0.36, 0.48, 0.16 };
            CompositionT comp;
            comp.defineByMaterialFraction(cons, 3, massFracs, 3);
            comp.setName(name);
            return comp;
         }
         else if (name == (K2472)) {
            const CompositionT* cons[] = { &compoundSiO2, &compoundBaO, &compoundTiO2, &compoundV2O5 };
            double massFracs[] = { 0.36, 0.48, 0.10, 0.06 };
            CompositionT comp;
            comp.defineByMaterialFraction(cons, 4, massFracs, 4);
            comp.setName(name);
            return comp;
         }
         else if (name == (K2496)) {
            CompositionT comp;
            const CompositionT* cons[] = { &compoundSiO2, &compoundBaO, &compoundTiO2 };
            double massFracs[] = { 0.49, 0.48, 0.03 };
            comp.defineByMaterialFraction(cons, 3, massFracs, 3);
            comp.setName(name);
            return comp;
         }
         else if (name == (ParaleneC)) {
            MaterialT mat = createCompound("C8H7Cl", ToSI::gPerCC(1.2));
            mat.setName(ParaleneC);
            return mat;
         }
         else if (name == (MagnesiumOxide)) {
            MaterialT mat = createCompound("MgO", ToSI::gPerCC(3.55));
            mat.setName(MagnesiumOxide);
            return mat;
         }
         else if (name == (CalciumFluoride)) {
            MaterialT mat = createCompound("CaF2", ToSI::gPerCC(3.18));
            mat.setName(CalciumFluoride);
            return mat;
         }
         else if (name == (Chloroapatite)) {
            MaterialT mat = createCompound("Ca5(PO4)3Cl", ToSI::gPerCC(3.15));
            mat.setName(Chloroapatite);
            return mat;
         }
         else if (name == (GalliumPhosphate)) {
            MaterialT mat = createCompound("GaPO4", ToSI::gPerCC(3.570));
            mat.setName(GalliumPhosphate);
            return mat;
         }
         else if (name == (Nothing)) {
            MaterialT mat(0.0);
            mat.setName("None");
            return mat;
         }
      }
      catch (std::exception&) {
         printf("failed creating material");
      }
   }
}