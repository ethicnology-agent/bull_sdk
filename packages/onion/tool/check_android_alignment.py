#!/usr/bin/env python3
"""Inspect ELF64 Android libraries and APK storage alignment without executing them."""
import argparse
import json
from pathlib import Path
import struct
import sys
import zipfile

PAGE = 16384


def inspect_elf(data):
    if len(data) < 64 or data[:6] != b'\x7fELF\x02\x01':
        raise ValueError('Expected little-endian ELF64')
    machine = struct.unpack_from('<H', data, 18)[0]
    if machine not in (62, 183):
        raise ValueError('Expected x86_64 or aarch64')
    offset = struct.unpack_from('<Q', data, 32)[0]
    entry_size, count = struct.unpack_from('<HH', data, 54)
    if entry_size != 56 or not count or offset < 64 or offset + count * entry_size > len(data):
        raise ValueError('Invalid or truncated program headers')
    loads, relro = [], []
    for index in range(count):
        kind, _, file_offset, address, _, file_size, memory_size, alignment = struct.unpack_from(
            '<IIQQQQQQ', data, offset + index * entry_size)
        if file_size > memory_size:
            raise ValueError('Segment file size exceeds memory size')
        if kind == 1:
            loads.append(alignment >= PAGE and alignment & (alignment - 1) == 0
                         and file_offset % PAGE == address % PAGE)
        elif kind == 0x6474e552:
            relro.append((address + memory_size) % PAGE == 0)
    return {'loadAligned': bool(loads) and all(loads),
            'relroEndAligned': bool(relro) and all(relro),
            'loadCount': len(loads), 'relroCount': len(relro)}


def inspect(path):
    if path.suffix != '.apk':
        return [{'library': path.name, **inspect_elf(path.read_bytes())}]
    results = []
    with zipfile.ZipFile(path) as apk, path.open('rb') as raw:
        for entry in apk.infolist():
            parts = entry.filename.split('/')
            if len(parts) != 3 or parts[0] != 'lib' or not parts[2].endswith('.so'):
                continue
            if parts[1] not in ('arm64-v8a', 'x86_64'):
                continue
            raw.seek(entry.header_offset)
            header = raw.read(30)
            if len(header) != 30 or header[:4] != b'PK\x03\x04':
                raise ValueError('Invalid ZIP local header')
            name_len, extra_len = struct.unpack_from('<HH', header, 26)
            data_offset = entry.header_offset + 30 + name_len + extra_len
            stored = entry.compress_type == zipfile.ZIP_STORED
            results.append({'library': entry.filename, **inspect_elf(apk.read(entry)),
                            'stored': stored,
                            'zipAligned': data_offset % PAGE == 0 if stored else None})
    if not results:
        raise ValueError('No supported 64-bit native libraries found')
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('artifact', type=Path, help='APK or 64-bit Android .so')
    args = parser.parse_args()
    try:
        results = inspect(args.artifact)
    except (ValueError, OSError, zipfile.BadZipFile, struct.error) as error:
        print(json.dumps({'error': str(error)}))
        return 2
    print(json.dumps(results, indent=2))
    return int(any(not r['loadAligned'] or not r['relroEndAligned']
                   or r.get('zipAligned') is False for r in results))


if __name__ == '__main__':
    sys.exit(main())
