import Foundation

private struct ActivitySeed {
    let title: String
    let instruction: String
    let format: ActivityFormat
    let movementModes: Set<MovementMode>
    let safetyLine: String?
    let answer: String?

    init(
        _ title: String,
        _ instruction: String,
        _ format: ActivityFormat = .timed(seconds: 30),
        movementModes: Set<MovementMode> = Set(MovementMode.allCases),
        safetyLine: String? = nil,
        answer: String? = nil
    ) {
        self.title = title
        self.instruction = instruction
        self.format = format
        self.movementModes = movementModes
        self.safetyLine = safetyLine
        self.answer = answer
    }
}

private struct ActivityCue {
    let title: String
    let instruction: String
}

enum ExpandedActivityCatalog {
    private static let targetCounts: [ActivityCategory: Int] = [
        .eyes: 70,
        .movement: 80,
        .mobility: 80,
        .calm: 95,
        .hydration: 70,
        .brain: 120,
        .voice: 100,
        .writing: 120,
        .rhythm: 85,
        .mindfulness: 95,
        .affirmations: 85
    ]

    static func build(from curated: [ActivityDefinition]) -> [ActivityDefinition] {
        var result = curated
        for category in ActivityCategory.allCases {
            let existingCount = result.lazy.filter { $0.category == category }.count
            let target = targetCounts[category, default: existingCount]
            let needed = max(0, target - existingCount)
            result.append(contentsOf: generated(for: category, count: needed))
        }

        precondition(result.count == 1_000, "NanoBreaks must ship exactly 1,000 activities")
        precondition(Set(result.map(\.id)).count == result.count, "Activity IDs must be unique")
        return result
    }

    private static func generated(for category: ActivityCategory, count: Int) -> [ActivityDefinition] {
        let bases = seeds(for: category)
        let modifiers = cues(for: category)
        precondition(bases.count * modifiers.count >= count)

        return (0..<count).map { index in
            let base = bases[index % bases.count]
            let cue = modifiers[(index / bases.count) % modifiers.count]
            return ActivityDefinition(
                id: "\(category.rawValue).expanded.\(String(format: "%03d", index + 1))",
                category: category,
                title: "\(base.title) · \(cue.title)",
                instruction: "\(base.instruction) \(cue.instruction)",
                format: base.format,
                movementModes: base.movementModes,
                safetyLine: base.safetyLine,
                answer: base.answer
            )
        }
    }

    private static func cues(for category: ActivityCategory) -> [ActivityCue] {
        switch category {
        case .eyes:
            return [
                ActivityCue(title: "easy pace", instruction: "Keep the effort soft and easy."),
                ActivityCue(title: "shoulders loose", instruction: "Let your shoulders stay loose."),
                ActivityCue(title: "quiet breath", instruction: "Keep breathing normally while you do it."),
                ActivityCue(title: "screen-free", instruction: "Keep your attention away from the screen until time is up."),
                ActivityCue(title: "gentle finish", instruction: "Finish with one relaxed blink."),
                ActivityCue(title: "no strain", instruction: "Use only a comfortable, strain-free range.")
            ]
        case .movement:
            return [
                ActivityCue(title: "steady", instruction: "Move at a steady, comfortable pace."),
                ActivityCue(title: "slow", instruction: "Make each repetition slow and controlled."),
                ActivityCue(title: "posture", instruction: "Keep your posture tall without stiffening."),
                ActivityCue(title: "easy breath", instruction: "Breathe normally throughout."),
                ActivityCue(title: "smooth", instruction: "Aim for smooth movement rather than speed."),
                ActivityCue(title: "light", instruction: "Keep the effort light enough to finish comfortably.")
            ]
        case .mobility:
            return [
                ActivityCue(title: "small range", instruction: "Start with a small range."),
                ActivityCue(title: "slow release", instruction: "Release slowly after each movement."),
                ActivityCue(title: "easy posture", instruction: "Stay tall but relaxed."),
                ActivityCue(title: "with breath", instruction: "Let your breathing stay easy."),
                ActivityCue(title: "one side", instruction: "Notice each side without forcing symmetry."),
                ActivityCue(title: "soft finish", instruction: "Finish in a comfortable neutral position.")
            ]
        case .calm:
            return [
                ActivityCue(title: "unhurried", instruction: "There is nothing to force or perfect."),
                ActivityCue(title: "feet grounded", instruction: "Notice the support beneath your feet."),
                ActivityCue(title: "soft gaze", instruction: "Let your gaze rest softly away from the screen."),
                ActivityCue(title: "quiet minute", instruction: "Allow the full pause to stay quiet."),
                ActivityCue(title: "easy breath", instruction: "Keep every breath comfortable."),
                ActivityCue(title: "gentle return", instruction: "Return to work without rushing.")
            ]
        case .hydration:
            return [
                ActivityCue(title: "check in", instruction: "Let thirst, preference, and your own health guidance decide."),
                ActivityCue(title: "no rush", instruction: "There is no target amount and no need to rush."),
                ActivityCue(title: "comfortable", instruction: "Only do what feels appropriate for you."),
                ActivityCue(title: "prepare", instruction: "Make the next comfortable sip easier to remember."),
                ActivityCue(title: "mindful", instruction: "Pause and notice temperature or taste without judging it."),
                ActivityCue(title: "simple", instruction: "Keep this practical and pressure-free.")
            ]
        case .brain:
            return [
                ActivityCue(title: "quiet", instruction: "Work it out silently."),
                ActivityCue(title: "say it", instruction: "Say your answer aloud if your space allows."),
                ActivityCue(title: "one try", instruction: "Give yourself one focused attempt."),
                ActivityCue(title: "first answer", instruction: "Use the first reasonable answer that comes to mind."),
                ActivityCue(title: "no notes", instruction: "Try it without writing anything down."),
                ActivityCue(title: "playful", instruction: "Treat it as play, not a test.")
            ]
        case .voice:
            return [
                ActivityCue(title: "quiet", instruction: "A quiet voice counts."),
                ActivityCue(title: "bright", instruction: "Try it once with a brighter tone."),
                ActivityCue(title: "slow", instruction: "Repeat it once more slowly."),
                ActivityCue(title: "expressive", instruction: "Add a little expression without adding volume."),
                ActivityCue(title: "clear", instruction: "Favor clear, easy sound over loudness."),
                ActivityCue(title: "gentle", instruction: "Keep your throat and jaw comfortable.")
            ]
        case .writing:
            return [
                ActivityCue(title: "no edits", instruction: "Keep typing and do not edit."),
                ActivityCue(title: "plain words", instruction: "Use the simplest words you can."),
                ActivityCue(title: "one sentence", instruction: "Finish with one complete sentence."),
                ActivityCue(title: "be specific", instruction: "Include one concrete detail."),
                ActivityCue(title: "fast draft", instruction: "Let this be a rough first draft."),
                ActivityCue(title: "surprise", instruction: "Include one unexpected word or idea.")
            ]
        case .rhythm:
            return [
                ActivityCue(title: "quiet taps", instruction: "Use fingertip taps if sound would distract someone."),
                ActivityCue(title: "steady", instruction: "Keep the pulse steady."),
                ActivityCue(title: "soft", instruction: "Keep every clap or tap light."),
                ActivityCue(title: "switch hands", instruction: "Lead once with each hand."),
                ActivityCue(title: "tempo shift", instruction: "Speed up slightly, then return to your first pace."),
                ActivityCue(title: "eyes away", instruction: "Look away from the screen while keeping the beat.")
            ]
        case .mindfulness:
            return [
                ActivityCue(title: "curious", instruction: "Notice it with curiosity, not judgment."),
                ActivityCue(title: "one thing", instruction: "Stay with just one detail at a time."),
                ActivityCue(title: "quiet", instruction: "Let the observation remain silent."),
                ActivityCue(title: "name it", instruction: "Give the experience a simple name."),
                ActivityCue(title: "changing", instruction: "Notice whether it changes on its own."),
                ActivityCue(title: "return", instruction: "When attention wanders, return gently.")
            ]
        case .affirmations:
            return [
                ActivityCue(title: "slowly", instruction: "Read it once more, slowly."),
                ActivityCue(title: "aloud", instruction: "Say it aloud if that feels natural."),
                ActivityCue(title: "quietly", instruction: "Repeat it silently in your own voice."),
                ActivityCue(title: "one breath", instruction: "Let one easy breath follow the words."),
                ActivityCue(title: "write it", instruction: "Type the sentence once if you want to make it concrete."),
                ActivityCue(title: "make it yours", instruction: "Change one word so it feels honest to you.")
            ]
        }
    }

    private static func seeds(for category: ActivityCategory) -> [ActivitySeed] {
        switch category {
        case .eyes: eyeSeeds
        case .movement: movementSeeds
        case .mobility: mobilitySeeds
        case .calm: calmSeeds
        case .hydration: hydrationSeeds
        case .brain: brainSeeds
        case .voice: voiceSeeds
        case .writing: writingSeeds
        case .rhythm: rhythmSeeds
        case .mindfulness: mindfulnessSeeds
        case .affirmations: affirmationSeeds
        }
    }

    private static let eyeSeeds: [ActivitySeed] = [
        ActivitySeed("Window horizon", "Look through a window toward the farthest comfortable point you can see.", .timed(seconds: 20)),
        ActivitySeed("Room horizon", "Look toward the far side of the room and notice three distant shapes.", .timed(seconds: 20)),
        ActivitySeed("Soft distance", "Let your eyes rest on a distant object without trying to sharpen it.", .timed(seconds: 30)),
        ActivitySeed("Blink reset", "Make six complete, gentle blinks without squeezing.", .timed(seconds: 20)),
        ActivitySeed("Closed-eye pause", "Close your eyes gently and leave them relaxed.", .timed(seconds: 30)),
        ActivitySeed("Near then far", "Look at your thumb, then a distant object, changing focus slowly four times.", .timed(seconds: 30)),
        ActivitySeed("Wide view", "Look away from the screen and notice the edges of your visual field.", .timed(seconds: 30)),
        ActivitySeed("Color scan", "Find three different colors away from the screen, moving only your gaze comfortably.", .timed(seconds: 30)),
        ActivitySeed("Shape scan", "Find a circle, a rectangle, and an irregular shape across the room.", .timed(seconds: 30)),
        ActivitySeed("Light and shadow", "Look away and notice one light area and one shadowed area.", .timed(seconds: 20)),
        ActivitySeed("Depth layers", "Notice something near, something midway, and something far away.", .timed(seconds: 30)),
        ActivitySeed("Outdoor detail", "If a window is available, notice one distant outdoor detail.", .timed(seconds: 20)),
        ActivitySeed("Gentle palming", "Cup warm palms around closed eyes without touching the eyelids.", .timed(seconds: 30), safetyLine: "Never press on your eyes."),
        ActivitySeed("Blink and breathe", "Pair five gentle blinks with five natural breaths.", .timed(seconds: 30)),
        ActivitySeed("Screen-free stillness", "Turn your face away from the display and let your eyes settle naturally.", .timed(seconds: 30))
    ]

    private static let movementSeeds: [ActivitySeed] = [
        ActivitySeed("Seated march", "Alternate lifting your feet as if marching in your chair.", .timed(seconds: 40), safetyLine: "Use a stable chair and stop if uncomfortable."),
        ActivitySeed("Toe lifts", "Keep heels down and lift both sets of toes ten times.", .repetitions(count: 10, minimumSeconds: 20)),
        ActivitySeed("Heel lifts", "Lift and lower both heels twelve times, seated or standing with support.", .repetitions(count: 12, minimumSeconds: 25)),
        ActivitySeed("Seated knee lifts", "Lift one knee, lower it, then alternate sides.", .repetitions(count: 10, minimumSeconds: 30)),
        ActivitySeed("Chair arm press", "Press your palms gently into the chair arms, release, and repeat.", .repetitions(count: 8, minimumSeconds: 20), safetyLine: "Use only a stable chair."),
        ActivitySeed("Palm press", "Press your palms together lightly for three seconds, then release.", .repetitions(count: 6, minimumSeconds: 30)),
        ActivitySeed("Standing march", "March gently beside your desk.", .timed(seconds: 40), movementModes: [.quietOffice, .standard], safetyLine: "Keep a stable support nearby if needed."),
        ActivitySeed("Side step", "Take small steps side to side in a clear space.", .timed(seconds: 40), movementModes: [.quietOffice, .standard]),
        ActivitySeed("Sit and stand", "Stand from a stable chair and sit with control.", .repetitions(count: 6, minimumSeconds: 30), movementModes: [.quietOffice, .standard], safetyLine: "Use a non-rolling chair."),
        ActivitySeed("Wall press", "Place hands on a wall and do eight controlled wall pushups.", .repetitions(count: 8, minimumSeconds: 30), movementModes: [.quietOffice, .standard], safetyLine: "Use a clear, stable wall."),
        ActivitySeed("Desk pushup", "Use a sturdy fixed desk for six gentle incline pushups.", .repetitions(count: 6, minimumSeconds: 30), movementModes: [.quietOffice, .standard], safetyLine: "Do not use a rolling or movable surface."),
        ActivitySeed("Mini squat", "Bend hips and knees slightly, then stand tall.", .repetitions(count: 8, minimumSeconds: 30), movementModes: [.quietOffice, .standard], safetyLine: "Use a comfortable depth and stable support."),
        ActivitySeed("Back steps", "Step one foot back lightly, return, and alternate.", .repetitions(count: 10, minimumSeconds: 30), movementModes: [.quietOffice, .standard]),
        ActivitySeed("Reach and lower", "Reach both arms comfortably upward, then lower them with control.", .repetitions(count: 8, minimumSeconds: 30)),
        ActivitySeed("Air punches", "Make light forward punches at chest height, alternating hands.", .timed(seconds: 30), movementModes: [.quietOffice, .standard]),
        ActivitySeed("Fast feet seated", "Tap alternating toes a little faster while staying seated.", .timed(seconds: 30)),
        ActivitySeed("Step-touch", "Step to one side and bring the other foot in, then switch.", .timed(seconds: 40), movementModes: [.quietOffice, .standard]),
        ActivitySeed("Standing weight shift", "Shift weight gently from one foot to the other.", .timed(seconds: 30), movementModes: [.quietOffice, .standard], safetyLine: "Hold support if balance is uncertain.")
    ]

    private static let mobilitySeeds: [ActivitySeed] = [
        ActivitySeed("Shoulder circles", "Circle both shoulders slowly backward, then forward.", .timed(seconds: 30)),
        ActivitySeed("Shoulder blade glide", "Draw shoulder blades gently together, then let them separate.", .repetitions(count: 8, minimumSeconds: 25)),
        ActivitySeed("Chin glide", "Draw your chin gently backward without tipping your head.", .repetitions(count: 6, minimumSeconds: 25), safetyLine: "Keep the movement small and pain-free."),
        ActivitySeed("Look left and right", "Turn your head slowly left and right within a comfortable range.", .repetitions(count: 6, minimumSeconds: 30), safetyLine: "Stop before strain or dizziness."),
        ActivitySeed("Ear toward shoulder", "Tilt one ear gently toward its shoulder, return, then switch.", .repetitions(count: 6, minimumSeconds: 30), safetyLine: "Do not pull on your head."),
        ActivitySeed("Wrist circles", "Make slow wrist circles in both directions.", .timed(seconds: 30)),
        ActivitySeed("Finger fan", "Spread your fingers, relax them, and repeat slowly.", .repetitions(count: 10, minimumSeconds: 25)),
        ActivitySeed("Thumb sweep", "Touch your thumb to each fingertip, then reverse.", .repetitions(count: 6, minimumSeconds: 30)),
        ActivitySeed("Forearm turn", "With elbows by your sides, turn palms up and down slowly.", .repetitions(count: 10, minimumSeconds: 30)),
        ActivitySeed("Ankle circles", "Lift one foot slightly and circle the ankle, then switch.", .timed(seconds: 35)),
        ActivitySeed("Ankle pumps", "Point and flex your feet slowly while seated.", .repetitions(count: 12, minimumSeconds: 30)),
        ActivitySeed("Side reach", "Reach one arm up and lean slightly to the other side, then switch.", .timed(seconds: 30), safetyLine: "Keep both sides comfortable."),
        ActivitySeed("Chest opener", "Move elbows gently back, then let your arms relax.", .repetitions(count: 8, minimumSeconds: 30)),
        ActivitySeed("Upper-back round", "Reach hands forward and let your upper back round gently, then release.", .timed(seconds: 30)),
        ActivitySeed("Seated torso turn", "Turn your chest slightly to one side, return, then switch.", .repetitions(count: 6, minimumSeconds: 30), safetyLine: "Do not force the twist."),
        ActivitySeed("Hip shift", "Shift your seated weight gently from one side to the other.", .timed(seconds: 30)),
        ActivitySeed("Posture change", "Choose a different supported sitting or standing position.", .timed(seconds: 40))
    ]

    private static let calmSeeds: [ActivitySeed] = [
        ActivitySeed("Natural breath", "Notice four natural breaths without changing them.", .timed(seconds: 40)),
        ActivitySeed("Easy exhale", "Let each exhale be slightly longer only if that feels comfortable.", .timed(seconds: 40), safetyLine: "Never force or hold your breath."),
        ActivitySeed("Unclench", "Unclench your jaw, soften your tongue, and relax your hands.", .timed(seconds: 30)),
        ActivitySeed("Shoulders down", "Notice your shoulders and let them settle away from your ears.", .timed(seconds: 30)),
        ActivitySeed("Support check", "Feel the chair and floor supporting your weight.", .timed(seconds: 30)),
        ActivitySeed("Quiet count", "Count four easy breaths from one to four, then begin again.", .timed(seconds: 40)),
        ActivitySeed("Long view", "Rest your gaze on a calm point away from the screen.", .timed(seconds: 30)),
        ActivitySeed("Pause the rush", "For this short pause, let nothing require an immediate answer.", .timed(seconds: 30)),
        ActivitySeed("Hands soften", "Open your hands, let the fingers curl naturally, and notice the change.", .timed(seconds: 30)),
        ActivitySeed("Face soften", "Relax your brow, cheeks, and the space around your eyes.", .timed(seconds: 30)),
        ActivitySeed("One sound", "Listen to one steady sound until the timer ends.", .timed(seconds: 40)),
        ActivitySeed("Three releases", "Exhale normally and release one small area of tension three times.", .timed(seconds: 40)),
        ActivitySeed("Still hands", "Place your hands somewhere comfortable and let them be still.", .timed(seconds: 30)),
        ActivitySeed("Nothing to solve", "Notice the moment without trying to fix or solve it.", .timed(seconds: 30)),
        ActivitySeed("Gentle reset", "Take a comfortable pause before choosing your next action.", .timed(seconds: 30)),
        ActivitySeed("Ten-second body scan", "Notice your forehead, jaw, shoulders, and hands, softening only what wants to soften.", .timed(seconds: 30)),
        ActivitySeed("Permission to pause", "For this moment, give yourself permission to leave everything unanswered.", .timed(seconds: 25)),
        ActivitySeed("Sound settling", "Listen to the room as a whole and let its sounds come and go.", .timed(seconds: 30)),
        ActivitySeed("Slow arrival", "Feel yourself arrive in the chair, in the room, and in this exact moment.", .timed(seconds: 30))
    ]

    private static let hydrationSeeds: [ActivitySeed] = [
        ActivitySeed("Thirst check", "Notice whether you feel thirsty right now.", .timed(seconds: 20)),
        ActivitySeed("Comfortable sip", "Take one or two comfortable sips if appropriate for you.", .timed(seconds: 20)),
        ActivitySeed("Drink in reach", "Put your preferred drink within easy reach if useful.", .timed(seconds: 30)),
        ActivitySeed("Refill plan", "Notice whether your cup or bottle needs refilling for later.", .timed(seconds: 30)),
        ActivitySeed("Mindful taste", "If you take a sip, notice its temperature and taste.", .timed(seconds: 20)),
        ActivitySeed("Cup check", "Check whether an empty cup can be cleared or refilled.", .timed(seconds: 30)),
        ActivitySeed("Future sip", "Choose a natural point in your work to check thirst again.", .timed(seconds: 20)),
        ActivitySeed("Bottle nearby", "Move your bottle or cup somewhere visible and easy to reach.", .timed(seconds: 20)),
        ActivitySeed("Pause and sip", "Pause your hands, sit comfortably, and take a relaxed sip if you want one.", .timed(seconds: 20)),
        ActivitySeed("Refill cue", "Choose a simple cue for your next refill, such as finishing this paragraph.", .timed(seconds: 25)),
        ActivitySeed("Drink choice", "Notice which available drink would feel most comfortable right now.", .timed(seconds: 20)),
        ActivitySeed("Clear the cup", "If useful, clear an old cup and make space for a fresh drink later.", .timed(seconds: 30))
    ]

    private static let brainSeeds: [ActivitySeed] = [
        ActivitySeed("Count by threes", "Start at 4 and add 3 five times.", .brainSpark(revealAfterSeconds: 15), answer: "7, 10, 13, 16, 19."),
        ActivitySeed("Count back by fours", "Start at 40 and subtract 4 five times.", .brainSpark(revealAfterSeconds: 15), answer: "36, 32, 28, 24, 20."),
        ActivitySeed("Number pattern", "What comes next: 3, 6, 12, 24, ?", .brainSpark(revealAfterSeconds: 12), answer: "48. Each number doubles."),
        ActivitySeed("Square pattern", "What comes next: 1, 4, 9, 16, ?", .brainSpark(revealAfterSeconds: 12), answer: "25. They are square numbers."),
        ActivitySeed("Odd one out", "Which differs: violin, trumpet, carrot, piano?", .brainSpark(revealAfterSeconds: 12), answer: "Carrot. The others are instruments."),
        ActivitySeed("Category dash", "Name five things that can roll.", .brainSpark(revealAfterSeconds: 15), answer: "Many answers work."),
        ActivitySeed("Reverse word", "Spell PLANET backward.", .brainSpark(revealAfterSeconds: 12), answer: "TENALP."),
        ActivitySeed("Letter step", "What letter comes next: B, D, F, H, ?", .brainSpark(revealAfterSeconds: 12), answer: "J. The sequence skips one letter."),
        ActivitySeed("Tiny analogy", "Bird is to nest as bee is to what?", .brainSpark(revealAfterSeconds: 12), answer: "Hive."),
        ActivitySeed("Memory four", "Remember: amber, bridge, nine, leaf.", .brainSpark(revealAfterSeconds: 15), answer: "Amber, bridge, nine, leaf."),
        ActivitySeed("Make a link", "Connect the words cloud and spoon with a short imaginary story.", .brainSpark(revealAfterSeconds: 15), answer: "There is no single right answer."),
        ActivitySeed("Three uses", "Think of three unusual uses for a rubber band.", .brainSpark(revealAfterSeconds: 15), answer: "There is no single right answer."),
        ActivitySeed("Quick estimate", "Without counting carefully, estimate how many keys are on your keyboard.", .brainSpark(revealAfterSeconds: 15), answer: "Compare your estimate with a quick glance."),
        ActivitySeed("Riddle shadow", "I follow you in light but vanish in darkness. What am I?", .brainSpark(revealAfterSeconds: 12), answer: "A shadow."),
        ActivitySeed("Riddle map", "I show cities but have no houses, and rivers but no water. What am I?", .brainSpark(revealAfterSeconds: 12), answer: "A map."),
        ActivitySeed("Alphabet neighbors", "What letters come immediately before and after M?", .brainSpark(revealAfterSeconds: 10), answer: "L and N."),
        ActivitySeed("Mental total", "Add 18, 7, and 25 in your head.", .brainSpark(revealAfterSeconds: 12), answer: "50."),
        ActivitySeed("Word ladder", "Change one letter in CAT to make something you wear on your head.", .brainSpark(revealAfterSeconds: 12), answer: "HAT."),
        ActivitySeed("Opposite pair", "Name a word that can mean the opposite of ‘expand.’", .brainSpark(revealAfterSeconds: 10), answer: "Contract, shrink, or reduce."),
        ActivitySeed("Mini planning puzzle", "Name the first two steps needed to mail a letter.", .brainSpark(revealAfterSeconds: 15), answer: "Many sensible sequences work."),
        ActivitySeed("Number bridge", "What number belongs between 14 and 26 if it is equally distant from both?", .brainSpark(revealAfterSeconds: 12), answer: "20."),
        ActivitySeed("Hidden rule", "Which does not fit: 8, 16, 24, 31, 40?", .brainSpark(revealAfterSeconds: 15), answer: "31. The others are multiples of 8."),
        ActivitySeed("Word connection", "What single word can follow both rain and brain?", .brainSpark(revealAfterSeconds: 15), answer: "Storm: rainstorm and brainstorm."),
        ActivitySeed("Tiny logic", "Mina is taller than Dev. Dev is taller than Lee. Who is shortest?", .brainSpark(revealAfterSeconds: 12), answer: "Lee.")
    ]

    private static let voiceSeeds: [ActivitySeed] = [
        ActivitySeed("Comfortable hum", "Hum one steady, comfortable note.", .timed(seconds: 25), safetyLine: "Stop if your voice feels strained."),
        ActivitySeed("Hum a melody", "Hum a short melody you know.", .timed(seconds: 30), safetyLine: "Keep the volume easy."),
        ActivitySeed("Sing one line", "Sing one familiar line at an easy pitch.", .timed(seconds: 30), safetyLine: "A quiet voice counts."),
        ActivitySeed("Three-note tune", "Sing or hum three notes up, then three notes down.", .timed(seconds: 25), safetyLine: "Stay in a comfortable pitch range."),
        ActivitySeed("Vowel glide", "Say ah, eh, ee, oh, oo at a relaxed volume.", .timed(seconds: 25)),
        ActivitySeed("Crisp consonants", "Say pa-ta-ka slowly four times.", .repetitions(count: 4, minimumSeconds: 20)),
        ActivitySeed("Red leather", "Say ‘red leather, yellow leather’ three times clearly.", .repetitions(count: 3, minimumSeconds: 20)),
        ActivitySeed("Toy boat", "Say ‘toy boat’ five times without rushing.", .repetitions(count: 5, minimumSeconds: 20)),
        ActivitySeed("Unique New York", "Say ‘unique New York’ three times clearly.", .repetitions(count: 3, minimumSeconds: 20)),
        ActivitySeed("Warm narrator", "Read one visible sentence like a calm audiobook narrator.", .timed(seconds: 25)),
        ActivitySeed("News reader", "Read one visible sentence like a friendly news presenter.", .timed(seconds: 25)),
        ActivitySeed("Character voice", "Say your name as a cheerful fictional character.", .timed(seconds: 20)),
        ActivitySeed("Pitch contrast", "Say ‘good morning’ once low and once slightly higher.", .timed(seconds: 20), safetyLine: "Use only comfortable pitches."),
        ActivitySeed("Volume ladder", "Say one short phrase quietly, then at normal conversational volume.", .timed(seconds: 20), safetyLine: "Do not shout."),
        ActivitySeed("Question and answer", "Say ‘Ready?’ like a question, then ‘Ready.’ like an answer.", .timed(seconds: 20)),
        ActivitySeed("Name five", "Name five foods aloud at a relaxed pace.", .timed(seconds: 25)),
        ActivitySeed("One-line jingle", "Invent and hum a tiny jingle for an ordinary desk object.", .timed(seconds: 30)),
        ActivitySeed("Open vowel", "Say one comfortable ah, then one comfortable oh, keeping both easy.", .timed(seconds: 25), safetyLine: "Stop if your voice feels strained."),
        ActivitySeed("Gratitude aloud", "Say one ordinary thing you appreciate today in a warm conversational voice.", .timed(seconds: 20)),
        ActivitySeed("Three moods", "Say ‘Here we go’ once calmly, once cheerfully, and once dramatically.", .timed(seconds: 25), safetyLine: "Keep the volume suitable for your space."),
        ActivitySeed("Gentle siren", "Hum softly from a comfortable low note to a comfortable high note and back.", .timed(seconds: 25), safetyLine: "Use a small range and stop before strain.")
    ]

    private static let writingSeeds: [ActivitySeed] = [
        ActivitySeed("Six-word scene", "Write a scene using exactly six words.", .writing(minimumSeconds: 25)),
        ActivitySeed("Tiny next step", "Write the smallest useful next action for your current work.", .writing(minimumSeconds: 25)),
        ActivitySeed("One clear sentence", "Explain what you are working on in one clear sentence.", .writing(minimumSeconds: 30)),
        ActivitySeed("Desk detail", "Describe one desk object using shape, color, and texture.", .writing(minimumSeconds: 30)),
        ActivitySeed("Five blue things", "Type five things that can be blue.", .writing(minimumSeconds: 25)),
        ActivitySeed("Five verbs", "Type five energetic verbs.", .writing(minimumSeconds: 25)),
        ActivitySeed("No letter E", "Write one sentence without using the letter E.", .writing(minimumSeconds: 30)),
        ActivitySeed("Future headline", "Write a positive headline about finishing today's key task.", .writing(minimumSeconds: 30)),
        ActivitySeed("Micro gratitude", "Write one specific thing you appreciate right now.", .writing(minimumSeconds: 25)),
        ActivitySeed("Useful question", "Write one question that would make your current task clearer.", .writing(minimumSeconds: 30)),
        ActivitySeed("Bad first idea", "Write a deliberately imperfect idea for the problem in front of you.", .writing(minimumSeconds: 30)),
        ActivitySeed("Unexpected pair", "Use the words lantern and keyboard in one sentence.", .writing(minimumSeconds: 30)),
        ActivitySeed("Sensory sentence", "Write a sentence that includes a sound and a texture.", .writing(minimumSeconds: 30)),
        ActivitySeed("Three priorities", "Type three things that matter today, in priority order.", .writing(minimumSeconds: 30)),
        ActivitySeed("Done list", "Write one thing you have already moved forward today.", .writing(minimumSeconds: 25)),
        ActivitySeed("Kind instruction", "Write the next step as advice to a friend.", .writing(minimumSeconds: 30)),
        ActivitySeed("One-line dialogue", "Write one line of dialogue that creates curiosity.", .writing(minimumSeconds: 30)),
        ActivitySeed("Twenty-second pitch", "Write a one-sentence pitch for a harmless imaginary product.", .writing(minimumSeconds: 30)),
        ActivitySeed("Remove a word", "Write a sentence, then make it clearer by removing one word.", .writing(minimumSeconds: 35)),
        ActivitySeed("Tiny celebration", "Write a short message celebrating a small recent win.", .writing(minimumSeconds: 25)),
        ActivitySeed("Fresh metaphor", "Describe your current energy as weather in one sentence.", .writing(minimumSeconds: 25)),
        ActivitySeed("Note to future you", "Write one useful sentence for yourself one hour from now.", .writing(minimumSeconds: 30)),
        ActivitySeed("Three curiosities", "Type three small things you are curious about today.", .writing(minimumSeconds: 30)),
        ActivitySeed("Change the ending", "Write a familiar phrase, then give it an unexpected ending.", .writing(minimumSeconds: 30))
    ]

    private static let rhythmSeeds: [ActivitySeed] = [
        ActivitySeed("Slow slow quick", "Repeat: slow, slow, quick, quick, slow.", .repetitions(count: 4, minimumSeconds: 25)),
        ActivitySeed("Thumb sequence", "Tap thumb to each fingertip forward and backward.", .timed(seconds: 30)),
        ActivitySeed("Alternating hands", "Alternate left and right fingertip taps on the desk.", .timed(seconds: 30)),
        ActivitySeed("Three-two pattern", "Tap three beats with one hand, then two with the other.", .timed(seconds: 30)),
        ActivitySeed("Clap pause clap", "Repeat two claps, one pause, and one clap.", .repetitions(count: 5, minimumSeconds: 25)),
        ActivitySeed("Desk drum", "Create a four-beat desk-tap pattern and repeat it.", .timed(seconds: 30)),
        ActivitySeed("Copy a clock", "Tap a steady beat like a ticking clock.", .timed(seconds: 30)),
        ActivitySeed("Accent the fourth", "Tap evenly but make every fourth tap slightly stronger.", .timed(seconds: 30)),
        ActivitySeed("Hands and thighs", "Alternate two hand taps with two light thigh taps.", .timed(seconds: 30)),
        ActivitySeed("Rhythm mirror", "Make a short pattern with one hand, then copy it with the other.", .timed(seconds: 35)),
        ActivitySeed("Count of six", "Tap six even beats, pause, then repeat.", .repetitions(count: 5, minimumSeconds: 30)),
        ActivitySeed("Syncopated tap", "Repeat: tap, pause, tap-tap, pause.", .timed(seconds: 30)),
        ActivitySeed("Finger wave", "Tap index through little finger, then reverse.", .timed(seconds: 30)),
        ActivitySeed("Build a beat", "Start with one tap and add one tap each round up to four.", .timed(seconds: 35)),
        ActivitySeed("Three-three-two", "Tap two groups of three beats, then one group of two, and repeat.", .timed(seconds: 30)),
        ActivitySeed("Missing beat", "Tap four steady beats but leave the third beat silent.", .timed(seconds: 30)),
        ActivitySeed("Hand-foot pulse", "Alternate a quiet fingertip tap with a gentle toe tap.", .timed(seconds: 30)),
        ActivitySeed("Silent conductor", "Conduct an imaginary four-beat pattern using small hand movements.", .timed(seconds: 30))
    ]

    private static let mindfulnessSeeds: [ActivitySeed] = [
        ActivitySeed("One breath", "Follow one natural breath from beginning to end.", .timed(seconds: 25)),
        ActivitySeed("Nearest sound", "Notice the nearest sound you can hear.", .timed(seconds: 30)),
        ActivitySeed("Farthest sound", "Listen for the most distant sound available.", .timed(seconds: 30)),
        ActivitySeed("Three colors", "Notice three colors in your surroundings away from the screen.", .timed(seconds: 30)),
        ActivitySeed("Contact points", "Notice where your body meets the chair and floor.", .timed(seconds: 30)),
        ActivitySeed("Hand sensation", "Notice temperature, pressure, or tingling in one hand.", .timed(seconds: 30)),
        ActivitySeed("Air on skin", "Notice where you can feel air touching your skin.", .timed(seconds: 30)),
        ActivitySeed("Object outline", "Trace the outline of one nearby object with your gaze.", .timed(seconds: 30)),
        ActivitySeed("Light quality", "Notice whether the light around you feels warm, cool, soft, or sharp.", .timed(seconds: 30)),
        ActivitySeed("Name a feeling", "Give one present feeling a simple, neutral name.", .timed(seconds: 25)),
        ActivitySeed("Thought passing", "Notice one thought arrive and let it pass without following it.", .timed(seconds: 30)),
        ActivitySeed("Taste check", "Notice any taste in your mouth without trying to change it.", .timed(seconds: 25)),
        ActivitySeed("Posture notice", "Notice your posture exactly as it is before adjusting anything.", .timed(seconds: 30)),
        ActivitySeed("Small movement", "Notice one tiny movement in your body, such as breathing or blinking.", .timed(seconds: 30)),
        ActivitySeed("Room temperature", "Notice how the room temperature feels on your face and hands.", .timed(seconds: 30)),
        ActivitySeed("Layers of sound", "Notice one sound in front of you, one beside you, and one farther away.", .timed(seconds: 30)),
        ActivitySeed("Scent check", "Notice whether there is any scent in the air, including almost none.", .timed(seconds: 25)),
        ActivitySeed("Emotion location", "Notice where an emotion seems to show up in your body, without explaining it.", .timed(seconds: 30)),
        ActivitySeed("Open attention", "Let sights, sounds, and sensations share your attention without choosing one.", .timed(seconds: 30))
    ]

    private static let affirmationSeeds: [ActivitySeed] = [
        ActivitySeed("Meaningful work", "Read slowly: ‘I am working on something important to me right now.’", .timed(seconds: 20)),
        ActivitySeed("One useful step", "Read slowly: ‘I can choose one useful next step.’", .timed(seconds: 20)),
        ActivitySeed("Small counts", "Read slowly: ‘A small amount of honest progress counts.’", .timed(seconds: 20)),
        ActivitySeed("Begin imperfectly", "Read slowly: ‘I am allowed to begin before it feels perfect.’", .timed(seconds: 20)),
        ActivitySeed("Return gently", "Read slowly: ‘I can return my attention without judging myself.’", .timed(seconds: 20)),
        ActivitySeed("Enough for now", "Read slowly: ‘Doing the next piece is enough for now.’", .timed(seconds: 20)),
        ActivitySeed("Clear choice", "Read slowly: ‘I can make one clear choice and continue.’", .timed(seconds: 20)),
        ActivitySeed("Pause belongs", "Read slowly: ‘A brief pause can belong inside useful work.’", .timed(seconds: 20)),
        ActivitySeed("Effort is real", "Read slowly: ‘My effort is real even when progress is quiet.’", .timed(seconds: 20)),
        ActivitySeed("Ask for clarity", "Read slowly: ‘I can ask for clarity when I need it.’", .timed(seconds: 20)),
        ActivitySeed("Not all today", "Read slowly: ‘I do not need to solve everything today.’", .timed(seconds: 20)),
        ActivitySeed("Kind persistence", "Read slowly: ‘I can be persistent without being harsh with myself.’", .timed(seconds: 20)),
        ActivitySeed("Own pace", "Read slowly: ‘I can work at a pace I can sustain.’", .timed(seconds: 20)),
        ActivitySeed("Notice progress", "Read slowly: ‘I can notice progress before chasing the next thing.’", .timed(seconds: 20)),
        ActivitySeed("Protect focus", "Read slowly: ‘My attention is worth protecting for the next small step.’", .timed(seconds: 20)),
        ActivitySeed("Restart counts", "Read slowly: ‘Restarting is part of continuing.’", .timed(seconds: 20)),
        ActivitySeed("Enough chosen", "Read slowly: ‘I can decide what is enough for this moment.’", .timed(seconds: 20)),
        ActivitySeed("Learning forward", "Read slowly: ‘I can learn while moving forward.’", .timed(seconds: 20))
    ]
}
