//#ifndef _COMPOSITION_CUH_
//#define _COMPOSITION_CUH_
//
//#include "Amphibian\LinkedList.cuh"
//#include "Amphibian\String.cuh"
//
//#include "Element.cuh"
//#include "gov\nist\microanalysis\Utility\UncertainValue2.cuh"
//
//#include <cuda_runtime.h>
//
//namespace Composition
//{
//   enum Representation
//   {
//      UNDETERMINED, WEIGHT_PCT, STOICIOMETRY
//   };
//
//   class Composition
//   {
//   public:
//      typedef Map::Map<Element::Element, double, String::CompareFcn, Comparator::DoubleCompareFcn, String::HashFcn, Hasher::DoubleHashFcn> CompositionMap;
//      typedef Map::Iterator<Element::Element, double, String::CompareFcn, Comparator::DoubleCompareFcn, String::HashFcn, Hasher::DoubleHashFcn> CompositionMapItr;
//
//      __device__ Composition();
//      //__device__ ~Composition();
//      //__device__ Composition(Composition& comp);
//      //__device__ Composition(Element::Element elms[], int elmsLen, double massFracs[], int massFracsLen);
//      //__device__ Composition(Element::Element elm);
//      //__device__ Composition(Element::Element elms[], int elmsLen, double massFracs[], int massFracsLen, char* name);
//
//      //__device__ Set::Set<Element::Element> getElementSet();
//      //__device__ Set::Set<Element::Element> getSortedElements();
//      //__device__ int getElementCount();
//      //__device__ void addElement(int atomicNo, double massFrac);
//      //__device__ void addElement(int atomicNo, UncertainValue2::UncertainValue2 massFrac);
//      //__device__ void addElement(Element::Element elm, double massFrac);
//      //__device__ double weightFraction(Element::Element elm, bool normalized);
//      //__device__ void addElement(Element::Element elm, UncertainValue2::UncertainValue2 massFrac);
//      //__device__ UncertainValue2::UncertainValue2 weightFractionU(Element::Element elm, bool normalized);
//      //__device__ UncertainValue2::UncertainValue2 weightFractionU(Element::Element elm, bool normalized, bool positiveOnly);
//      //__device__ void addElementByStoiciometry(Element::Element elm, UncertainValue2::UncertainValue2 moleFrac);
//      //__device__ void addElementByStoiciometry(Element::Element elm, double moleFrac);
//      //__device__ UncertainValue2::UncertainValue2 atomicPercentU(Element::Element elm);
//      //__device__ UncertainValue2::UncertainValue2 atomicPercentU(Element::Element elm, bool positiveOnly);
//      //__device__ void defineByWeightFraction(Element::Element elms[], int elmsLen, double wgtFracs[], int wgtFracsLen);
//      //__device__ void defineByWeightFraction(Element::Element elms[], int elmsLen, UncertainValue2::UncertainValue2 wgtFracs[], int wgtFracsLen);
//      //__device__ void defineByWeightFraction(LinkedListKV::Node<Element::Element, double> map);
//      //__device__ UncertainValue2::UncertainValue2 stoichiometryU(Element::Element elm);
//      //__device__ double atomsPerKg(Element::Element elm, bool normalized);
//      //__device__ UncertainValue2::UncertainValue2 atomsPerKgU(Element::Element elm, bool normalized);
//
//      //template<typename T>
//      //__device__ Element::Element GetElementBy(T k)
//      //{
//      //   return NULL;
//      //}
//
//      //template<>
//      //__device__ Element::Element GetElementBy<int>(int k)
//      //{
//      //   return Element::byAtomicNumber(k);
//      //}
//
//      //template<>
//      //__device__ Element::Element GetElementBy<String::String>(String::String s)
//      //{
//      //   return Element::byName(s.Get());
//      //}
//
//      //template<>
//      //__device__ Element::Element GetElementBy<Element::Element>(Element::Element e)
//      //{
//      //   return e;
//      //}
//
//      //template<typename T>
//      //__device__ void defineByWeightFraction(LinkedListKV::Node<T, double>* map)
//      //{
//      //   while (map != NULL) {
//      //      double wp = map->GetValue();
//      //      T key = map->GetKey();
//      //      Element::Element elm = GetElementBy<T>(key);
//      //      if (*((int*)&elm) == NULL) {
//      //         printf("Composition::defineByWeightFraction: wrong type");
//      //      }
//      //      if (elm.getAtomicNumber() == Element::elmNone) {
//      //         printf("Composition::defineByWeightFraction: bad element");
//      //      }
//      //      if ((*((int*)&elm) != NULL) && (elm.getAtomicNumber() == Element::elmNone)) {
//      //         LinkedListKV::InsertHead(&mConstituents, elm, UncertainValue2::UncertainValue2(wp));
//      //      }
//      //   }
//      //   recomputeStoiciometry();
//      //   renormalize();
//      //}
//
//      //__device__ void defineByMoleFraction(Element::Element elms[], int elmsLen, double moleFracs[], int moleFracsLen);
//      //__device__ void setOptimalRepresentation(Representation opt);
//      //__device__ void defineByMaterialFraction(Composition compositions[], int compLen, double matFracs[], int matFracsLen);
//      //__device__ void removeElement(Element::Element el);
//      //__device__ bool containsElement(Element::Element el);
//      //__device__ bool containsAll(LinkedList::Node<Element::Element>* elms);
//      //__device__ double atomicPercent(Element::Element elm);
//      //__device__ double stoichiometry(Element::Element elm);
//      //__device__ UncertainValue2::UncertainValue2 weightAvgAtomicNumberU();
//      //__device__ double weightAvgAtomicNumber();
//      //__device__ double sumWeightFraction();
//      //__device__ UncertainValue2::UncertainValue2 sumWeightFractionU();
//      //////__device__ String::String toString();
//      //////__device__ String::String stoichiometryString();
//      //////__device__ String::String weightPercentString(bool normalize);
//      //////__device__ String::String descriptiveString(bool normalize);
//      ////__device__ Element::Element getNthElementByWeight(int n);
//      ////__device__ Element::Element getNthElementByAtomicFraction(int n);
//      //__device__ void setName(String::String name);
//      //__device__ String::String getName();
//      //__device__ int compareTo(Composition& comp);
//      //__device__ Composition asComposition();
//      //__device__ Composition clone();
//      //__device__ UncertainValue2::UncertainValue2 differenceU(Composition& comp);
//      //__device__ double difference(Composition& comp);
//      //__device__ Representation getOptimalRepresentation();
//      ////__device__ int hashCode();
//      //__device__ bool equals(Composition& other);
//      //__device__ bool almostEquals(Composition& other, double tol);
//      //__device__ Map::Map<Element::Element, double> absoluteError(Composition& std, bool normalize);
//      //__device__ Map::Map<Element::Element, double> relativeError(Composition& std, bool normalize);
//      //__device__ bool isUncertain();
//      //__device__ UncertainValue2::UncertainValue2 meanAtomicNumberU();
//      //__device__ double meanAtomicNumber();
//      //__device__ void forceNormalization();
//      //__device__ Composition randomize(double offset, double proportional);
//      //__device__ long indexHashCodeS();
//      //__device__ long indexHashCodeL();
//
//      //__device__ bool AreEqualConstituents(LinkedListKV::Node<Element::Element, UncertainValue2::UncertainValue2>* a, LinkedListKV::Node<Element::Element, UncertainValue2::UncertainValue2>* b);
//      //__device__ Map::Map<Element::Element, UncertainValue2::UncertainValue2> GetConstituents();
//
//   private:
//      //__device__ Composition readResolve();
//      //__device__ void recomputeStoiciometry();
//      //__device__ void recomputeWeightFractions();
//
//      //Map::Map<Element::Element, UncertainValue2::UncertainValue2> mConstituents;
//      CompositionMap mConstituents;
//      //LinkedListKV::Node<Element::Element, UncertainValue2::UncertainValue2>* mConstituentsAtomic;
//
//      //UncertainValue2::UncertainValue2 mNormalization;// = UncertainValue2::UncertainValue2(1); // UncertainValue2::ONE();
//      //UncertainValue2::UncertainValue2 mAtomicNormalization;// = UncertainValue2::UncertainValue2(1); // UncertainValue2::ONE();
//      //String::String mName;
//      //Representation mOptimalRepresentation;// = Representation::UNDETERMINED;
//      //UncertainValue2::UncertainValue2 mMoleNorm;// = UncertainValue2::NaN();
//
//   protected:
//      //__device__ void renormalize();
//      //__device__ void replicate(Composition& comp);
//      //__device__ void clear();
//
//      int mHashCode; // = CUDART_INF_F;
//   };
//
//   //__device__ Composition positiveDefinite(Composition& comp);
//   //__device__ UncertainValue2::UncertainValue2 normalize(UncertainValue2::UncertainValue2& val, UncertainValue2::UncertainValue2& norm, bool positive);
//   //__device__ Composition parseGlass(char str[], int numlines);
//   //void createProjectors(long seed);
//}
//#endif
