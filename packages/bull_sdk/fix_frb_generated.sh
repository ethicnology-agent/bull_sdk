#!/bin/bash
# Post-process frb_generated.rs to wrap external crate error types in FrbWrapper
FILE="rust/src/frb_generated.rs"

# Portable in-place sed (works on both GNU/Linux and BSD/macOS)
sedi() { sed -i.bak "$@" && rm -f "${@: -1}.bak"; }

# Step 1: Change type parameter from Error to FrbWrapper<Error>
sedi 's/transform_result_dco::<_, _, lwk::api::error::LwkError>/transform_result_dco::<_, _, FrbWrapper<lwk::api::error::LwkError>>/g' "$FILE"
sedi 's/transform_result_dco::<_, _, boltz::api::error::BoltzError>/transform_result_dco::<_, _, FrbWrapper<boltz::api::error::BoltzError>>/g' "$FILE"
# dart_bwk's SpError is an external-crate error type like the two above: the
# aggregator cannot implement IntoDart for it directly, so wrap it too.
sedi 's/transform_result_dco::<_, _, SpError>/transform_result_dco::<_, _, FrbWrapper<dart_bwk::api::types::SpError>>/g' "$FILE"

# Step 2: For those calls, the closure result needs .map_err(FrbWrapper)
# The pattern is })()) at the end of the transform_result_dco block
# We use awk to find lines after transform_result_dco::<_, _, FrbWrapper< and add .map_err(FrbWrapper) before the closing )
python3 -c "
import re
with open('$FILE', 'r') as f:
    content = f.read()

# Find transform_result_dco with FrbWrapper and add .map_err(FrbWrapper) to the closure result
# Pattern: })()) — closure end, becomes }).map_err(FrbWrapper))
# But we need to only do this for the FrbWrapper variants

# Strategy: find all transform_result_dco::<_, _, FrbWrapper< blocks
# and in each, find the matching })()) and change to })().map_err(FrbWrapper))

lines = content.split('\n')
in_frb_wrapper_block = False
brace_depth = 0
result = []

for line in lines:
    if 'transform_result_dco::<_, _, FrbWrapper<' in line:
        in_frb_wrapper_block = True
        # Count opening parens in this line
        brace_depth = line.count('(') - line.count(')')
        result.append(line)
        continue

    if in_frb_wrapper_block:
        brace_depth += line.count('(') - line.count(')')
        if brace_depth <= 0:
            # This is the closing line — add .map_err(FrbWrapper)
            # Replace })()) with })().map_err(FrbWrapper))
            line = line.replace('})())', '})().map_err(FrbWrapper))')
            in_frb_wrapper_block = False
        result.append(line)
    else:
        result.append(line)

with open('$FILE', 'w') as f:
    f.write('\n'.join(result))
"

# Step 3: Convert mirrored TxFee to boltz::TxFee via .into()
sedi 's/api_miner_fee,/api_miner_fee.into(),/g' "$FILE"

# Step 4: dart_bwk SpAccount::init takes a StreamSink<SpNotification> (element
# type dart_bwk::api::types::SpNotification under the bull_sdk feature). The
# mirror enum makes codegen emit the aggregator's StreamSinkBase reconstruction
# with the bare/mirror element type, which does not match init's signature. The
# dependency crate cannot name the aggregator's wrapper, so we bridge the
# boundary here: reconstruct a StreamSinkBase typed with dart_bwk's own
# SpNotification (wire-identical — dart_bwk provides a matching IntoDart). This
# is the same role Steps 1-3 play for other capability crates.
python3 -c "
with open('$FILE', 'r') as f:
    content = f.read()
old_sig = ('    sink: impl CstDecode<\n'
           '        StreamSink<\n'
           '            crate::api::simple::SpNotification,\n'
           '            flutter_rust_bridge::for_generated::DcoCodec,\n'
           '        >,\n'
           '    >,')
new_sig = '    sink: impl CstDecode<String>,'
old_dec = '            let api_sink = sink.cst_decode();'
new_dec = ('            let api_sink = flutter_rust_bridge::for_generated::StreamSinkBase::<\n'
           '                dart_bwk::api::types::SpNotification,\n'
           '                flutter_rust_bridge::for_generated::DcoCodec,\n'
           '            >::deserialize(sink.cst_decode());')
marker = 'fn wire__dart_bwk__api__sp_account__SpAccount_init_impl('
idx = content.find(marker)
if idx != -1:
    head, tail = content[:idx], content[idx:]
    tail = tail.replace(old_sig, new_sig, 1)
    tail = tail.replace(old_dec, new_dec, 1)
    content = head + tail
    with open('$FILE', 'w') as f:
        f.write(content)
"

# Step 5: RecipientView is an INPUT (Dart->Rust) enum that we mirror in the
# primary crate; prepare_psbt takes dart_bwk's own Vec<RecipientView>. The wire
# decodes the mirror Vec, so convert it before passing to the real function.
python3 -c "
with open('$FILE', 'r') as f:
    content = f.read()
marker = 'fn wire__dart_bwk__api__sp_account__SpAccount_prepare_psbt_impl('
idx = content.find(marker)
if idx != -1:
    head, tail = content[:idx], content[idx:]
    tail = tail.replace(
        '            let api_recipients = recipients.cst_decode();',
        '            let api_recipients: Vec<crate::api::simple::RecipientView> = recipients.cst_decode();\n'
        '            let api_recipients: Vec<dart_bwk::api::types::RecipientView> =\n'
        '                api_recipients.into_iter().map(Into::into).collect();',
        1,
    )
    content = head + tail
    with open('$FILE', 'w') as f:
        f.write(content)
"

# Step 6: a dart_bwk struct that FRB treats as transparent (TxSimulation,
# SimulatedOutput) can hold a field whose type we mirror in the primary crate
# (RecipientView, OutputDestination). Codegen then uses the mirror type at that
# field's codec sites while the struct holds dart_bwk's own type. Convert at
# exactly those sites, each searched for only inside its own impl block, so a
# new field elsewhere in the struct does not break the patch.
python3 - "$FILE" <<'PY'
import re, sys
path = sys.argv[1]
content = open(path).read()
REAL = 'dart_bwk::api::types::'
MIRROR = 'crate::api::simple::'
# (struct, field, mirrored type, is the field a Vec)
FIELDS = [
    ('TxSimulation', 'outputs', 'RecipientView', True),
    ('SimulatedOutput', 'destination', 'OutputDestination', False),
]

def camel(name):
    head, *rest = name.split('_')
    return head + ''.join(w[:1].upper() + w[1:] for w in rest)

def snake(name):
    return re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()

def block(header):
    start = content.find(header)
    if start == -1:
        sys.exit('fix_frb_generated: missing ' + header)
    ends = [e for e in (content.find('\nimpl ', start + 1), content.find('\n    impl ', start + 1)) if e != -1]
    return start, (min(ends) if ends else len(content))

def patch(header, old, new):
    global content
    start, end = block(header)
    body = content[start:end]
    if old not in body:
        sys.exit('fix_frb_generated: %r not found under %s' % (old, header))
    content = content[:start] + body.replace(old, new, 1) + content[end:]

for struct, field, ty, is_vec in FIELDS:
    real_ty = 'Vec<%s%s>' % (REAL, ty) if is_vec else REAL + ty
    mirror_ty = 'Vec<%s%s>' % (MIRROR, ty) if is_vec else MIRROR + ty
    to_real = (lambda x, t=ty: '%s.into_iter().map(Into::into).collect::<Vec<%s%s>>()' % (x, REAL, t)) if is_vec \
        else (lambda x, t=ty: '<%s%s>::from(%s)' % (REAL, t, x))
    to_mirror = (lambda x, t=ty: '%s.into_iter().map(Into::into).collect::<Vec<%s%s>>()' % (x, MIRROR, t)) if is_vec \
        else (lambda x, t=ty: '<%s%s>::from(%s)' % (MIRROR, t, x))
    var = 'var_' + camel(field)
    patch('impl SseDecode for %s%s {' % (REAL, struct),
          '%s: %s,' % (field, var), '%s: %s,' % (field, to_real(var)))
    patch('impl SseEncode for %s%s {' % (REAL, struct),
          '<%s>::sse_encode(self.%s, serializer);' % (mirror_ty, field),
          '<%s>::sse_encode(%s, serializer);' % (mirror_ty, to_mirror('self.' + field)))
    patch('impl flutter_rust_bridge::IntoDart for FrbWrapper<%s%s> {' % (REAL, struct),
          'self.0.%s.into_into_dart().into_dart(),' % field,
          '(%s).into_into_dart().into_dart(),' % to_mirror('self.0.' + field))
    patch('impl CstDecode<%s%s> for wire_cst_%s {' % (REAL, struct, snake(struct)),
          '%s: self.%s.cst_decode(),' % (field, field),
          '%s: { let __m: %s = self.%s.cst_decode(); %s },' % (field, mirror_ty, field, to_real('__m')))
    old_assert = 'let _: %s = %s.%s;' % (mirror_ty, struct, field)
    if old_assert not in content:
        sys.exit('fix_frb_generated: missing ' + old_assert)
    content = content.replace(old_assert, 'let _: %s = %s.%s;' % (real_ty, struct, field), 1)

open(path, 'w').write(content)
PY

# Step 7: FRB 2.12 may emit the same call sites on compact single lines.
python3 -c "
with open('$FILE', 'r') as f:
    content = f.read()

content = content.replace(
    'let output_ok = ark_wallet::ark::client::ArkWallet::transaction_history(&*api_that_guard).await?;   Ok(output_ok)',
    'let output_ok = ark_wallet::ark::client::ArkWallet::transaction_history(&*api_that_guard).await.map(|v| v.into_iter().map(|t| -> crate::api::simple::ArkTransaction { t.into() }).collect::<Vec<_>>())?;   Ok(output_ok)',
    1,
)

content = content.replace(
    'sink: impl CstDecode<StreamSink<crate::api::simple::SpNotification,flutter_rust_bridge::for_generated::DcoCodec>>) -> flutter_rust_bridge::for_generated::WireSyncRust2DartDco',
    'sink: impl CstDecode<String>) -> flutter_rust_bridge::for_generated::WireSyncRust2DartDco',
    1,
)

content = content.replace(
    'let api_that = that.cst_decode();let api_sink = sink.cst_decode();\n                transform_result_dco::<_, _, String>((move || {',
    'let api_that = that.cst_decode();let api_sink = flutter_rust_bridge::for_generated::StreamSinkBase::<dart_bwk::api::types::SpNotification,flutter_rust_bridge::for_generated::DcoCodec>::deserialize(sink.cst_decode());\n                transform_result_dco::<_, _, String>((move || {',
    1,
)

content = content.replace(
    'let api_that = that.cst_decode();let api_recipients = recipients.cst_decode();let api_feerate_sat_vb = feerate_sat_vb.cst_decode(); move |context|  {',
    'let api_that = that.cst_decode();let api_recipients: Vec<crate::api::simple::RecipientView> = recipients.cst_decode();let api_recipients: Vec<dart_bwk::api::types::RecipientView> = api_recipients.into_iter().map(Into::into).collect();let api_feerate_sat_vb = feerate_sat_vb.cst_decode(); move |context|  {',
    1,
)

content = content.replace(
    'return dart_bwk::api::types::TxSimulation{inputs: var_inputs, outputs: var_outputs, fee_sat: var_feeSat, change_sat: var_changeSat};}',
    'return dart_bwk::api::types::TxSimulation{inputs: var_inputs, outputs: var_outputs.into_iter().map(Into::into).collect::<Vec<dart_bwk::api::types::RecipientView>>(), fee_sat: var_feeSat, change_sat: var_changeSat};}',
    1,
)

content = content.replace(
    'self.0.inputs.into_into_dart().into_dart(),\nself.0.outputs.into_into_dart().into_dart(),',
    'self.0.inputs.into_into_dart().into_dart(),\nself.0.outputs.into_iter().map(|o| -> crate::api::simple::RecipientView { o.into() }).collect::<Vec<_>>().into_into_dart().into_dart(),',
    1,
)

content = content.replace(
    'let _: Vec<crate::api::simple::RecipientView> = TxSimulation.outputs;',
    'let _: Vec<dart_bwk::api::types::RecipientView> = TxSimulation.outputs;',
    1,
)

content = content.replace(
    '<Vec<crate::api::simple::RecipientView>>::sse_encode(self.outputs, serializer);',
    '<Vec<crate::api::simple::RecipientView>>::sse_encode(self.outputs.into_iter().map(Into::into).collect::<Vec<crate::api::simple::RecipientView>>(), serializer);',
    1,
)

content = content.replace(
    'dart_bwk::api::types::TxSimulation{inputs:  self.inputs.cst_decode(),outputs:  self.outputs.cst_decode(),fee_sat:  self.fee_sat.cst_decode(),change_sat:  self.change_sat.cst_decode()}',
    'dart_bwk::api::types::TxSimulation{inputs:  self.inputs.cst_decode(),outputs:  { let outputs: Vec<crate::api::simple::RecipientView> = self.outputs.cst_decode(); outputs.into_iter().map(Into::into).collect::<Vec<dart_bwk::api::types::RecipientView>>() },fee_sat:  self.fee_sat.cst_decode(),change_sat:  self.change_sat.cst_decode()}',
    1,
)

with open('$FILE', 'w') as f:
    f.write(content)
"

# Step 8: The DCO encoder for dart_bwk SpPaymentView is generated through the
# external-type wrapper and can miss newly-added fields. Keep it in lock-step
# with the Dart decoder and SSE codec: txid, direction, status, amount, fee,
# height, timestamp, label.
python3 -c "
with open('$FILE', 'r') as f:
    content = f.read()

old = '''impl flutter_rust_bridge::IntoDart for FrbWrapper<dart_bwk::api::types::SpPaymentView> {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.0.txid.into_into_dart().into_dart(),
            self.0.direction.into_into_dart().into_dart(),
            self.0.status.into_into_dart().into_dart(),
            self.0.amount_sat.into_into_dart().into_dart(),
            self.0.fee_sat.into_into_dart().into_dart(),
            self.0.height.into_into_dart().into_dart(),
            self.0.timestamp.into_into_dart().into_dart(),
            self.0.label.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}'''

legacy_old = '''impl flutter_rust_bridge::IntoDart for FrbWrapper<dart_bwk::api::types::SpPaymentView> {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        [
            self.0.txid.into_into_dart().into_dart(),
            self.0.direction.into_into_dart().into_dart(),
            self.0.amount_sat.into_into_dart().into_dart(),
            self.0.fee_sat.into_into_dart().into_dart(),
            self.0.height.into_into_dart().into_dart(),
            self.0.timestamp.into_into_dart().into_dart(),
            self.0.label.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}'''

new = '''impl flutter_rust_bridge::IntoDart for FrbWrapper<dart_bwk::api::types::SpPaymentView> {
    fn into_dart(self) -> flutter_rust_bridge::for_generated::DartAbi {
        fn payment_status_idx(status: dart_bwk::api::types::SpPaymentStatus) -> i32 {
            match status {
                dart_bwk::api::types::SpPaymentStatus::Unconfirmed => 0,
                dart_bwk::api::types::SpPaymentStatus::ConfirmedUnverified => 1,
                dart_bwk::api::types::SpPaymentStatus::Verified => 2,
                dart_bwk::api::types::SpPaymentStatus::VerifyFailed => 3,
            }
        }
        [
            self.0.txid.into_into_dart().into_dart(),
            self.0.direction.into_into_dart().into_dart(),
            payment_status_idx(self.0.status).into_dart(),
            self.0.amount_sat.into_into_dart().into_dart(),
            self.0.fee_sat.into_into_dart().into_dart(),
            self.0.height.into_into_dart().into_dart(),
            self.0.timestamp.into_into_dart().into_dart(),
            self.0.label.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}'''

content = content.replace(old, new, 1)
content = content.replace(legacy_old, new, 1)
if 'payment_status_idx(self.0.status).into_dart()' not in content:
    raise SystemExit('SpPaymentView DCO encoder still lacks status')

with open('$FILE', 'w') as f:
    f.write(content)
"

echo "Post-processed $FILE"

# Step 9: Bound the unsigned 64-bit encoders on the Dart side.
# FRB emits toSigned(64).toInt(), which wraps modulo 2^64 rather than failing,
# so an out-of-range amount reached Rust as a different number. Rust cannot
# detect this: the wrapping happens before the call.
DART_FILE="lib/src/rust/frb_generated.io.dart"

python3 - "$DART_FILE" <<'PY'
import sys
import re

path = sys.argv[1]
with open(path) as f:
    source = f.read()

source = source.replace(
    "typedef bool = ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Int>)>;\n\n",
    "",
)
source = source.replace("ffi.Pointer<bool>", "bool")
source = re.sub(
    r"ffi\.NativeFunction<(?P<body>.*?)\n\s*>",
    lambda match: match.group(0).replace("bool,", "ffi.Bool,"),
    source,
    flags=re.S,
)
source = source.replace("\n  external bool ", "\n  @ffi.Bool()\n  external bool ")
source = re.sub(r"(\n\s+@ffi\.Bool\(\)\n)(?:\s+@ffi\.Bool\(\)\n)+", r"\1", source)

import_anchor = "import 'frb_generated.dart';"
import_line = "import '../checked_u64.dart';"
encoders = [
    ("cst_encode_u_64", "int cst_encode_u_64(BigInt raw) {"),
    ("cst_encode_usize", "int cst_encode_usize(BigInt raw) {"),
]
body = "    // Codec=Cst (C-struct based), see doc to use other codecs\n    return raw.toSigned(64).toInt();"
patched = "    // Codec=Cst (C-struct based), see doc to use other codecs\n    return checkedU64ToNativeInt(raw);"

if import_line not in source:
    if source.count(import_anchor) != 1:
        sys.exit(f"expected exactly one {import_anchor!r} in {path}")
    source = source.replace(import_anchor, f"{import_anchor}\n{import_line}", 1)

for name, signature in encoders:
    if source.count(signature) != 1:
        sys.exit(f"expected exactly one {name} in {path}")
    already = f"{signature}\n{patched}"
    if already in source:
        continue
    target = f"{signature}\n{body}"
    if target not in source:
        sys.exit(f"{name} in {path} does not match the expected generated body")
    source = source.replace(target, f"{signature}\n{patched}", 1)

with open(path, "w") as f:
    f.write(source)
PY

echo "Post-processed $DART_FILE"
