import Foundation

public enum ActivityCatalog {
    static let curated: [ActivityDefinition] = [
        ActivityDefinition(
            id: "eyes.distant-gaze", category: .eyes, title: "Distant gaze",
            instruction: "Look at something far away, ideally across the room or out a window.",
            format: .timed(seconds: 20)
        ),
        ActivityDefinition(
            id: "eyes.complete-blinks", category: .eyes, title: "Complete blinks",
            instruction: "Slowly close and open your eyes five times. Do not squeeze.",
            format: .timed(seconds: 20)
        ),
        ActivityDefinition(
            id: "eyes.closed-rest", category: .eyes, title: "Eyes-closed rest",
            instruction: "Close your eyes gently. Drop your shoulders and take three easy breaths.",
            format: .timed(seconds: 30)
        ),
        ActivityDefinition(
            id: "eyes.palming", category: .eyes, title: "Pressure-free palming",
            instruction: "Close your eyes and cup your palms over them without touching or pressing.",
            format: .timed(seconds: 30), safetyLine: "No pressure on your eyes."
        ),

        ActivityDefinition(
            id: "movement.wall-pushups", category: .movement, title: "Wall pushups",
            instruction: "Use a clear wall and do eight slow pushups with your body straight.",
            format: .repetitions(count: 8, minimumSeconds: 10),
            movementModes: [.quietOffice, .standard], safetyLine: "Use a stable surface and breathe normally."
        ),
        ActivityDefinition(
            id: "movement.calf-raises", category: .movement, title: "Calf raises",
            instruction: "Lift and lower your heels slowly. Hold a stable support if needed.",
            format: .repetitions(count: 12, minimumSeconds: 10)
        ),
        ActivityDefinition(
            id: "movement.march", category: .movement, title: "March in place",
            instruction: "March at a comfortable pace. Seated marching works too.",
            format: .timed(seconds: 45)
        ),
        ActivityDefinition(
            id: "movement.side-steps", category: .movement, title: "Side steps",
            instruction: "Step gently side to side at a comfortable pace.",
            format: .timed(seconds: 45), movementModes: [.quietOffice, .standard]
        ),
        ActivityDefinition(
            id: "movement.sit-stand", category: .movement, title: "Sit to stand",
            instruction: "Stand up and sit down with control eight times.",
            format: .repetitions(count: 8, minimumSeconds: 10),
            movementModes: [.quietOffice, .standard], safetyLine: "Use a stable, non-rolling chair."
        ),
        ActivityDefinition(
            id: "movement.floor-pushups", category: .movement, title: "Floor pushups",
            instruction: "Do five to twelve controlled pushups, using knees if preferred.",
            format: .repetitions(count: 8, minimumSeconds: 10),
            movementModes: [.standard], safetyLine: "Only continue if this is already comfortable for you."
        ),

        ActivityDefinition(
            id: "mobility.shoulder-rolls", category: .mobility, title: "Shoulder rolls",
            instruction: "Make five slow shoulder rolls backward, then five forward.",
            format: .timed(seconds: 30)
        ),
        ActivityDefinition(
            id: "mobility.reach-tall", category: .mobility, title: "Reach tall",
            instruction: "Sit or stand tall. Reach comfortably upward, release, and repeat three times.",
            format: .timed(seconds: 30)
        ),
        ActivityDefinition(
            id: "mobility.chin-reset", category: .mobility, title: "Chin reset",
            instruction: "Draw your chin gently back without tilting your head. Release and repeat.",
            format: .repetitions(count: 5, minimumSeconds: 10), safetyLine: "Use a small, comfortable range."
        ),
        ActivityDefinition(
            id: "mobility.hands", category: .mobility, title: "Hands off keyboard",
            instruction: "Relax your hands, open and close them slowly, then let your arms hang.",
            format: .timed(seconds: 30)
        ),
        ActivityDefinition(
            id: "mobility.ankle-pumps", category: .mobility, title: "Ankle pumps",
            instruction: "Lift and lower your toes slowly while seated or standing with support.",
            format: .timed(seconds: 30)
        ),
        ActivityDefinition(
            id: "mobility.change-position", category: .mobility, title: "Change position",
            instruction: "Stand, or move into a different supported sitting position.",
            format: .timed(seconds: 45)
        ),

        ActivityDefinition(
            id: "calm.longer-exhale", category: .calm, title: "Longer exhale",
            instruction: "Breathe comfortably and let each exhale run slightly longer. Do not force it.",
            format: .timed(seconds: 60)
        ),
        ActivityDefinition(
            id: "calm.drop-tension", category: .calm, title: "Drop tension",
            instruction: "Unclench your jaw, lower your shoulders, soften your hands, and breathe easily.",
            format: .timed(seconds: 30)
        ),
        ActivityDefinition(
            id: "calm.three-senses", category: .calm, title: "Three senses",
            instruction: "Notice one thing you can see, one you can hear, and one you can feel.",
            format: .timed(seconds: 45)
        ),
        ActivityDefinition(
            id: "calm.external-focus", category: .calm, title: "External focus",
            instruction: "Choose an object away from the screen. Notice its shape, color, and texture.",
            format: .timed(seconds: 45)
        ),
        ActivityDefinition(
            id: "calm.quiet-count", category: .calm, title: "Quiet count",
            instruction: "Close your eyes if comfortable and count four normal breaths.",
            format: .timed(seconds: 30)
        ),

        ActivityDefinition(
            id: "hydration.sips", category: .hydration, title: "Take a few sips",
            instruction: "Drink a few comfortable sips if that is appropriate for you.",
            format: .timed(seconds: 20)
        ),
        ActivityDefinition(
            id: "hydration.refill", category: .hydration, title: "Refill",
            instruction: "Refill or fetch a drink and place it within reach.",
            format: .timed(seconds: 60)
        ),
        ActivityDefinition(
            id: "hydration.check", category: .hydration, title: "Water check",
            instruction: "Notice whether you are thirsty and put a drink within reach if useful.",
            format: .timed(seconds: 20)
        ),

        ActivityDefinition(
            id: "brain.riddle-clock", category: .brain, title: "Quick riddle",
            instruction: "What has hands and a face but cannot hold or smile?",
            format: .brainSpark(revealAfterSeconds: 10), answer: "A clock."
        ),
        ActivityDefinition(
            id: "brain.math", category: .brain, title: "Mental math",
            instruction: "Start at 100. Subtract 7 three times.",
            format: .brainSpark(revealAfterSeconds: 10), answer: "93, 86, 79."
        ),
        ActivityDefinition(
            id: "brain.scramble", category: .brain, title: "Word scramble",
            instruction: "Unscramble: NIMTUE",
            format: .brainSpark(revealAfterSeconds: 10), answer: "MINUTE."
        ),
        ActivityDefinition(
            id: "brain.pattern", category: .brain, title: "Find the pattern",
            instruction: "What comes next: 2, 6, 12, 20, ?",
            format: .brainSpark(revealAfterSeconds: 10), answer: "30. Add 4, 6, 8, then 10."
        ),
        ActivityDefinition(
            id: "brain.uses", category: .brain, title: "Five uses",
            instruction: "Name five unusual uses for a paperclip.",
            format: .brainSpark(revealAfterSeconds: 10), answer: "There is no single right answer."
        ),
        ActivityDefinition(
            id: "brain.memory", category: .brain, title: "Memory flash",
            instruction: "Remember these: cedar, seven, blue, key.",
            format: .brainSpark(revealAfterSeconds: 10), answer: "Cedar, seven, blue, key."
        ),

        ActivityDefinition(
            id: "voice.hum", category: .voice, title: "Hum a tune",
            instruction: "Hum a familiar tune at an easy, comfortable volume.",
            format: .timed(seconds: 30), safetyLine: "Stop if your voice feels strained."
        ),
        ActivityDefinition(
            id: "voice.sing-line", category: .voice, title: "Sing one line",
            instruction: "Sing one line from a song you know, then repeat it with feeling.",
            format: .timed(seconds: 30), safetyLine: "A quiet voice counts."
        ),
        ActivityDefinition(
            id: "voice.tongue-twister", category: .voice, title: "Tongue twister",
            instruction: "Say “red leather, yellow leather” slowly three times.",
            format: .repetitions(count: 3, minimumSeconds: 10)
        ),
        ActivityDefinition(
            id: "voice.week-backward", category: .voice, title: "Say it backward",
            instruction: "Say the days of the week backward, starting with Sunday.",
            format: .timed(seconds: 30)
        ),
        ActivityDefinition(
            id: "voice.narrator", category: .voice, title: "Movie-trailer voice",
            instruction: "Read any visible sentence as if it opens a dramatic movie trailer.",
            format: .timed(seconds: 20), safetyLine: "Keep the volume suitable for your space."
        ),

        ActivityDefinition(
            id: "writing.six-word-story", category: .writing, title: "Six-word story",
            instruction: "Write a complete story using exactly six words.",
            format: .writing(minimumSeconds: 20)
        ),
        ActivityDefinition(
            id: "writing.next-step", category: .writing, title: "Next tiny step",
            instruction: "Write the smallest useful next action for your current task.",
            format: .writing(minimumSeconds: 20)
        ),
        ActivityDefinition(
            id: "writing.rapid-list", category: .writing, title: "Rapid list",
            instruction: "Type five things that are blue. No editing.",
            format: .writing(minimumSeconds: 20)
        ),
        ActivityDefinition(
            id: "writing.describe-object", category: .writing, title: "Notice and describe",
            instruction: "Describe one object on your desk in a vivid sentence.",
            format: .writing(minimumSeconds: 30)
        ),
        ActivityDefinition(
            id: "writing.no-e", category: .writing, title: "Avoid one letter",
            instruction: "Write a sentence without using the letter E.",
            format: .writing(minimumSeconds: 30)
        ),
        ActivityDefinition(
            id: "writing.one-line-win", category: .writing, title: "One-line win",
            instruction: "Write one thing you finished or moved forward today.",
            format: .writing(minimumSeconds: 20)
        ),

        ActivityDefinition(
            id: "rhythm.clap-pattern", category: .rhythm, title: "Clap the pattern",
            instruction: "Repeat four times: slow, slow, quick, quick, slow.",
            format: .repetitions(count: 4, minimumSeconds: 10), safetyLine: "Finger taps work in a quiet space."
        ),
        ActivityDefinition(
            id: "rhythm.finger-taps", category: .rhythm, title: "Alternating taps",
            instruction: "Tap each fingertip to your thumb, forward and backward, on both hands.",
            format: .timed(seconds: 30)
        ),
        ActivityDefinition(
            id: "rhythm.thigh-drum", category: .rhythm, title: "Tiny drum break",
            instruction: "Tap a simple beat on your thighs and change it halfway through.",
            format: .timed(seconds: 30)
        ),
        ActivityDefinition(
            id: "rhythm.snap-clap", category: .rhythm, title: "Snap and clap",
            instruction: "Alternate a finger snap or tap with a clap for twenty seconds.",
            format: .timed(seconds: 20), safetyLine: "Use two different taps if clapping is not suitable."
        ),
        ActivityDefinition(
            id: "rhythm.steady-beat", category: .rhythm, title: "Hold the beat",
            instruction: "Tap a steady beat, speed it up slightly, then return to the original pace.",
            format: .timed(seconds: 30)
        ),

        ActivityDefinition(
            id: "mindfulness.one-breath", category: .mindfulness, title: "One complete breath",
            instruction: "Notice one natural breath from beginning to end without changing it.",
            format: .timed(seconds: 20)
        ),
        ActivityDefinition(
            id: "mindfulness.body-notice", category: .mindfulness, title: "Three-point body check",
            instruction: "Notice your face, shoulders, and hands. Let each be exactly as it is.",
            format: .timed(seconds: 30)
        ),
        ActivityDefinition(
            id: "mindfulness.farthest-sound", category: .mindfulness, title: "Farthest sound",
            instruction: "Listen for the most distant sound you can hear, then the nearest.",
            format: .timed(seconds: 30)
        ),
        ActivityDefinition(
            id: "mindfulness.name-feeling", category: .mindfulness, title: "Name this moment",
            instruction: "Quietly name one feeling or sensation present right now. No need to change it.",
            format: .timed(seconds: 20)
        ),
        ActivityDefinition(
            id: "mindfulness.single-object", category: .mindfulness, title: "One object",
            instruction: "Give one nearby object your full attention: color, outline, texture, and shadow.",
            format: .timed(seconds: 30)
        ),

        ActivityDefinition(
            id: "affirmation.important", category: .affirmations, title: "Important work",
            instruction: "Read slowly: “I am working on something important to me right now.”",
            format: .timed(seconds: 20)
        ),
        ActivityDefinition(
            id: "affirmation.steady", category: .affirmations, title: "Steady effort",
            instruction: "Read slowly: “Small, steady effort counts.”",
            format: .timed(seconds: 20)
        ),
        ActivityDefinition(
            id: "affirmation.next-step", category: .affirmations, title: "Useful next step",
            instruction: "Read slowly: “I can choose the next useful step.”",
            format: .timed(seconds: 20)
        ),
        ActivityDefinition(
            id: "affirmation.not-all", category: .affirmations, title: "Not all at once",
            instruction: "Read slowly: “I do not need to finish everything at once.”",
            format: .timed(seconds: 20)
        ),
        ActivityDefinition(
            id: "affirmation.return", category: .affirmations, title: "Return gently",
            instruction: "Read slowly: “My attention can return, gently.”",
            format: .timed(seconds: 20)
        ),
        ActivityDefinition(
            id: "affirmation.quiet-progress", category: .affirmations, title: "Quiet progress",
            instruction: "Read slowly: “Progress can be quiet and still be real.”",
            format: .timed(seconds: 20)
        )
    ]

    public static let all: [ActivityDefinition] = ExpandedActivityCatalog.build(from: curated)
}
