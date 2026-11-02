#!/bin/bash
# =============================================================================
# DSA IDPT Test Suite Script
# Generated: 2026-11-02
# Covers:
#   - Type Conversion (Entry Check Fail)
#   - Type Conversion (IDPT)
#   - Reduce with Dualcast (IDPT) - Scenarios 1-8
#   - IDPT Reduce with Dualcast Reserved Flags / Entry Fail Check
#   - Reduce (IDPT) - Scenarios 1-6
#   - IDPT Reduce Reserved Flags Check
#   - IDPT Reduce Invalid IDPT Handle
#   - IDPT Reduce Unaligned Source and Destination Addresses
# =============================================================================

# =============================================================================
# USAGE / ARGUMENT PARSING
# =============================================================================
usage() {
    echo ""
    echo "Usage: $0 --dsa_test_path=<path_to_dsa_test_v2>"
    echo ""
    echo "  --dsa_test_path=<path>   Full or relative path to the dsa_test_v2 binary"
    echo ""
    echo "Example:"
    echo "  $0 --dsa_test_path=/home/user/dsa_build/dsa_test_v2"
    echo "  $0 --dsa_test_path=../dsa_build/dsa_test_v2"
    echo ""
    exit 1
}

DSA_TEST=""

for arg in "$@"; do
    case "$arg" in
        --dsa_test_path=*)
            DSA_TEST="${arg#*=}"
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "[ERROR] Unknown argument: $arg"
            usage
            ;;
    esac
done

# Validate argument is provided
if [ -z "$DSA_TEST" ]; then
    echo "[ERROR] --dsa_test_path is required."
    usage
fi

# Validate binary exists and is executable
if [ ! -f "$DSA_TEST" ]; then
    echo "[ERROR] dsa_test_v2 binary not found at: $DSA_TEST"
    exit 1
fi

if [ ! -x "$DSA_TEST" ]; then
    echo "[ERROR] dsa_test_v2 binary is not executable at: $DSA_TEST"
    echo "        Run: chmod +x $DSA_TEST"
    exit 1
fi

echo "[INFO] Using dsa_test_v2 binary: $DSA_TEST"

# =============================================================================
# LOG FILE SETUP
# =============================================================================
LOG_FILE="dsa_idpt_test_results_$(date +%Y%m%d_%H%M%S).log"
PASS=0
FAIL=0
TOTAL=0

# -----------------------------------------------------------------------------
# Helper: run a single test case
#   $1 = Test group name
#   $2 = Test case description
#   $3+ = command arguments
# -----------------------------------------------------------------------------
run_test() {
    local group="$1"
    local desc="$2"
    shift 2
    local cmd="$DSA_TEST $*"

    TOTAL=$((TOTAL + 1))
    echo "------------------------------------------------------------" | tee -a "$LOG_FILE"
    echo "[TEST $TOTAL] Group   : $group"                               | tee -a "$LOG_FILE"
    echo "            Case    : $desc"                                  | tee -a "$LOG_FILE"
    echo "            Command : $cmd"                                   | tee -a "$LOG_FILE"
    echo "------------------------------------------------------------" | tee -a "$LOG_FILE"

    eval "$cmd" >> "$LOG_FILE" 2>&1
    local rc=$?

    if [ $rc -eq 0 ]; then
        echo "[RESULT] PASS (exit code: $rc)" | tee -a "$LOG_FILE"
        PASS=$((PASS + 1))
    else
        echo "[RESULT] FAIL (exit code: $rc)" | tee -a "$LOG_FILE"
        FAIL=$((FAIL + 1))
    fi
    echo "" | tee -a "$LOG_FILE"
}

# =============================================================================
echo "============================================================"  | tee -a "$LOG_FILE"
echo " DSA IDPT Test Suite - Start: $(date)"                         | tee -a "$LOG_FILE"
echo " Binary Path : $DSA_TEST"                                      | tee -a "$LOG_FILE"
echo " Log file    : $LOG_FILE"                                      | tee -a "$LOG_FILE"
echo "============================================================"  | tee -a "$LOG_FILE"
echo ""                                                              | tee -a "$LOG_FILE"

# =============================================================================
# 1. TYPE CONVERSION - ENTRY CHECK FAIL
# =============================================================================
run_test "Type Conversion - Entry Check Fail" \
    "opflags=0x1000C (entry check fail variant 1)" \
    --instancenum=0 --wqmode=1 --length=0x100 --numofdesc=1 \
    --nbsub=1 --mstimeout=200 --verbose=1 \
    --iData=1 --oData=1 \
    --opcode=0x18 --opflags=0x1000C --enidpt=1

run_test "Type Conversion - Entry Check Fail" \
    "opflags=0x2000C (entry check fail variant 2)" \
    --instancenum=0 --wqmode=1 --length=0x100 --numofdesc=1 \
    --nbsub=1 --mstimeout=200 --verbose=1 \
    --iData=1 --oData=1 \
    --opcode=0x18 --opflags=0x2000C --enidpt=1

# =============================================================================
# 2. TYPE CONVERSION - IDPT
# =============================================================================
run_test "Type Conversion - IDPT" \
    "Basic Type Conversion with IDPT enabled" \
    --instancenum=0 --wqmode=1 --length=0x100 --numofdesc=1 \
    --nbsub=1 --mstimeout=200 --verbose=1 \
    --iData=1 --oData=1 \
    --opcode=0x18 --enidpt=1

# =============================================================================
# 3. REDUCE WITH DUALCAST - IDPT (opcode=0x1a)
# =============================================================================
run_test "Reduce with Dualcast - IDPT" \
    "Scenario 1: Source1 selector -> IDPT Handle1 (interdomain_selector=0x01)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x1a --enidpt=1 --interdomain_selector=0x01

run_test "Reduce with Dualcast - IDPT" \
    "Scenario 2: Source1 selector -> IDPT Handle2 (interdomain_selector=0x02)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x1a --enidpt=1 --interdomain_selector=0x02

run_test "Reduce with Dualcast - IDPT" \
    "Scenario 3: Source2 selector -> IDPT Handle1 (interdomain_selector=0x04)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x1a --enidpt=1 --interdomain_selector=0x04

run_test "Reduce with Dualcast - IDPT" \
    "Scenario 4: Source2 selector -> IDPT Handle2 (interdomain_selector=0x08)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x1a --enidpt=1 --interdomain_selector=0x08

run_test "Reduce with Dualcast - IDPT" \
    "Scenario 5: Destination1 -> Handle1 (interdomain_selector=0x10) [expect: success but data never lands / exit 2]" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x1a --enidpt=1 --interdomain_selector=0x10

run_test "Reduce with Dualcast - IDPT" \
    "Scenario 6: Destination1 -> Handle2 (interdomain_selector=0x20) [expect: same failure]" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x1a --enidpt=1 --interdomain_selector=0x20

run_test "Reduce with Dualcast - IDPT" \
    "Scenario 7: Destination2 -> Handle1 (interdomain_selector=0x40) [expect: same failure]" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x1a --enidpt=1 --interdomain_selector=0x40

run_test "Reduce with Dualcast - IDPT" \
    "Scenario 8: Destination2 -> Handle2 (interdomain_selector=0x80) [expect: same failure]" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x1a --enidpt=1 --interdomain_selector=0x80

# =============================================================================
run_test "IDPT Reduce with Dualcast - Reserved Flags/Entry Fail" \
    "opflags=0x30000E (reserved flags check)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x1a --enidpt=1 --interdomain_selector=0x80 --opflags=0x30000E

run_test "IDPT Reduce with Dualcast - Reserved Flags/Entry Fail" \
    "opflags=0x10000E (entry fail check)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x1a --enidpt=1 --interdomain_selector=0x80 --opflags=0x10000E

# =============================================================================
# 5. REDUCE - IDPT (opcode=0x19)
# =============================================================================
run_test "Reduce - IDPT" \
    "Scenario 1: Source1 selector -> IDPT Handle1 (interdomain_selector=0x01)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x19 --enidpt=1 --interdomain_selector=0x01

run_test "Reduce - IDPT" \
    "Scenario 2: Source1 selector -> IDPT Handle2 (interdomain_selector=0x02)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x19 --enidpt=1 --interdomain_selector=0x02

run_test "Reduce - IDPT" \
    "Scenario 3: Source2 selector -> IDPT Handle1 (interdomain_selector=0x04)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x19 --enidpt=1 --interdomain_selector=0x04

run_test "Reduce - IDPT" \
    "Scenario 4: Source2 selector -> IDPT Handle2 (interdomain_selector=0x08)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x19 --enidpt=1 --interdomain_selector=0x08

run_test "Reduce - IDPT" \
    "Scenario 5: Destination1 selector -> IDPT Handle1 (interdomain_selector=0x10)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x19 --enidpt=1 --interdomain_selector=0x10

run_test "Reduce - IDPT" \
    "Scenario 6: Destination1 selector -> IDPT Handle2 (interdomain_selector=0x20)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x19 --enidpt=1 --interdomain_selector=0x20

# =============================================================================
# 6. IDPT REDUCE - RESERVED FLAGS CHECK
# =============================================================================
run_test "IDPT Reduce - Reserved Flags Check" \
    "opflags=0x2000E with interdomain_selector=0x20" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x19 --enidpt=1 --interdomain_selector=0x20 --opflags=0x2000E

# =============================================================================
# 7. IDPT REDUCE - INVALID IDPT HANDLE
# =============================================================================
run_test "IDPT Reduce - Invalid IDPT Handle" \
    "fuzzflag=4096 (invalid handle variant 1)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x19 --enidpt=1 --fuzzflag=4096

run_test "IDPT Reduce - Invalid IDPT Handle" \
    "fuzzflag=8192 (invalid handle variant 2)" \
    --wqmode=1 --length=0x20 --numofdesc=1 --nbsub=1 --mstimeout=200 \
    --verbose=1 --iData=1 --oData=1 --compute_flags=1 --compute_type=1 \
    --opcode=0x19 --enidpt=1 --fuzzflag=8192

# =============================================================================
# 8. IDPT REDUCE - UNALIGNED SOURCE AND DESTINATION ADDRESSES
# =============================================================================
run_test "IDPT Reduce - Unaligned Addresses" \
    "Source unaligned: interdomain_selector=0x01, win_base_off=1" \
    --instancenum=0 --wqmode=1 --length=0x100 --numofdesc=1 \
    --nbsub=1 --mstimeout=200 --verbose=1 --opcode=0x19 --enidpt=1 \
    --iData=2 --oData=2 --compute_type=1 --compute_flags=1 \
    --interdomain_selector=1 --win_base_off=1

run_test "IDPT Reduce - Unaligned Addresses" \
    "Destination unaligned: interdomain_selector=0x10, win_base_off=1" \
    --instancenum=0 --wqmode=1 --length=0x100 --numofdesc=1 \
    --nbsub=1 --mstimeout=200 --verbose=1 --opcode=0x19 --enidpt=1 \
    --iData=2 --oData=2 --compute_type=1 --compute_flags=1 \
    --interdomain_selector=0x10 --win_base_off=1

# =============================================================================
# FINAL SUMMARY
# =============================================================================
echo "============================================================" | tee -a "$LOG_FILE"
echo " DSA IDPT Test Suite - End: $(date)"                          | tee -a "$LOG_FILE"
echo "------------------------------------------------------------" | tee -a "$LOG_FILE"
echo " Binary Path : $DSA_TEST"                                     | tee -a "$LOG_FILE"
echo " Total Tests : $TOTAL"                                        | tee -a "$LOG_FILE"
echo " PASSED      : $PASS"                                         | tee -a "$LOG_FILE"
echo " FAILED      : $FAIL"                                         | tee -a "$LOG_FILE"
echo "============================================================" | tee -a "$LOG_FILE"

# Exit with non-zero if any test failed
[ $FAIL -eq 0 ] && exit 0 || exit 1
