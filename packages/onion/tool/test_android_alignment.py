"""Hermetic malformed/unaligned ELF fixtures for the artifact guard."""
import struct
import unittest
from pathlib import Path
import tempfile
import zipfile

from check_android_alignment import inspect, inspect_elf


def elf(load_alignment=16384, relro_end=32768):
    data = bytearray(64 + 2 * 56)
    data[:6] = b'\x7fELF\x02\x01'
    struct.pack_into('<H', data, 18, 183)
    struct.pack_into('<Q', data, 32, 64)
    struct.pack_into('<HH', data, 54, 56, 2)
    struct.pack_into('<IIQQQQQQ', data, 64, 1, 4, 0, 0, 0, 176, 176, load_alignment)
    struct.pack_into('<IIQQQQQQ', data, 120, 0x6474e552, 4, 0, 16384, 0, 0,
                     relro_end - 16384, 1)
    return data


class AlignmentTest(unittest.TestCase):
    def test_aligned_segments(self):
        self.assertTrue(inspect_elf(elf())['loadAligned'])
        self.assertTrue(inspect_elf(elf())['relroEndAligned'])

    def test_load_alignment_alone_does_not_establish_relro_alignment(self):
        result = inspect_elf(elf(relro_end=24576))
        self.assertTrue(result['loadAligned'])
        self.assertFalse(result['relroEndAligned'])

    def test_four_kib_load_fails(self):
        self.assertFalse(inspect_elf(elf(load_alignment=4096))['loadAligned'])

    def test_apk_local_storage_offset_and_compression(self):
        name = 'lib/arm64-v8a/libfixture.so'
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'fixture.apk'
            for aligned, compression, expected in [
                (False, zipfile.ZIP_STORED, False),
                (True, zipfile.ZIP_STORED, True),
                (False, zipfile.ZIP_DEFLATED, None),
            ]:
                entry = zipfile.ZipInfo(name)
                entry.compress_type = compression
                if aligned:
                    padding = 16384 - 30 - len(name) - 4
                    entry.extra = struct.pack('<HH', 0xcafe, padding) + bytes(padding)
                with zipfile.ZipFile(path, 'w') as archive:
                    archive.writestr(entry, elf())
                result = inspect(path)
                self.assertEqual(len(result), 1)
                self.assertIs(result[0]['zipAligned'], expected)

    def test_truncated_and_wrong_architecture_fail(self):
        for data in [b'', elf()[:130], b'not an ELF']:
            with self.assertRaises(ValueError):
                inspect_elf(data)
        data = elf()
        struct.pack_into('<H', data, 18, 40)
        with self.assertRaises(ValueError):
            inspect_elf(data)


if __name__ == '__main__':
    unittest.main()
