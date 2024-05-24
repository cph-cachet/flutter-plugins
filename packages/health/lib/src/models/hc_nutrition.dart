part of health;

class HealthConnectNutrition extends HealthConnectData {
  final DateTime startTime;
  final DateTime endTime;

  final MealType? mealType;

  /// Name for food or drink, provided by the user. Optional field. */
  final String? name;

  /// Zinc in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? zinc;

  /// Vitamin K in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? vitaminK;

  /// Biotin in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? biotin;

  /// Caffeine in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? caffeine;

  /// Calcium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? calcium;

  /// Energy in [Energy] unit. Optional field. Valid range: 0-100000 kcal. */
  final Energy? energy;

  /// Energy from fat in [Energy] unit. Optional field. Valid range: 0-100000 kcal. */
  final Energy? energyFromFat;

  /// Chloride in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? chloride;

  /// Cholesterol in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? cholesterol;

  /// Chromium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? chromium;

  /// Copper in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? copper;

  /// Dietary fiber in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  final Mass? dietaryFiber;

  /// Folate in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? folate;

  /// Folic acid in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? folicAcid;

  /// Iodine in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? iodine;

  /// Iron in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? iron;

  /// Magnesium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? magnesium;

  /// Manganese in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? manganese;

  /// Molybdenum in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? molybdenum;

  /// Monounsaturated fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  final Mass? monounsaturatedFat;

  /// Niacin in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? niacin;

  /// Pantothenic acid in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? pantothenicAcid;

  /// Phosphorus in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? phosphorus;

  /// Polyunsaturated fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  final Mass? polyunsaturatedFat;

  /// Potassium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? potassium;

  /// Protein in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  final Mass? protein;

  /// Riboflavin in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? riboflavin;

  /// Saturated fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  final Mass? saturatedFat;

  /// Selenium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? selenium;

  /// Sodium in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? sodium;

  /// Sugar in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  final Mass? sugar;

  /// Thiamin in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? thiamin;

  /// Total carbohydrate in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  final Mass? totalCarbohydrate;

  /// Total fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  final Mass? totalFat;

  /// Trans fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  final Mass? transFat;

  /// Unsaturated fat in [Mass] unit. Optional field. Valid range: 0-100000 grams. */
  final Mass? unsaturatedFat;

  /// Vitamin A in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? vitaminA;

  /// Vitamin B12 in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? vitaminB12;

  /// Vitamin B6 in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? vitaminB6;

  /// Vitamin C in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? vitaminC;

  /// Vitamin D in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? vitaminD;

  /// Vitamin E in [Mass] unit. Optional field. Valid range: 0-100 grams. */
  final Mass? vitaminE;

  HealthConnectNutrition(
    this.startTime,
    this.endTime, {
    super.uID,
    super.healthDataType,
    super.packageName,
    this.mealType,
    this.name,
    this.vitaminK,
    this.zinc,
    this.biotin,
    this.caffeine,
    this.calcium,
    this.chloride,
    this.cholesterol,
    this.chromium,
    this.copper,
    this.dietaryFiber,
    this.energy,
    this.energyFromFat,
    this.folate,
    this.folicAcid,
    this.iodine,
    this.iron,
    this.magnesium,
    this.manganese,
    this.molybdenum,
    this.monounsaturatedFat,
    this.niacin,
    this.pantothenicAcid,
    this.phosphorus,
    this.polyunsaturatedFat,
    this.potassium,
    this.protein,
    this.riboflavin,
    this.saturatedFat,
    this.selenium,
    this.sodium,
    this.sugar,
    this.thiamin,
    this.totalCarbohydrate,
    this.totalFat,
    this.transFat,
    this.unsaturatedFat,
    this.vitaminA,
    this.vitaminB6,
    this.vitaminB12,
    this.vitaminC,
    this.vitaminD,
    this.vitaminE,
  });

  factory HealthConnectNutrition.fromJson(
          Map<dynamic, dynamic> json, HealthDataType type) =>
      HealthConnectNutrition(
        DateTime.fromMillisecondsSinceEpoch(json['startDateTime']),
        DateTime.fromMillisecondsSinceEpoch(json['endDateTime']),
        uID: json['uid'],
        healthDataType: type,
        packageName: json['packageName'],
        mealType: json.containsKey("mealType")
            ? MealType.getMealType(json['mealType'])
            : null,
        name: json.containsKey("name") ? json['name'] : null,
        biotin: json.containsKey("biotin") ? Mass(json['biotin']) : null,
        caffeine: json.containsKey("caffeine") ? Mass(json['caffeine']) : null,
        calcium: json.containsKey("calcium") ? Mass(json['calcium']) : null,
        energy: json.containsKey("energy") ? Energy(json['energy']) : null,
        energyFromFat: json.containsKey("energyFromFat")
            ? Energy(json['energyFromFat'])
            : null,
        chloride: json.containsKey("chloride") ? Mass(json['chloride']) : null,
        cholesterol:
            json.containsKey("cholesterol") ? Mass(json['cholesterol']) : null,
        chromium: json.containsKey("chromium") ? Mass(json['chromium']) : null,
        copper: json.containsKey("copper") ? Mass(json['copper']) : null,
        dietaryFiber: json.containsKey("dietaryFiber")
            ? Mass(json['dietaryFiber'])
            : null,
        folate: json.containsKey("folate") ? Mass(json['folate']) : null,
        folicAcid:
            json.containsKey("folicAcid") ? Mass(json['folicAcid']) : null,
        iodine: json.containsKey("iodine") ? Mass(json['iodine']) : null,
        iron: json.containsKey("iron") ? Mass(json['iron']) : null,
        magnesium:
            json.containsKey("magnesium") ? Mass(json['magnesium']) : null,
        manganese:
            json.containsKey("manganese") ? Mass(json['manganese']) : null,
        molybdenum:
            json.containsKey("molybdenum") ? Mass(json['molybdenum']) : null,
        monounsaturatedFat: json.containsKey("monounsaturatedFat")
            ? Mass(json['monounsaturatedFat'])
            : null,
        niacin: json.containsKey("niacin") ? Mass(json['niacin']) : null,
        pantothenicAcid: json.containsKey("pantothenicAcid")
            ? Mass(json['pantothenicAcid'])
            : null,
        phosphorus:
            json.containsKey("phosphorus") ? Mass(json['phosphorus']) : null,
        polyunsaturatedFat: json.containsKey("polyunsaturatedFat")
            ? Mass(json['polyunsaturatedFat'])
            : null,
        potassium:
            json.containsKey("potassium") ? Mass(json['potassium']) : null,
        protein: json.containsKey("protein") ? Mass(json['protein']) : null,
        riboflavin:
            json.containsKey("riboflavin") ? Mass(json['riboflavin']) : null,
        saturatedFat: json.containsKey("saturatedFat")
            ? Mass(json['saturatedFat'])
            : null,
        selenium: json.containsKey("selenium") ? Mass(json['selenium']) : null,
        sodium: json.containsKey("sodium") ? Mass(json['sodium']) : null,
        sugar: json.containsKey("sugar") ? Mass(json['sugar']) : null,
        thiamin: json.containsKey("thiamin") ? Mass(json['thiamin']) : null,
        totalCarbohydrate: json.containsKey("totalCarbohydrate")
            ? Mass(json['totalCarbohydrate'])
            : null,
        totalFat: json.containsKey("totalFat") ? Mass(json['totalFat']) : null,
        transFat: json.containsKey("transFat") ? Mass(json['transFat']) : null,
        unsaturatedFat: json.containsKey("unsaturatedFat")
            ? Mass(json['unsaturatedFat'])
            : null,
        vitaminA: json.containsKey("vitaminA") ? Mass(json['vitaminA']) : null,
        vitaminB12:
            json.containsKey("vitaminB12") ? Mass(json['vitaminB12']) : null,
        vitaminB6:
            json.containsKey("vitaminB6") ? Mass(json['vitaminB6']) : null,
        vitaminC: json.containsKey("vitaminC") ? Mass(json['vitaminC']) : null,
        vitaminD: json.containsKey("vitaminD") ? Mass(json['vitaminD']) : null,
        vitaminE: json.containsKey("vitaminE") ? Mass(json['vitaminE']) : null,
        vitaminK: json.containsKey("vitaminK") ? Mass(json['vitaminK']) : null,
        zinc: json.containsKey("zinc") ? Mass(json['zinc']) : null,
      );

  Map toMap() {
    var map = Map<String, dynamic>();
    map['startTime'] =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startTime).toString();
    map['endTime'] =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(endTime).toString();

    final MealType? mealTypeLocal = mealType;
    if (mealTypeLocal != null) {
      map['mealType'] = mealTypeLocal.getMealTypeAsString();
    }
    if (name != null) {
      map['name'] = name;
    }
    if (zinc != null) {
      map['zinc'] = {'value': zinc?.value, 'type': _enumToString(zinc?.type)};
    }
    if (vitaminK != null) {
      map['vitaminK'] = {
        'value': vitaminK?.value,
        'type': _enumToString(vitaminK?.type)
      };
    }
    if (biotin != null) {
      map['biotin'] = {
        'value': biotin?.value,
        'type': _enumToString(biotin?.type)
      };
    }
    if (caffeine != null) {
      map['caffeine'] = {
        'value': caffeine?.value,
        'type': _enumToString(caffeine?.type)
      };
    }
    if (calcium != null) {
      map['calcium'] = {
        'value': calcium?.value,
        'type': _enumToString(calcium?.type)
      };
    }
    if (energy != null) {
      map['energy'] = {
        'value': energy?.value,
        'type': _enumToString(energy?.type)
      };
    }
    if (energyFromFat != null) {
      map['energyFromFat'] = {
        'value': energyFromFat?.value,
        'type': _enumToString(energyFromFat?.type)
      };
    }
    if (chloride != null) {
      map['chloride'] = {
        'value': chloride?.value,
        'type': _enumToString(chloride?.type)
      };
    }
    if (cholesterol != null) {
      map['cholesterol'] = {
        'value': cholesterol?.value,
        'type': _enumToString(cholesterol?.type)
      };
    }
    if (chromium != null) {
      map['chromium'] = {
        'value': chromium?.value,
        'type': _enumToString(chromium?.type)
      };
    }
    if (copper != null) {
      map['copper'] = {
        'value': copper?.value,
        'type': _enumToString(copper?.type)
      };
    }
    if (dietaryFiber != null) {
      map['dietaryFiber'] = {
        'value': dietaryFiber?.value,
        'type': _enumToString(dietaryFiber?.type)
      };
    }
    if (folate != null) {
      map['folate'] = {
        'value': folate?.value,
        'type': _enumToString(folate?.type)
      };
    }
    if (folicAcid != null) {
      map['folicAcid'] = {
        'value': folicAcid?.value,
        'type': _enumToString(folicAcid?.type)
      };
    }
    if (iodine != null) {
      map['iodine'] = {
        'value': iodine?.value,
        'type': _enumToString(iodine?.type)
      };
    }
    if (iron != null) {
      map['iron'] = {'value': iron?.value, 'type': _enumToString(iron?.type)};
    }
    if (magnesium != null) {
      map['magnesium'] = {
        'value': magnesium?.value,
        'type': _enumToString(magnesium?.type)
      };
    }
    if (manganese != null) {
      map['manganese'] = {
        'value': manganese?.value,
        'type': _enumToString(manganese?.type)
      };
    }
    if (molybdenum != null) {
      map['molybdenum'] = {
        'value': molybdenum?.value,
        'type': _enumToString(molybdenum?.type)
      };
    }
    if (monounsaturatedFat != null) {
      map['monounsaturatedFat'] = {
        'value': monounsaturatedFat?.value,
        'type': _enumToString(monounsaturatedFat?.type)
      };
    }
    if (niacin != null) {
      map['niacin'] = {
        'value': niacin?.value,
        'type': _enumToString(niacin?.type)
      };
    }
    if (pantothenicAcid != null) {
      map['pantothenicAcid'] = {
        'value': pantothenicAcid?.value,
        'type': _enumToString(pantothenicAcid?.type)
      };
    }
    if (phosphorus != null) {
      map['phosphorus'] = {
        'value': phosphorus?.value,
        'type': _enumToString(phosphorus?.type)
      };
    }
    if (polyunsaturatedFat != null) {
      map['polyunsaturatedFat'] = {
        'value': polyunsaturatedFat?.value,
        'type': _enumToString(polyunsaturatedFat?.type)
      };
    }
    if (potassium != null) {
      map['potassium'] = {
        'value': potassium?.value,
        'type': _enumToString(potassium?.type)
      };
    }
    if (protein != null) {
      map['protein'] = {
        'value': protein?.value,
        'type': _enumToString(protein?.type)
      };
    }
    if (riboflavin != null) {
      map['riboflavin'] = {
        'value': riboflavin?.value,
        'type': _enumToString(riboflavin?.type)
      };
    }
    if (saturatedFat != null) {
      map['saturatedFat'] = {
        'value': saturatedFat?.value,
        'type': _enumToString(saturatedFat?.type)
      };
    }
    if (selenium != null) {
      map['selenium'] = {
        'value': selenium?.value,
        'type': _enumToString(selenium?.type)
      };
    }
    if (sodium != null) {
      map['sodium'] = {
        'value': sodium?.value,
        'type': _enumToString(sodium?.type)
      };
    }
    if (sugar != null) {
      map['sugar'] = {
        'value': sugar?.value,
        'type': _enumToString(sugar?.type)
      };
    }
    if (thiamin != null) {
      map['thiamin'] = {
        'value': thiamin?.value,
        'type': _enumToString(thiamin?.type)
      };
    }
    if (totalCarbohydrate != null) {
      map['totalCarbohydrate'] = {
        'value': totalCarbohydrate?.value,
        'type': _enumToString(totalCarbohydrate?.type)
      };
    }
    if (totalFat != null) {
      map['totalFat'] = {
        'value': totalFat?.value,
        'type': _enumToString(totalFat?.type)
      };
    }
    if (transFat != null) {
      map['transFat'] = {
        'value': transFat?.value,
        'type': _enumToString(transFat?.type)
      };
    }
    if (unsaturatedFat != null) {
      map['unsaturatedFat'] = {
        'value': unsaturatedFat?.value,
        'type': _enumToString(unsaturatedFat?.type)
      };
    }
    if (vitaminA != null) {
      map['vitaminA'] = {
        'value': vitaminA?.value,
        'type': _enumToString(vitaminA?.type)
      };
    }
    if (vitaminB12 != null) {
      map['vitaminB12'] = {
        'value': vitaminB12?.value,
        'type': _enumToString(vitaminB12?.type)
      };
    }
    if (vitaminB6 != null) {
      map['vitaminB6'] = {
        'value': vitaminB6?.value,
        'type': _enumToString(vitaminB6?.type)
      };
    }
    if (vitaminC != null) {
      map['vitaminC'] = {
        'value': vitaminC?.value,
        'type': _enumToString(vitaminC?.type)
      };
    }
    if (vitaminD != null) {
      map['vitaminD'] = {
        'value': vitaminD?.value,
        'type': _enumToString(vitaminD?.type)
      };
    }
    if (vitaminE != null) {
      map['vitaminE'] = {
        'value': vitaminE?.value,
        'type': _enumToString(vitaminE?.type)
      };
    }
    return map;
  }

  @override
  String toString() => '${this.runtimeType} - '
      '${toMap().toString()}';

  Mass? _add(Mass? a, Mass? b) {
    if (a == null && b == null) {
      return null;
    }
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }

    return a + b;
  }

  Energy? _addE(Energy? a, Energy? b) {
    if (a == null && b == null) {
      return null;
    }
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }

    return a + b;
  }

  /// Adds two [HealthConnectNutrition] objects. start date and end dates are determined based on input.
  @override
  HealthConnectNutrition operator +(HealthConnectNutrition other) {
    final newStartTime =
        startTime.isBefore(other.startTime) ? startTime : other.startTime;
    final newEndTime = endTime.isAfter(other.endTime) ? endTime : other.endTime;
    // TODO: check if all nutrients are used
    // TODO: add new nutrients
    return HealthConnectNutrition(
      newStartTime,
      newEndTime,
      energy: _addE(energy, other.energy),
      energyFromFat: _addE(energyFromFat, other.energyFromFat),
      protein: _add(protein, other.protein),
      totalCarbohydrate: _add(totalCarbohydrate, other.totalCarbohydrate),
      dietaryFiber: _add(dietaryFiber, other.dietaryFiber),
      sugar: _add(sugar, other.sugar),
      totalFat: _add(totalFat, other.totalFat),
      saturatedFat: _add(saturatedFat, other.saturatedFat),
      polyunsaturatedFat: _add(polyunsaturatedFat, other.polyunsaturatedFat),
      monounsaturatedFat: _add(monounsaturatedFat, other.monounsaturatedFat),
      cholesterol: _add(cholesterol, other.cholesterol),
      sodium: _add(sodium, other.sodium),
      potassium: _add(potassium, other.potassium),
      vitaminA: _add(vitaminA, other.vitaminA),
      thiamin: _add(thiamin, other.thiamin),
      riboflavin: _add(riboflavin, other.riboflavin),
      niacin: _add(niacin, other.niacin),
      pantothenicAcid: _add(pantothenicAcid, other.pantothenicAcid),
      vitaminB6: _add(vitaminB6, other.vitaminB6),
      vitaminB12: _add(vitaminB12, other.vitaminB12),
      vitaminC: _add(vitaminC, other.vitaminC),
      vitaminD: _add(vitaminD, other.vitaminD),
      vitaminE: _add(vitaminE, other.vitaminE),
      vitaminK: _add(vitaminK, other.vitaminK),
      folate: _add(folate, other.folate),
      calcium: _add(calcium, other.calcium),
      iron: _add(iron, other.iron),
      magnesium: _add(magnesium, other.magnesium),
      phosphorus: _add(phosphorus, other.phosphorus),
      zinc: _add(zinc, other.zinc),
      caffeine: _add(caffeine, other.caffeine),
      copper: _add(copper, other.copper),
      manganese: _add(manganese, other.manganese),
      selenium: _add(selenium, other.selenium),
    );
  }
}

enum MealType {
  UNKNOWN,
  BREAKFAST,
  LUNCH,
  DINNER,
  SNACK;

  const MealType();

  String getMealTypeAsString() {
    switch (this) {
      case MealType.UNKNOWN:
        return "unknown";
      case MealType.BREAKFAST:
        return "breakfast";
      case MealType.DINNER:
        return "dinner";
      case MealType.LUNCH:
        return "lunch";
      case MealType.SNACK:
        return "snack";
    }
  }

  static MealType getMealType(String data) {
    switch (data) {
      case "breakfast":
        return MealType.BREAKFAST;
      case "dinner":
        return MealType.DINNER;
      case "lunch":
        return MealType.LUNCH;
      case "snack":
        return MealType.SNACK;
      case "unknown":
      default:
        return MealType.UNKNOWN;
    }
  }
}
