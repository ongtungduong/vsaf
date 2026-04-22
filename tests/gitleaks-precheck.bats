#!/usr/bin/env bats
# Tests for scripts/hooks/gitleaks-precheck.sh
#
# These tests feed PreToolUse JSON payloads on stdin and assert the hook
# allows clean input (exit 0), blocks secret-bearing input (exit 2), and
# fail-closes when gitleaks is missing (exit 2).
#
# Secret-triggering fixtures are built at runtime via string concatenation so
# the raw pattern never appears in the test file itself — otherwise the
# PreToolUse hook guarding the test-author's own session would block the
# Write that created this file.

setup() {
    ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
    HOOK="$ROOT/scripts/hooks/gitleaks-precheck.sh"
    WORK=$(mktemp -d)

    # Build the gitleaks-triggering fixture at runtime.
    # An RSA PRIVATE KEY block is a built-in gitleaks rule and is the most
    # portable trigger across gitleaks versions.
    DASHES="-----"
    LEAK_BODY="MIIEpAIBAAKCAQEA0Z3VS5uBL2yj5rxmG1Z7XWvR3nJkBnQJe2kvL8D7F9gK1rVsNQ"
    LEAK_CONTENT="${DASHES}BEGIN RSA PRIVATE KEY${DASHES}
${LEAK_BODY}
${DASHES}END RSA PRIVATE KEY${DASHES}"
    export LEAK_CONTENT
}

teardown() {
    rm -rf "$WORK"
}

# Helper: run the hook with stdin from a temp file. Avoids quoting pitfalls
# when the payload itself contains single quotes or newlines.
run_hook_with_payload() {
    local payload="$1"
    local pf="$WORK/payload.json"
    printf '%s' "$payload" > "$pf"
    run bash "$HOOK" < "$pf"
}

@test "allows clean Bash command" {
    run_hook_with_payload '{"tool_name":"Bash","tool_input":{"command":"echo hello"}}'
    [ "$status" -eq 0 ]
}

@test "allows Write with innocuous content" {
    run_hook_with_payload '{"tool_name":"Write","tool_input":{"file_path":"/tmp/x.md","content":"# heading\nsome prose"}}'
    [ "$status" -eq 0 ]
}

@test "allows empty stdin (no tool_input to scan)" {
    run bash "$HOOK" < /dev/null
    [ "$status" -eq 0 ]
}

@test "blocks Write when content contains a secret pattern" {
    command -v jq >/dev/null || skip "jq not installed"
    PAYLOAD="$(jq -nc --arg c "$LEAK_CONTENT" \
        '{tool_name:"Write",tool_input:{file_path:"/tmp/x",content:$c}}')"
    run_hook_with_payload "$PAYLOAD"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCK"* ]]
}

@test "blocks Bash when command contains a secret pattern" {
    command -v jq >/dev/null || skip "jq not installed"
    CMD="cat <<EOF
$LEAK_CONTENT
EOF"
    PAYLOAD="$(jq -nc --arg c "$CMD" \
        '{tool_name:"Bash",tool_input:{command:$c}}')"
    run_hook_with_payload "$PAYLOAD"
    [ "$status" -eq 2 ]
}

@test "blocks MultiEdit when any edit.new_string contains a secret" {
    command -v jq >/dev/null || skip "jq not installed"
    PAYLOAD="$(jq -nc --arg c "$LEAK_CONTENT" '{
        tool_name:"MultiEdit",
        tool_input:{
            file_path:"/tmp/x",
            edits:[
                {old_string:"x",new_string:"safe replacement"},
                {old_string:"y",new_string:$c}
            ]
        }
    }')"
    run_hook_with_payload "$PAYLOAD"
    [ "$status" -eq 2 ]
}

@test "fail-closes (exit 2) when gitleaks is not on PATH" {
    # Minimal PATH omits the usual gitleaks install locations.
    pf="$WORK/payload.json"
    printf '%s' '{"tool_name":"Bash","tool_input":{"command":"echo x"}}' > "$pf"
    run env -i HOME="$HOME" PATH="/usr/bin:/bin" bash "$HOOK" < "$pf"
    [ "$status" -eq 2 ]
    [[ "$output" == *"gitleaks not installed"* ]] || [[ "$output" == *"BLOCK"* ]]
}

@test "backward-compat: uses TOOL_INPUT env var when stdin is empty" {
    run env TOOL_INPUT="echo hello" bash "$HOOK" < /dev/null
    [ "$status" -eq 0 ]
}
