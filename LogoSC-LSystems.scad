// ============================================================================
// LogoSC L-Systems - optional deterministic grammar companion
//
// Pure OpenSCAD functions expand integer-symbol L-systems and interpret the
// resulting symbols as ordinary LogoSC command lists. LogoSC Core remains the
// geometry evaluator; this companion adds no Core opcodes.
//
// WHAT IS AN L-SYSTEM?
//
// An L-system (Lindenmayer system) is a compact rewriting grammar. It begins
// with an initial list of symbols called the axiom. On every expansion pass,
// each symbol is replaced in parallel according to a rule. Repeating a small
// rule can quickly produce a detailed fractal, curve, or branching plant.
//
// For example, imagine this symbolic grammar:
//
//     axiom: F
//     rule:  F -> F + F
//
// Its first expansions are:
//
//     depth 0: F
//     depth 1: F + F
//     depth 2: F + F + F + F
//
// Rewriting only creates symbols. A separate interpretation step assigns
// drawing meanings to them. In the standard LogoSC interpretation:
//
//     F  draws forward with [MOVE, step]
//     f  moves forward with the pen up
//     +  turns left with [TURN, angle]
//     -  turns right with [TURN, -angle]
//     [  saves the turtle state with [PUSH]
//     ]  restores the turtle state with [POP]
//
// Other symbols, such as A, B, X, and Y, can participate in rewriting without
// drawing anything. They are useful as grammar variables.
//
// WHY USE ONE?
//
// L-systems are useful whenever a design needs structured detail at several
// scales rather than simple repetition. Practical examples include branching
// trees, coral, roots, leaf veins, lightning-like traces, space-filling paths,
// decorative borders, fractal cutouts, ornaments, and texture or infill paths.
// A designer can change one rule or the expansion depth to produce a related
// family of parts instead of drawing every branch or edge independently.
// They are less helpful for regular grids or fixed hole patterns, where an
// OpenSCAD loop or an ordinary LogoSC command list is usually clearer.
//
// BASIC USE
//
// Include LogoSC Core in the calling file, include this companion, choose a
// system, and ask it for an ordinary LogoSC command list:
//
//     include <LogoSC-Foundation-Core.scad>
//     include <LogoSC-LSystems.scad>
//
//     system = MakeKochLSystem();
//     commands = LSystemCommands(system, depth = 2, size = 45);
//     RenderLogo2D(commands);
//
// Closed systems such as Koch, quadratic Koch, and Sierpinski can produce
// filled LogoSC regions. Hilbert, Dragon, and plant systems are naturally open
// paths; inspect those with RenderLogoDebug() unless the caller deliberately
// converts them into closed manufacturing geometry.
//
// MAIN FUNCTIONS
//
//     MakeLSystemRule(symbol, replacementSymbols)
//         Constructs one rewrite rule.
//
//     MakeLSystem(name, axiom, rules, angle, stepDivisor, interpretations)
//         Constructs a complete custom grammar record.
//
//     LSystemExpand(system, depth)
//         Performs rewriting and returns the final symbol list.
//
//     LSystemInterpret(symbols, step, angle, interpretations)
//         Converts an already expanded symbol list into LogoSC commands.
//
//     LSystemCommands(system, depth, size)
//         Convenience function that expands and interprets a system. It scales
//         the drawing step by the system's per-depth stepDivisor.
//
//     LSystemPreset(name) and LSystemPresetNames()
//         Select or enumerate the built-in grammars.
//
// Named constructors are MakeKochLSystem(), MakeQuadraticKochLSystem(),
// MakeHilbertLSystem(), MakeDragonLSystem(), MakeSierpinskiLSystem(),
// MakePlantLSystem(), MakeLevyCLSystem(), MakeGosperLSystem(), and
// MakeCanopyLSystem(). Record accessors begin with LSystem; validation starts
// with LSystemIsValid(). See LogoSC-LSystems-Guide.md for the complete usage
// guide and its compact comparison table, LogoSC-LSystems-Examples.scad for
// the runnable centered 3-by-3 gallery, and
// LogoSC-LSystems-Test-Runner.scad for the focused deterministic test suite.
// ============================================================================

use <LogoSC-Foundation-Core.scad>

// Public symbols used by the built-in grammars.
LSYS_F = 100 + 0;
LSYS_G = 101 + 0;
LSYS_f = 102 + 0;
LSYS_PLUS = 103 + 0;
LSYS_MINUS = 104 + 0;
LSYS_PUSH = 105 + 0;
LSYS_POP = 106 + 0;
LSYS_A = 107 + 0;
LSYS_B = 108 + 0;
LSYS_X = 109 + 0;
LSYS_Y = 110 + 0;

// Interpretation action codes.
LSYS_ACTION_IGNORE = 0 + 0;
LSYS_ACTION_DRAW = 1 + 0;
LSYS_ACTION_MOVE = 2 + 0;
LSYS_ACTION_TURN = 3 + 0;
LSYS_ACTION_PUSH = 4 + 0;
LSYS_ACTION_POP = 5 + 0;

// Rule record: [symbol, replacementSymbols].
LSYS_RULE_SYMBOL = 0 + 0;
LSYS_RULE_REPLACEMENT = 1 + 0;

// Interpretation record: [symbol, action, multiplier].
LSYS_INTERPRET_SYMBOL = 0 + 0;
LSYS_INTERPRET_ACTION = 1 + 0;
LSYS_INTERPRET_MULTIPLIER = 2 + 0;

// System record: [name, axiom, rules, angle, stepDivisor, interpretations].
LSYS_SYSTEM_NAME = 0 + 0;
LSYS_SYSTEM_AXIOM = 1 + 0;
LSYS_SYSTEM_RULES = 2 + 0;
LSYS_SYSTEM_ANGLE = 3 + 0;
LSYS_SYSTEM_STEP_DIVISOR = 4 + 0;
LSYS_SYSTEM_INTERPRETATIONS = 5 + 0;

function MakeLSystemRule(symbol, replacementSymbols) =
    [symbol, replacementSymbols];

function LSystemRuleSymbol(rule) = rule[LSYS_RULE_SYMBOL];
function LSystemRuleReplacement(rule) = rule[LSYS_RULE_REPLACEMENT];

function MakeLSystemInterpretation(symbol, action, multiplier = 1) =
    [symbol, action, multiplier];

function LSystemInterpretationSymbol(interpretation) =
    interpretation[LSYS_INTERPRET_SYMBOL];
function LSystemInterpretationAction(interpretation) =
    interpretation[LSYS_INTERPRET_ACTION];
function LSystemInterpretationMultiplier(interpretation) =
    len(interpretation) > LSYS_INTERPRET_MULTIPLIER
        ? interpretation[LSYS_INTERPRET_MULTIPLIER]
        : 1;

function LSystemStandardInterpretations() =
[
    MakeLSystemInterpretation(LSYS_F, LSYS_ACTION_DRAW),
    MakeLSystemInterpretation(LSYS_G, LSYS_ACTION_DRAW),
    MakeLSystemInterpretation(LSYS_f, LSYS_ACTION_MOVE),
    MakeLSystemInterpretation(LSYS_PLUS, LSYS_ACTION_TURN),
    MakeLSystemInterpretation(LSYS_MINUS, LSYS_ACTION_TURN, -1),
    MakeLSystemInterpretation(LSYS_PUSH, LSYS_ACTION_PUSH),
    MakeLSystemInterpretation(LSYS_POP, LSYS_ACTION_POP)
];

function MakeLSystem(
    name,
    axiom,
    rules,
    angle,
    stepDivisor,
    interpretations = undef) =
[
    name,
    axiom,
    rules,
    angle,
    stepDivisor,
    is_undef(interpretations)
        ? LSystemStandardInterpretations()
        : interpretations
];

function LSystemName(system) = system[LSYS_SYSTEM_NAME];
function LSystemAxiom(system) = system[LSYS_SYSTEM_AXIOM];
function LSystemRules(system) = system[LSYS_SYSTEM_RULES];
function LSystemAngle(system) = system[LSYS_SYSTEM_ANGLE];
function LSystemStepDivisor(system) = system[LSYS_SYSTEM_STEP_DIVISOR];
function LSystemInterpretations(system) = system[LSYS_SYSTEM_INTERPRETATIONS];

function LSystemIsRule(rule) =
    is_list(rule)
    && len(rule) == 2
    && is_num(LSystemRuleSymbol(rule))
    && is_list(LSystemRuleReplacement(rule));

function LSystemRulesAreValid(rules, index = 0) =
    !is_list(rules)
        ? false
        : index >= len(rules)
            ? true
            : LSystemIsRule(rules[index])
                && LSystemRulesAreValid(rules, index + 1);

function LSystemIsInterpretation(interpretation) =
    is_list(interpretation)
    && len(interpretation) >= 2
    && len(interpretation) <= 3
    && is_num(LSystemInterpretationSymbol(interpretation))
    && is_num(LSystemInterpretationAction(interpretation))
    && LSystemInterpretationAction(interpretation) >= LSYS_ACTION_IGNORE
    && LSystemInterpretationAction(interpretation) <= LSYS_ACTION_POP
    && is_num(LSystemInterpretationMultiplier(interpretation));

function LSystemInterpretationsAreValid(interpretations, index = 0) =
    !is_list(interpretations)
        ? false
        : index >= len(interpretations)
            ? true
            : LSystemIsInterpretation(interpretations[index])
                && LSystemInterpretationsAreValid(interpretations, index + 1);

function LSystemIsValid(system) =
    is_list(system)
    && len(system) == 6
    && is_string(LSystemName(system))
    && is_list(LSystemAxiom(system))
    && LSystemRulesAreValid(LSystemRules(system))
    && is_num(LSystemAngle(system))
    && is_num(LSystemStepDivisor(system))
    && LSystemStepDivisor(system) > 0
    && LSystemInterpretationsAreValid(LSystemInterpretations(system));

function LSystemFindRule(rules, symbol, index = 0) =
    index >= len(rules)
        ? undef
        : LSystemRuleSymbol(rules[index]) == symbol
            ? rules[index]
            : LSystemFindRule(rules, symbol, index + 1);

function LSystemReplacement(rules, symbol) =
    let(rule = LSystemFindRule(rules, symbol))
    is_undef(rule) ? [symbol] : LSystemRuleReplacement(rule);

function LSystemRewrite(symbols, rules) =
[
    for (symbol = symbols)
        each LSystemReplacement(rules, symbol)
];

function LSystemExpandSymbols(symbols, rules, depth) =
    depth <= 0
        ? symbols
        : LSystemExpandSymbols(
            LSystemRewrite(symbols, rules),
            rules,
            depth - 1
        );

function LSystemExpand(system, depth) =
    assert(LSystemIsValid(system), "Malformed L-system record.")
    assert(depth >= 0, "L-system depth must be nonnegative.")
    LSystemExpandSymbols(LSystemAxiom(system), LSystemRules(system), depth);

function LSystemFindInterpretation(interpretations, symbol, index = 0) =
    index >= len(interpretations)
        ? undef
        : LSystemInterpretationSymbol(interpretations[index]) == symbol
            ? interpretations[index]
            : LSystemFindInterpretation(interpretations, symbol, index + 1);

function LSystemInterpretSymbol(symbol, step, angle, interpretations) =
    let(interpretation = LSystemFindInterpretation(interpretations, symbol))
    is_undef(interpretation)
        ? []
        : let(
            action = LSystemInterpretationAction(interpretation),
            multiplier = LSystemInterpretationMultiplier(interpretation)
        )
        action == LSYS_ACTION_DRAW
            ? [[MOVE, step * multiplier]]
            : action == LSYS_ACTION_MOVE
                ? [[PENUP], [MOVE, step * multiplier], [PENDOWN]]
                : action == LSYS_ACTION_TURN
                    ? [[TURN, angle * multiplier]]
                    : action == LSYS_ACTION_PUSH
                        ? [[PUSH]]
                        : action == LSYS_ACTION_POP
                            ? [[POP]]
                            : [];

function LSystemInterpret(symbols, step, angle, interpretations) =
[
    for (symbol = symbols)
        each LSystemInterpretSymbol(symbol, step, angle, interpretations)
];

function LSystemStep(system, size, depth) =
    size / pow(LSystemStepDivisor(system), depth);

function LSystemCommands(system, depth, size) =
    let(
        symbols = LSystemExpand(system, depth),
        step = LSystemStep(system, size, depth)
    )
    LSystemInterpret(
        symbols,
        step,
        LSystemAngle(system),
        LSystemInterpretations(system)
    );

function MakeKochLSystem() =
    MakeLSystem(
        "Koch",
        [LSYS_F, LSYS_MINUS, LSYS_MINUS, LSYS_F,
         LSYS_MINUS, LSYS_MINUS, LSYS_F],
        [
            MakeLSystemRule(
                LSYS_F,
                [LSYS_F, LSYS_PLUS, LSYS_F, LSYS_MINUS,
                 LSYS_MINUS, LSYS_F, LSYS_PLUS, LSYS_F]
            )
        ],
        60,
        3
    );

function MakeQuadraticKochLSystem() =
    MakeLSystem(
        "Quadratic Koch",
        [LSYS_F, LSYS_PLUS, LSYS_F, LSYS_PLUS,
         LSYS_F, LSYS_PLUS, LSYS_F],
        [
            MakeLSystemRule(
                LSYS_F,
                [LSYS_F, LSYS_MINUS, LSYS_F, LSYS_PLUS,
                 LSYS_F, LSYS_PLUS, LSYS_F, LSYS_F,
                 LSYS_MINUS, LSYS_F, LSYS_MINUS, LSYS_F,
                 LSYS_PLUS, LSYS_F]
            )
        ],
        90,
        4
    );

function MakeHilbertLSystem() =
    MakeLSystem(
        "Hilbert",
        [LSYS_A],
        [
            MakeLSystemRule(
                LSYS_A,
                [LSYS_PLUS, LSYS_B, LSYS_F, LSYS_MINUS,
                 LSYS_A, LSYS_F, LSYS_A, LSYS_MINUS,
                 LSYS_F, LSYS_B, LSYS_PLUS]
            ),
            MakeLSystemRule(
                LSYS_B,
                [LSYS_MINUS, LSYS_A, LSYS_F, LSYS_PLUS,
                 LSYS_B, LSYS_F, LSYS_B, LSYS_PLUS,
                 LSYS_F, LSYS_A, LSYS_MINUS]
            )
        ],
        90,
        2
    );

function MakeDragonLSystem() =
    MakeLSystem(
        "Dragon",
        [LSYS_F, LSYS_X],
        [
            MakeLSystemRule(
                LSYS_X,
                [LSYS_X, LSYS_PLUS, LSYS_Y, LSYS_F, LSYS_PLUS]
            ),
            MakeLSystemRule(
                LSYS_Y,
                [LSYS_MINUS, LSYS_F, LSYS_X, LSYS_MINUS, LSYS_Y]
            )
        ],
        90,
        sqrt(2)
    );

function MakeSierpinskiLSystem() =
    MakeLSystem(
        "Sierpinski",
        [LSYS_F, LSYS_MINUS, LSYS_G, LSYS_MINUS, LSYS_G],
        [
            MakeLSystemRule(
                LSYS_F,
                [LSYS_F, LSYS_MINUS, LSYS_G, LSYS_PLUS,
                 LSYS_F, LSYS_PLUS, LSYS_G, LSYS_MINUS, LSYS_F]
            ),
            MakeLSystemRule(LSYS_G, [LSYS_G, LSYS_G])
        ],
        120,
        2
    );

function MakePlantLSystem() =
    MakeLSystem(
        "Plant",
        [LSYS_X],
        [
            MakeLSystemRule(
                LSYS_X,
                [LSYS_F,
                 LSYS_PUSH,
                 LSYS_PLUS, LSYS_PLUS,
                 LSYS_F, LSYS_X,
                 LSYS_POP,
                 LSYS_PUSH,
                 LSYS_MINUS, LSYS_MINUS, LSYS_MINUS,
                 LSYS_F, LSYS_G, LSYS_X,
                 LSYS_POP]
            ),
            MakeLSystemRule(LSYS_F, [LSYS_F, LSYS_F])
        ],
        10,
        2
    );

function MakeLevyCLSystem() =
    MakeLSystem(
        "Levy C",
        [LSYS_F, LSYS_PLUS, LSYS_PLUS,
         LSYS_F, LSYS_PLUS, LSYS_PLUS,
         LSYS_F, LSYS_PLUS, LSYS_PLUS,
         LSYS_F, LSYS_PLUS, LSYS_PLUS],
        [
            MakeLSystemRule(
                LSYS_F,
                [LSYS_PLUS, LSYS_F, LSYS_MINUS, LSYS_MINUS,
                 LSYS_F, LSYS_PLUS]
            )
        ],
        45,
        sqrt(2)
    );

function MakeGosperLSystem() =
    MakeLSystem(
        "Gosper",
        [LSYS_F],
        [
            MakeLSystemRule(
                LSYS_F,
                [LSYS_F, LSYS_MINUS, LSYS_G, LSYS_MINUS, LSYS_MINUS,
                 LSYS_G, LSYS_PLUS, LSYS_F, LSYS_PLUS, LSYS_PLUS,
                 LSYS_F, LSYS_F, LSYS_PLUS, LSYS_G, LSYS_MINUS]
            ),
            MakeLSystemRule(
                LSYS_G,
                [LSYS_PLUS, LSYS_F, LSYS_MINUS, LSYS_G, LSYS_G,
                 LSYS_MINUS, LSYS_MINUS, LSYS_G, LSYS_MINUS, LSYS_F,
                 LSYS_PLUS, LSYS_PLUS, LSYS_F, LSYS_PLUS, LSYS_G]
            )
        ],
        60,
        sqrt(7)
    );

function MakeCanopyLSystem() =
    MakeLSystem(
        "Canopy",
        [LSYS_X],
        [
            MakeLSystemRule(
                LSYS_X,
                [LSYS_F, LSYS_PUSH, LSYS_PLUS, LSYS_X, LSYS_POP,
                 LSYS_PUSH, LSYS_MINUS, LSYS_X, LSYS_POP]
            ),
            MakeLSystemRule(LSYS_F, [LSYS_F, LSYS_F])
        ],
        28,
        2
    );

function LSystemPreset(name) =
    name == "Koch"
        ? MakeKochLSystem()
        : name == "Quadratic Koch"
            ? MakeQuadraticKochLSystem()
            : name == "Hilbert"
                ? MakeHilbertLSystem()
                : name == "Dragon"
                    ? MakeDragonLSystem()
                    : name == "Sierpinski"
                        ? MakeSierpinskiLSystem()
                        : name == "Plant"
                            ? MakePlantLSystem()
                            : name == "Levy C"
                                ? MakeLevyCLSystem()
                                : name == "Gosper"
                                    ? MakeGosperLSystem()
                                    : name == "Canopy"
                                        ? MakeCanopyLSystem()
                                        : assert(false, str("Unknown L-system preset: ", name));

function LSystemPresetNames() =
    ["Koch", "Quadratic Koch", "Sierpinski",
     "Hilbert", "Dragon", "Levy C",
     "Gosper", "Plant", "Canopy"];
