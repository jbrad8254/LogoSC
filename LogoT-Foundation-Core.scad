// ============================================================================
// LogoT-Foundation Core
//
// Core interpreter and renderer.
// See LogoT-README.md for overview, command reference, and roadmap.
// ============================================================================

// -----------------------------------------------------------------------------
// LogoT-Foundation
//
// OpenSCAD Logo / Logo-style command evaluator.
// Interpreter uses one Eval* handler function per opcode.
//
// This split-file baseline contains core interpreter controls, constants,
// state functions, trace functions, opcode handlers, and evaluator logic.
// The companion LogoT-Foundation-Tests.scad file is included at parse time
// below, with test execution gated by RunLogoTests.
//
// Command format:
//     [MOVE,   len]
//     [TURN,   deltaHeading]
//     [DIR,    absoluteHeading]
//     [SCALE,  scaleMultiplier]
//     [GOTO,   x, y, heading]
//
//     [RUN,    cmds]
//     [RUN,    cmds, scale]
//     [RUN,    cmds, scale, maxRec]
//
//     [PUSH]
//         Saves the current Logo state [x, y, heading, scale] onto the
//         interpreter state stack.
//
//     [POP]
//         Restores the most recently pushed Logo state. If the stack is empty,
//         this reports a soft error and continues when HardErrors = false.
//
//     [PENUP]
//         Stops adding MOVE/GOTO destinations to the current contour. Logo
//         position and heading still change.
//
//     [PENDOWN]
//         Starts a new contour at the current Logo location and resumes adding
//         MOVE/GOTO destinations.
//
//     [REPEAT, count, cmds]
//         Executes cmds count times. The command body can contain MOVE, TURN,
//         RUN, PUSH, POP, PENUP, PENDOWN, nested REPEAT, and other supported
//         Logo commands.
//
// RUN defaults:
//     scale  = 1
//     maxRec = 2
//
// Rendering model:
//     LogoT now returns multiple contours. Each contour is rendered with a
//     separate polygon() call. Holes and open-stroke rendering are intentionally
//     deferred.
// -----------------------------------------------------------------------------

/* [LogoT Controls] */

// Circle divisions used for any curved geometry in tests.
$fn = 256;     // [32:32:1024]

// Enable hard-stop interpreter errors.
// false: print [ERROR] and continue the test suite.
// true: use assert() and stop immediately on serious interpreter errors.
HardErrors = false; // [false:true]

// Trace verbosity.
//
// 0 : No trace output.
// 1 : Major entry/exit messages and errors.
// 2 : Static command-list trace (TraceCmds) and summary information.
// 3 : Additional state/contour dumps.
// 4 : Full instruction-by-instruction execution trace from evalLogo().
//
// Higher levels include all lower levels.
TraceLevel = 2; // [0:4]

// Global safety limit for RUN command recursion inside evalLogo().
maxRunRecursions = 5; // [0:20]

// Default per-RUN recursion limit when RUN is written without maxRec.
DefaultRunMaxRecursions = 2; // [0:20]

// Default extrusion height used by LogoTest().
DefaultTestHeight = 5; // [1:1:20]

// Run regression tests from LogoT-Foundation-Tests.scad.
RunLogoTests = true; // [false:true]

// Non-fatal error helper for use inside functions.
function ErrorOrZero(msg, value = undef) =
    HardErrors
        ? assert(false, msg) 0
        : echo("[ERROR]", msg, value) 0;

function SoftError(msg, value = undef) =
    ErrorOrZero(msg, value);

// -----------------------------------------------------------------------------
// Logo command opcodes
// -----------------------------------------------------------------------------
// The '+ 0' keeps implementation constants out of the OpenSCAD Customizer.
MOVE    = 0 + 0;  // [MOVE, len]
TURN    = 1 + 0;  // [TURN, deltaHeading]
DIR     = 2 + 0;  // [DIR, absoluteHeading]
SCALE   = 3 + 0;  // [SCALE, scaleMultiplier]
GOTO    = 4 + 0;  // [GOTO, x, y, heading]
RUN     = 5 + 0;  // [RUN, cmds], [RUN, cmds, scale], [RUN, cmds, scale, maxRec]
PUSH    = 6 + 0;  // [PUSH] saves current Logo state on the stack.
POP     = 7 + 0;  // [POP] restores the most recently pushed Logo state.
REPEAT  = 8 + 0;  // [REPEAT, count, cmds] executes cmds count times.
PENUP   = 9 + 0;  // [PENUP] disables point emission while movement continues.
PENDOWN = 10 + 0; // [PENDOWN] starts a new contour and resumes point emission.

// -----------------------------------------------------------------------------
// Logo state indices: [x, y, heading, scale]
// -----------------------------------------------------------------------------
SX = 0 + 0;
SY = 1 + 0;
SH = 2 + 0;
SS = 3 + 0;

// -----------------------------------------------------------------------------
// Pen state values
// -----------------------------------------------------------------------------
PEN_UP   = 0 + 0;
PEN_DOWN = 1 + 0;

// -----------------------------------------------------------------------------
// Command field indices
// -----------------------------------------------------------------------------
COP = 0 + 0;
CA1 = 1 + 0;
CA2 = 2 + 0;
CA3 = 3 + 0;

// -----------------------------------------------------------------------------
// Evaluator result indices: [state, contours, stack, pen]
// -----------------------------------------------------------------------------
ER_STATE    = 0 + 0;
ER_CONTOURS = 1 + 0;
ER_STACK    = 2 + 0;
ER_PEN      = 3 + 0;

// Access an optional command argument.
//
// Returns defaultValue if the requested command field is absent or undef.
function CmdArg(vCmd, fieldIndex, defaultValue = undef) =
    (vCmd != undef && len(vCmd) > fieldIndex && vCmd[fieldIndex] != undef)
        ? vCmd[fieldIndex]
        : defaultValue;

// Construct an evaluator result vector [state, contours, stack, pen].
function EvalResult(state, contours, stack, pen) =
[
    state,
    contours,
    stack,
    pen
];

function ResultState(result) =
    result[ER_STATE];

function ResultContours(result) =
    result[ER_CONTOURS];

function ResultStack(result) =
    result[ER_STACK];

function ResultPen(result) =
    result[ER_PEN];

// Return the current contour from a contour list.
function CurrentContour(contours) =
    (len(contours) == 0)
        ? []
        : contours[len(contours) - 1];

// Replace the current contour in a contour list.
function ReplaceCurrentContour(contours, contour) =
    (len(contours) == 0)
        ? [contour]
        :
        [
            for (i = [0 : len(contours) - 1])
                (i == len(contours) - 1) ? contour : contours[i]
        ];

// Append a point to the current contour, creating one if needed.
function AddPointToContours(contours, point) =
    ReplaceCurrentContour(
        contours,
        concat(CurrentContour(contours), [point])
    );

// Start a new contour at the current Logo state.
function StartContour(contours, state) =
    concat(contours, [[[state[SX], state[SY]]]]);

// Count total points across all contours.
//
// Expected recursive use:
//     Calls itself with index + 1 until every contour has been counted.
function CountContourPoints(contours, index = 0) =
    (index >= len(contours))
        ? 0
        : len(contours[index]) + CountContourPoints(contours, index + 1);

// Return the smaller of two scalar values.
function min2(a, b) =
    (a < b) ? a : b;

// Construct a Logo state vector [x, y, heading, scale].
function stateMake(x, y, heading, scale) =
[
    x,
    y,
    heading,
    scale
];

// Create a new absolute Logo state at x/y with heading h and scale s.
function stateGoto(x, y, h, s = 1) =
    stateMake(x, y, h, s);

// Low-level Logo state transform: move by len * scale along the current heading.
function stateMove(vState, len, scale) =
    let(
        h = vState[SH],
        x = vState[SX] + scale * len * cos(h),
        y = vState[SY] + scale * len * sin(h),
        s = vState[SS]
    )
    stateMake(x, y, h, s);

// Low-level Logo state transform: rotate heading by a relative angle.
function stateTurn(vState, dh) =
    let(
        x = vState[SX],
        y = vState[SY],
        h = vState[SH] + dh,
        s = vState[SS]
    )
    stateMake(x, y, h, s);

// Low-level Logo state transform: set the heading to an absolute angle.
function stateDir(vState, absh) =
    let(
        x = vState[SX],
        y = vState[SY],
        h = absh,
        s = vState[SS]
    )
    stateMake(x, y, h, s);

// Low-level Logo state transform: multiply the movement scale.
function stateScale(vState, ss) =
    let(
        x = vState[SX],
        y = vState[SY],
        h = vState[SH],
        s = vState[SS] * ss
    )
    stateMake(x, y, h, s);


// -----------------------------------------------------------------------------
// RUN and REPEAT command helpers
// -----------------------------------------------------------------------------

// Extract the child command list from a RUN command.
function RunCmds(logoCmd) =
    CmdArg(logoCmd, CA1, []);

// Extract the optional RUN scale; defaults to 1.
function RunScale(logoCmd) =
    CmdArg(logoCmd, CA2, 1);

// Extract the optional RUN recursion limit; defaults to DefaultRunMaxRecursions.
function RunMaxRec(logoCmd) =
    CmdArg(logoCmd, CA3, DefaultRunMaxRecursions);

// Extract the repeat count from a REPEAT command.
function RepeatCount(logoCmd) =
    CmdArg(logoCmd, CA1, 0);

// Extract the child command list from a REPEAT command.
function RepeatCmds(logoCmd) =
    CmdArg(logoCmd, CA2, []);

// Convert an opcode to a printable command name.
function CmdName(op) =
      (op == MOVE)   ? "MOVE"
    : (op == TURN)   ? "TURN"
    : (op == DIR)    ? "DIR"
    : (op == SCALE)  ? "SCALE"
    : (op == GOTO)   ? "GOTO"
    : (op == RUN)    ? "RUN"
    : (op == PUSH)   ? "PUSH"
    : (op == POP)    ? "POP"
    : (op == REPEAT) ? "REPEAT"
    : (op == PENUP)  ? "PENUP"
    : (op == PENDOWN)? "PENDOWN"
    : str("UNKNOWN(", op, ")");

// Emit one command-execution trace line from inside a function.
function TraceExec(level, index, state, vCmd, tag = "TRACE") =
    (level <= TraceLevel)
        ? echo(
            str("[", tag, "]"),
            "index=", index,
            "op=", (vCmd == undef) ? "UNDEF" : CmdName(vCmd[COP]),
            "pos=", [state[SX], state[SY]],
            "heading=", state[SH],
            "scale=", state[SS],
            "cmd=", vCmd
          )
          0
        : 0;

// Emit one generic trace message from inside a function.
function TraceMsg(level, msg, value = undef, tag = "TRACE") =
    (level <= TraceLevel)
        ? echo(str("[", tag, "]"), msg, value) 0
        : 0;

// Print a static trace line for one command. Used by TraceCmds().
module TraceCmd(level, index, state, vCmd, indent = "")
{
    if (level <= TraceLevel)
    {
        echo(
            indent,
            "[", index, "] ",
            (vCmd == undef) ? "UNDEF" : CmdName(vCmd[COP]),
            " Pos=(",
            state[SX], ",", state[SY],
            ") H=", state[SH],
            " S=", state[SS],
            " Cmd=", vCmd
        );
    }
}

// Recursively print the static structure of a command list.
//
// Expected recursive use:
//     Calls itself when a RUN or REPEAT command contains a nonempty child list.
module TraceCmds(
    vtCmds,
    state = stateGoto(0, 0, 0, 1),
    indent = "",
    maxRec = DefaultRunMaxRecursions,
    level = 2)
{
    if (maxRec < 0)
    {
        echo(indent, "*** Maximum trace recursion exceeded ***");
    }
    else if (len(vtCmds) == 0)
    {
        echo(indent, "<empty command list>");
    }
    else
    {
        for (i = [0 : len(vtCmds) - 1])
        {
            cmd = vtCmds[i];
            TraceCmd(level, i, state, cmd, indent);

            if (cmd[COP] == RUN)
            {
                childCmds = RunCmds(cmd);

                if (len(childCmds) == 0)
                {
                    echo(str(indent, "    "), "<empty command list>");
                }
                else
                {
                    TraceCmds(
                        childCmds,
                        state,
                        str(indent, "    "),
                        min2(maxRec - 1, RunMaxRec(cmd) - 1),
                        level
                    );
                }
            }
            else if (cmd[COP] == REPEAT)
            {
                echo(
                    str(indent, "    "),
                    "REPEAT count=",
                    RepeatCount(cmd),
                    " childCmds=",
                    len(RepeatCmds(cmd))
                );

                TraceCmds(
                    RepeatCmds(cmd),
                    state,
                    str(indent, "    "),
                    maxRec,
                    level
                );
            }
        }
    }
}

// -----------------------------------------------------------------------------
// Evaluator
// -----------------------------------------------------------------------------

// Handler result format:
//     EvalResult(nextState, nextContours, nextStack, nextPen)
//
// Each opcode handler returns this format so evalLogo() can remain a compact
// dispatcher. This also keeps opcode-specific behavior localized.

// Handle MOVE.
//
// Moves the Logo. If the pen is down, adds the destination point to the
// current contour. If the pen is up, only the state changes.
function EvalMove(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA1)
        ? let(
            _err = SoftError("Malformed MOVE command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : let(
            nextState = stateMove(state, CmdArg(vCmd, CA1), state[SS]),
            nextPoint = [nextState[SX], nextState[SY]],
            nextContours =
                (pen == PEN_DOWN)
                    ? AddPointToContours(contours, nextPoint)
                    : contours
        )
        EvalResult(nextState, nextContours, stack, pen);

// Handle GOTO.
//
// Sets absolute position and heading, preserving the current movement scale. If
// the pen is down, the destination point is added to the current contour.
function EvalGoto(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA3)
        ? let(
            _err = SoftError("Malformed GOTO command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : let(
            nextState = stateGoto(
                CmdArg(vCmd, CA1),
                CmdArg(vCmd, CA2),
                CmdArg(vCmd, CA3),
                state[SS]
            ),
            nextPoint = [nextState[SX], nextState[SY]],
            nextContours =
                (pen == PEN_DOWN)
                    ? AddPointToContours(contours, nextPoint)
                    : contours
        )
        EvalResult(nextState, nextContours, stack, pen);

// Handle TURN.
//
// Changes heading by a relative angle.
function EvalTurn(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA1)
        ? let(
            _err = SoftError("Malformed TURN command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : EvalResult(stateTurn(state, CmdArg(vCmd, CA1)), contours, stack, pen);

// Handle DIR.
//
// Sets heading to an absolute angle.
function EvalDir(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA1)
        ? let(
            _err = SoftError("Malformed DIR command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : EvalResult(stateDir(state, CmdArg(vCmd, CA1)), contours, stack, pen);

// Handle SCALE.
//
// Multiplies the current movement scale.
function EvalScale(vCmd, state, contours, stack, pen) =
    (len(vCmd) <= CA1)
        ? let(
            _err = SoftError("Malformed SCALE command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : EvalResult(stateScale(state, CmdArg(vCmd, CA1)), contours, stack, pen);

// Handle PUSH.
//
// Saves the full Logo state [x, y, heading, scale].
function EvalPush(vCmd, state, contours, stack, pen) =
    EvalResult(state, contours, concat(stack, [state]), pen);

// Handle POP.
//
// Restores the most recently pushed Logo state. It does not draw a connector
// line. If the pen is down and the restored state should begin a new polygon,
// use PENUP before POP and PENDOWN after POP.
function EvalPop(vCmd, state, contours, stack, pen) =
    (len(stack) == 0)
        ? let(
            _err = SoftError("POP with empty state stack", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : let(
            restoredState = stack[len(stack) - 1],
            nextStack =
                (len(stack) <= 1)
                    ? []
                    :
                    [
                        for (i = [0 : len(stack) - 2])
                            stack[i]
                    ]
        )
        EvalResult(restoredState, contours, nextStack, pen);

// Handle PENUP.
//
// Stops adding MOVE/GOTO destinations to contours.
function EvalPenUp(vCmd, state, contours, stack, pen) =
    EvalResult(state, contours, stack, PEN_UP);

// Handle PENDOWN.
//
// Starts a new contour at the current Logo location and resumes adding
// MOVE/GOTO destinations. If the pen is already down, this still starts a new
// contour, which is useful for intentionally disconnected polygons.
function EvalPenDown(vCmd, state, contours, stack, pen) =
    EvalResult(state, StartContour(contours, state), stack, PEN_DOWN);

// Handle RUN.
//
// Expected recursive use:
//     Calls evalLogoR() to evaluate the child command list.
//
// Notes:
//     Empty child command lists are legal no-ops. Recursion-limit exhaustion is
//     also treated as a soft no-op/error so test suites can continue.
function EvalRun(vCmd, state, contours, stack, pen, maxRec) =
    let(
        childCmds = RunCmds(vCmd),
        localMaxRec = RunMaxRec(vCmd)
    )
    (len(childCmds) == 0)
        ? EvalResult(state, contours, stack, pen)
        : (maxRec <= 0 || localMaxRec <= 0)
            ? let(
                _err = SoftError("RUN recursion limit reached", vCmd)
            )
            EvalResult(state, contours, stack, pen)
            : let(
                nextMaxRec = min2(maxRec - 1, localMaxRec - 1),
                nextScale = RunScale(vCmd) * state[SS],
                nextState = stateMake(
                    state[SX],
                    state[SY],
                    state[SH],
                    nextScale
                ),
                recResult = evalLogoR(
                    childCmds,
                    nextState,
                    0,
                    nextMaxRec,
                    [],
                    stack,
                    pen
                ),
                recState = ResultState(recResult),
                recContours = ResultContours(recResult),
                recStack = ResultStack(recResult),
                recPen = ResultPen(recResult),
                nextContours = concat(contours, recContours)
            )
            EvalResult(recState, nextContours, recStack, recPen);

// Handle REPEAT.
//
// Expected recursive use:
//     Calls evalRepeatLogo(), which calls evalLogo() once per iteration.
function EvalRepeat(vCmd, state, contours, stack, pen, maxRec) =
    (len(vCmd) <= CA2)
        ? let(
            _err = SoftError("Malformed REPEAT command", vCmd)
        )
        EvalResult(state, contours, stack, pen)
        : let(
            repeatCount = RepeatCount(vCmd),
            childCmds = RepeatCmds(vCmd)
        )
        (repeatCount <= 0 || len(childCmds) == 0)
            ? EvalResult(state, contours, stack, pen)
            : evalRepeatLogo(
                childCmds,
                repeatCount,
                state,
                maxRec,
                contours,
                stack,
                pen
            );

// Dispatch one Logo command to its opcode handler.
function EvalOpcode(vCmd, state, contours, stack, pen, maxRec) =
      (vCmd == undef)
        ? let(
            _err = SoftError("Empty or out-of-range command list", undef)
        )
        EvalResult(state, contours, stack, pen)
    : (vCmd[COP] == MOVE)
        ? EvalMove(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == TURN)
        ? EvalTurn(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == DIR)
        ? EvalDir(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == SCALE)
        ? EvalScale(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == GOTO)
        ? EvalGoto(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == RUN)
        ? EvalRun(vCmd, state, contours, stack, pen, maxRec)
    : (vCmd[COP] == PUSH)
        ? EvalPush(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == POP)
        ? EvalPop(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == PENUP)
        ? EvalPenUp(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == PENDOWN)
        ? EvalPenDown(vCmd, state, contours, stack, pen)
    : (vCmd[COP] == REPEAT)
        ? EvalRepeat(vCmd, state, contours, stack, pen, maxRec)
    : let(
        _err = SoftError(str("Invalid Logo command: ", CmdName(vCmd[COP])), vCmd)
    )
    EvalResult(state, contours, stack, pen);

// Evaluate a child Logo command list.
//
// Expected recursive use:
//     Called by EvalRun() when a RUN command expands a child command list.
//
// Notes:
//     Empty command lists are legal no-ops. This is useful for recursive command
//     generators whose base case returns [].
function evalLogoR(
    vtCmds,
    state,
    index,
    maxRec,
    contours = [],
    stack = [],
    pen = PEN_DOWN
) =
    let(
        _traceEnter = TraceMsg(1, "evalLogoR Enter", maxRunRecursions - maxRec)
    )
    (maxRec == undef || maxRec < 0 || maxRec >= 100)
        ? let(
            _err = SoftError("Bad recursion depth", maxRec)
        )
        EvalResult(state, contours, stack, pen)
        : let(
            result = evalLogo(vtCmds, state, index, maxRec, contours, stack, pen),
            _traceExit = TraceMsg(1, "evalLogoR Exit", maxRunRecursions - maxRec),
            _traceState = TraceMsg(2, "evalLogoR State", ResultState(result)),
            _traceContours = TraceMsg(
                3,
                "evalLogoR Contours",
                [len(ResultContours(result)), CountContourPoints(ResultContours(result))]
            )
        )
        result;

// Evaluate Logo commands into a final Logo state and a contour list.
//
// Expected recursive use:
//     This function calls itself to iterate through a command list. It also calls
//     evalLogoR() to evaluate RUN child command lists.
//
// State stack:
//     PUSH saves the current Logo state.
//     POP restores the most recently saved Logo state.
//
// Pen state:
//     PENUP stops point emission.
//     PENDOWN starts a new contour and resumes point emission.
//
// Returns:
//     EvalResult(finalState, contours, stack, pen)
//
// Soft-error behavior:
//     If HardErrors is false, bad commands are reported with [ERROR] and treated
//     as no-ops so the full test suite can continue.
function evalLogo(
    vtCmds,
    state = stateGoto(0, 0, 0, 1),
    index = 0,
    maxRec = maxRunRecursions,
    contours = [[]],
    stack = [],
    pen = PEN_DOWN
) =
    let(
        vCmd = (len(vtCmds) == 0 || index >= len(vtCmds)) ? undef : vtCmds[index],
        _traceIndex = TraceMsg(
            2,
            "evalLogo index/maxRec",
            [index, len(vtCmds), maxRec]
        ),
        _traceState = TraceMsg(
            3,
            "evalLogo State/Contours/Stack/Pen",
            [state, contours, stack, pen]
        ),
        _traceCmd = (vCmd == undef)
            ? TraceMsg(1, "Empty or out-of-range command list", index)
            : TraceExec(4, index, state, vCmd),
        thisResult = EvalOpcode(vCmd, state, contours, stack, pen, maxRec)
    )
    (vCmd == undef)
        ? thisResult
        : (index < len(vtCmds) - 1)
            ? evalLogo(
                vtCmds,
                ResultState(thisResult),
                index + 1,
                maxRec,
                ResultContours(thisResult),
                ResultStack(thisResult),
                ResultPen(thisResult)
            )
            : let(
                _traceReturnState = TraceMsg(2, "evalLogo Returning state", ResultState(thisResult)),
                _traceReturnContours = TraceMsg(
                    3,
                    "evalLogo Returning contours",
                    [len(ResultContours(thisResult)), CountContourPoints(ResultContours(thisResult))]
                )
            )
            thisResult;

// Evaluate a REPEAT command body count times.
//
// Expected recursive use:
//     Calls itself with count - 1 until count <= 0.
function evalRepeatLogo(
    childCmds,
    count,
    state,
    maxRec,
    contours,
    stack,
    pen
) =
    (count <= 0)
        ? EvalResult(state, contours, stack, pen)
        : let(
            result = evalLogo(childCmds, state, 0, maxRec, contours, stack, pen)
        )
        evalRepeatLogo(
            childCmds,
            count - 1,
            ResultState(result),
            maxRec,
            ResultContours(result),
            ResultStack(result),
            ResultPen(result)
        );

// -----------------------------------------------------------------------------
// Optional test-suite include
// -----------------------------------------------------------------------------
// OpenSCAD include/use directives are parse-time constructs, so this include is
// unconditional. Test execution is guarded in LogoT-Foundation-Tests.scad by
// RunLogoTests.
include <LogoT-Foundation-Tests.scad>
