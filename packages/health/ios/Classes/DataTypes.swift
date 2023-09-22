
import HealthKit

enum HealthWorkoutActivityType: String, CaseIterable {
    // Both
    case ARCHERY
    case BADMINTON
    case BASEBALL
    case BASKETBALL
    case BIKING  // This also entails the iOS version where it is called CYCLING
    case BOXING
    case CRICKET
    case CURLING
    case ELLIPTICAL
    case FENCING
    case AMERICAN_FOOTBALL
    case AUSTRALIAN_FOOTBALL
    case SOCCER
    case GOLF
    case GYMNASTICS
    case HANDBALL
    case HIGH_INTENSITY_INTERVAL_TRAINING
    case HIKING
    case HOCKEY
    case SKATING
    case JUMP_ROPE
    case KICKBOXING
    case MARTIAL_ARTS
    case PILATES
    case RACQUETBALL
    case ROWING
    case RUGBY
    case RUNNING
    case SAILING
    case CROSS_COUNTRY_SKIING
    case DOWNHILL_SKIING
    case SNOWBOARDING
    case SOFTBALL
    case SQUASH
    case STAIR_CLIMBING
    case SWIMMING
    case TABLE_TENNIS
    case TENNIS
    case VOLLEYBALL
    case WALKING
    case WATER_POLO
    case YOGA

    // iOS only
    case BOWLING
    case CROSS_TRAINING
    case TRACK_AND_FIELD
    case DISC_SPORTS
    case LACROSSE
    case PREPARATION_AND_RECOVERY
    case FLEXIBILITY
    case COOLDOWN
    case WHEELCHAIR_WALK_PACE
    case WHEELCHAIR_RUN_PACE
    case HAND_CYCLING
    case CORE_TRAINING
    case FUNCTIONAL_STRENGTH_TRAINING
    case TRADITIONAL_STRENGTH_TRAINING
    case MIXED_CARDIO
    case STAIRS
    case STEP_TRAINING
    case FITNESS_GAMING
    case BARRE
    case CARDIO_DANCE
    case SOCIAL_DANCE
    case MIND_AND_BODY
    case PICKLEBALL
    case CLIMBING
    case EQUESTRIAN_SPORTS
    case FISHING
    case HUNTING
    case PLAY
    case SNOW_SPORTS
    case PADDLE_SPORTS
    case SURFING_SPORTS
    case WATER_FITNESS
    case WATER_SPORTS
    case TAI_CHI
    case WRESTLING

    // Android only
    case AEROBICS
    case BIATHLON
    case CALISTHENICS
    case CIRCUIT_TRAINING
    case CROSS_FIT
    case DANCING
    case DIVING
    case ELEVATOR
    case ERGOMETER
    case ESCALATOR
    case FRISBEE_DISC
    case GARDENING
    case GUIDED_BREATHING
    case HORSEBACK_RIDING
    case HOUSEWORK
    case INTERVAL_TRAINING
    case IN_VEHICLE
    case KAYAKING
    case KETTLEBELL_TRAINING
    case KICK_SCOOTER
    case KITE_SURFING
    case MEDITATION
    case MIXED_MARTIAL_ARTS
    case P90X
    case PARAGLIDING
    case POLO
    case ROCK_CLIMBING // on iOS this is the same as CLIMBING
    case RUNNING_JOGGING // on iOS this is the same as RUNNING
    case RUNNING_SAND // on iOS this is the same as RUNNING
    case RUNNING_TREADMILL // on iOS this is the same as RUNNING
    case SCUBA_DIVING
    case SKATING_CROSS // on iOS this is the same as SKATING
    case SKATING_INDOOR // on iOS this is the same as SKATING
    case SKATING_INLINE // on iOS this is the same as SKATING
    case SKIING_BACK_COUNTRY
    case SKIING_KITE
    case SKIING_ROLLER
    case SLEDDING
    case STAIR_CLIMBING_MACHINE
    case STANDUP_PADDLEBOARDING
    case STILL
    case STRENGTH_TRAINING
    case SURFING
    case SWIMMING_OPEN_WATER
    case SWIMMING_POOL
    case TEAM_SPORTS
    case TILTING
    case VOLLEYBALL_BEACH
    case VOLLEYBALL_INDOOR
    case WAKEBOARDING
    case WALKING_FITNESS
    case WALKING_NORDIC
    case WALKING_STROLLER
    case WALKING_TREADMILL
    case WEIGHTLIFTING
    case WHEELCHAIR
    case WINDSURFING
    case ZUMBA

    //
    case OTHER

    static func withLabel(_ label: String) -> HealthWorkoutActivityType? {
      return self.allCases.first{ "\($0)" == label }
    }
}


class HealthToHealthkitActivityMapping {
    var healthActivityTypeToHealthkit: [HealthWorkoutActivityType: HKWorkoutActivityType] = [:]
    var healthkitTypeToHealth: [HKWorkoutActivityType: HealthWorkoutActivityType] = [:]

    init() {
        healthActivityTypeToHealthkit[.ARCHERY] = .archery
        healthActivityTypeToHealthkit[.BOWLING] = .bowling
        healthActivityTypeToHealthkit[.FENCING] = .fencing
        healthActivityTypeToHealthkit[.GYMNASTICS] = .gymnastics
        healthActivityTypeToHealthkit[.TRACK_AND_FIELD] = .trackAndField
        healthActivityTypeToHealthkit[.AMERICAN_FOOTBALL] = .americanFootball
        healthActivityTypeToHealthkit[.AUSTRALIAN_FOOTBALL] = .australianFootball
        healthActivityTypeToHealthkit[.BASEBALL] = .baseball
        healthActivityTypeToHealthkit[.BASKETBALL] = .basketball
        healthActivityTypeToHealthkit[.CRICKET] = .cricket
        healthActivityTypeToHealthkit[.DISC_SPORTS] = .discSports
        healthActivityTypeToHealthkit[.HANDBALL] = .handball
        healthActivityTypeToHealthkit[.HOCKEY] = .hockey
        healthActivityTypeToHealthkit[.LACROSSE] = .lacrosse
        healthActivityTypeToHealthkit[.RUGBY] = .rugby
        healthActivityTypeToHealthkit[.SOCCER] = .soccer
        healthActivityTypeToHealthkit[.SOFTBALL] = .softball
        healthActivityTypeToHealthkit[.VOLLEYBALL] = .volleyball
        healthActivityTypeToHealthkit[.PREPARATION_AND_RECOVERY] = .preparationAndRecovery
        healthActivityTypeToHealthkit[.FLEXIBILITY] = .flexibility
        healthActivityTypeToHealthkit[.WALKING] = .walking
        healthActivityTypeToHealthkit[.RUNNING] = .running
        healthActivityTypeToHealthkit[.RUNNING_JOGGING] = .running // Supported due to combining with Android naming
        healthActivityTypeToHealthkit[.RUNNING_SAND] = .running // Supported due to combining with Android naming
        healthActivityTypeToHealthkit[.RUNNING_TREADMILL] = .running // Supported due to combining with Android naming
        healthActivityTypeToHealthkit[.WHEELCHAIR_WALK_PACE] = .wheelchairWalkPace
        healthActivityTypeToHealthkit[.WHEELCHAIR_RUN_PACE] = .wheelchairRunPace
        healthActivityTypeToHealthkit[.BIKING] = .cycling
        healthActivityTypeToHealthkit[.HAND_CYCLING] = .handCycling
        healthActivityTypeToHealthkit[.CORE_TRAINING] = .coreTraining
        healthActivityTypeToHealthkit[.ELLIPTICAL] = .elliptical
        healthActivityTypeToHealthkit[.FUNCTIONAL_STRENGTH_TRAINING] = .functionalStrengthTraining
        healthActivityTypeToHealthkit[.TRADITIONAL_STRENGTH_TRAINING] = .traditionalStrengthTraining
        healthActivityTypeToHealthkit[.CROSS_TRAINING] = .crossTraining
        healthActivityTypeToHealthkit[.MIXED_CARDIO] = .mixedCardio
        healthActivityTypeToHealthkit[.HIGH_INTENSITY_INTERVAL_TRAINING] = .highIntensityIntervalTraining
        healthActivityTypeToHealthkit[.JUMP_ROPE] = .jumpRope
        healthActivityTypeToHealthkit[.STAIR_CLIMBING] = .stairClimbing
        healthActivityTypeToHealthkit[.STAIRS] = .stairs
        healthActivityTypeToHealthkit[.STEP_TRAINING] = .stepTraining
        healthActivityTypeToHealthkit[.FITNESS_GAMING] = .fitnessGaming
        healthActivityTypeToHealthkit[.BARRE] = .barre
        healthActivityTypeToHealthkit[.YOGA] = .yoga
        healthActivityTypeToHealthkit[.MIND_AND_BODY] = .mindAndBody
        healthActivityTypeToHealthkit[.PILATES] = .pilates
        healthActivityTypeToHealthkit[.BADMINTON] = .badminton
        healthActivityTypeToHealthkit[.RACQUETBALL] = .racquetball
        healthActivityTypeToHealthkit[.SQUASH] = .squash
        healthActivityTypeToHealthkit[.TABLE_TENNIS] = .tableTennis
        healthActivityTypeToHealthkit[.TENNIS] = .tennis
        healthActivityTypeToHealthkit[.CLIMBING] = .climbing
        healthActivityTypeToHealthkit[.ROCK_CLIMBING] = .climbing // Supported due to combining with Android naming
        healthActivityTypeToHealthkit[.EQUESTRIAN_SPORTS] = .equestrianSports
        healthActivityTypeToHealthkit[.FISHING] = .fishing
        healthActivityTypeToHealthkit[.GOLF] = .golf
        healthActivityTypeToHealthkit[.HIKING] = .hiking
        healthActivityTypeToHealthkit[.HUNTING] = .hunting
        healthActivityTypeToHealthkit[.PLAY] = .play
        healthActivityTypeToHealthkit[.CROSS_COUNTRY_SKIING] = .crossCountrySkiing
        healthActivityTypeToHealthkit[.CURLING] = .curling
        healthActivityTypeToHealthkit[.DOWNHILL_SKIING] = .downhillSkiing
        healthActivityTypeToHealthkit[.SNOW_SPORTS] = .snowSports
        healthActivityTypeToHealthkit[.SNOWBOARDING] = .snowboarding
        healthActivityTypeToHealthkit[.SKATING] = .skatingSports
        healthActivityTypeToHealthkit[.SKATING_CROSS] = .skatingSports // Supported due to combining with Android naming
        healthActivityTypeToHealthkit[.SKATING_INDOOR] = .skatingSports // Supported due to combining with Android naming
        healthActivityTypeToHealthkit[.SKATING_INLINE] = .skatingSports // Supported due to combining with Android naming
        healthActivityTypeToHealthkit[.PADDLE_SPORTS] = .paddleSports
        healthActivityTypeToHealthkit[.ROWING] = .rowing
        healthActivityTypeToHealthkit[.SAILING] = .sailing
        healthActivityTypeToHealthkit[.SURFING_SPORTS] = .surfingSports
        healthActivityTypeToHealthkit[.SWIMMING] = .swimming
        healthActivityTypeToHealthkit[.WATER_FITNESS] = .waterFitness
        healthActivityTypeToHealthkit[.WATER_POLO] = .waterPolo
        healthActivityTypeToHealthkit[.WATER_SPORTS] = .waterSports
        healthActivityTypeToHealthkit[.BOXING] = .boxing
        healthActivityTypeToHealthkit[.KICKBOXING] = .kickboxing
        healthActivityTypeToHealthkit[.MARTIAL_ARTS] = .martialArts
        healthActivityTypeToHealthkit[.TAI_CHI] = .taiChi
        healthActivityTypeToHealthkit[.WRESTLING] = .wrestling
        healthActivityTypeToHealthkit[.OTHER] = .other

        healthkitTypeToHealth[.archery] = .ARCHERY
        healthkitTypeToHealth[.bowling] = .BOWLING
        healthkitTypeToHealth[.fencing] = .FENCING
        healthkitTypeToHealth[.gymnastics] = .GYMNASTICS
        healthkitTypeToHealth[.trackAndField] = .TRACK_AND_FIELD
        healthkitTypeToHealth[.americanFootball] = .AMERICAN_FOOTBALL
        healthkitTypeToHealth[.australianFootball] = .AUSTRALIAN_FOOTBALL
        healthkitTypeToHealth[.baseball] = .BASEBALL
        healthkitTypeToHealth[.basketball] = .BASKETBALL
        healthkitTypeToHealth[.cricket] = .CRICKET
        healthkitTypeToHealth[.discSports] = .DISC_SPORTS
        healthkitTypeToHealth[.handball] = .HANDBALL
        healthkitTypeToHealth[.hockey] = .HOCKEY
        healthkitTypeToHealth[.lacrosse] = .LACROSSE
        healthkitTypeToHealth[.rugby] = .RUGBY
        healthkitTypeToHealth[.soccer] = .SOCCER
        healthkitTypeToHealth[.softball] = .SOFTBALL
        healthkitTypeToHealth[.volleyball] = .VOLLEYBALL
        healthkitTypeToHealth[.preparationAndRecovery] = .PREPARATION_AND_RECOVERY
        healthkitTypeToHealth[.flexibility] = .FLEXIBILITY
        healthkitTypeToHealth[.walking] = .WALKING
        healthkitTypeToHealth[.running] = .RUNNING
        healthkitTypeToHealth[.wheelchairWalkPace] = .WHEELCHAIR_WALK_PACE
        healthkitTypeToHealth[.wheelchairRunPace] = .WHEELCHAIR_RUN_PACE
        healthkitTypeToHealth[.cycling] = .BIKING
        healthkitTypeToHealth[.handCycling] = .HAND_CYCLING
        healthkitTypeToHealth[.coreTraining] = .CORE_TRAINING
        healthkitTypeToHealth[.elliptical] = .ELLIPTICAL
        healthkitTypeToHealth[.functionalStrengthTraining] = .FUNCTIONAL_STRENGTH_TRAINING
        healthkitTypeToHealth[.traditionalStrengthTraining] = .TRADITIONAL_STRENGTH_TRAINING
        healthkitTypeToHealth[.crossTraining] = .CROSS_TRAINING
        healthkitTypeToHealth[.mixedCardio] = .MIXED_CARDIO
        healthkitTypeToHealth[.highIntensityIntervalTraining] = .HIGH_INTENSITY_INTERVAL_TRAINING
        healthkitTypeToHealth[.jumpRope] = .JUMP_ROPE
        healthkitTypeToHealth[.stairClimbing] = .STAIR_CLIMBING
        healthkitTypeToHealth[.stairs] = .STAIRS
        healthkitTypeToHealth[.stepTraining] = .STEP_TRAINING
        healthkitTypeToHealth[.fitnessGaming] = .FITNESS_GAMING
        healthkitTypeToHealth[.barre] = .BARRE
        healthkitTypeToHealth[.yoga] = .YOGA
        healthkitTypeToHealth[.mindAndBody] = .MIND_AND_BODY
        healthkitTypeToHealth[.pilates] = .PILATES
        healthkitTypeToHealth[.badminton] = .BADMINTON
        healthkitTypeToHealth[.racquetball] = .RACQUETBALL
        healthkitTypeToHealth[.squash] = .SQUASH
        healthkitTypeToHealth[.tableTennis] = .TABLE_TENNIS
        healthkitTypeToHealth[.tennis] = .TENNIS
        healthkitTypeToHealth[.climbing] = .CLIMBING
        healthkitTypeToHealth[.equestrianSports] = .EQUESTRIAN_SPORTS
        healthkitTypeToHealth[.fishing] = .FISHING
        healthkitTypeToHealth[.golf] = .GOLF
        healthkitTypeToHealth[.hiking] = .HIKING
        healthkitTypeToHealth[.hunting] = .HUNTING
        healthkitTypeToHealth[.play] = .PLAY
        healthkitTypeToHealth[.crossCountrySkiing] = .CROSS_COUNTRY_SKIING
        healthkitTypeToHealth[.curling] = .CURLING
        healthkitTypeToHealth[.downhillSkiing] = .DOWNHILL_SKIING
        healthkitTypeToHealth[.snowSports] = .SNOW_SPORTS
        healthkitTypeToHealth[.snowboarding] = .SNOWBOARDING
        healthkitTypeToHealth[.skatingSports] = .SKATING
        healthkitTypeToHealth[.paddleSports] = .PADDLE_SPORTS
        healthkitTypeToHealth[.rowing] = .ROWING
        healthkitTypeToHealth[.sailing] = .SAILING
        healthkitTypeToHealth[.surfingSports] = .SURFING_SPORTS
        healthkitTypeToHealth[.swimming] = .SWIMMING
        healthkitTypeToHealth[.waterFitness] = .WATER_FITNESS
        healthkitTypeToHealth[.waterPolo] = .WATER_POLO
        healthkitTypeToHealth[.waterSports] = .WATER_SPORTS
        healthkitTypeToHealth[.boxing] = .BOXING
        healthkitTypeToHealth[.kickboxing] = .KICKBOXING
        healthkitTypeToHealth[.martialArts] = .MARTIAL_ARTS
        healthkitTypeToHealth[.taiChi] = .TAI_CHI
        healthkitTypeToHealth[.wrestling] = .WRESTLING
        healthkitTypeToHealth[.other] = .OTHER

      if #available(iOS 14.0, *) {
          healthActivityTypeToHealthkit[.CARDIO_DANCE] = HKWorkoutActivityType.cardioDance
          healthActivityTypeToHealthkit[.SOCIAL_DANCE] = HKWorkoutActivityType.socialDance
          healthActivityTypeToHealthkit[.PICKLEBALL] = HKWorkoutActivityType.pickleball
          healthActivityTypeToHealthkit[.COOLDOWN] = HKWorkoutActivityType.cooldown

          healthkitTypeToHealth[.cardioDance] = .CARDIO_DANCE
          healthkitTypeToHealth[.socialDance] = .SOCIAL_DANCE
          healthkitTypeToHealth[.pickleball] = .PICKLEBALL
          healthkitTypeToHealth[.cooldown] = .COOLDOWN
      }
    }


    func toHealthkitActivityType(healthActivityType: String) -> HKWorkoutActivityType? {
        return healthActivityTypeToHealthkit[HealthWorkoutActivityType.withLabel(healthActivityType) ?? .OTHER];
    }

    func toHealthActivityType(hkActivityType: HKWorkoutActivityType) -> HealthWorkoutActivityType {
        return healthkitTypeToHealth[hkActivityType] ?? .OTHER;
    }
}