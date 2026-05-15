"""DeepSeek POW solver using bundled SHA3 WASM module.
Pure-Python via wasmtime — no Node.js dependency.
"""
from __future__ import annotations
import wasmtime
import os, struct
from pathlib import Path

WASM = Path(__file__).parent / "sha3.wasm"

def solve_pow_challenge(
    algorithm: str,
    challenge: str,
    salt: str,
    expire_at: int,
    difficulty: int,
    signature: str,
    target_path: str,
) -> dict:
    if algorithm != "DeepSeekHashV1":
        raise ValueError(f"Unsupported algorithm: {algorithm}")

    engine = wasmtime.Engine()
    module = wasmtime.Module.from_file(engine, str(WASM))
    store = wasmtime.Store(engine)
    instance = wasmtime.Instance(store, module, [])
    exp = instance.exports(store)
    memory: wasmtime.Memory = exp["memory"]
    malloc = exp["__wbindgen_export_0"]
    add_to_stack = exp["__wbindgen_add_to_stack_pointer"]
    wasm_solve = exp["wasm_solve"]

    def _write_str(s: str) -> tuple[int, int]:
        b = s.encode("utf-8")
        ptr = malloc(store, len(b), 1)
        memory.write(store, b, ptr)
        return ptr, len(b)

    prefix = f"{salt}_{expire_at}_"
    stack = add_to_stack(store, -16)
    c_ptr, c_len = _write_str(challenge)
    p_ptr, p_len = _write_str(prefix)

    wasm_solve(store, stack, c_ptr, c_len, p_ptr, p_len, float(difficulty))

    raw = memory.read(store, stack, stack + 16)
    ok = struct.unpack("<i", raw[0:4])[0]
    answer = struct.unpack("<d", raw[8:16])[0]
    add_to_stack(store, 16)
    if ok != 1:
        raise RuntimeError("POW solve failed (no answer)")
    return {
        "algorithm": algorithm,
        "challenge": challenge,
        "salt": salt,
        "answer": int(answer),
        "signature": signature,
        "target_path": target_path,
    }


if __name__ == "__main__":
    # Self-test against captured challenge from HAR
    out = solve_pow_challenge(
        algorithm="DeepSeekHashV1",
        challenge="9b72b6d340e0faa9edbcd5ba8c211474f4cb6d0b8119164818d61ae28b459c63",
        salt="502b4b40390be320ae05",
        expire_at=1778351492367,
        difficulty=144000,
        signature="953153170c47dc92c990f7938f0e2efbb48713592ddcdc3c1576f89fd04d2a07",
        target_path="/api/v0/chat/completion",
    )
    assert out["answer"] == 49586, f'expected 49586 got {out["answer"]}'
    print("self-test OK:", out["answer"])
