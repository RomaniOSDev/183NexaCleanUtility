import Foundation

enum WorkoutPresets {
    static let all: [WorkoutPreset] = [
        WorkoutPreset(
            id: "tabata",
            name: "Tabata",
            subtitle: "20s on · 10s off",
            goal: "Peak cardio bursts",
            workSeconds: 20,
            restSeconds: 10,
            roundsCount: 8,
            suggestedRoutineTitle: "Tabata Finisher",
            suggestedExercises: [
                ExerciseItem(name: "Jump Squats", detail: "20 sec"),
                ExerciseItem(name: "Mountain Climbers", detail: "20 sec"),
                ExerciseItem(name: "Burpees", detail: "20 sec"),
                ExerciseItem(name: "High Knees", detail: "20 sec")
            ]
        ),
        WorkoutPreset(
            id: "hiit20",
            name: "HIIT 20",
            subtitle: "~20 minute session",
            goal: "Fat-burn intervals",
            workSeconds: 40,
            restSeconds: 20,
            roundsCount: 20,
            suggestedRoutineTitle: "HIIT 20 Circuit",
            suggestedExercises: [
                ExerciseItem(name: "Squat Thrusts", detail: "40 sec"),
                ExerciseItem(name: "Push-ups", detail: "40 sec"),
                ExerciseItem(name: "Lunges", detail: "40 sec"),
                ExerciseItem(name: "Plank Jacks", detail: "40 sec"),
                ExerciseItem(name: "Rest", detail: "20 sec")
            ]
        ),
        WorkoutPreset(
            id: "strength_warmup",
            name: "Strength Warm-up",
            subtitle: "Controlled prep sets",
            goal: "Prime muscles before lifting",
            workSeconds: 30,
            restSeconds: 15,
            roundsCount: 6,
            suggestedRoutineTitle: "Strength Warm-up",
            suggestedExercises: [
                ExerciseItem(name: "Band Pull-aparts", detail: "12 reps"),
                ExerciseItem(name: "Bodyweight Squats", detail: "15 reps"),
                ExerciseItem(name: "Inchworms", detail: "8 reps"),
                ExerciseItem(name: "Dead Bug", detail: "10 reps")
            ]
        ),
        WorkoutPreset(
            id: "recovery",
            name: "Recovery",
            subtitle: "Low-intensity reset",
            goal: "Mobility and active rest",
            workSeconds: 45,
            restSeconds: 60,
            roundsCount: 5,
            suggestedRoutineTitle: "Recovery Flow",
            suggestedExercises: [
                ExerciseItem(name: "Cat-Cow", detail: "45 sec"),
                ExerciseItem(name: "Hip Circles", detail: "45 sec"),
                ExerciseItem(name: "Child's Pose", detail: "45 sec"),
                ExerciseItem(name: "Walking Stretch", detail: "45 sec")
            ]
        )
    ]
}
